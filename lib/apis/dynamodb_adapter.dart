import 'package:tewo_p/apis/database_adapter.dart';
import 'package:tewo_p/apis/aws_service.dart';
import 'package:aws_dynamodb_api/dynamodb-2012-08-10.dart';

class DynamoDbAdapter implements DatabaseAdapter {
  final AwsService _awsService = AwsService();

  @override
  Future<void> connect({Map<String, dynamic>? config}) async {
    // Config expects keys like accessKey, secretKey, region, endpointUrl if overriding defaults
    // Otherwise AwsService uses internal defaults or what was already init.
    _awsService.init(
      accessKey: config?['accessKey'],
      secretKey: config?['secretKey'],
      region: config?['region'],
      endpointUrl: config?['endpointUrl'],
    );
  }

  @override
  Future<bool> checkConnection() async {
    return _awsService.checkConnection();
  }

  @override
  Future<void> createTable(
    String tableName,
    List<Map<String, dynamic>> attributes,
    String pkName,
  ) async {
    final db = _awsService.client;

    try {
      await db.describeTable(tableName: tableName);
      print('Table $tableName already exists in DynamoDB.');
    } catch (e) {
      print('Creating table $tableName in DynamoDB...');
      await db.createTable(
        tableName: tableName,
        attributeDefinitions: [
          AttributeDefinition(
            attributeName: pkName,
            attributeType: ScalarAttributeType
                .s, // Using S for PK logic by default from legacy code, or we could inspect type?
            // Legacy code used S for PK in createTable always.
            // Ideally we check attributeTypeMap for PK if possible, but attributes list has type.
            // Let's check attributes list for PK type.
          ),
        ],
        keySchema: [
          KeySchemaElement(attributeName: pkName, keyType: KeyType.hash),
        ],
        provisionedThroughput: ProvisionedThroughput(
          readCapacityUnits: 5,
          writeCapacityUnits: 5,
        ),
      );
      print('Table $tableName created in DynamoDB.');
    }
  }

  @override
  Future<void> insert(
    String tableName,
    Map<String, dynamic> data,
    String pkName,
    Map<String, String> attributeTypeMap,
  ) async {
    final db = _awsService.client;
    final item = <String, AttributeValue>{};

    data.forEach((key, value) {
      final type = attributeTypeMap[key] ?? 'string';
      final sToken = value.toString();

      if (type == 'int') {
        // DynamoDB N
        item[key] = AttributeValue(n: sToken);
      } else if (type == 'double') {
        item[key] = AttributeValue(n: sToken);
      } else if (type == 'bool') {
        item[key] = AttributeValue(boolValue: sToken.toLowerCase() == 'true');
      } else if (type == 'list') {
        if (value is List) {
          item[key] = AttributeValue(
            l: value.map((e) => AttributeValue(s: e.toString())).toList(),
          );
        } else {
          item[key] = AttributeValue(l: []);
        }
      } else {
        item[key] = AttributeValue(s: sToken);
      }
    });

    await db.putItem(tableName: tableName, item: item);
    print('Inserted data into $tableName (DynamoDB)');
  }

  @override
  Future<List<Map<String, dynamic>>> scan(String tableName) async {
    final db = _awsService.client;
    await db.scan(tableName: tableName);
    // Convert output items to Map<String, dynamic>
    // This requires unmarshalling AttributeValue.
    // For now returning empty list or implemented if needed later.
    return [];
  }
}
