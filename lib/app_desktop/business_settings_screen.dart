//THIS PAGE IS LIKE PROFILE PAGE, BUT FOR THE BUSSINESS
//TO MAKE CHANGES AT THE DB YOU MUST VERIFY THE OWNER EMAIL
//NOTE: YOU MUST KNOW HOW TO MANAGE bussines_prefix and bussines_target
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:aws_dynamodb_api/dynamodb-2012-08-10.dart';
import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tewo_p/apis/aws_service.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:tewo_p/app_desktop/ui_desktop.dart';

class BusinessSettingsScreen extends StatefulWidget {
  final Map<String, AttributeValue> currentUser;
  final String usersTableName;

  const BusinessSettingsScreen({
    super.key,
    required this.currentUser,
    required this.usersTableName,
  });

  @override
  State<BusinessSettingsScreen> createState() => _BusinessSettingsScreenState();
}

class _BusinessSettingsScreenState extends State<BusinessSettingsScreen> {
  bool _isLoading = false;
  Map<String, dynamic> _businessData = {};
  String? _errorMessage;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  // Edit Controllers
  String? _generatedCode;
  Timer? _resendTimer;
  int _resendCountdown = 120;
  bool _canResend = false;
  final TextEditingController _verificationCodeController =
      TextEditingController();

  // Interaction Control
  bool _isCooldown = false;
  Timer? _cooldownTimer;
  int _cooldownSeconds = 0;

  @override
  void initState() {
    super.initState();
    _fetchBusinessData();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _cooldownTimer?.cancel();
    _verificationCodeController.dispose();
    super.dispose();
  }

  Future<void> _fetchBusinessData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1. Get Bussiness Name from oxfek.json
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/assets/json/dkskdp/oxfek.json');

      if (!await file.exists()) {
        throw Exception("Configuration file not found.");
      }

      final content = await file.readAsString();
      final envelope = jsonDecode(content);
      final iv = encrypt.IV.fromBase64(envelope['iv']);
      final key = encrypt.Key.fromUtf8('my32lengthsupersecretnooneknows1');
      final encrypter = encrypt.Encrypter(encrypt.AES(key));

      final decrypted = encrypter.decrypt(
        encrypt.Encrypted.fromBase64(envelope['content']),
        iv: iv,
      );
      final settings = jsonDecode(decrypted);
      final businessName = settings['bussiness_name'];

      if (businessName == null) {
        throw Exception("Business name not found in configuration.");
      }

      // 2. Fetch from DynamoDB
      final scanOutput = await AwsService().client.scan(
        tableName: 'clients_setups',
        filterExpression: 'bussiness_name = :n',
        expressionAttributeValues: {':n': AttributeValue(s: businessName)},
      );

      if (scanOutput.items == null || scanOutput.items!.isEmpty) {
        throw Exception("Business not found in database.");
      }

      final item = scanOutput.items!.first;

