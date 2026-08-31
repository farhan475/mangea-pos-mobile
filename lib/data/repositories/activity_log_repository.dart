import '../local/entities/activity_log_entity.dart';

abstract class ActivityLogRepository {
  Future<void> log(ActivityLogEntity activity);
  Future<List<ActivityLogEntity>> getAllLogs();
  Future<List<ActivityLogEntity>> getLogsByType(ActivityType type);
  Future<List<ActivityLogEntity>> getLogsByDateRange(
    DateTime start,
    DateTime end,
  );
  Future<List<ActivityLogEntity>> getRecentLogs({int limit = 50});
  Future<void> clearOldLogs({int daysToKeep = 30});
  Future<void> deleteLog(String id);
}
