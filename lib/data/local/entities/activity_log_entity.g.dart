// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_log_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ActivityLogEntityAdapter extends TypeAdapter<ActivityLogEntity> {
  @override
  final int typeId = 8;

  @override
  ActivityLogEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ActivityLogEntity(
      id: fields[0] as String,
      type: fields[1] as ActivityType,
      action: fields[2] as String,
      description: fields[3] as String,
      entityId: fields[4] as String?,
      entityType: fields[5] as String?,
      metadata: (fields[6] as Map?)?.cast<String, dynamic>(),
      timestamp: fields[7] as DateTime,
      userId: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ActivityLogEntity obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.action)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.entityId)
      ..writeByte(5)
      ..write(obj.entityType)
      ..writeByte(6)
      ..write(obj.metadata)
      ..writeByte(7)
      ..write(obj.timestamp)
      ..writeByte(8)
      ..write(obj.userId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActivityLogEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ActivityTypeAdapter extends TypeAdapter<ActivityType> {
  @override
  final int typeId = 9;

  @override
  ActivityType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ActivityType.order;
      case 1:
        return ActivityType.table;
      case 2:
        return ActivityType.product;
      case 3:
        return ActivityType.payment;
      case 4:
        return ActivityType.system;
      case 5:
        return ActivityType.user;
      default:
        return ActivityType.order;
    }
  }

  @override
  void write(BinaryWriter writer, ActivityType obj) {
    switch (obj) {
      case ActivityType.order:
        writer.writeByte(0);
        break;
      case ActivityType.table:
        writer.writeByte(1);
        break;
      case ActivityType.product:
        writer.writeByte(2);
        break;
      case ActivityType.payment:
        writer.writeByte(3);
        break;
      case ActivityType.system:
        writer.writeByte(4);
        break;
      case ActivityType.user:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActivityTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
