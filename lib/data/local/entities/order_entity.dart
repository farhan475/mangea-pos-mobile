import 'package:hive/hive.dart';

part 'order_entity.g.dart';

@HiveType(typeId: 2)
enum OrderStatusEntity {
  @HiveField(0)
  pending,
  @HiveField(1)
  cooking,
  @HiveField(2)
  ready,
  @HiveField(3)
  paid,
  @HiveField(4)
  cancelled,
}

@HiveType(typeId: 3)
enum SyncStatus {
  @HiveField(0)
  pending,
  @HiveField(1)
  synced,
}

@HiveType(typeId: 11)
enum PaymentMethod {
  @HiveField(0)
  cash,
  @HiveField(1)
  card,
  @HiveField(2)
  ewallet,
  @HiveField(3)
  qris,
}

@HiveType(typeId: 4)
class OrderEntity extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String? userId;

  @HiveField(2)
  String? customerName;

  @HiveField(3)
  String? tableNumber;

  @HiveField(4)
  double totalAmount;

  @HiveField(5)
  OrderStatusEntity status;

  @HiveField(6)
  SyncStatus syncStatus;

  @HiveField(7)
  DateTime createdAt;

  @HiveField(8)
  DateTime updatedAt;

  @HiveField(9)
  List<OrderItemEntity> items;

  @HiveField(10)
  PaymentMethod? paymentMethod;

  @HiveField(11)
  double? paidAmount;

  @HiveField(12)
  double? changeAmount;

  OrderEntity({
    required this.id,
    this.userId,
    this.customerName,
    this.tableNumber,
    required this.totalAmount,
    required this.status,
    this.syncStatus = SyncStatus.pending,
    required this.createdAt,
    required this.updatedAt,
    this.items = const [],
    this.paymentMethod,
    this.paidAmount,
    this.changeAmount,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'customer_name': customerName,
      'table_number': tableNumber,
      'total_amount': totalAmount,
      'status': status.name,
      'sync_status': syncStatus.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
      'payment_method': paymentMethod?.name,
      'paid_amount': paidAmount,
      'change_amount': changeAmount,
    };
  }

  factory OrderEntity.fromJson(Map<String, dynamic> json) {
    return OrderEntity(
      id: json['id'],
      userId: json['user_id'],
      customerName: json['customer_name'],
      tableNumber: json['table_number'],
      totalAmount: (json['total_amount'] as num).toDouble(),
      status: OrderStatusEntity.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => OrderStatusEntity.pending,
      ),
      syncStatus: json['sync_status'] != null
          ? SyncStatus.values.firstWhere(
              (e) => e.name == json['sync_status'],
              orElse: () => SyncStatus.pending,
            )
          : SyncStatus.pending,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      items: json['items'] != null
          ? (json['items'] as List)
              .map((item) => OrderItemEntity.fromJson(item))
              .toList()
          : [],
      paymentMethod: json['payment_method'] != null
          ? PaymentMethod.values.firstWhere(
              (e) => e.name == json['payment_method'],
              orElse: () => PaymentMethod.cash,
            )
          : null,
      paidAmount: json['paid_amount'] != null 
          ? (json['paid_amount'] as num).toDouble() 
          : null,
      changeAmount: json['change_amount'] != null 
          ? (json['change_amount'] as num).toDouble() 
          : null,
    );
  }
}

@HiveType(typeId: 10)
class OrderItemEntity extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String orderId;

  @HiveField(2)
  String productId;

  @HiveField(3)
  String productName;

  @HiveField(4)
  double price;

  @HiveField(5)
  int quantity;

  @HiveField(6)
  double subtotal;

  OrderItemEntity({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.subtotal,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'product_id': productId,
      'product_name': productName,
      'price': price,
      'quantity': quantity,
      'subtotal': subtotal,
    };
  }

  factory OrderItemEntity.fromJson(Map<String, dynamic> json) {
    return OrderItemEntity(
      id: json['id'],
      orderId: json['order_id'],
      productId: json['product_id'],
      productName: json['product_name'],
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'],
      subtotal: (json['subtotal'] as num).toDouble(),
    );
  }
}
