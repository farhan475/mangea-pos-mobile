import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../data/local/entities/order_entity.dart';
import '../../../dashboard/presentation/bloc/order_bloc.dart';
import '../../../pos/presentation/bloc/product_bloc.dart';
import '../widgets/create_order_dialog.dart';
import '../widgets/order_detail_card.dart';
import '../widgets/order_filter_chips.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  OrderStatusEntity? _selectedStatus;

  @override
  void initState() {
    super.initState();
    context.read<OrderBloc>().add(LoadTodayOrders());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: AppSizes.spacingLg),
            OrderFilterChips(
              selectedStatus: _selectedStatus,
              onStatusSelected: _onStatusFilterChanged,
            ),
            const SizedBox(height: AppSizes.spacingLg),
            Expanded(
              child: _buildOrdersList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Orders Management',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.spacingSm),
            Text(
              'Manage and track all orders',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () => _showCreateOrderDialog(context),
          icon: const Icon(Icons.add),
          label: const Text('New Order'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingLg,
              vertical: AppSizes.paddingMd,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrdersList() {
    return BlocBuilder<OrderBloc, OrderState>(
      builder: (context, state) {
        if (state is OrderLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is OrderError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: AppSizes.spacingMd),
                Text('Error: ${state.message}'),
                const SizedBox(height: AppSizes.spacingMd),
                ElevatedButton(
                  onPressed: () {
                    context.read<OrderBloc>().add(LoadTodayOrders());
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is OrderLoaded) {
          final orders = state.orders;

          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: AppSizes.spacingMd),
                  Text(
                    'No orders found',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSizes.spacingSm),
                  Text(
                    'Create a new order to get started',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 400,
              childAspectRatio: 1.5,
              crossAxisSpacing: AppSizes.spacingMd,
              mainAxisSpacing: AppSizes.spacingMd,
            ),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return OrderDetailCard(
                order: order,
                onTap: () => _showOrderDetailDialog(context, order),
                onStatusChange: (newStatus) =>
                    _updateOrderStatus(context, order, newStatus),
                onDelete: () => _deleteOrder(context, order),
              );
            },
          );
        }

        return const Center(child: Text('No data'));
      },
    );
  }

  void _onStatusFilterChanged(OrderStatusEntity? status) {
    setState(() {
      _selectedStatus = status;
    });

    if (status == null) {
      context.read<OrderBloc>().add(LoadTodayOrders());
    } else {
      context.read<OrderBloc>().add(LoadOrdersByStatus(status));
    }
  }

  void _showCreateOrderDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<OrderBloc>()),
          BlocProvider.value(value: context.read<ProductBloc>()),
        ],
        child: const CreateOrderDialog(),
      ),
    );
  }

  void _showOrderDetailDialog(BuildContext context, OrderEntity order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Order ${order.tableNumber ?? order.id}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Customer', order.customerName ?? 'N/A'),
              _buildDetailRow('Table', order.tableNumber ?? 'N/A'),
              _buildDetailRow('Status', order.status.name),
              _buildDetailRow(
                'Total',
                'Rp ${order.totalAmount.toStringAsFixed(0)}',
              ),
              _buildDetailRow(
                'Created',
                '${order.createdAt.hour}:${order.createdAt.minute.toString().padLeft(2, '0')}',
              ),
              const SizedBox(height: AppSizes.spacingMd),
              const Text(
                'Items:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSizes.spacingSm),
              ...order.items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.spacingXs),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text('${item.quantity}x ${item.productName}'),
                        ),
                        Text('Rp ${item.subtotal.toStringAsFixed(0)}'),
                      ],
                    ),
                  )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spacingSm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(value),
        ],
      ),
    );
  }

  void _updateOrderStatus(
    BuildContext context,
    OrderEntity order,
    OrderStatusEntity newStatus,
  ) {
    order.status = newStatus;
    order.updatedAt = DateTime.now();
    context.read<OrderBloc>().add(UpdateOrder(order));
  }

  void _deleteOrder(BuildContext context, OrderEntity order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Order'),
        content: const Text('Are you sure you want to delete this order?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<OrderBloc>().add(DeleteOrder(order.id));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
