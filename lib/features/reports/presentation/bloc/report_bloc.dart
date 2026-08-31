import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/report_repository.dart';
import 'report_event.dart';
import 'report_state.dart';

class ReportBloc extends Bloc<ReportEvent, ReportState> {
  final ReportRepository _repository;

  ReportBloc(this._repository) : super(ReportInitial()) {
    on<LoadDailyReport>(_onLoadDailyReport);
    on<LoadReportRange>(_onLoadReportRange);
    on<ExportReportToCSV>(_onExportReportToCSV);
    on<ExportReportToPDF>(_onExportReportToPDF);
  }

  Future<void> _onLoadDailyReport(
    LoadDailyReport event,
    Emitter<ReportState> emit,
  ) async {
    try {
      emit(ReportLoading());
      final report = await _repository.getDailyReport(event.date);
      emit(ReportLoaded(report));
    } catch (e) {
      emit(ReportError(e.toString()));
    }
  }

  Future<void> _onLoadReportRange(
    LoadReportRange event,
    Emitter<ReportState> emit,
  ) async {
    try {
      emit(ReportLoading());
      final reports = await _repository.getReportRange(
        event.startDate,
        event.endDate,
      );
      emit(ReportRangeLoaded(reports));
    } catch (e) {
      emit(ReportError(e.toString()));
    }
  }

  Future<void> _onExportReportToCSV(
    ExportReportToCSV event,
    Emitter<ReportState> emit,
  ) async {
    try {
      emit(ReportLoading());
      final filePath = await _repository.exportToCSV(event.report);
      emit(ReportExported(filePath, 'CSV'));
    } catch (e) {
      emit(ReportError('Failed to export CSV: $e'));
    }
  }

  Future<void> _onExportReportToPDF(
    ExportReportToPDF event,
    Emitter<ReportState> emit,
  ) async {
    try {
      emit(ReportLoading());
      final filePath = await _repository.exportToPDF(event.report);
      emit(ReportExported(filePath, 'PDF'));
    } catch (e) {
      emit(ReportError('Failed to export PDF: $e'));
    }
  }
}
