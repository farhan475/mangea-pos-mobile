import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/services/activity_log_service.dart';
import 'core/theme/app_theme.dart';
import 'data/local/database/hive_database.dart';
import 'data/remote/dio_client.dart';
import 'data/remote/order_api_service.dart';
import 'data/remote/product_api_service.dart';
import 'data/remote/table_api_service.dart';
import 'data/repositories/activity_log_repository_impl.dart';
import 'data/repositories/order_repository_impl.dart';
import 'data/repositories/product_repository_impl.dart';
import 'data/repositories/table_repository_impl.dart';
import 'data/sync/sync_manager.dart';
import 'features/activity_log/presentation/bloc/activity_log_bloc.dart';
import 'features/auth/data/auth_repository_impl.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/screens/splash_screen.dart';
import 'features/dashboard/presentation/bloc/order_bloc.dart';
import 'features/pos/presentation/bloc/product_bloc.dart';
import 'features/reports/data/report_repository_impl.dart';
import 'features/reports/presentation/bloc/report_bloc.dart';
import 'features/tables/presentation/bloc/table_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive database
  await HiveDatabase.init();
  
  // Initialize default users if not exists
  final authRepo = AuthRepositoryImpl();
  await authRepo.initializeDefaultUsers();

  runApp(const MangeaApp());
}

class MangeaApp extends StatefulWidget {
  const MangeaApp({super.key});

  @override
  State<MangeaApp> createState() => _MangeaAppState();
}

class _MangeaAppState extends State<MangeaApp> {
  StreamSubscription? _autoSyncSub;

  @override
  void initState() {
    super.initState();
    // Start background sync: uploads pending offline orders whenever
    // connectivity is restored (kept alive for the app's lifetime)
    final dioClient = DioClient();
    final orderApiService = OrderApiService(dioClient);
    final syncManager = SyncManager(orderApiService);
    _autoSyncSub = syncManager.startAutoSync();
  }

  @override
  void dispose() {
    _autoSyncSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Initialize dependencies
    final dioClient = DioClient();
    final orderApiService = OrderApiService(dioClient);
    final productApiService = ProductApiService(dioClient);
    final tableApiService = TableApiService(dioClient);
    final syncManager = SyncManager(orderApiService);

    final orderRepository = OrderRepositoryImpl(orderApiService, syncManager);
    final productRepository = ProductRepositoryImpl(productApiService, syncManager);
    final tableRepository = TableRepositoryImpl(tableApiService);
    final activityLogRepository = ActivityLogRepositoryImpl(
      HiveDatabase.activityLogsBoxInstance,
    );
    final reportRepository = ReportRepositoryImpl();
    final authRepository = AuthRepositoryImpl();

    // Initialize activity log service
    final activityLogService = ActivityLogService(activityLogRepository);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(authRepository),
        ),
        BlocProvider(
          create: (context) => OrderBloc(
            orderRepository,
            activityLogService: activityLogService,
          )..add(LoadTodayOrders()),
        ),
        BlocProvider(
          create: (context) => ProductBloc(productRepository)..add(LoadProducts()),
        ),
        BlocProvider(
          create: (context) => TableBloc(
            tableRepository,
            activityLogService: activityLogService,
          )..add(LoadTables()),
        ),
        BlocProvider(
          create: (context) => ActivityLogBloc(activityLogRepository),
        ),
        BlocProvider(
          create: (context) => ReportBloc(reportRepository),
        ),
      ],
      child: MaterialApp(
        title: 'Mangea POS',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const SplashScreen(),
      ),
    );
  }
}
