import 'dart:convert';
import 'dart:io';
// import 'package:aws_dynamodb_api/dynamodb-2012-08-10.dart'; // No longer direct dependency
import 'package:tewo_p/apis/database_adapter.dart';
import 'package:tewo_p/apis/drift_adapter.dart';
import 'package:tewo_p/apis/dynamodb_adapter.dart';

class DbInstructionService {
  late DatabaseAdapter _adapter;

  /// Selects the adapter to use.
  /// [type] can be 'local' (Drift) or 'cloud' (DynamoDB).
  void useAdapter(String type) {
    if (type == 'cloud') {
      _adapter = DynamoDbAdapter();
    } else {
      _adapter = DriftAdapter();
    }
  }

  /// Initialize adapter connection
  Future<void> connect({Map<String, dynamic>? config}) async {
    await _adapter.connect(config: config);
  }

  /// Parses the db.instructions.json file.
  Future<Map<String, dynamic>> parseInstructions(String jsonPath) async {
    final file = File(jsonPath);
    if (!await file.exists()) {
      throw Exception('Instructions file not found at $jsonPath');
    }
    final content = await file.readAsString();
    return jsonDecode(content);
  }

  /// Creates tables and inserts initial data based on instructions.
  Future<void> createTables({
    required String prefix,
    required Map<String, dynamic> instructions,
    required Map<String, dynamic> businessData,
    required Map<String, dynamic> ownerData,
    Future<String?> Function(String tableName, List<String> attributes)?
    onPkRequest,
  }) async {
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
        // Legacy: Prompt user if PK missing
        // For dynamic SQLite, we really need a PK.
        // If adapter is Drift, we need it for CREATE TABLE.
        if (onPkRequest != null) {
          final attributesList =
              (table['attributes'] as List<dynamic>?)
                  ?.map((e) => (e is Map ? e['name'] : e).toString())
                  .toList() ??
              [];
          pkName = await onPkRequest(tableName, attributesList);
        }
      }

      if (pkName == null || pkName.isEmpty) {
        throw Exception(
          "Could not determine Partition Key for table $tableName",
        );
      }

      print('Final PK for $tableName: $pkName');

      // Parse attributes for creation
      final List<Map<String, dynamic>> attrList = [];
      final attributes = table['attributes'] as List<dynamic>? ?? [];
      for (var attr in attributes) {
        if (attr is Map) {
          attrList.add(Map<String, dynamic>.from(attr));
        } else {
          // Backward compat if strings
          attrList.add({'name': attr.toString(), 'type': 'string'});
        }
      }

