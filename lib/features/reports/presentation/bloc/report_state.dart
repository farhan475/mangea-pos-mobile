import 'package:equatable/equatable.dart';

import '../../data/daily_report_model.dart';

abstract class ReportState extends Equatable {
  const ReportState();

  @override
  List<Object?> get props => [];
}

class ReportInitial extends ReportState {}

class ReportLoading extends ReportState {}

class ReportLoaded extends ReportState {
  final DailyReportModel report;

  const ReportLoaded(this.report);

  @override
  List<Object?> get props => [report];
}

class ReportRangeLoaded extends ReportState {
  final List<DailyReportModel> reports;

  const ReportRangeLoaded(this.reports);

  @override
  List<Object?> get props => [reports];
}

class ReportExported extends ReportState {
  final String filePath;
  final String fileType;

  const ReportExported(this.filePath, this.fileType);

  @override
  List<Object?> get props => [filePath, fileType];
}

class ReportError extends ReportState {
  final String message;

  const ReportError(this.message);

  @override
  List<Object?> get props => [message];
}
