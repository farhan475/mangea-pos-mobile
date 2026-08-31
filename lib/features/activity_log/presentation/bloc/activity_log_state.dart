part of 'activity_log_bloc.dart';

abstract class ActivityLogState extends Equatable {
  const ActivityLogState();

  @override
  List<Object?> get props => [];
}

class ActivityLogInitial extends ActivityLogState {}

class ActivityLogLoading extends ActivityLogState {}

class ActivityLogLoaded extends ActivityLogState {
  final List<ActivityLogEntity> logs;

  const ActivityLogLoaded(this.logs);

  @override
  List<Object?> get props => [logs];
}

class ActivityLogError extends ActivityLogState {
  final String message;

  const ActivityLogError(this.message);

  @override
  List<Object?> get props => [message];
}
