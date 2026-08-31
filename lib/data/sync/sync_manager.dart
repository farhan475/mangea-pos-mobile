import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

import '../local/database/hive_database.dart';
import '../local/entities/order_entity.dart';
import '../remote/order_api_service.dart';

class SyncManager {
  final OrderApiService _orderApiService;
  final Connectivity _connectivity;

  StreamSubscription<List<ConnectivityResult>>? _autoSyncSub;
  bool _isSyncing = false;
  DateTime? _lastSyncAt;
  static const _minSyncInterval = Duration(seconds: 10);

  SyncManager(this._orderApiService) : _connectivity = Connectivity();

  /// Check if device is online
  Future<bool> isOnline() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    return !connectivityResult.contains(ConnectivityResult.none);
  }

  /// Sync pending orders to server
  Future<SyncResult> syncOrders() async {
    // Prevent concurrent syncs (race condition producing duplicates)
    if (_isSyncing) {
      return SyncResult(
        success: false,
        message: 'Sync already in progress',
      );
    }
    _isSyncing = true;

    try {
      // Check connection
      if (!await isOnline()) {
        return SyncResult(
          success: false,
          message: 'No internet connection',
        );
      }

      // Get all pending orders from local database
      final ordersBox = HiveDatabase.ordersBoxInstance;
      final pendingOrders = ordersBox.values
          .where((order) => order.syncStatus == SyncStatus.pending)
          .toList();

      if (pendingOrders.isEmpty) {
        return SyncResult(
          success: true,
          message: 'No pending orders to sync',
          syncedCount: 0,
        );
      }

      // Send to server
      final syncedOrders = await _orderApiService.syncOrders(pendingOrders);

      // Update local database with synced status
      final syncedIds = syncedOrders.map((o) => o.id).toSet();
      for (final orderId in syncedIds) {
        final localOrder = ordersBox.get(orderId);
        if (localOrder == null) continue; // deleted locally meanwhile; skip

        localOrder.syncStatus = SyncStatus.synced;
        localOrder.updatedAt = DateTime.now();
        await localOrder.save();
      }

      _lastSyncAt = DateTime.now();
      return SyncResult(
        success: true,
        message: 'Successfully synced ${syncedOrders.length} orders',
        syncedCount: syncedOrders.length,
      );
    } catch (e) {
      return SyncResult(
        success: false,
        message: 'Sync failed: $e',
      );
    } finally {
      _isSyncing = false;
    }
  }

  /// Starts listening to connectivity changes and syncs when back online.
  /// Returns the subscription so callers can cancel it on shutdown.
  StreamSubscription<List<ConnectivityResult>> startAutoSync({
    void Function(SyncResult result)? onResult,
  }) {
    _autoSyncSub?.cancel();
    _autoSyncSub = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> connectivityResult) async {
        if (connectivityResult.contains(ConnectivityResult.none)) return;

        // Wait for the connection to stabilize
        await Future.delayed(const Duration(seconds: 2));

        // Debounce: skip if we synced very recently (connectivity streams can
        // emit rapid duplicate events when switching networks)
        final now = DateTime.now();
        if (_lastSyncAt != null &&
            now.difference(_lastSyncAt!) < _minSyncInterval) {
          return;
        }

        final result = await syncOrders();
        onResult?.call(result);
      },
    );
    return _autoSyncSub!;
  }

  /// Stops the auto-sync listener.
  Future<void> stopAutoSync() async {
    await _autoSyncSub?.cancel();
    _autoSyncSub = null;
  }

  /// Get pending orders count
  int getPendingOrdersCount() {
    final ordersBox = HiveDatabase.ordersBoxInstance;
    return ordersBox.values
        .where((order) => order.syncStatus == SyncStatus.pending)
        .length;
  }
}

class SyncResult {
  final bool success;
  final String message;
  final int syncedCount;

  SyncResult({
    required this.success,
    required this.message,
    this.syncedCount = 0,
  });
}
