// Session Service, this manage the session as ACTIVE, IDLE OR INACTIVE
import 'package:tewo_p/apis/aws_service.dart';
import 'package:aws_dynamodb_api/dynamodb-2012-08-10.dart';
import 'package:flutter/foundation.dart';

class SessionService {
  static final SessionService _instance = SessionService._internal();

  factory SessionService() {
    return _instance;
  }

  SessionService._internal();

  String? _currentUserId;
  String? _tableName;

  void setTableName(String name) {
    _tableName = name;
  }

  String get tableName {
    if (_tableName == null) {
      // Fallback or throw? Throwing is safer to ensure config is loaded.
      // But for emergency deactivate, if config failed, we might not have it.
      // If we don't have it, we can't deactivate properly anyway.
      throw Exception("SessionService: tableName not set");
    }
    return _tableName!;
  }

  void registerSession(String userId) {
    _currentUserId = userId;
    print(
      '[DEBUG] Session registered for User ID: $_currentUserId in table: $tableName',
    );
  }

  Future<void> emergencyDeactivate() async {
    if (_currentUserId == null) {
      print('[DEBUG] No active session to deactivate.');
      return;
    }

    try {
      print(
        '[CRITICAL] Attempting emergency session deactivation for User ID: $_currentUserId',
      );

      await AwsService().client.updateItem(
        tableName: tableName,
        key: {'user_id': AttributeValue(n: _currentUserId)},
        attributeUpdates: {
          'is_active': AttributeValueUpdate(
            action: AttributeAction.put,
            value: AttributeValue(s: 'INACTIVE'),
          ),
        },
      );

      print('[SUCCESS] User session marked as INACTIVE.');
    } catch (e) {
      print('[ERROR] Failed to deactivate session during emergency: $e');
    }
  }
  // --- Smart Remote Deactivation & Spam Protection ---

  // Spam Protection State (THIS IS SETTED UP THINKING ON DYNAMODB LIMITS)
  final List<DateTime> _clickTimestamps = [];
  bool _isPenaltyActive = false;
  DateTime? _penaltyEndTime;
  static const int _maxClicksPerSecond = 3;
  static const Duration _penaltyDuration = Duration(
    seconds: 5, //Be Careful with this value
  ); //EDIT AT YOUR OWN RISK

  /// Records a user interaction (click) to monitor for spamming.
  ///
  /// This method should be called on every relevant UI interaction (e.g., tap/click).
  /// It maintains a sliding window of timestamps to detect if the user exceeds
  /// [_maxClicksPerSecond].
  ///
  /// Algorithm:
  /// 1. Removes timestamps older than 1 second.
  /// 2. If penalty is active:
  ///    - If penalty time has expired, clears penalty.
  ///    - If penalty is still active, extends the penalty by [_penaltyDuration] from NOW
  ///      (punishing continued spamming).
  /// 3. If not in penalty and click count >= [_maxClicksPerSecond], activates penalty.
  void recordClick() {
    final now = DateTime.now();

    // 1. Clean old timestamps (keep only last 1 second)
    _clickTimestamps.removeWhere(
      (t) => now.difference(t) > const Duration(seconds: 1),
    );

    // Add current click
    _clickTimestamps.add(now);

    final clicksCount = _clickTimestamps.length;
    // Debug print as requested
    print('[DEBUG] User Clicks/Sec: $clicksCount');

    // 2. Manage Penalty
    if (_isPenaltyActive) {
      if (_penaltyEndTime != null && now.isAfter(_penaltyEndTime!)) {
        // Penalty expired
        _isPenaltyActive = false;
        _penaltyEndTime = null;
        print('[INFO] Spam penalty lifted.');
      } else {
        // Penalty active and user clicked -> Extend penalty
        _penaltyEndTime = now.add(_penaltyDuration);
        print(
          '[WARN] Spam detected during penalty! Penalty extended until $_penaltyEndTime',
        );
      }
    } else if (clicksCount >= _maxClicksPerSecond) {
      // 3. Trigger Penalty
      _isPenaltyActive = true;
      _penaltyEndTime = now.add(_penaltyDuration);
      print(
        '[WARN] Spam detected ($clicksCount clicks/s). Penalty activated until $_penaltyEndTime',
      );
    }
  }

  /// Checks the user's session status from DynamoDB, respecting the spam penalty.
  ///
  /// This method should be called on critical events like Tab switching.
  ///
  /// Optimization:
  /// - If the spam penalty is active, it SKIPS the DynamoDB read to save Read Capacity Units (RCU).
  /// - If allowed, it performs a GetItem to check 'is_active'.
  /// - If 'is_active' is 'INACTIVE', it triggers the [onInactive] callback.
  Future<void> checkSessionStatus(VoidCallback onInactive) async {
    if (_currentUserId == null || tableName.isEmpty) return;

    // Check Penalty
    if (_isPenaltyActive) {
      // If penalty is conceptually active, check if it actually expired by time
      // (in case recordClick wasn't called recently to clear it)
      if (_penaltyEndTime != null && DateTime.now().isAfter(_penaltyEndTime!)) {
        _isPenaltyActive = false;
        _penaltyEndTime = null;
      } else {
        print('[SKIP] Status check skipped due to active spam penalty.');
        return;
      }
    }

    try {
      print('[INFO] Checking remote session status...');
      final output = await AwsService().client.getItem(
        tableName: tableName,
        key: {'user_id': AttributeValue(n: _currentUserId)},
        attributesToGet: ['is_active'], // Optimization: Fetch only needed field
      );

      if (output.item != null) {
        final status = output.item!['is_active']?.s;
        if (status == 'INACTIVE') {
          print('[ALERT] Remote session is INACTIVE. Triggering logout.');
          onInactive();
        } else {
          print('[DEBUG] Session is ACTIVE.');
        }
      }
    } catch (e) {
      print('[ERROR] Failed to check session status: $e');
    }
  }
}
