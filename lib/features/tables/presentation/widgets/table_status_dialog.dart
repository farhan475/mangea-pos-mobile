import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../data/local/entities/table_entity.dart';
import '../bloc/table_bloc.dart';

class TableStatusDialog extends StatelessWidget {
  final TableEntity table;

  const TableStatusDialog({
    super.key,
    required this.table,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.table_restaurant, color: AppColors.primary),
          const SizedBox(width: AppSizes.spacingSm),
          Text('Update Table ${table.tableNumber}'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select new status:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: AppSizes.spacingMd),
          _StatusOption(
            status: TableStatus.available,
            currentStatus: table.status,
            icon: Icons.check_circle,
            color: AppColors.statusReady,
            label: 'Available',
            description: 'Table is ready for new customers',
            onTap: () => _updateStatus(context, TableStatus.available),
          ),
          const SizedBox(height: AppSizes.spacingSm),
          _StatusOption(
            status: TableStatus.occupied,
            currentStatus: table.status,
            icon: Icons.people,
            color: Colors.red,
            label: 'Occupied',
            description: 'Customers are currently seated',
            onTap: () => _updateStatus(context, TableStatus.occupied),
          ),
          const SizedBox(height: AppSizes.spacingSm),
          _StatusOption(
            status: TableStatus.reserved,
            currentStatus: table.status,
            icon: Icons.event,
            color: Colors.orange,
            label: 'Reserved',
            description: 'Table is reserved for later',
            onTap: () => _updateStatus(context, TableStatus.reserved),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  void _updateStatus(BuildContext context, TableStatus newStatus) {
    context.read<TableBloc>().add(UpdateTableStatus(table.id, newStatus));
    Navigator.pop(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Table ${table.tableNumber} status updated to ${newStatus.name}'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _StatusOption extends StatelessWidget {
  final TableStatus status;
  final TableStatus currentStatus;
  final IconData icon;
  final Color color;
  final String label;
  final String description;
  final VoidCallback onTap;

  const _StatusOption({
    required this.status,
    required this.currentStatus,
    required this.icon,
    required this.color,
    required this.label,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = status == currentStatus;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.paddingMd),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: AppSizes.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isSelected ? color : Colors.black87,
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 8),
                        Icon(Icons.check, color: color, size: 16),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
