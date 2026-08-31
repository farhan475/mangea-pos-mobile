part of 'order_bloc.dart';

abstract class OrderState extends Equatable {
  const OrderState();

  @override
  List<Object?> get props => [];
}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrderLoaded extends OrderState {
  final List<OrderEntity> orders;

  /// Marks when this state was emitted. Hive returns the same cached object
  /// instances for unchanged keys, so Equatable's deep comparison can't tell
  /// an updated order from the previous state — the timestamp forces a rebuild.
  final DateTime emittedAt;

  // Not const: each emission must capture a fresh timestamp so the UI
  // rebuilds even when Hive hands back the same cached entity instances.
  // ignore: prefer_const_constructors_in_immutables
  OrderLoaded(this.orders) : emittedAt = DateTime.now();

  @override
  List<Object?> get props => [orders, emittedAt];
}

class OrderError extends OrderState {
  final String message;

  const OrderError(this.message);

  @override
  List<Object?> get props => [message];
}
