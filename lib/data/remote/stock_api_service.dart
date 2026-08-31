import '../../core/constants/api_constants.dart';
import 'dio_client.dart';

class StockApiService {
  final DioClient _dioClient;

  StockApiService(this._dioClient);

  /// Get stock statistics
  Future<Map<String, dynamic>> getStockStatistics() async {
    try {
      final response =
          await _dioClient.get('${ApiConstants.stock}/statistics');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to fetch stock statistics: $e');
    }
  }

  /// Get products with low stock
  Future<List<Map<String, dynamic>>> getLowStockProducts() async {
    try {
      final response = await _dioClient.get('${ApiConstants.stock}/low');
      if (response.data is List) {
        return (response.data as List).cast<Map<String, dynamic>>();
      }
      throw Exception('Invalid response format');
    } catch (e) {
      throw Exception('Failed to fetch low stock products: $e');
    }
  }

  /// Get out of stock products
  Future<List<Map<String, dynamic>>> getOutOfStockProducts() async {
    try {
      final response = await _dioClient.get('${ApiConstants.stock}/out');
      if (response.data is List) {
        return (response.data as List).cast<Map<String, dynamic>>();
      }
      throw Exception('Invalid response format');
    } catch (e) {
      throw Exception('Failed to fetch out of stock products: $e');
    }
  }

  /// Set exact stock quantity
  Future<Map<String, dynamic>> updateStock(
      String productId, int stock) async {
    try {
      final response = await _dioClient.patch(
        '${ApiConstants.stock}/products/$productId',
        data: {'stock': stock},
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to update stock: $e');
    }
  }

  /// Add stock quantity
  Future<Map<String, dynamic>> addStock(
      String productId, int quantity) async {
    try {
      final response = await _dioClient.post(
        '${ApiConstants.stock}/products/$productId/add',
        data: {'quantity': quantity},
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to add stock: $e');
    }
  }

  /// Reduce stock quantity
  Future<Map<String, dynamic>> reduceStock(
      String productId, int quantity) async {
    try {
      final response = await _dioClient.post(
        '${ApiConstants.stock}/products/$productId/reduce',
        data: {'quantity': quantity},
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to reduce stock: $e');
    }
  }
}
