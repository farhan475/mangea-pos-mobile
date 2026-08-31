import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/local/entities/activity_log_entity.dart';
import '../../../../data/repositories/activity_log_repository.dart';

part 'activity_log_event.dart';
part 'activity_log_state.dart';

class ActivityLogBloc extends Bloc<ActivityLogEvent, ActivityLogState> {
  final ActivityLogRepository _repository;

  ActivityLogBloc(this._repository) : super(ActivityLogInitial()) {
    on<LoadActivityLogs>(_onLoadActivityLogs);
    on<LoadActivityLogsByType>(_onLoadActivityLogsByType);
    on<LoadActivityLogsByDateRange>(_onLoadActivityLogsByDateRange);
    on<AddActivityLog>(_onAddActivityLog);
    on<ClearOldLogs>(_onClearOldLogs);
  }

  Future<void> _onLoadActivityLogs(
    LoadActivityLogs event,
    Emitter<ActivityLogState> emit,
  ) async {
    emit(ActivityLogLoading());
    try {
      final logs = event.limit != null
          ? await _repository.getRecentLogs(limit: event.limit!)
          : await _repository.getAllLogs();
      emit(ActivityLogLoaded(logs));
    } catch (e) {
      emit(ActivityLogError(e.toString()));
    }
  }

  Future<void> _onLoadActivityLogsByType(
    LoadActivityLogsByType event,
    Emitter<ActivityLogState> emit,
  ) async {
    emit(ActivityLogLoading());
    try {
      final logs = await _repository.getLogsByType(event.type);
      emit(ActivityLogLoaded(logs));
    } catch (e) {
      emit(ActivityLogError(e.toString()));
    }
  }

  Future<void> _onLoadActivityLogsByDateRange(
    LoadActivityLogsByDateRange event,
    Emitter<ActivityLogState> emit,
  ) async {
    emit(ActivityLogLoading());
    try {
      final logs = await _repository.getLogsByDateRange(
        event.start,
        event.end,
      );
      emit(ActivityLogLoaded(logs));
    } catch (e) {
      emit(ActivityLogError(e.toString()));
    }
  }

  Future<void> _onAddActivityLog(
    AddActivityLog event,
    Emitter<ActivityLogState> emit,
  ) async {
    try {
      await _repository.log(event.log);
      // Reload logs after adding new one
      add(const LoadActivityLogs());
    } catch (e) {
      emit(ActivityLogError(e.toString()));
    }
  }

  Future<void> _onClearOldLogs(
    ClearOldLogs event,
    Emitter<ActivityLogState> emit,
  ) async {
    try {
      await _repository.clearOldLogs(daysToKeep: event.daysToKeep);
      // Reload logs after clearing
      add(const LoadActivityLogs());
    } catch (e) {
      emit(ActivityLogError(e.toString()));
    }
  }
}
