import 'package:aws_dynamodb_api/dynamodb-2012-08-10.dart';

class AwsLocalService {
  /// Creates a DynamoDB client configured for a local instance.
  /// Used when an endpointUrl is provided.
  static DynamoDB createClient({
    required String endpointUrl,
    String region = 'us-west-2',
    String accessKey = 'fake',
    String secretKey = 'fake',
  }) {
    print('[DEBUG] Creating Local DynamoDB Client for $endpointUrl');

    // Local DynamoDB often requires "fake" credentials but they must be present.
    // We use the provided ones or default to 'fake'.
    final finalAccessKey = accessKey.isNotEmpty ? accessKey : 'fake';
    final finalSecretKey = secretKey.isNotEmpty ? secretKey : 'fake';
    final finalRegion = region.isNotEmpty ? region : 'us-west-2';

    final provider = ({dynamic client}) async {
      return AwsClientCredentials(
        accessKey: finalAccessKey,
        secretKey: finalSecretKey,
      );
    };

    return DynamoDB(
      region: finalRegion,
      endpointUrl: endpointUrl,
      credentialsProvider: provider,
    );
  }
}
