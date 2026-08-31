import '../../core/constants/api_constants.dart';
import '../local/entities/table_entity.dart';
import 'dio_client.dart';

class TableApiService {
  final DioClient _dioClient;

  TableApiService(this._dioClient);

  Future<List<TableEntity>> getTables({String? status}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null) queryParams['status'] = status;

      final response = await _dioClient.get(
        ApiConstants.tables,
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );

      if (response.data is List) {
        return (response.data as List)
            .map((json) => TableEntity.fromJson(json))
            .toList();
      }

      throw Exception('Invalid response format');
    } catch (e) {
      throw Exception('Failed to fetch tables: $e');
    }
  }

  Future<TableEntity> getTableById(String id) async {
    try {
      final response = await _dioClient.get('${ApiConstants.tables}/$id');
      return TableEntity.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch table: $e');
    }
  }

  Future<TableEntity> createTable(TableEntity table) async {
    try {
      final response = await _dioClient.post(
        ApiConstants.tables,
        data: table.toJson(),
      );
      return TableEntity.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create table: $e');
    }
  }

  Future<TableEntity> updateTable(TableEntity table) async {
    try {
      final response = await _dioClient.put(
        '${ApiConstants.tables}/${table.id}',
        data: {
          'table_number': table.tableNumber,
          'capacity': table.capacity,
        },
      );
      return TableEntity.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update table: $e');
    }
  }

  Future<TableEntity> updateTableStatus(String id, String status) async {
    try {
      final response = await _dioClient.patch(
        '${ApiConstants.tables}/$id/status',
        data: {'status': status},
      );
      return TableEntity.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update table status: $e');
    }
  }

  Future<void> deleteTable(String id) async {
    try {
      await _dioClient.delete('${ApiConstants.tables}/$id');
    } catch (e) {
      throw Exception('Failed to delete table: $e');
    }
  }
}
