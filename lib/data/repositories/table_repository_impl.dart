import 'package:uuid/uuid.dart';

import '../../domain/repository_interfaces/table_repository.dart';
import '../local/database/hive_database.dart';
import '../local/entities/table_entity.dart';
import '../remote/table_api_service.dart';

class TableRepositoryImpl implements TableRepository {
  final TableApiService _apiService;
  final _uuid = const Uuid();

  TableRepositoryImpl(this._apiService);

  @override
  Future<TableEntity> createTable(TableEntity table) async {
    try {
      if (table.id.isEmpty) {
        table.id = _uuid.v4();
      }
      table.createdAt = DateTime.now();
      table.updatedAt = DateTime.now();

      // Try API first
      try {
        final remote = await _apiService.createTable(table);
        await HiveDatabase.tablesBoxInstance.put(remote.id, remote);
        return remote;
      } catch (_) {
        // Fallback to local
        await HiveDatabase.tablesBoxInstance.put(table.id, table);
        return table;
      }
    } catch (e) {
      throw Exception('Failed to create table: $e');
    }
  }

  @override
  Future<void> deleteTable(String id) async {
    try {
      // Try API first
      try {
        await _apiService.deleteTable(id);
      } catch (_) {
        // Continue with local deletion even if API fails
      }
      await HiveDatabase.tablesBoxInstance.delete(id);
    } catch (e) {
      throw Exception('Failed to delete table: $e');
    }
  }

  @override
  Future<TableEntity?> getTableById(String id) async {
    try {
      // Try API first
      try {
        final remote = await _apiService.getTableById(id);
        await HiveDatabase.tablesBoxInstance.put(remote.id, remote);
        return remote;
      } catch (_) {
        return HiveDatabase.tablesBoxInstance.get(id);
      }
    } catch (e) {
      throw Exception('Failed to get table: $e');
    }
  }

  @override
  Future<TableEntity?> getTableByNumber(String tableNumber) async {
    try {
      final tablesBox = HiveDatabase.tablesBoxInstance;
      return tablesBox.values.cast<TableEntity?>().firstWhere(
        (table) => table?.tableNumber == tableNumber,
        orElse: () => null,
      );
    } catch (e) {
      throw Exception('Failed to get table by number: $e');
    }
  }

  @override
  Future<List<TableEntity>> getTables() async {
    try {
      // Try API first, cache in Hive
      try {
        final remote = await _apiService.getTables();
        final box = HiveDatabase.tablesBoxInstance;
        await box.clear();
        for (final t in remote) {
          await box.put(t.id, t);
        }
        return remote;
      } catch (_) {
        // Fallback to local cache
        return HiveDatabase.tablesBoxInstance.values.toList();
      }
    } catch (e) {
      throw Exception('Failed to get tables: $e');
    }
  }

  @override
  Future<List<TableEntity>> getTablesByStatus(TableStatus status) async {
    try {
      try {
        final remote = await _apiService.getTables(status: status.name);
        return remote;
      } catch (_) {
        return HiveDatabase.tablesBoxInstance.values
            .where((table) => table.status == status)
            .toList();
      }
    } catch (e) {
      throw Exception('Failed to get tables by status: $e');
    }
  }

  @override
  Future<TableEntity> updateTable(TableEntity table) async {
    try {
      try {
        final remote = await _apiService.updateTable(table);
        await HiveDatabase.tablesBoxInstance.put(remote.id, remote);
        return remote;
      } catch (_) {
        table.updatedAt = DateTime.now();
        await HiveDatabase.tablesBoxInstance.put(table.id, table);
        return table;
      }
    } catch (e) {
      throw Exception('Failed to update table: $e');
    }
  }

  @override
  Future<TableEntity> updateTableStatus(String id, TableStatus status) async {
    try {
      try {
        final remote = await _apiService.updateTableStatus(id, status.name);
        await HiveDatabase.tablesBoxInstance.put(remote.id, remote);
        return remote;
      } catch (_) {
        final table = await getTableById(id);
        if (table == null) throw Exception('Table not found');
        table.status = status;
        table.updatedAt = DateTime.now();
        await HiveDatabase.tablesBoxInstance.put(table.id, table);
        return table;
      }
    } catch (e) {
      throw Exception('Failed to update table status: $e');
    }
  }

  @override
  Stream<List<TableEntity>> watchTables() async* {
    final tablesBox = HiveDatabase.tablesBoxInstance;
    yield tablesBox.values.toList();
    await for (final _ in tablesBox.watch()) {
      yield tablesBox.values.toList();
    }
  }
}
