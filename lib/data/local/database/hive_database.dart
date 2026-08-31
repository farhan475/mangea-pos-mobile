import 'package:hive_flutter/hive_flutter.dart';

import '../entities/activity_log_entity.dart';
import '../entities/category_entity.dart';
import '../entities/order_entity.dart';
import '../entities/product_entity.dart';
import '../entities/table_entity.dart';
import '../entities/user_entity.dart';

class HiveDatabase {
  static const String categoriesBox = 'categories';
  static const String productsBox = 'products';
  static const String ordersBox = 'orders';
  static const String tablesBox = 'tables';
  static const String activityLogsBox = 'activity_logs';
  static const String usersBox = 'users';
  static const String settingsBox = 'settings';

  static Future<void> init() async {
    // Initialize Hive
    await Hive.initFlutter();

    // Register adapters
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
    Hive.registerAdapter(UserEntityAdapter());
    Hive.registerAdapter(UserRoleAdapter());

    // Open boxes
    await Hive.openBox<CategoryEntity>(categoriesBox);
    await Hive.openBox<ProductEntity>(productsBox);
    await Hive.openBox<OrderEntity>(ordersBox);
    await Hive.openBox<TableEntity>(tablesBox);
    await Hive.openBox<ActivityLogEntity>(activityLogsBox);
    await Hive.openBox<UserEntity>(usersBox);
    await Hive.openBox(settingsBox);
  }

  static Box<CategoryEntity> get categoriesBoxInstance =>
      Hive.box<CategoryEntity>(categoriesBox);

  static Box<ProductEntity> get productsBoxInstance =>
      Hive.box<ProductEntity>(productsBox);

  static Box<OrderEntity> get ordersBoxInstance =>
      Hive.box<OrderEntity>(ordersBox);

  static Box<TableEntity> get tablesBoxInstance =>
      Hive.box<TableEntity>(tablesBox);

  static Box<ActivityLogEntity> get activityLogsBoxInstance =>
      Hive.box<ActivityLogEntity>(activityLogsBox);

  static Box<UserEntity> get usersBoxInstance =>
      Hive.box<UserEntity>(usersBox);

  static Box get settingsBoxInstance => Hive.box(settingsBox);

  static Future<void> clearAll() async {
    await categoriesBoxInstance.clear();
    await productsBoxInstance.clear();
    await ordersBoxInstance.clear();
    await tablesBoxInstance.clear();
    await activityLogsBoxInstance.clear();
  }

  static Future<void> close() async {
    await Hive.close();
  }
}
