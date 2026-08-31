import '../../core/constants/api_constants.dart';
import 'dio_client.dart';

class DashboardApiService {
  final DioClient _dioClient;

  DashboardApiService(this._dioClient);

  /// Get dashboard metrics
  Future<Map<String, dynamic>> getMetrics() async {
    try {
      final response = await _dioClient.get('${ApiConstants.dashboard}/metrics');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to fetch dashboard metrics: $e');
    }
  }

  /// Get popular dishes
  Future<List<Map<String, dynamic>>> getPopularDishes({int limit = 5}) async {
    try {
      final response = await _dioClient.get(
        '${ApiConstants.dashboard}/popular-dishes',
        queryParameters: {'limit': limit},
      );

      if (response.data is List) {
        return (response.data as List).cast<Map<String, dynamic>>();
      }
      throw Exception('Invalid response format');
    } catch (e) {
      throw Exception('Failed to fetch popular dishes: $e');
    }
  }

  /// Get out of stock products
  Future<List<Map<String, dynamic>>> getOutOfStock() async {
    try {
      final response =
          await _dioClient.get('${ApiConstants.dashboard}/out-of-stock');

      if (response.data is List) {
        return (response.data as List).cast<Map<String, dynamic>>();
      }
      throw Exception('Invalid response format');
    } catch (e) {
      throw Exception('Failed to fetch out of stock products: $e');
    }
  }
}
