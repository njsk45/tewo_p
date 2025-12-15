import 'dart:io';
import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:tewo_p/apis/database_adapter.dart';

class DriftAdapter implements DatabaseAdapter {
  late NativeDatabase _db;
  bool _isConnected = false;

  @override
  Future<void> connect({Map<String, dynamic>? config}) async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'tewo_local.sqlite'));
    _db = NativeDatabase(file);
    _isConnected = true;

    // Ensure we can open it
    await _db.ensureOpen(_QueryExecutorUser(0, 1));
    print('Connected to Local SQLite: ${file.path}');
  }

  @override
  Future<bool> checkConnection() async {
    return _isConnected;
  }

  @override
  Future<void> createTable(
    String tableName,
    List<Map<String, dynamic>> attributes,
    String pkName,
  ) async {
    if (!_isConnected) await connect();

    // Sanitize tableName
    // Assume trusted input from internal instructions
    final buffer = StringBuffer('CREATE TABLE IF NOT EXISTS $tableName (');

    // PK definition
    // For SQLite, it's good to define PK in the columns
    // We iterate attributes to build columns
    final List<String> defs = [];

    for (var attr in attributes) {
      final name = attr['name'] as String;
      final type = attr['type'] as String;

      String sqlType = 'TEXT';
      if (type == 'int') sqlType = 'INTEGER';
      if (type == 'double') sqlType = 'REAL';
      if (type == 'bool') sqlType = 'INTEGER'; // 0 or 1
      if (type == 'list') sqlType = 'TEXT'; // JSON encoded

      if (name == pkName) {
        defs.add('$name $sqlType PRIMARY KEY');
      } else {
        defs.add('$name $sqlType');
      }
    }

    buffer.write(defs.join(', '));
    buffer.write(')');

    final sql = buffer.toString();
    print('DriftAdapter executing: $sql');
    await _db.runCustom(sql);
  }

  @override
  Future<void> insert(
    String tableName,
    Map<String, dynamic> data,
    String pkName,
    Map<String, String> attributeTypeMap,
  ) async {
    if (!_isConnected) await connect();

    final columns = data.keys.toList();
    final values = <dynamic>[];
    final placeholders = <String>[];

    for (var col in columns) {
      placeholders.add('?');
      final val = data[col];
      final type = attributeTypeMap[col] ?? 'string';

      if (type == 'list') {
        values.add(jsonEncode(val));
      } else if (type == 'bool') {
        values.add(
          val == true || val.toString().toLowerCase() == 'true' ? 1 : 0,
        );
      } else {
        // int, double, string -> pass as is, SQLite expects standard types
        // We assume input data is already native types (int, double) where appropriate or convertable
        values.add(val);
      }
    }

    final sql =
        'INSERT OR REPLACE INTO $tableName (${columns.join(', ')}) VALUES (${placeholders.join(', ')})';
    // execute with args
    // NativeDatabase doesn't expose convenient "execute with args" easily on the top level object usually?
    // Actually it does via customStatement or similar?
    // NativeDatabase is a QueryExecutor.
    // We should use QueryExecutor.runCustom

    // But wait, NativeDatabase API usage:
    // _db.runCustom(sql, values);

    print('DriftAdapter executing: $sql with $values');
    await _db.runCustom(sql, values);
  }

  @override
  Future<List<Map<String, dynamic>>> scan(String tableName) async {
    // Implement if needed
    return [];
  }
}

// Dummy user for ensureOpen
class _QueryExecutorUser extends QueryExecutorUser {
  final int schemaVersion;
  final int version;
  _QueryExecutorUser(this.schemaVersion, this.version);

  @override
  Future<void> beforeOpen(
    QueryExecutor executor,
    OpeningDetails details,
  ) async {}
}
