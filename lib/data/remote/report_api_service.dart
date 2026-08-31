import '../../core/constants/api_constants.dart';
import 'dio_client.dart';

class ReportApiService {
  final DioClient _dioClient;

  ReportApiService(this._dioClient);

  /// Get daily report for a given date (default: today)
  Future<Map<String, dynamic>> getDailyReport({DateTime? date}) async {
    try {
      final dateStr =
          (date ?? DateTime.now()).toIso8601String().substring(0, 10);
      final response = await _dioClient.get(
        '${ApiConstants.reports}/daily',
        queryParameters: {'date': dateStr},
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to fetch daily report: $e');
    }
  }

  /// Get weekly report
  Future<Map<String, dynamic>> getWeeklyReport({DateTime? date}) async {
    try {
      final dateStr =
          (date ?? DateTime.now()).toIso8601String().substring(0, 10);
      final response = await _dioClient.get(
        '${ApiConstants.reports}/weekly',
        queryParameters: {'date': dateStr},
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to fetch weekly report: $e');
    }
  }

  /// Get top selling products
  Future<List<Map<String, dynamic>>> getTopProducts({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final now = DateTime.now();
      final start = (startDate ?? now).toIso8601String().substring(0, 10);
      final end = (endDate ?? now).toIso8601String().substring(0, 10);

      final response = await _dioClient.get(
        '${ApiConstants.reports}/top-products',
        queryParameters: {'start_date': start, 'end_date': end},
      );

      if (response.data is List) {
        return (response.data as List).cast<Map<String, dynamic>>();
      }
      throw Exception('Invalid response format');
    } catch (e) {
      throw Exception('Failed to fetch top products: $e');
    }
  }
}
