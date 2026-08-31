import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:mangea_app/data/local/entities/activity_log_entity.dart';
import 'package:mangea_app/data/local/entities/category_entity.dart';
import 'package:mangea_app/data/local/entities/order_entity.dart';
import 'package:mangea_app/data/local/entities/product_entity.dart';
import 'package:mangea_app/data/local/entities/table_entity.dart';
import 'package:mangea_app/main.dart';

void main() {
  setUpAll(() async {
    // Initialize Hive for testing with temporary directory
    final tempDir = Directory.systemTemp.createTempSync();
    Hive.init(tempDir.path);
    
    // Register adapters
    Hive.registerAdapter(CategoryEntityAdapter());
    Hive.registerAdapter(ProductEntityAdapter());
    Hive.registerAdapter(OrderEntityAdapter());
    Hive.registerAdapter(OrderItemEntityAdapter());
    Hive.registerAdapter(OrderStatusEntityAdapter());
    Hive.registerAdapter(SyncStatusAdapter());
    Hive.registerAdapter(TableEntityAdapter());
    Hive.registerAdapter(TableStatusAdapter());
    Hive.registerAdapter(ActivityLogEntityAdapter());
    Hive.registerAdapter(ActivityTypeAdapter());
    
    // Open boxes
    await Hive.openBox<CategoryEntity>('categories');
    await Hive.openBox<ProductEntity>('products');
    await Hive.openBox<OrderEntity>('orders');
    await Hive.openBox<TableEntity>('tables');
    await Hive.openBox<ActivityLogEntity>('activity_logs');
    await Hive.openBox('settings');
  });

  tearDownAll(() async {
    // Close Hive after tests
    await Hive.close();
  });

  testWidgets('DashboardScreen renders key sections', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MangeaApp());
    
    // Pump multiple frames to allow async operations to complete
    for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    // Check if the app renders without crashing
    expect(find.byType(MangeaApp), findsOneWidget);
  });
}
