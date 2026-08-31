import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../data/local/entities/table_entity.dart';
import '../../../../shared_widgets/app_card.dart';
import 'table_status_dialog.dart';

class TableCard extends StatelessWidget {
  final TableEntity table;
  final VoidCallback onTap;
  final Function(TableStatus) onStatusChange;

  const TableCard({
    super.key,
    required this.table,
    required this.onTap,
    required this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AppCard(
      onTap: onTap,
      color: _getBackgroundColor(),
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.table_restaurant,
                size: 48,
                color: _getIconColor(),
              ),
              const SizedBox(height: AppSizes.spacingSm),
              Text(
                table.tableNumber,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _getTextColor(),
                ),
              ),
              const SizedBox(height: AppSizes.spacingXs),
              Text(
                '${table.capacity} people',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: _getTextColor().withOpacity(0.8),
                ),
              ),
              const SizedBox(height: AppSizes.spacingSm),
              _buildStatusBadge(),
            ],
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              onPressed: () => _showStatusDialog(context),
              icon: const Icon(Icons.more_vert),
              iconSize: 20,
              color: _getTextColor(),
              tooltip: 'Change Status',
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.8),
                padding: const EdgeInsets.all(4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: _getStatusColor(),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        table.status.name.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showStatusDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => TableStatusDialog(table: table),
    );
  }

  Color _getBackgroundColor() {
    switch (table.status) {
      case TableStatus.available:
        return Colors.white;
      case TableStatus.occupied:
        return Colors.red[50]!;
      case TableStatus.reserved:
        return Colors.orange[50]!;
    }
  }

  Color _getIconColor() {
    switch (table.status) {
      case TableStatus.available:
        return AppColors.statusReady;
      case TableStatus.occupied:
        return Colors.red;
      case TableStatus.reserved:
        return Colors.orange;
    }
  }

  Color _getTextColor() {
    switch (table.status) {
      case TableStatus.available:
        return Colors.black87;
      case TableStatus.occupied:
        return Colors.red[900]!;
      case TableStatus.reserved:
        return Colors.orange[900]!;
    }
  }

  Color _getStatusColor() {
    switch (table.status) {
      case TableStatus.available:
        return AppColors.statusReady;
      case TableStatus.occupied:
        return Colors.red;
      case TableStatus.reserved:
        return Colors.orange;
    }
  }
}
