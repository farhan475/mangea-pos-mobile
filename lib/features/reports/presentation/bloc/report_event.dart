import 'package:equatable/equatable.dart';

import '../../data/daily_report_model.dart';

abstract class ReportEvent extends Equatable {
  const ReportEvent();

  @override
  List<Object?> get props => [];
}

class LoadDailyReport extends ReportEvent {
  final DateTime date;

  const LoadDailyReport(this.date);

  @override
  List<Object?> get props => [date];
}

class LoadReportRange extends ReportEvent {
  final DateTime startDate;
  final DateTime endDate;

  const LoadReportRange(this.startDate, this.endDate);

  @override
  List<Object?> get props => [startDate, endDate];
}

class ExportReportToCSV extends ReportEvent {
  final DailyReportModel report;

  const ExportReportToCSV(this.report);

  @override
  List<Object?> get props => [report];
}

class ExportReportToPDF extends ReportEvent {
  final DailyReportModel report;

  const ExportReportToPDF(this.report);

  @override
  List<Object?> get props => [report];
}
