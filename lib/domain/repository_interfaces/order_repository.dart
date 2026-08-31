import '../../data/local/entities/order_entity.dart';

abstract class OrderRepository {
  Future<List<OrderEntity>> getOrders();
  Future<OrderEntity?> getOrderById(String id);
  Future<OrderEntity> createOrder(OrderEntity order);
  Future<OrderEntity> updateOrder(OrderEntity order);
  Future<void> deleteOrder(String id);
  Future<List<OrderEntity>> getOrdersByStatus(OrderStatusEntity status);
  Future<List<OrderEntity>> getTodayOrders();
  Stream<List<OrderEntity>> watchOrders();
}