      await _adapter.createTable(tableName, attrList, pkName);
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
          await _insertData(tableName, businessData, pkName, attributeTypeMap);
        } else if (tableName == '${prefix}_users') {
          await _insertData(tableName, ownerData, pkName, attributeTypeMap);
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
          } else if (type == 'double' || type == 'float') {
            testData[name] = 99.99;
          } else if (type == 'bool') {
            testData[name] = true;
          } else if (type == 'list') {
            testData[name] = ['tag1', 'tag2'];
          } else {
            testData[name] = "test_$name";
          }
        }
        await _insertData(tableName, testData, pkName, attributeTypeMap);
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
        } else if (attr is String) {
          if (attr.toLowerCase().contains('id')) return attr;
        }
      }
    }
    return null;
  }

  Future<void> _insertData(
    String tableName,
    Map<String, dynamic> data,
    String pkName,
    Map<String, String> attributeTypeMap,
  ) async {
    // Coerce data types before sending to adapter?
    // The adapter needs raw values but correctly typed for its engine.
    //
    // DriftAdapter needs: int, double, string (native Dart types).
    // DynamoAdapter needs: AttributeValue (which it creates from native types based on map).
    //
    // So here we should ensure 'data' holds Map<String, dynamic> with INTs as ints, DOUBLEs as doubles.
    // The Input 'data' from UI (TextEditingController) is usually String.

    final cleanData = <String, dynamic>{};

    dynamic coerce(String key, dynamic val) {
      final type = attributeTypeMap[key] ?? 'string';
      final sToken = val.toString();

      if (type == 'int') {
        // Return int
        return int.tryParse(sToken) ?? 0;
      } else if (type == 'double' || type == 'float') {
        // Return double
        return double.tryParse(sToken) ?? 0.0;
      } else if (type == 'bool') {
        return sToken.toLowerCase() == 'true';
      } else if (type == 'list') {
        if (val is List) return val;
        return [];
      }
      return sToken;
    }

    // Ensure PK
    if (!data.containsKey(pkName)) {
      if (tableName == 'bussiness_data') {
        // bussiness_id -> int
        cleanData[pkName] = DateTime.now().millisecondsSinceEpoch;
      } else {
        cleanData[pkName] = DateTime.now().millisecondsSinceEpoch;
      }
    } else {
      cleanData[pkName] = coerce(pkName, data[pkName]);
    }

    data.forEach((key, value) {
      if (key == pkName) return;
      cleanData[key] = coerce(key, value);
    });

    try {
      await _adapter.insert(tableName, cleanData, pkName, attributeTypeMap);
    } catch (e) {
      print('Error inserting into $tableName: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> generatePreview({
    required String prefix,
    required Map<String, dynamic> instructions,
    required Map<String, dynamic> businessData,
    required Map<String, dynamic> ownerData,
  }) async {
    final List<dynamic> tables = instructions['tables'] ?? [];
    final List<Map<String, dynamic>> previews = [];

    for (var table in tables) {
      bool isEssential = table['essential_table'] == true;
      String tableNameTemplate = table['table_name'];
      String tableName = tableNameTemplate
          .replaceAll('${prefix}', prefix)
          .replaceAll(r'${prefix}', prefix);

      String? pkName = _getPk(table);
      // If we can't find PK here, we might skip data generation or assume one for preview
      pkName ??= 'id';

      // Build Attribute Type Map
      final Map<String, String> attributeTypeMap = {};
      final attributes = table['attributes'] as List<dynamic>? ?? [];
      for (var attr in attributes) {
        if (attr is Map) {
          attributeTypeMap[attr['name']] = attr['type'];
        }
      }

      final List<Map<String, dynamic>> rows = [];

      if (isEssential) {
        if (tableName == 'bussiness_data') {
          rows.add(
            _prepareRowData(tableName, businessData, pkName, attributeTypeMap),
          );
        } else if (tableName == '${prefix}_users') {
          rows.add(
            _prepareRowData(tableName, ownerData, pkName, attributeTypeMap),
          );
        }
      } else {
        // Generate test data row
        final testData = <String, dynamic>{};
        for (var attr in attributes) {
          if (attr is! Map) continue;
          final name = attr['name'] as String;
          final type = attr['type'] as String;

          if (name == pkName) continue;

          if (type == 'int') {
            testData[name] = 10;
          } else if (type == 'double' || type == 'float') {
            testData[name] = 99.99;
          } else if (type == 'bool') {
            testData[name] = true;
          } else if (type == 'list') {
            testData[name] = ['tag1', 'tag2'];
          } else {
            testData[name] = "test_$name";
          }
        }
        rows.add(
          _prepareRowData(tableName, testData, pkName, attributeTypeMap),
        );
      }

      previews.add({
        'tableName': tableName,
        'columns': attributes
            .map((e) => e is Map ? e['name'] : e.toString())
            .toList(),
        'data': rows,
      });
    }

    return previews;
  }

  Map<String, dynamic> _prepareRowData(
    String tableName,
    Map<String, dynamic> data,
    String pkName,
    Map<String, String> attributeTypeMap,
  ) {
    final cleanData = <String, dynamic>{};

    dynamic coerce(String key, dynamic val) {
      final type = attributeTypeMap[key] ?? 'string';
      final sToken = val.toString();

      if (type == 'int') {
        return int.tryParse(sToken) ?? 0;
      } else if (type == 'double' || type == 'float') {
        return double.tryParse(sToken) ?? 0.0;
      } else if (type == 'bool') {
        return sToken.toLowerCase() == 'true';
      } else if (type == 'list') {
        if (val is List) return val;
        return [];
      }
      return sToken;
    }

    // Ensure PK
    if (!data.containsKey(pkName)) {
      cleanData[pkName] = DateTime.now().millisecondsSinceEpoch; // Preview ID
    } else {
      cleanData[pkName] = coerce(pkName, data[pkName]);
    }

    data.forEach((key, value) {
      if (key == pkName) return;
      cleanData[key] = coerce(key, value);
    });

    return cleanData;
  }
}
