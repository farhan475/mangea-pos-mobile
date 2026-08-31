import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../data/local/entities/order_entity.dart';
import '../../../../shared_widgets/app_card.dart';
import 'receipt_preview_dialog.dart';

class OrderDetailCard extends StatelessWidget {
  final OrderEntity order;
  final VoidCallback onTap;
  final Function(OrderStatusEntity) onStatusChange;
  final VoidCallback onDelete;

  const OrderDetailCard({
    super.key,
    required this.order,
    required this.onTap,
    required this.onStatusChange,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AppCard(
      onTap: onTap,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Table ${order.tableNumber ?? 'N/A'}',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSizes.spacingXs),
                        Text(
                          order.customerName ?? 'Walk-in Customer',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(),
                ],
              ),
              const SizedBox(height: AppSizes.spacingMd),
              Divider(color: Colors.grey[300], height: 1),
              const SizedBox(height: AppSizes.spacingMd),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Items',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${order.items.length} items',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Total',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Rp ${order.totalAmount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      context,
                      icon: Icons.arrow_forward,
                      label: _getNextStatusLabel(),
                      onPressed: () => onStatusChange(_getNextStatus()),
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppSizes.spacingSm),
                  if (order.status == OrderStatusEntity.paid)
                    IconButton(
                      onPressed: () => _showReceiptPreview(context),
                      icon: const Icon(Icons.print),
                      color: AppColors.primary,
                      tooltip: 'Cetak Struk',
                    ),
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline),
                    color: Colors.red,
                    tooltip: 'Delete order',
                  ),
                ],
              ),
            ],
          ),
          if (order.syncStatus == SyncStatus.pending)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.cloud_upload, size: 12, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'Pending Sync',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color backgroundColor;
    Color textColor = Colors.white;
    
    switch (order.status) {
      case OrderStatusEntity.pending:
        backgroundColor = Colors.orange;
        break;
      case OrderStatusEntity.cooking:
        backgroundColor = Colors.amber;
        textColor = Colors.black87;
        break;
      case OrderStatusEntity.ready:
        backgroundColor = AppColors.statusReady;
        break;
      case OrderStatusEntity.paid:
        backgroundColor = Colors.blue;
        break;
      case OrderStatusEntity.cancelled:
        backgroundColor = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        order.status.name.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  String _getNextStatusLabel() {
    switch (order.status) {
      case OrderStatusEntity.pending:
        return 'Start Cooking';
      case OrderStatusEntity.cooking:
        return 'Mark Ready';
      case OrderStatusEntity.ready:
        return 'Mark Paid';
      case OrderStatusEntity.paid:
        return 'Completed';
      case OrderStatusEntity.cancelled:
        return 'Cancelled';
    }
  }

  OrderStatusEntity _getNextStatus() {
    switch (order.status) {
      case OrderStatusEntity.pending:
        return OrderStatusEntity.cooking;
      case OrderStatusEntity.cooking:
        return OrderStatusEntity.ready;
      case OrderStatusEntity.ready:
        return OrderStatusEntity.paid;
      case OrderStatusEntity.paid:
      case OrderStatusEntity.cancelled:
        return order.status;
    }
  }

  void _showReceiptPreview(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => ReceiptPreviewDialog(
        order: order,
        items: order.items,
      ),
    );
  }
}
