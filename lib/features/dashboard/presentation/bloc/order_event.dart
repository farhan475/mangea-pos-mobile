part of 'order_bloc.dart';

abstract class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object?> get props => [];
}

class LoadOrders extends OrderEvent {}

class LoadTodayOrders extends OrderEvent {}

class LoadOrdersByStatus extends OrderEvent {
  final OrderStatusEntity status;

  const LoadOrdersByStatus(this.status);

  @override
  List<Object?> get props => [status];
}

class CreateOrder extends OrderEvent {
  final OrderEntity order;

  const CreateOrder(this.order);

  @override
  List<Object?> get props => [order];
}

class UpdateOrder extends OrderEvent {
  final OrderEntity order;

  const UpdateOrder(this.order);

  @override
  List<Object?> get props => [order];
}

class DeleteOrder extends OrderEvent {
  final String orderId;

  const DeleteOrder(this.orderId);

  @override
  List<Object?> get props => [orderId];
}
