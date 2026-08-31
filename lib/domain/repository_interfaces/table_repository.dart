import '../../data/local/entities/table_entity.dart';

abstract class TableRepository {
  Future<List<TableEntity>> getTables();
  Future<TableEntity?> getTableById(String id);
  Future<TableEntity?> getTableByNumber(String tableNumber);
  Future<TableEntity> createTable(TableEntity table);
  Future<TableEntity> updateTable(TableEntity table);
  Future<void> deleteTable(String id);
  Future<List<TableEntity>> getTablesByStatus(TableStatus status);
  Future<TableEntity> updateTableStatus(String id, TableStatus status);
  Stream<List<TableEntity>> watchTables();
}
