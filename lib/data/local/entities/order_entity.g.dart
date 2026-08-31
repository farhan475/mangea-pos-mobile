// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OrderEntityAdapter extends TypeAdapter<OrderEntity> {
  @override
  final int typeId = 4;

  @override
  OrderEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OrderEntity(
      id: fields[0] as String,
      userId: fields[1] as String?,
      customerName: fields[2] as String?,
      tableNumber: fields[3] as String?,
      totalAmount: fields[4] as double,
      status: fields[5] as OrderStatusEntity,
      syncStatus: fields[6] as SyncStatus,
      createdAt: fields[7] as DateTime,
      updatedAt: fields[8] as DateTime,
      items: (fields[9] as List).cast<OrderItemEntity>(),
      paymentMethod: fields[10] as PaymentMethod?,
      paidAmount: fields[11] as double?,
      changeAmount: fields[12] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, OrderEntity obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.customerName)
      ..writeByte(3)
      ..write(obj.tableNumber)
      ..writeByte(4)
      ..write(obj.totalAmount)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.syncStatus)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.updatedAt)
      ..writeByte(9)
      ..write(obj.items)
      ..writeByte(10)
      ..write(obj.paymentMethod)
      ..writeByte(11)
      ..write(obj.paidAmount)
      ..writeByte(12)
      ..write(obj.changeAmount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class OrderItemEntityAdapter extends TypeAdapter<OrderItemEntity> {
  @override
  final int typeId = 10;

  @override
  OrderItemEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OrderItemEntity(
      id: fields[0] as String,
      orderId: fields[1] as String,
      productId: fields[2] as String,
      productName: fields[3] as String,
      price: fields[4] as double,
      quantity: fields[5] as int,
      subtotal: fields[6] as double,
    );
  }

  @override
  void write(BinaryWriter writer, OrderItemEntity obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.orderId)
      ..writeByte(2)
      ..write(obj.productId)
      ..writeByte(3)
      ..write(obj.productName)
      ..writeByte(4)
      ..write(obj.price)
      ..writeByte(5)
      ..write(obj.quantity)
      ..writeByte(6)
      ..write(obj.subtotal);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderItemEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class OrderStatusEntityAdapter extends TypeAdapter<OrderStatusEntity> {
  @override
  final int typeId = 2;

  @override
  OrderStatusEntity read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return OrderStatusEntity.pending;
      case 1:
        return OrderStatusEntity.cooking;
      case 2:
        return OrderStatusEntity.ready;
      case 3:
        return OrderStatusEntity.paid;
      case 4:
        return OrderStatusEntity.cancelled;
      default:
        return OrderStatusEntity.pending;
    }
  }

  @override
  void write(BinaryWriter writer, OrderStatusEntity obj) {
    switch (obj) {
      case OrderStatusEntity.pending:
        writer.writeByte(0);
        break;
      case OrderStatusEntity.cooking:
        writer.writeByte(1);
        break;
      case OrderStatusEntity.ready:
        writer.writeByte(2);
        break;
      case OrderStatusEntity.paid:
        writer.writeByte(3);
        break;
      case OrderStatusEntity.cancelled:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderStatusEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SyncStatusAdapter extends TypeAdapter<SyncStatus> {
  @override
  final int typeId = 3;

  @override
  SyncStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SyncStatus.pending;
      case 1:
        return SyncStatus.synced;
      default:
        return SyncStatus.pending;
    }
  }

  @override
  void write(BinaryWriter writer, SyncStatus obj) {
    switch (obj) {
      case SyncStatus.pending:
        writer.writeByte(0);
        break;
      case SyncStatus.synced:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PaymentMethodAdapter extends TypeAdapter<PaymentMethod> {
  @override
  final int typeId = 11;

  @override
  PaymentMethod read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PaymentMethod.cash;
      case 1:
        return PaymentMethod.card;
      case 2:
        return PaymentMethod.ewallet;
      case 3:
        return PaymentMethod.qris;
      default:
        return PaymentMethod.cash;
    }
  }

  @override
  void write(BinaryWriter writer, PaymentMethod obj) {
    switch (obj) {
      case PaymentMethod.cash:
        writer.writeByte(0);
        break;
      case PaymentMethod.card:
        writer.writeByte(1);
        break;
      case PaymentMethod.ewallet:
        writer.writeByte(2);
        break;
      case PaymentMethod.qris:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentMethodAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
