import 'package:equatable/equatable.dart';

class DailyReportModel extends Equatable {
  final DateTime date;
  final int totalOrders;
  final double totalRevenue;
  final double totalTax;
  final int completedOrders;
  final int cancelledOrders;
  final List<ProductSalesModel> topProducts;
  final List<HourlySalesModel> hourlySales;

  const DailyReportModel({
    required this.date,
    required this.totalOrders,
    required this.totalRevenue,
    required this.totalTax,
    required this.completedOrders,
    required this.cancelledOrders,
    required this.topProducts,
    required this.hourlySales,
  });

  /// Average spend per *paid* order — cancelled orders must not dilute it.
  double get averageOrderValue =>
      completedOrders > 0 ? totalRevenue / completedOrders : 0;

  double get completionRate =>
      totalOrders > 0 ? (completedOrders / totalOrders) * 100 : 0;

  @override
  List<Object?> get props => [
        date,
        totalOrders,
        totalRevenue,
        totalTax,
        completedOrders,
        cancelledOrders,
        topProducts,
        hourlySales,
      ];
}

class ProductSalesModel extends Equatable {
  final String productId;
  final String productName;
  final int quantitySold;
  final double revenue;

  const ProductSalesModel({
    required this.productId,
    required this.productName,
    required this.quantitySold,
    required this.revenue,
  });

  @override
  List<Object?> get props => [productId, productName, quantitySold, revenue];
}

class HourlySalesModel extends Equatable {
  final int hour;
  final int orders;
  final double revenue;

  const HourlySalesModel({
    required this.hour,
    required this.orders,
    required this.revenue,
  });

  @override
  List<Object?> get props => [hour, orders, revenue];
}
