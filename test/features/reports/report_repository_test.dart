import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mangea_app/features/reports/data/report_repository_impl.dart';
import 'package:mangea_app/data/local/entities/category_entity.dart';
import 'package:mangea_app/data/local/entities/product_entity.dart';
import 'package:mangea_app/data/local/entities/order_entity.dart';
import 'package:mangea_app/data/local/entities/table_entity.dart';
import 'package:mangea_app/data/local/entities/activity_log_entity.dart';
import 'package:mangea_app/data/local/entities/user_entity.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  late ReportRepositoryImpl repository;

  setUpAll(() async {
    // Create test directories
    final testDocDir = Directory('./test_documents');
    if (!testDocDir.existsSync()) {
      testDocDir.createSync(recursive: true);
    }
    
    // Mock path_provider for testing
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'getApplicationDocumentsDirectory') {
          return './test_documents';
        }
        return null;
      },
    );
    
    // Initialize Hive for testing
    Hive.init('./test_hive');
    
    // Register all required adapters
    Hive.registerAdapter(CategoryEntityAdapter());
    Hive.registerAdapter(ProductEntityAdapter());
    Hive.registerAdapter(OrderEntityAdapter());
    Hive.registerAdapter(OrderItemEntityAdapter());
    Hive.registerAdapter(OrderStatusEntityAdapter());
    Hive.registerAdapter(SyncStatusAdapter());
    Hive.registerAdapter(PaymentMethodAdapter());
    Hive.registerAdapter(TableEntityAdapter());
    Hive.registerAdapter(TableStatusAdapter());
    Hive.registerAdapter(ActivityLogEntityAdapter());
    Hive.registerAdapter(ActivityTypeAdapter());
    Hive.registerAdapter(UserEntityAdapter());
    Hive.registerAdapter(UserRoleAdapter());
    
    // Open required boxes
    await Hive.openBox<CategoryEntity>('categories');
    await Hive.openBox<ProductEntity>('products');
    await Hive.openBox<OrderEntity>('orders');
    await Hive.openBox<TableEntity>('tables');
    await Hive.openBox<ActivityLogEntity>('activity_logs');
    await Hive.openBox<UserEntity>('users');
    await Hive.openBox('settings');
  });

  setUp(() {
    repository = ReportRepositoryImpl();
  });
  
  tearDownAll(() async {
    await Hive.close();
  });

  group('ReportRepository Tests', () {
    test('getDailyReport returns valid report model', () async {
      // Arrange
      final testDate = DateTime.now();

      // Act
      final report = await repository.getDailyReport(testDate);

      // Assert
      expect(report, isNotNull);
      expect(report.date.year, testDate.year);
      expect(report.date.month, testDate.month);
      expect(report.date.day, testDate.day);
      expect(report.totalOrders, isA<int>());
      expect(report.totalRevenue, isA<double>());
      expect(report.completedOrders, isA<int>());
      expect(report.topProducts, isA<List>());
      expect(report.hourlySales, hasLength(24));
    });

    test('getReportRange returns list of reports', () async {
      // Arrange
      final startDate = DateTime.now().subtract(const Duration(days: 2));
      final endDate = DateTime.now();

      // Act
      final reports = await repository.getReportRange(startDate, endDate);

      // Assert
      expect(reports, isNotNull);
      expect(reports, isA<List>());
      expect(reports.length, greaterThanOrEqualTo(1));
    });

    test('exportToCSV generates valid file path', () async {
      // Arrange
      final testDate = DateTime.now();
      final report = await repository.getDailyReport(testDate);

      // Act
      final filePath = await repository.exportToCSV(report);

      // Assert
      expect(filePath, isNotNull);
      expect(filePath, contains('.csv'));
      expect(filePath, contains('daily_report_'));
    });

    test('exportToPDF generates valid file path', () async {
      // Arrange
      final testDate = DateTime.now();
      final report = await repository.getDailyReport(testDate);

      // Act
      final filePath = await repository.exportToPDF(report);

      // Assert
      expect(filePath, isNotNull);
      expect(filePath, contains('.txt'));
      expect(filePath, contains('daily_report_'));
    });

    test('report calculates average order value correctly', () async {
      // Arrange
      final testDate = DateTime.now();
      final report = await repository.getDailyReport(testDate);

      // Act & Assert
      if (report.totalOrders > 0) {
        expect(report.averageOrderValue, 
               equals(report.totalRevenue / report.totalOrders));
      } else {
        expect(report.averageOrderValue, equals(0));
      }
    });

    test('report calculates completion rate correctly', () async {
      // Arrange
      final testDate = DateTime.now();
      final report = await repository.getDailyReport(testDate);

      // Act & Assert
      if (report.totalOrders > 0) {
        expect(report.completionRate, 
               equals((report.completedOrders / report.totalOrders) * 100));
      } else {
        expect(report.completionRate, equals(0));
      }
    });
  });
}
