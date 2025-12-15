abstract class DatabaseAdapter {
  Future<void> connect({Map<String, dynamic>? config});
  Future<void> createTable(
    String tableName,
    List<Map<String, dynamic>> attributes,
    String pkName,
  );
  Future<void> insert(
    String tableName,
    Map<String, dynamic> data,
    String pkName,
    Map<String, String> attributeTypeMap,
  );
  Future<List<Map<String, dynamic>>> scan(String tableName);
  Future<bool> checkConnection();
}
