import 'dart:io';

import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../../../data/local/database/hive_database.dart';
import '../../../data/local/entities/order_entity.dart';
import '../domain/report_repository.dart';
import 'daily_report_model.dart';

class ReportRepositoryImpl implements ReportRepository {
  @override
  Future<DailyReportModel> getDailyReport(DateTime date) async {
    final ordersBox = HiveDatabase.ordersBoxInstance;
    
    // Filter orders for the specific date
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    
    final dayOrders = ordersBox.values.where((order) {
      return order.createdAt.isAfter(startOfDay) && 
             order.createdAt.isBefore(endOfDay);
    }).toList();
    
    // Calculate metrics
    final totalOrders = dayOrders.length;
    final completedOrders = dayOrders
        .where((o) => o.status == OrderStatusEntity.paid)
        .length;
    final cancelledOrders = dayOrders
        .where((o) => o.status == OrderStatusEntity.cancelled)
        .length;
    
    double totalRevenue = 0;
    double totalTax = 0;

    for (var order in dayOrders) {
      if (order.status == OrderStatusEntity.paid) {
        totalRevenue += order.totalAmount;
        // Tax stored on the order if present; totals are tax-inclusive
        // (total = subtotal * 1.1), mirroring the backend report convention.
        if (order.items.isNotEmpty) {
          final subtotal = order.items.fold<double>(
              0, (sum, item) => sum + item.subtotal);
          totalTax += order.totalAmount - subtotal;
        } else {
          // Fallback: extract 10% from the tax-inclusive total
          totalTax += order.totalAmount - (order.totalAmount / 1.1);
        }
      }
    }
    
    // Calculate top products
    final productSales = <String, Map<String, dynamic>>{};
    
    for (var order in dayOrders) {
      if (order.status == OrderStatusEntity.paid) {
        for (var item in order.items) {
          if (!productSales.containsKey(item.productId)) {
            productSales[item.productId] = {
              'name': item.productName,
              'quantity': 0,
              'revenue': 0.0,
            };
          }
          productSales[item.productId]!['quantity'] += item.quantity;
          productSales[item.productId]!['revenue'] += item.price * item.quantity;
        }
      }
    }
    
    final topProducts = productSales.entries
        .map((e) => ProductSalesModel(
              productId: e.key,
              productName: e.value['name'],
              quantitySold: e.value['quantity'],
              revenue: e.value['revenue'],
            ))
        .toList()
      ..sort((a, b) => b.quantitySold.compareTo(a.quantitySold));
    
    // Calculate hourly sales
    final hourlySalesMap = <int, Map<String, dynamic>>{};
    
    for (var order in dayOrders) {
      if (order.status == OrderStatusEntity.paid) {
        final hour = order.createdAt.hour;
        if (!hourlySalesMap.containsKey(hour)) {
          hourlySalesMap[hour] = {'orders': 0, 'revenue': 0.0};
        }
        hourlySalesMap[hour]!['orders'] += 1;
        hourlySalesMap[hour]!['revenue'] += order.totalAmount;
      }
    }
    
    final hourlySales = List.generate(24, (hour) {
      final data = hourlySalesMap[hour];
      return HourlySalesModel(
        hour: hour,
        orders: data?['orders'] ?? 0,
        revenue: data?['revenue'] ?? 0.0,
      );
    });
    
    return DailyReportModel(
      date: date,
      totalOrders: totalOrders,
      totalRevenue: totalRevenue,
      totalTax: totalTax,
      completedOrders: completedOrders,
      cancelledOrders: cancelledOrders,
      topProducts: topProducts.take(10).toList(),
      hourlySales: hourlySales,
    );
  }

  @override
  Future<List<DailyReportModel>> getReportRange(
      DateTime startDate, DateTime endDate) async {
    final reports = <DailyReportModel>[];
    var currentDate = startDate;
    
    while (currentDate.isBefore(endDate) ||
        currentDate.isAtSameMomentAs(endDate)) {
      final report = await getDailyReport(currentDate);
      reports.add(report);
      currentDate = currentDate.add(const Duration(days: 1));
    }
    
    return reports;
  }

