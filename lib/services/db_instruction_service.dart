import 'dart:convert';
import 'dart:io';
import 'package:aws_dynamodb_api/dynamodb-2012-08-10.dart';
import 'package:tewo_p/apis/aws_service.dart';

class DbInstructionService {
  /// Parses the db.instructions.json file.
  Future<Map<String, dynamic>> parseInstructions(String jsonPath) async {
    final file = File(jsonPath);
    if (!await file.exists()) {
      throw Exception('Instructions file not found at $jsonPath');
    }
    final content = await file.readAsString();
    return jsonDecode(content);
  }

  /// Creates tables in DynamoDB based on the instructions and user prefix.
  ///
  /// [prefix] The business prefix chosen by the user.
  /// [instructions] The parsed JSON instructions which contain the list of tables.
  /// [businessData] Map containing business data to be inserted into 'bussiness_data' table
  /// [ownerData] Map containing owner user data to be inserted into '{prefix}_users' table
  /// [onPkRequest] Optional callback to request PK from user if not detected.
  Future<void> createTables({
    required String prefix,
    required Map<String, dynamic> instructions,
    required Map<String, dynamic> businessData,
    required Map<String, dynamic> ownerData,
    Future<String?> Function(String tableName, List<String> attributes)?
    onPkRequest,
  }) async {
    final db = AwsService().client;
    final List<dynamic> tables = instructions['tables'] ?? [];

    for (var table in tables) {
      String tableNameTemplate = table['table_name'];
      String tableName = tableNameTemplate
          .replaceAll('${prefix}', prefix)
          .replaceAll(r'${prefix}', prefix);

      // Detect Partition Key
      String? pkName = _getPk(table);

      if (pkName == null) {
        print('PK not automatically detected for $tableName');
        if (onPkRequest != null) {
          final attributes =
              (table['attributes'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              [];
          pkName = await onPkRequest(tableName, attributes);
        }
      }

      if (pkName == null || pkName.isEmpty) {
        throw Exception(
          "Could not determine Partition Key for table $tableName",
        );
      }

      print('Final PK for $tableName: $pkName');

      try {
        await db.describeTable(tableName: tableName);
        print('Table $tableName already exists. Skipping creation.');
      } catch (e) {
        print('Creating table $tableName with PK: $pkName...');

        await db.createTable(
          tableName: tableName,
          attributeDefinitions: [
            AttributeDefinition(
              attributeName: pkName,
              attributeType: ScalarAttributeType.s,
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
        print('Table $tableName created.');
      }
    }

    // Data Insertion Loop
    for (var table in tables) {
      bool isEssential = table['essential_table'] == true;
      String tableNameTemplate = table['table_name'];
      String tableName = tableNameTemplate
          .replaceAll('${prefix}', prefix)
          .replaceAll(r'${prefix}', prefix);

      String? pkName = _getPk(table);
      if (pkName == null) {
        print('Skipping data insertion for $tableName due to missing PK');
        continue;
      }

      // Build Attribute Type Map
      final Map<String, String> attributeTypeMap = {};
      final attributes = table['attributes'] as List<dynamic>? ?? [];
      for (var attr in attributes) {
        if (attr is Map) {
          attributeTypeMap[attr['name']] = attr['type'];
        }
      }

      if (isEssential) {
        if (tableName == 'bussiness_data') {
          await _insertData(
            db,
            tableName,
            businessData,
            pkName,
            attributeTypeMap,
          );
        } else if (tableName == '${prefix}_users') {
          await _insertData(db, tableName, ownerData, pkName, attributeTypeMap);
        }
      } else {
        // Generate and insert test data
        final testData = <String, dynamic>{};

        for (var attr in attributes) {
          if (attr is! Map) continue;
          final name = attr['name'] as String;
          final type = attr['type'] as String;

          if (name == pkName) continue;

          if (type == 'int') {
            testData[name] = 10;
          } else if (type == 'double') {
            testData[name] = 99.99;
          } else if (type == 'bool') {
            testData[name] = true;
          } else if (type == 'list') {
            testData[name] = ['tag1', 'tag2'];
          } else {
            testData[name] = "test_$name";
          }
        }
        await _insertData(db, tableName, testData, pkName, attributeTypeMap);
      }
    }
  }

  String? _getPk(Map<String, dynamic> table) {
    if (table['attributes'] != null) {
      for (var attr in table['attributes']) {
        if (attr is Map) {
          final name = attr['name'] as String;
          if (name.toLowerCase().contains('id')) {
            return name;
          }
        }
      }
    }
    return null;
  }

  Future<void> _insertData(
    DynamoDB db,
    String tableName,
    Map<String, dynamic> data,
    String pkName,
    Map<String, String> attributeTypeMap,
  ) async {
    final item = <String, AttributeValue>{};

    // Helper to coerce value
    AttributeValue coerce(String key, dynamic val) {
      final type = attributeTypeMap[key] ?? 'string';
      final sToken = val.toString();

      if (type == 'int') {
        // DynamoDB 'N' stores string representation of number
        // Try parsing to int first to clean valid input, fallback to '0'
        final intVal = int.tryParse(sToken);
        if (intVal != null) {
          return AttributeValue(n: intVal.toString());
        }
        // Fallback: If it's effectively an int in a string?
        return AttributeValue(n: '0');
      } else if (type == 'double') {
        final dVal = double.tryParse(sToken) ?? 0.0;
        return AttributeValue(n: dVal.toString());
      } else if (type == 'bool') {
        return AttributeValue(boolValue: sToken.toLowerCase() == 'true');
      } else if (type == 'list') {
        if (val is List) {
          return AttributeValue(
            l: val.map((e) => AttributeValue(s: e.toString())).toList(),
          );
        }
        return AttributeValue(l: []);
      }

      return AttributeValue(s: sToken);
    }

    // Ensure PK
    if (!data.containsKey(pkName)) {
      if (tableName == 'bussiness_data') {
        item[pkName] = AttributeValue(
          n: DateTime.now().millisecondsSinceEpoch.toString(),
        );
      } else {
        item[pkName] = AttributeValue(
          n: DateTime.now().millisecondsSinceEpoch.toString(),
        );
      }
    } else {
      item[pkName] = coerce(pkName, data[pkName]);
    }

    // Rest of data
    data.forEach((key, value) {
      if (key == pkName) return;
      item[key] = coerce(key, value);
    });

    try {
      await db.putItem(tableName: tableName, item: item);
      print('Inserted data into $tableName');
    } catch (e) {
      print('Error inserting into $tableName: $e');
      rethrow;
    }
  }
}
