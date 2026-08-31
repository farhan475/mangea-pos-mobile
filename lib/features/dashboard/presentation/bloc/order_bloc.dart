import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/activity_log_service.dart';
import '../../../../data/local/entities/order_entity.dart';
import '../../../../domain/repository_interfaces/order_repository.dart';

part 'order_event.dart';
part 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRepository _orderRepository;
  final ActivityLogService? _activityLogService;

  OrderBloc(this._orderRepository, {ActivityLogService? activityLogService})
      : _activityLogService = activityLogService,
        super(OrderInitial()) {
    on<LoadOrders>(_onLoadOrders);
    on<CreateOrder>(_onCreateOrder);
    on<UpdateOrder>(_onUpdateOrder);
    on<DeleteOrder>(_onDeleteOrder);
    on<LoadTodayOrders>(_onLoadTodayOrders);
    on<LoadOrdersByStatus>(_onLoadOrdersByStatus);
  }

  Future<void> _onLoadOrders(
    LoadOrders event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());
    try {
      final orders = await _orderRepository.getOrders();
      emit(OrderLoaded(orders));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> _onCreateOrder(
    CreateOrder event,
    Emitter<OrderState> emit,
  ) async {
    try {
      await _orderRepository.createOrder(event.order);
      
      // Log activity
      await _activityLogService?.logOrderCreated(
        event.order.id,
        event.order.customerName ?? 'Unknown',
        event.order.tableNumber ?? 'N/A',
      );
      
      add(LoadOrders());
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> _onUpdateOrder(
    UpdateOrder event,
    Emitter<OrderState> emit,
  ) async {
    try {
      // Get old order for comparison
      final oldOrder = await _orderRepository.getOrderById(event.order.id);
      
      await _orderRepository.updateOrder(event.order);
      
      // Log activity if status changed
      if (oldOrder != null && oldOrder.status != event.order.status) {
        await _activityLogService?.logOrderStatusChanged(
          event.order.id,
          event.order.customerName ?? 'Unknown',
          oldOrder.status.name,
          event.order.status.name,
        );
      }
      
      add(LoadOrders());
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> _onDeleteOrder(
    DeleteOrder event,
    Emitter<OrderState> emit,
  ) async {
    try {
      // Get order before deleting for logging
      final order = await _orderRepository.getOrderById(event.orderId);
      
      await _orderRepository.deleteOrder(event.orderId);
      
      // Log activity
      if (order != null) {
        await _activityLogService?.logOrderDeleted(
          event.orderId,
          order.customerName ?? 'Unknown',
        );
      }
      
      add(LoadOrders());
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> _onLoadTodayOrders(
    LoadTodayOrders event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());
    try {
      final orders = await _orderRepository.getTodayOrders();
      emit(OrderLoaded(orders));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> _onLoadOrdersByStatus(
    LoadOrdersByStatus event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());
    try {
      final orders = await _orderRepository.getOrdersByStatus(event.status);
      emit(OrderLoaded(orders));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }
}
