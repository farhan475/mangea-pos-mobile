part of 'activity_log_bloc.dart';

abstract class ActivityLogEvent extends Equatable {
  const ActivityLogEvent();

  @override
  List<Object?> get props => [];
}

class LoadActivityLogs extends ActivityLogEvent {
  final int? limit;

  const LoadActivityLogs({this.limit});

  @override
  List<Object?> get props => [limit];
}

class LoadActivityLogsByType extends ActivityLogEvent {
  final ActivityType type;

  const LoadActivityLogsByType(this.type);

  @override
  List<Object?> get props => [type];
}

class LoadActivityLogsByDateRange extends ActivityLogEvent {
  final DateTime start;
  final DateTime end;

  const LoadActivityLogsByDateRange(this.start, this.end);

  @override
  List<Object?> get props => [start, end];
}

class AddActivityLog extends ActivityLogEvent {
  final ActivityLogEntity log;

  const AddActivityLog(this.log);

  @override
  List<Object?> get props => [log];
}

class ClearOldLogs extends ActivityLogEvent {
  final int daysToKeep;

  const ClearOldLogs({this.daysToKeep = 30});

  @override
  List<Object?> get props => [daysToKeep];
}