      _businessData = {
        'bussiness_name': item['bussiness_name']?.s ?? '',
        'bussiness_location': item['bussiness_location']?.s ?? '',
        'bussiness_owner': item['bussiness_owner']?.s ?? '',
        'bussiness_enabled': item['bussiness_enabled']?.s ?? 'DISABLED',
        'bussiness_key': item['bussiness_key']?.s ?? '',
        'owner_email': item['owner_email']?.s ?? '',
        'owner_phone': item['owner_phone']?.s ?? item['owner_phone']?.n ?? '',
      };
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateBusinessEnabled(bool enabled) async {
    setState(() => _isLoading = true);
    try {
      final newValue = enabled ? 'ENABLED' : 'DISABLED';
      await AwsService().client.updateItem(
        tableName: 'clients_setups',
        key: {
          'bussiness_name': AttributeValue(s: _businessData['bussiness_name']),
        },
        attributeUpdates: {
          'bussiness_enabled': AttributeValueUpdate(
            action: AttributeAction.put,
            value: AttributeValue(s: newValue),
          ),
        },
      );
      setState(() {
        _businessData['bussiness_enabled'] = newValue;
      });
      _showMessage("Business status updated to $newValue");
    } catch (e) {
      _showMessage("Error updating status: $e", isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _requestEdit(String field, String label) async {
    if (_isCooldown || _isLoading) return;

    // 1. Send Verification Email
    setState(() => _isLoading = true);
    try {
      await _sendVerificationEmail();
    } catch (e) {
      _showMessage("Error sending email: $e", isError: true);
      setState(() => _isLoading = false);
      return;
    }
    setState(() => _isLoading = false);

    // 2. Show Verification Dialog
    if (!mounted) return;

    // Start Cooldown immediately after successful email send/dialog open logic
    _startCooldown();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Verify Identity"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "A code has been sent to ${_businessData['owner_email']} to edit $label.",
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _verificationCodeController,
                  decoration: const InputDecoration(
                    labelText: "Enter 6-digit Code",
                  ),
                ),
                const SizedBox(height: 8),
                if (_isLoading) const CircularProgressIndicator(),
                TextButton(
                  onPressed: _canResend
                      ? () async {
                          setState(() => _isLoading = true);
                          await _sendVerificationEmail();
                          setState(() => _isLoading = false);
                        }
                      : null,
                  child: Text(
                    _canResend
                        ? "Resend Code"
                        : "Resend in $_resendCountdown s",
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_verificationCodeController.text == _generatedCode) {
                    Navigator.pop(context); // Close verification
                    _showEditDialog(field, label);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Invalid Code")),
                    );
                  }
                },
                child: const Text("Verify"),
              ),
            ],
          );
        },
      ),
    );
    _startResendTimer();
  }

  void _startResendTimer() {
    _canResend = false;
    _resendCountdown = 120;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_resendCountdown > 0) {
          _resendCountdown--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  void _startCooldown() {
    setState(() {
      _isCooldown = true;
      _cooldownSeconds = 10;
    });
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_cooldownSeconds > 0) {
          _cooldownSeconds--;
        } else {
          _isCooldown = false;
          timer.cancel();
        }
      });
    });
  }

  Future<void> _sendVerificationEmail() async {
    final rnd = Random();
    _generatedCode = (rnd.nextInt(900000) + 100000).toString();

    // Retrieve TeWo SMTP creds
    final tewoScan = await AwsService().client.scan(
      tableName: 'clients_setups',
      filterExpression: 'bussiness_name = :n',
      expressionAttributeValues: {':n': AttributeValue(s: 'TeWo')},
    );
    if (tewoScan.items == null || tewoScan.items!.isEmpty)
      throw Exception("System Error: SMTP Provider not found");

    final tewoItem = tewoScan.items!.first;
    final smtpUser = tewoItem['owner_email']?.s;
    final smtpPass = tewoItem['bussiness_key']?.s;

    if (smtpUser == null || smtpPass == null)
      throw Exception("System Error: Invalid SMTP config");

    final smtpServer = SmtpServer(
      'smtp.gmail.com',
      username: smtpUser,
      password: smtpPass,
    );

    final message = Message()
      ..from = Address(smtpUser, 'TeWo Email Service')
      ..recipients.add(_businessData['owner_email'])
      ..subject = 'Verification Code Request'
      ..text =
          '''
TeWo Email Service

Dear, ${_businessData['bussiness_owner']}
A VERIFICATION CODE has been requested to edit your business settings, do not share this code.

If you didn't requested this code, just ignore it.
Code: $_generatedCode
''';

    try {
      await send(message, smtpServer);
    } catch (e) {
      print("SMTP Fail (simulating): $_generatedCode");
      // throw e; // Uncomment in prod
    }
  }

  Future<void> _showEditDialog(String field, String label) async {
    final controller = TextEditingController(text: _businessData[field]);
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit $label"),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: label),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _updateField(field, controller.text);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Future<void> _updateField(String field, String value) async {
    setState(() => _isLoading = true);
    try {
      await AwsService().client.updateItem(
        tableName: 'clients_setups',
        key: {
          'bussiness_name': AttributeValue(s: _businessData['bussiness_name']),
        },
        attributeUpdates: {
          field: AttributeValueUpdate(
            action: AttributeAction.put,
            value: AttributeValue(s: value),
          ),
        },
      );
      setState(() {
        _businessData[field] = value;
      });
      _showMessage("$field updated successfully. Updating local config...");

      await _updateLocalJson(field, value);
      await _restartSession();
    } catch (e) {
      _showMessage("Error updating $field: $e", isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String msg, {bool isError = false}) {
    _scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        appBar: AppBar(title: const Text("Business Settings")),
        body: Stack(
          children: [
            // Main Content
            _businessData.isEmpty && _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                ? Center(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 600),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Business Profile",
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const Divider(),
                            _buildReadOnlyField(
                              "Business Name",
                              _businessData['bussiness_name'],
                            ),
                            _buildReadOnlyField(
                              "Owner Name",
                              _businessData['bussiness_owner'],
                            ),
                            _buildReadOnlyField(
                              "Business Location",
                              _businessData['bussiness_location'],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                const Text(
                                  "Status: ",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Switch(
                                  value:
                                      _businessData['bussiness_enabled'] ==
                                      'ENABLED',
                                  onChanged: _isCooldown || _isLoading
                                      ? null
                                      : _updateBusinessEnabled,
                                ),
                                Text(
                                  _businessData['bussiness_enabled'] ==
                                          'ENABLED'
                                      ? "ENABLED"
                                      : "DISABLED",
                                ),
                              ],
                            ),
                            const Divider(),
                            const SizedBox(height: 16),
                            Text(
                              "Sensitive Information (Requires Verification)",
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 16),
                            _buildEditableField(
                              "App Key",
                              "bussiness_key",
                              _businessData['bussiness_key'],
                            ),
                            _buildEditableField(
                              "Owner Email",
                              "owner_email",
                              _businessData['owner_email'],
                            ),
                            _buildEditableField(
                              "Owner Phone",
                              "owner_phone",
                              _businessData['owner_phone'],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
            // Loading Overlay
            if (_isLoading && _businessData.isNotEmpty)
              Container(
                color: Colors.black54,
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(value ?? 'N/A', style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildEditableField(String label, String fieldKey, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  fieldKey == 'bussiness_key' ? '********' : (value ?? 'N/A'),
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: _isCooldown || _isLoading
                ? null
                : () => _requestEdit(fieldKey, label),
          ),
          if (_isCooldown && fieldKey != 'bussiness_enabled') // Visual feedback
            const Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: Icon(Icons.timer, size: 16, color: Colors.grey),
            ),
        ],
      ),
    );
  }

  Future<void> _updateLocalJson(String field, String value) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/assets/json/dkskdp/oxfek.json');
      if (!await file.exists()) return;

      final content = await file.readAsString();
      final envelope = jsonDecode(content);
      final iv = encrypt.IV.fromBase64(envelope['iv']);
      final key = encrypt.Key.fromUtf8('my32lengthsupersecretnooneknows1');
      final encrypter = encrypt.Encrypter(encrypt.AES(key));

      final decrypted = encrypter.decrypt(
        encrypt.Encrypted.fromBase64(envelope['content']),
        iv: iv,
      );
      final Map<String, dynamic> settings = jsonDecode(decrypted);

      // Update specific field
      settings[field] = value;

      // Encrypt back
      final newIv = encrypt.IV.fromLength(16);
      final encrypted = encrypter.encrypt(jsonEncode(settings), iv: newIv);
      final newEnvelope = {'iv': newIv.base64, 'content': encrypted.base64};

      await file.writeAsString(jsonEncode(newEnvelope));
    } catch (e) {
      print('Error updating local JSON: $e');
      rethrow;
    }
  }

  Future<void> _restartSession() async {
    _showMessage("Restarting session in 3 seconds to apply changes...");
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => LogoutSplashScreen(
            currentUser: widget.currentUser,
            usersTableName: widget.usersTableName,
          ),
        ),
        (route) => false,
      );
    }
  }
}
