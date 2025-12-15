import 'package:aws_dynamodb_api/dynamodb-2012-08-10.dart';
import 'package:tewo_p/apis/aws_local_service.dart';

class AwsService {
  // Singleton instance
  static final AwsService _instance = AwsService._internal();

  factory AwsService() {
    return _instance;
  }

  AwsService._internal();

  // AWS Configuration Variables, the Key is only yours, I can't help you with that.
  String _accessKey = '';
  String _secretKey = '';
  String _region = '';
  String _endpointUrl = '';

  DynamoDB? _client;

  /// Initializes the AWS Service with credentials.
  /// You can pass them here or set them in the variables above.
  void init({
    String? accessKey,
    String? secretKey,
    String? region,
    String? endpointUrl,
  }) {
    if (accessKey != null) _accessKey = accessKey;
    if (secretKey != null) _secretKey = secretKey;
    if (region != null) _region = region;
    if (endpointUrl != null) _endpointUrl = endpointUrl;

    if (_accessKey.isEmpty || _secretKey.isEmpty || _region.isEmpty) {
      print('Warning: AWS Credentials are not fully set.');
    }

    print('[DEBUG] AwsService.init called with region: $_region');

    if (_endpointUrl.isNotEmpty) {
      // Delegate to Local Service for custom endpoints
      _client = AwsLocalService.createClient(
        endpointUrl: _endpointUrl,
        region: _region,
        accessKey: _accessKey,
        secretKey: _secretKey,
      );
      return;
    }

    var provider;
    if (accessKey != null && secretKey != null) {
      print('[DEBUG] Creating provider with passed args');
      provider = ({dynamic client}) async {
        print('[DEBUG] Provider called with args');
        return AwsClientCredentials(accessKey: accessKey, secretKey: secretKey);
      };
    } else if (_accessKey.isNotEmpty && _secretKey.isNotEmpty) {
      print('[DEBUG] Creating provider with internal args');
      provider = ({dynamic client}) async {
        print('[DEBUG] Provider (internal) called');
        return AwsClientCredentials(
          accessKey: _accessKey,
          secretKey: _secretKey,
        );
      };
    } else {
      print('[DEBUG] No credentials available for provider');
    }

    _client = DynamoDB(region: _region, credentialsProvider: provider);
  }

  /// Returns the configured DynamoDb client.
  /// Throws an exception if init() has not been called or variables are missing.
  DynamoDB get client {
    if (_client == null) {
      // Try to auto-init if variables are set in code
      if (_accessKey.isNotEmpty &&
          _secretKey.isNotEmpty &&
          _region.isNotEmpty) {
        init();
      } else {
        throw Exception(
          'AwsService is not initialized. keys are empty. Call init() or fill variables.',
        );
      }
    }
    return _client!;
  }

  /// Checks if the connection to DynamoDB is valid by listing tables.
  Future<bool> checkConnection() async {
    print('[DEBUG] checkConnection called');
    try {
      await client.listTables();
      print('[DEBUG] checkConnection success');
      return true;
    } catch (e) {
      print('Connection check failed: $e');
      print('[DEBUG] checkConnection error: $e');
      return false;
    }
  }

  /// Lists the tables in the connected DynamoDB account.
  Future<List<String>> getTables() async {
    try {
      final output = await client.listTables();
      return output.tableNames ?? [];
    } catch (e) {
      // ignore: avoid_print
      print('Error listing tables: $e');
      rethrow;
    }
  }
}
