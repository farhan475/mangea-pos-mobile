import '../../core/constants/api_constants.dart';
import '../local/entities/order_entity.dart';
import 'dio_client.dart';

class OrderApiService {
  final DioClient _dioClient;

  OrderApiService(this._dioClient);

  Future<List<OrderEntity>> getOrders() async {
    try {
      final response = await _dioClient.get(ApiConstants.orders);
      
      if (response.data is List) {
        return (response.data as List)
            .map((json) => OrderEntity.fromJson(json))
            .toList();
      }
      
      throw Exception('Invalid response format');
    } catch (e) {
      throw Exception('Failed to fetch orders: $e');
    }
  }

  Future<OrderEntity> getOrderById(String id) async {
    try {
      final response = await _dioClient.get('${ApiConstants.orders}/$id');
      return OrderEntity.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch order: $e');
    }
  }

  Future<OrderEntity> createOrder(OrderEntity order) async {
    try {
      final response = await _dioClient.post(
        ApiConstants.orders,
        data: order.toJson(),
      );
      return OrderEntity.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  Future<OrderEntity> updateOrder(OrderEntity order) async {
    try {
      final response = await _dioClient.put(
        '${ApiConstants.orders}/${order.id}',
        data: order.toJson(),
      );
      return OrderEntity.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update order: $e');
    }
  }

  Future<void> deleteOrder(String id) async {
    try {
      await _dioClient.delete('${ApiConstants.orders}/$id');
    } catch (e) {
      throw Exception('Failed to delete order: $e');
    }
  }

  Future<List<OrderEntity>> syncOrders(List<OrderEntity> orders) async {
    try {
      final response = await _dioClient.post(
        '${ApiConstants.sync}/orders',
        data: orders.map((order) => order.toJson()).toList(),
      );
      
      if (response.data is List) {
        return (response.data as List)
            .map((json) => OrderEntity.fromJson(json))
            .toList();
      }
      
      throw Exception('Invalid response format');
    } catch (e) {
      throw Exception('Failed to sync orders: $e');
    }
  }
}
