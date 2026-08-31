import 'package:hive/hive.dart';

part 'activity_log_entity.g.dart';

@HiveType(typeId: 8)
class ActivityLogEntity extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final ActivityType type;

  @HiveField(2)
  final String action;

  @HiveField(3)
  final String description;

  @HiveField(4)
  final String? entityId;

  @HiveField(5)
  final String? entityType;

  @HiveField(6)
  final Map<String, dynamic>? metadata;

  @HiveField(7)
  final DateTime timestamp;

  @HiveField(8)
  final String? userId;

  ActivityLogEntity({
    required this.id,
    required this.type,
    required this.action,
    required this.description,
    this.entityId,
    this.entityType,
    this.metadata,
    required this.timestamp,
    this.userId,
  });

  factory ActivityLogEntity.fromJson(Map<String, dynamic> json) {
    return ActivityLogEntity(
      id: json['id'] as String,
      type: ActivityType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ActivityType.system,
      ),
      action: json['action'] as String,
      description: json['description'] as String,
      entityId: json['entity_id'] as String?,
      entityType: json['entity_type'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      userId: json['user_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'action': action,
      'description': description,
      'entity_id': entityId,
      'entity_type': entityType,
      'metadata': metadata,
      'timestamp': timestamp.toIso8601String(),
      'user_id': userId,
    };
  }
}

@HiveType(typeId: 9)
enum ActivityType {
  @HiveField(0)
  order,

  @HiveField(1)
  table,

  @HiveField(2)
  product,

  @HiveField(3)
  payment,

  @HiveField(4)
  system,

  @HiveField(5)
  user,
}

extension ActivityTypeExtension on ActivityType {
  String get displayName {
    switch (this) {
      case ActivityType.order:
        return 'Order';
      case ActivityType.table:
        return 'Table';
      case ActivityType.product:
        return 'Product';
      case ActivityType.payment:
        return 'Payment';
      case ActivityType.system:
        return 'System';
      case ActivityType.user:
        return 'User';
    }
  }

  String get icon {
    switch (this) {
      case ActivityType.order:
        return '📋';
      case ActivityType.table:
        return '🪑';
      case ActivityType.product:
        return '🍽️';
      case ActivityType.payment:
        return '💰';
      case ActivityType.system:
        return '⚙️';
      case ActivityType.user:
        return '👤';
    }
  }
}
