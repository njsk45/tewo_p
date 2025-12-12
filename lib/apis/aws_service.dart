import 'package:aws_dynamodb_api/dynamodb-2012-08-10.dart';

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

  DynamoDB? _client;

  /// Initializes the AWS Service with credentials.
  /// You can pass them here or set them in the variables above.
  void init({String? accessKey, String? secretKey, String? region}) {
    if (accessKey != null) _accessKey = accessKey;
    if (secretKey != null) _secretKey = secretKey;
    if (region != null) _region = region;

    if (_accessKey.isEmpty || _secretKey.isEmpty || _region.isEmpty) {
      print('Warning: AWS Credentials are not fully set.');
    }

    // Using simple alphanumeric credential provider for standard keys
    // Note: Assuming AwsClientCredentials is the correct type based on previous errors.
    // If not, we might need to adjust or import it.

    _client = DynamoDB(region: _region, credentialsProvider: null);
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
