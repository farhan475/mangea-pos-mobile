import 'package:intl/intl.dart';

import '../../../domain/models/order_model.dart';
import '../../../domain/models/popular_dish_model.dart';
import '../../../domain/models/stock_alert_model.dart';

/// Data dummy sementara untuk preview UI Dashboard.
/// Akan digantikan oleh repository (local/remote) pada fase integrasi data.
class DummyDashboardData {
  DummyDashboardData._();

  static int get newOrdersCount {
    final oneHourAgo = DateTime.now().subtract(const Duration(hours: 1));
    return orders
        .where((o) =>
            o.status == OrderStatus.inProgress &&
            o.createdAt.isAfter(oneHourAgo))
        .length;
  }

  static List<OrderModel> get newOrders {
    final oneHourAgo = DateTime.now().subtract(const Duration(hours: 1));
    return orders
        .where((o) =>
            o.status == OrderStatus.inProgress &&
            o.createdAt.isAfter(oneHourAgo))
        .toList();
  }

  static int get totalOrdersToday => orders.length;

  static const double totalOrdersGrowthPercent = 12.5;

  static int get waitingListCount {
    return orders
        .where((o) =>
            o.status == OrderStatus.inProgress || o.status == OrderStatus.ready)
        .length;
  }

  static String formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0)
        .format(amount);
  }

  static final List<OrderModel> orders = [
    OrderModel(
      id: 'ord-1',
      tableCode: 'A4',
      customerName: 'Budi Santoso',
      itemCount: 3,
      status: OrderStatus.ready,
      totalAmount: 145000,
      createdAt: DateTime.now().subtract(const Duration(minutes: 12)),
    ),
    OrderModel(
      id: 'ord-2',
      tableCode: 'B2',
      customerName: 'Siti Aminah',
      itemCount: 5,
      status: OrderStatus.inProgress,
      totalAmount: 267500,
      createdAt: DateTime.now().subtract(const Duration(minutes: 4)),
    ),
    OrderModel(
      id: 'ord-3',
      tableCode: 'C1',
      customerName: 'Andi Wijaya',
      itemCount: 2,
      status: OrderStatus.completed,
      totalAmount: 98000,
      createdAt: DateTime.now().subtract(const Duration(minutes: 25)),
    ),
    OrderModel(
      id: 'ord-4',
      tableCode: 'A1',
      customerName: 'Rina Marlina',
      itemCount: 4,
      status: OrderStatus.completed,
      totalAmount: 182000,
      createdAt: DateTime.now().subtract(const Duration(minutes: 18)),
    ),
    OrderModel(
      id: 'ord-5',
      tableCode: 'D3',
      customerName: 'Joko Prasetyo',
      itemCount: 6,
      status: OrderStatus.inProgress,
      totalAmount: 310000,
      createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
    ),
  ];

  static List<OrderModel> get readyForPayment =>
      orders.where((o) => o.status == OrderStatus.completed).toList();

  static final List<PopularDishModel> popularDishes = [
    const PopularDishModel(id: 'p1', name: 'Nasi Goreng Spesial', soldCount: 48),
    const PopularDishModel(id: 'p2', name: 'Ayam Bakar Madu', soldCount: 39),
    const PopularDishModel(id: 'p3', name: 'Es Teh Manis', soldCount: 35),
    const PopularDishModel(id: 'p4', name: 'Sate Ayam', soldCount: 28),
    const PopularDishModel(id: 'p5', name: 'Mie Goreng Jawa', soldCount: 21),
  ];

  static final List<StockAlertModel> outOfStock = [
    const StockAlertModel(
      id: 's1',
      productName: 'Jus Alpukat',
      availabilityNote: 'Habis hari ini',   
    ),
    const StockAlertModel(
      id: 's2',
      productName: 'Steak Sirloin',
      availabilityNote: 'Tersedia jam 15:00',
    ),
    const StockAlertModel(
      id: 's3',
      productName: 'Kentang Goreng',
      availabilityNote: 'Stok tersisa 2 porsi',
    ),
  ];
}
