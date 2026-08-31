import 'package:hive/hive.dart';

part 'table_entity.g.dart';

@HiveType(typeId: 13)
enum TableStatus {
  @HiveField(0)
  available,
  @HiveField(1)
  occupied,
  @HiveField(2)
  reserved,
}

@HiveType(typeId: 12)
class TableEntity extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String tableNumber;

  @HiveField(2)
  int capacity;

  @HiveField(3)
  TableStatus status;

  @HiveField(4)
  String? currentOrderId;

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  DateTime updatedAt;

  TableEntity({
    required this.id,
    required this.tableNumber,
    required this.capacity,
    this.status = TableStatus.available,
    this.currentOrderId,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'table_number': tableNumber,
      'capacity': capacity,
      'status': status.name,
      'current_order_id': currentOrderId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory TableEntity.fromJson(Map<String, dynamic> json) {
    return TableEntity(
      id: json['id'],
      tableNumber: json['table_number'],
      capacity: json['capacity'],
      status: TableStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TableStatus.available,
      ),
      currentOrderId: json['current_order_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
