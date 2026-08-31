import 'package:hive/hive.dart';

import '../local/entities/activity_log_entity.dart';
import 'activity_log_repository.dart';

class ActivityLogRepositoryImpl implements ActivityLogRepository {
  final Box<ActivityLogEntity> _box;

  ActivityLogRepositoryImpl(this._box);

  @override
  Future<void> log(ActivityLogEntity activity) async {
    await _box.put(activity.id, activity);
  }

  @override
  Future<List<ActivityLogEntity>> getAllLogs() async {
    final logs = _box.values.toList();
    logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return logs;
  }

  @override
  Future<List<ActivityLogEntity>> getLogsByType(ActivityType type) async {
    final logs = _box.values.where((log) => log.type == type).toList();
    logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return logs;
  }

  @override
  Future<List<ActivityLogEntity>> getLogsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final logs = _box.values.where((log) {
      return log.timestamp.isAfter(start) && log.timestamp.isBefore(end);
    }).toList();
    logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return logs;
  }

  @override
  Future<List<ActivityLogEntity>> getRecentLogs({int limit = 50}) async {
    final logs = _box.values.toList();
    logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return logs.take(limit).toList();
  }

  @override
  Future<void> clearOldLogs({int daysToKeep = 30}) async {
    final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));
    final oldLogs = _box.values.where((log) {
      return log.timestamp.isBefore(cutoffDate);
    }).toList();

    for (final log in oldLogs) {
      await _box.delete(log.id);
    }
  }

  @override
  Future<void> deleteLog(String id) async {
    await _box.delete(id);
  }
}
