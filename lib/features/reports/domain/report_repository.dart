import '../data/daily_report_model.dart';

abstract class ReportRepository {
  /// Get daily report for a specific date
  Future<DailyReportModel> getDailyReport(DateTime date);
  
  /// Get report for date range
  Future<List<DailyReportModel>> getReportRange(DateTime startDate, DateTime endDate);
  
  /// Export report to CSV format
  Future<String> exportToCSV(DailyReportModel report);
  
  /// Export report to PDF format (simple text-based)
  Future<String> exportToPDF(DailyReportModel report);
}
