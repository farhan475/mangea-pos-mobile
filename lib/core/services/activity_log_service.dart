import 'package:uuid/uuid.dart';

import '../../data/local/entities/activity_log_entity.dart';
import '../../data/repositories/activity_log_repository.dart';

class ActivityLogService {
  final ActivityLogRepository _repository;
  final _uuid = const Uuid();

  ActivityLogService(this._repository);

  Future<void> logOrderCreated(String orderId, String customerName, String tableNumber) async {
    await _repository.log(
      ActivityLogEntity(
        id: _uuid.v4(),
        type: ActivityType.order,
        action: 'Order Created',
        description: 'New order created for $customerName at table $tableNumber',
        entityId: orderId,
        entityType: 'order',
        metadata: {
          'customer_name': customerName,
          'table_number': tableNumber,
        },
        timestamp: DateTime.now(),
      ),
    );
  }

  Future<void> logOrderStatusChanged(String orderId, String customerName, String oldStatus, String newStatus) async {
    await _repository.log(
      ActivityLogEntity(
        id: _uuid.v4(),
        type: ActivityType.order,
        action: 'Order Status Changed',
        description: 'Order for $customerName changed from $oldStatus to $newStatus',
        entityId: orderId,
        entityType: 'order',
        metadata: {
          'customer_name': customerName,
          'old_status': oldStatus,
          'new_status': newStatus,
        },
        timestamp: DateTime.now(),
      ),
    );
  }

  Future<void> logOrderDeleted(String orderId, String customerName) async {
    await _repository.log(
      ActivityLogEntity(
        id: _uuid.v4(),
        type: ActivityType.order,
        action: 'Order Deleted',
        description: 'Order for $customerName was deleted',
        entityId: orderId,
        entityType: 'order',
        metadata: {
          'customer_name': customerName,
        },
        timestamp: DateTime.now(),
      ),
    );
  }

  Future<void> logTableStatusChanged(String tableId, String tableNumber, String oldStatus, String newStatus) async {
    await _repository.log(
      ActivityLogEntity(
        id: _uuid.v4(),
        type: ActivityType.table,
        action: 'Table Status Changed',
        description: 'Table $tableNumber status changed from $oldStatus to $newStatus',
        entityId: tableId,
        entityType: 'table',
        metadata: {
          'table_number': tableNumber,
          'old_status': oldStatus,
          'new_status': newStatus,
        },
        timestamp: DateTime.now(),
      ),
    );
  }

  Future<void> logTableCreated(String tableId, String tableNumber, int capacity) async {
    await _repository.log(
      ActivityLogEntity(
        id: _uuid.v4(),
        type: ActivityType.table,
        action: 'Table Created',
        description: 'New table $tableNumber created with capacity of $capacity',
        entityId: tableId,
        entityType: 'table',
        metadata: {
          'table_number': tableNumber,
          'capacity': capacity.toString(),
        },
        timestamp: DateTime.now(),
      ),
    );
  }

  Future<void> logTableDeleted(String tableId, String tableNumber) async {
    await _repository.log(
      ActivityLogEntity(
        id: _uuid.v4(),
        type: ActivityType.table,
        action: 'Table Deleted',
        description: 'Table $tableNumber was deleted',
        entityId: tableId,
        entityType: 'table',
        metadata: {
          'table_number': tableNumber,
        },
        timestamp: DateTime.now(),
      ),
    );
  }

  Future<void> logPaymentCompleted(String orderId, String customerName, double amount) async {
    await _repository.log(
      ActivityLogEntity(
        id: _uuid.v4(),
        type: ActivityType.payment,
        action: 'Payment Completed',
        description: 'Payment of Rp ${amount.toStringAsFixed(0)} received from $customerName',
        entityId: orderId,
        entityType: 'payment',
        metadata: {
          'customer_name': customerName,
          'amount': amount.toString(),
        },
        timestamp: DateTime.now(),
      ),
    );
  }
}
