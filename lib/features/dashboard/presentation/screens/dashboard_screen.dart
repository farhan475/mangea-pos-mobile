import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../domain/models/order_model.dart';
import '../../data/dummy_dashboard_data.dart';
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

  List<OrderModel> get _filteredOrders {
    if (_searchQuery.isEmpty) return DummyDashboardData.orders;
    final query = _searchQuery.toLowerCase();
    return DummyDashboardData.orders
        .where(
          (o) =>
              o.customerName.toLowerCase().contains(query) ||
              o.tableCode.toLowerCase().contains(query),
        )
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
    final readyForPayment = DummyDashboardData.readyForPayment;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.paddingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Dashboard', style: theme.textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            'Ringkasan performa restoran hari ini',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: AppSizes.spacingLg),
          _buildMetrics(isTablet: isTablet),
          const SizedBox(height: AppSizes.spacingLg),
          if (isTablet)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: _buildOrderListColumn()),
                  const SizedBox(width: AppSizes.spacingLg),
                  Expanded(child: _buildPaymentColumn(readyForPayment)),
                  const SizedBox(width: AppSizes.spacingLg),
                  Expanded(child: _buildSidebarWidgetsColumn()),
                ],
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOrderListColumn(),
                const SizedBox(height: AppSizes.spacingLg),
                _buildPaymentColumn(readyForPayment),
                const SizedBox(height: AppSizes.spacingLg),
                _buildSidebarWidgetsColumn(),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildMetrics({required bool isTablet}) {
    final metrics = [
      MetricCard(
        icon: Icons.notifications_active_rounded,
        title: 'New Orders',
        value: '${DummyDashboardData.newOrdersCount}',
      ),
      MetricCard(
        icon: Icons.receipt_long_rounded,
        title: 'Total Orders',
        value: '${DummyDashboardData.totalOrdersToday}',
        subtitle:
            '+${DummyDashboardData.totalOrdersGrowthPercent.toStringAsFixed(1)}% vs kemarin',
      ),
      MetricCard(
        icon: Icons.hourglass_bottom_rounded,
        title: 'Waiting List',
        value: '${DummyDashboardData.waitingListCount}',
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

  Widget _buildOrderListColumn() {
    final orders = _filteredOrders;
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

  Widget _buildSidebarWidgetsColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PopularDishesWidget(dishes: DummyDashboardData.popularDishes),
        const SizedBox(height: AppSizes.spacingLg),
        OutOfStockWidget(alerts: DummyDashboardData.outOfStock),
      ],
    );
  }

  void _showPayNowDialog(OrderModel order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        title: const Text('Konfirmasi Pembayaran'),
        content: Text(
          'Proses pembayaran untuk ${order.customerName} (Meja ${order.tableCode})?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Konfirmasi'),
          ),
        ],
      ),
    );
  }
}