  @override
  Future<String> exportToCSV(DailyReportModel report) async {
    final rows = <List<dynamic>>[];
    
    // Header
    rows.add(['Daily Sales Report']);
    rows.add(['Date', DateFormat('yyyy-MM-dd').format(report.date)]);
    rows.add([]);
    
    // Summary
    rows.add(['Summary']);
    rows.add(['Total Orders', report.totalOrders]);
    rows.add(['Completed Orders', report.completedOrders]);
    rows.add(['Cancelled Orders', report.cancelledOrders]);
    rows.add(['Total Revenue', 'Rp ${report.totalRevenue.toStringAsFixed(0)}']);
    rows.add(['Total Tax', 'Rp ${report.totalTax.toStringAsFixed(0)}']);
    rows.add(['Average Order Value', 'Rp ${report.averageOrderValue.toStringAsFixed(0)}']);
    rows.add(['Completion Rate', '${report.completionRate.toStringAsFixed(1)}%']);
    rows.add([]);
    
    // Top Products
    rows.add(['Top Selling Products']);
    rows.add(['Product Name', 'Quantity Sold', 'Revenue']);
    for (var product in report.topProducts) {
      rows.add([
        product.productName,
        product.quantitySold,
        'Rp ${product.revenue.toStringAsFixed(0)}',
      ]);
    }
    rows.add([]);
    
    // Hourly Sales
    rows.add(['Hourly Sales']);
    rows.add(['Hour', 'Orders', 'Revenue']);
    for (var hourly in report.hourlySales) {
      if (hourly.orders > 0) {
        rows.add([
          '${hourly.hour.toString().padLeft(2, '0')}:00',
          hourly.orders,
          'Rp ${hourly.revenue.toStringAsFixed(0)}',
        ]);
      }
    }
    
    final csvString = const ListToCsvConverter().convert(rows);
    
    // Save to file
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'daily_report_${DateFormat('yyyy-MM-dd').format(report.date)}.csv';
    final filePath = '${directory.path}/$fileName';
    final file = File(filePath);
    await file.writeAsString(csvString);
    
    return filePath;
  }

  @override
  Future<String> exportToPDF(DailyReportModel report) async {
    // For now, export as text file (simple PDF alternative)
    final buffer = StringBuffer();
    
    buffer.writeln('═══════════════════════════════════════════');
    buffer.writeln('           DAILY SALES REPORT');
    buffer.writeln('═══════════════════════════════════════════');
    buffer.writeln('Date: ${DateFormat('EEEE, dd MMMM yyyy').format(report.date)}');
    buffer.writeln('');
    
    buffer.writeln('─────────────────────────────────────────');
    buffer.writeln('SUMMARY');
    buffer.writeln('─────────────────────────────────────────');
    buffer.writeln('Total Orders        : ${report.totalOrders}');
    buffer.writeln('Completed Orders    : ${report.completedOrders}');
    buffer.writeln('Cancelled Orders    : ${report.cancelledOrders}');
    buffer.writeln('Total Revenue       : Rp ${report.totalRevenue.toStringAsFixed(0)}');
    buffer.writeln('Total Tax           : Rp ${report.totalTax.toStringAsFixed(0)}');
    buffer.writeln('Average Order Value : Rp ${report.averageOrderValue.toStringAsFixed(0)}');
    buffer.writeln('Completion Rate     : ${report.completionRate.toStringAsFixed(1)}%');
    buffer.writeln('');
    
    buffer.writeln('─────────────────────────────────────────');
    buffer.writeln('TOP SELLING PRODUCTS');
    buffer.writeln('─────────────────────────────────────────');
    for (var i = 0; i < report.topProducts.length; i++) {
      final product = report.topProducts[i];
      buffer.writeln('${i + 1}. ${product.productName}');
      buffer.writeln('   Quantity: ${product.quantitySold} | Revenue: Rp ${product.revenue.toStringAsFixed(0)}');
    }
    buffer.writeln('');
    
    buffer.writeln('─────────────────────────────────────────');
    buffer.writeln('HOURLY SALES');
    buffer.writeln('─────────────────────────────────────────');
    for (var hourly in report.hourlySales) {
      if (hourly.orders > 0) {
        buffer.writeln(
            '${hourly.hour.toString().padLeft(2, '0')}:00 - Orders: ${hourly.orders} | Revenue: Rp ${hourly.revenue.toStringAsFixed(0)}');
      }
    }
    buffer.writeln('');
    buffer.writeln('═══════════════════════════════════════════');
    buffer.writeln('Generated on ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}');
    buffer.writeln('═══════════════════════════════════════════');
    
    // Save to file
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'daily_report_${DateFormat('yyyy-MM-dd').format(report.date)}.txt';
    final filePath = '${directory.path}/$fileName';
    final file = File(filePath);
    await file.writeAsString(buffer.toString());
    
    return filePath;
  }
}
