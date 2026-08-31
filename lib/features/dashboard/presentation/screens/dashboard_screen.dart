import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../data/local/entities/order_entity.dart';
import '../../../../data/local/entities/product_entity.dart';
import '../../../../domain/models/order_model.dart';
import '../../../../domain/models/popular_dish_model.dart';
import '../../../../domain/models/stock_alert_model.dart';
import '../../../pos/presentation/bloc/product_bloc.dart';
import '../bloc/order_bloc.dart';
import '../widgets/metric_card.dart';
import '../widgets/order_card.dart';
import '../widgets/out_of_stock_widget.dart';
import '../widgets/payment_card.dart';
import '../widgets/popular_dishes_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _searchQuery = '';

  /// Maps OrderEntity to the UI-facing OrderModel.
  OrderModel _toOrderModel(OrderEntity order) {
    final OrderStatus status;
    switch (order.status) {
      case OrderStatusEntity.pending:
      case OrderStatusEntity.cooking:
        status = OrderStatus.inProgress;
        break;
      case OrderStatusEntity.ready:
        status = OrderStatus.ready;
        break;
      case OrderStatusEntity.paid:
      case OrderStatusEntity.cancelled:
        status = OrderStatus.completed;
        break;
    }

    return OrderModel(
      id: order.id,
      tableCode: order.tableNumber ?? '-',
      customerName: order.customerName ?? 'Walk-in',
      itemCount: order.items.fold(0, (sum, item) => sum + item.quantity),
      status: status,
      totalAmount: order.totalAmount,
      createdAt: order.createdAt,
    );
  }

  /// Orders that are ready to be paid (status == ready).
  List<OrderModel> _readyForPaymentFrom(List<OrderEntity> orders) {
    return orders
        .where((o) => o.status == OrderStatusEntity.ready)
        .map(_toOrderModel)
        .toList();
  }

  /// Popular dishes computed from today's paid orders (top 5 by quantity).
  List<PopularDishModel> _computePopularDishes(List<OrderEntity> orders) {
    final sales = <String, ({String name, int qty})>{};
    for (final order in orders) {
      if (order.status != OrderStatusEntity.paid) continue;
      for (final item in order.items) {
        final existing = sales[item.productId];
        sales[item.productId] = (
          name: item.productName,
          qty: (existing?.qty ?? 0) + item.quantity,
        );
      }
    }

    final ranked = sales.entries.toList()
      ..sort((a, b) => b.value.qty.compareTo(a.value.qty));

    return ranked
        .take(5)
        .map((e) => PopularDishModel(
              id: e.key,
              name: e.value.name,
              soldCount: e.value.qty,
            ))
        .toList();
  }

  /// Out-of-stock / low-stock alerts from the real product data.
  List<StockAlertModel> _computeStockAlerts(List<ProductEntity> products) {
    return products
        .where((p) => p.stock <= p.lowStockThreshold)
        .map((p) => StockAlertModel(
              id: p.id,
              productName: p.name,
              availabilityNote: p.stock == 0
                  ? 'Stok habis'
                  : 'Stok menipis: ${p.stock} tersisa',
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth >= AppSizes.tabletBreakpoint;
        return _buildContent(context, isTablet: isTablet);
      },
    );
  }

  Widget _buildContent(BuildContext context, {required bool isTablet}) {
    final theme = Theme.of(context);

    return BlocBuilder<OrderBloc, OrderState>(
      builder: (context, orderState) {
        final orders = orderState is OrderLoaded
            ? orderState.orders
            : const <OrderEntity>[];

        final filteredOrders = _filteredOrders(orders);
        final readyForPayment = _readyForPaymentFrom(orders);

        final newOrdersCount =
            orders.where((o) => o.status == OrderStatusEntity.pending).length;
        final totalOrders = orders.length;
        final waitingListCount = orders
            .where((o) =>
                o.status == OrderStatusEntity.cooking ||
                o.status == OrderStatusEntity.ready)
            .length;
        final revenue = orders
            .where((o) => o.status == OrderStatusEntity.paid)
            .fold(0.0, (sum, o) => sum + o.totalAmount);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Dashboard', style: theme.textTheme.titleLarge),
                      const SizedBox(height: 4),
                      Text(
                        'Ringkasan performa restoran hari ini',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                  IconButton(
                    tooltip: 'Refresh',
                    onPressed: () =>
                        context.read<OrderBloc>().add(LoadTodayOrders()),
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.spacingLg),
              _buildMetrics(
                isTablet: isTablet,
                newOrdersCount: newOrdersCount,
                totalOrders: totalOrders,
                waitingListCount: waitingListCount,
                revenue: revenue,
              ),
              const SizedBox(height: AppSizes.spacingLg),
              if (orderState is OrderLoading)
                const Center(child: CircularProgressIndicator())
              else if (orderState is OrderError)
                Center(
                  child: Text(
                    orderState.message,
                    style: const TextStyle(color: AppColors.error),
                  ),
                ),
              if (isTablet)
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 2, child: _buildOrderListColumn(filteredOrders)),
                      const SizedBox(width: AppSizes.spacingLg),
                      Expanded(child: _buildPaymentColumn(readyForPayment)),
                      const SizedBox(width: AppSizes.spacingLg),
                      Expanded(child: _buildSidebarWidgetsColumn(orders)),
                    ],
                  ),
                )
              else ...[
                _buildOrderListColumn(filteredOrders),
                const SizedBox(height: AppSizes.spacingLg),
                _buildPaymentColumn(readyForPayment),
                const SizedBox(height: AppSizes.spacingLg),
                _buildSidebarWidgetsColumn(orders),
              ],
            ],
          ),
        );
      },
    );
  }

  List<OrderModel> _filteredOrders(List<OrderEntity> orders) {
    var models = orders.map(_toOrderModel).toList();
    if (_searchQuery.isEmpty) return models;
    final query = _searchQuery.toLowerCase();
    return models
        .where(
          (o) =>
              o.customerName.toLowerCase().contains(query) ||
              o.tableCode.toLowerCase().contains(query),
        )
        .toList();
  }

  Widget _buildMetrics({
    required bool isTablet,
    required int newOrdersCount,
    required int totalOrders,
    required int waitingListCount,
    required double revenue,
  }) {
    final metrics = [
      MetricCard(
        icon: Icons.notifications_active_rounded,
        title: 'New Orders',
        value: '$newOrdersCount',
      ),
      MetricCard(
        icon: Icons.receipt_long_rounded,
        title: 'Total Orders',
        value: '$totalOrders',
      ),
      MetricCard(
        icon: Icons.payments_rounded,
        title: 'Revenue',
        value: formatRupiah(revenue),
      ),
      MetricCard(
        icon: Icons.hourglass_bottom_rounded,
        title: 'Waiting List',
        value: '$waitingListCount',
      ),
    ];

    if (isTablet) {
      return Row(
        children: [
          for (var i = 0; i < metrics.length; i++) ...[
            if (i > 0) const SizedBox(width: AppSizes.spacingMd),
            Expanded(child: metrics[i]),
          ],
        ],
      );
    }

    return Column(
      children: [
        for (var i = 0; i < metrics.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSizes.spacingMd),
          metrics[i],
        ],
      ],
    );
  }

  Widget _buildOrderListColumn(List<OrderModel> orders) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Order List', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSizes.spacingSm),
        TextField(
          onChanged: (value) => setState(() => _searchQuery = value),
          decoration: const InputDecoration(
            hintText: 'Cari nama pelanggan atau nomor meja',
            prefixIcon: Icon(Icons.search_rounded, color: AppColors.textSecondary),
          ),
        ),
        const SizedBox(height: AppSizes.spacingMd),
        if (orders.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingLg),
            child: Text(
              'Tidak ada pesanan ditemukan.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          )
        else
          for (var i = 0; i < orders.length; i++)
            Padding(
              padding: EdgeInsets.only(
                bottom: i == orders.length - 1 ? 0 : AppSizes.spacingMd,
              ),
              child: OrderCard(order: orders[i]),
            ),
      ],
    );
  }

  Widget _buildPaymentColumn(List<OrderModel> readyForPayment) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Payment', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSizes.spacingMd),
        if (readyForPayment.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingLg),
            child: Text(
              'Belum ada pesanan yang siap dibayar.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          )
        else
          for (var i = 0; i < readyForPayment.length; i++)
            Padding(
              padding: EdgeInsets.only(
                bottom: i == readyForPayment.length - 1 ? 0 : AppSizes.spacingMd,
              ),
              child: PaymentCard(
                order: readyForPayment[i],
                onPayNow: () => _showPayNowDialog(readyForPayment[i]),
              ),
            ),
      ],
    );
  }

  Widget _buildSidebarWidgetsColumn(List<OrderEntity> orders) {
    final productState = context.watch<ProductBloc>().state;
    final products = productState is ProductLoaded
        ? productState.products
        : const <ProductEntity>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PopularDishesWidget(dishes: _computePopularDishes(orders)),
        const SizedBox(height: AppSizes.spacingLg),
        OutOfStockWidget(alerts: _computeStockAlerts(products)),
      ],
    );
  }

  void _showPayNowDialog(OrderModel order) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        title: const Text('Konfirmasi Pembayaran'),
        content: Text(
          'Proses pembayaran untuk ${order.customerName} (Meja ${order.tableCode}) sebesar ${formatRupiah(order.totalAmount)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              // Mark the order as paid through the OrderBloc
              final state = context.read<OrderBloc>().state;
              if (state is OrderLoaded) {
                final entity = state.orders.firstWhere(
                  (o) => o.id == order.id,
                );
                final paid = entity.copyWith(
                  status: OrderStatusEntity.paid,
                  paymentMethod: entity.paymentMethod ?? PaymentMethod.cash,
                  paidAmount: entity.paidAmount ?? entity.totalAmount,
                  changeAmount: entity.changeAmount ?? 0,
                  updatedAt: DateTime.now(),
                );
                context.read<OrderBloc>().add(UpdateOrder(paid));
              }
              Navigator.pop(dialogContext);
            },
            child: const Text('Konfirmasi'),
          ),
        ],
      ),
    );
  }
}
