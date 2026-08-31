import 'package:uuid/uuid.dart';

import '../../domain/repository_interfaces/order_repository.dart';
import '../local/database/hive_database.dart';
import '../local/entities/order_entity.dart';
import '../remote/order_api_service.dart';
import '../sync/sync_manager.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderApiService _apiService;
  final SyncManager _syncManager;
  final _uuid = const Uuid();

  OrderRepositoryImpl(this._apiService, this._syncManager);

  @override
  Future<OrderEntity> createOrder(OrderEntity order) async {
    try {
      // Save to local database first (offline-first)
      final ordersBox = HiveDatabase.ordersBoxInstance;
      
      // Generate UUID if not provided
      if (order.id.isEmpty) {
        order.id = _uuid.v4();
      }
      
      order.syncStatus = SyncStatus.pending;
      order.createdAt = DateTime.now();
      order.updatedAt = DateTime.now();
      
      await ordersBox.put(order.id, order);

      // Try to sync if online
      if (await _syncManager.isOnline()) {
        try {
          final syncedOrder = await _apiService.createOrder(order);
          syncedOrder.syncStatus = SyncStatus.synced;
          await ordersBox.put(syncedOrder.id, syncedOrder);
          return syncedOrder;
        } catch (e) {
          // If sync fails, return local order
          // It will be synced later by SyncManager
        }
      }

      return order;
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  @override
  Future<void> deleteOrder(String id) async {
    try {
      final ordersBox = HiveDatabase.ordersBoxInstance;
      await ordersBox.delete(id);

      // Try to delete from server if online
      if (await _syncManager.isOnline()) {
        try {
          await _apiService.deleteOrder(id);
        } catch (e) {
          // Ignore server error, already deleted locally
        }
      }
    } catch (e) {
      throw Exception('Failed to delete order: $e');
    }
  }

  @override
  Future<OrderEntity?> getOrderById(String id) async {
    try {
      final ordersBox = HiveDatabase.ordersBoxInstance;
      return ordersBox.get(id);
    } catch (e) {
      throw Exception('Failed to get order: $e');
    }
  }

  @override
  Future<List<OrderEntity>> getOrders() async {
    try {
      final ordersBox = HiveDatabase.ordersBoxInstance;
      
      // Try to fetch from server if online
      if (await _syncManager.isOnline()) {
        try {
          final serverOrders = await _apiService.getOrders();
          
          // Update local database
          for (var order in serverOrders) {
            order.syncStatus = SyncStatus.synced;
            await ordersBox.put(order.id, order);
          }
        } catch (e) {
          // If server fails, continue with local data
        }
      }

      return ordersBox.values.toList();
    } catch (e) {
      throw Exception('Failed to get orders: $e');
    }
  }

  @override
  Future<List<OrderEntity>> getOrdersByStatus(OrderStatusEntity status) async {
    try {
      final ordersBox = HiveDatabase.ordersBoxInstance;
      return ordersBox.values.where((order) => order.status == status).toList();
    } catch (e) {
      throw Exception('Failed to get orders by status: $e');
    }
  }

  @override
  Future<List<OrderEntity>> getTodayOrders() async {
    try {
      final ordersBox = HiveDatabase.ordersBoxInstance;
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      
      return ordersBox.values
          .where((order) => order.createdAt.isAfter(startOfDay))
          .toList();
    } catch (e) {
      throw Exception('Failed to get today orders: $e');
    }
  }

  @override
  Future<OrderEntity> updateOrder(OrderEntity order) async {
    try {
      final ordersBox = HiveDatabase.ordersBoxInstance;
      
      order.syncStatus = SyncStatus.pending;
      order.updatedAt = DateTime.now();
      
      await ordersBox.put(order.id, order);

      // Try to sync if online
      if (await _syncManager.isOnline()) {
        try {
          final syncedOrder = await _apiService.updateOrder(order);
          syncedOrder.syncStatus = SyncStatus.synced;
          await ordersBox.put(syncedOrder.id, syncedOrder);
          return syncedOrder;
        } catch (e) {
          // If sync fails, return local order
        }
      }

      return order;
    } catch (e) {
      throw Exception('Failed to update order: $e');
    }
  }

  @override
  Stream<List<OrderEntity>> watchOrders() async* {
    final ordersBox = HiveDatabase.ordersBoxInstance;
    
    // Emit initial data
    yield ordersBox.values.toList();
    
    // Watch for changes
    await for (final _ in ordersBox.watch()) {
      yield ordersBox.values.toList();
    }
  }
}
