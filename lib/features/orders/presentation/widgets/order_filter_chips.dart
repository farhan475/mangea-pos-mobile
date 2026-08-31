import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../data/local/entities/order_entity.dart';

class OrderFilterChips extends StatelessWidget {
  final OrderStatusEntity? selectedStatus;
  final Function(OrderStatusEntity?) onStatusSelected;

  const OrderFilterChips({
    super.key,
    required this.selectedStatus,
    required this.onStatusSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip(
            context,
            label: 'All Orders',
            isSelected: selectedStatus == null,
            onTap: () => onStatusSelected(null),
          ),
          const SizedBox(width: AppSizes.spacingSm),
          _buildFilterChip(
            context,
            label: 'Pending',
            isSelected: selectedStatus == OrderStatusEntity.pending,
            onTap: () => onStatusSelected(OrderStatusEntity.pending),
            color: Colors.orange,
          ),
          const SizedBox(width: AppSizes.spacingSm),
          _buildFilterChip(
            context,
            label: 'Cooking',
            isSelected: selectedStatus == OrderStatusEntity.cooking,
            onTap: () => onStatusSelected(OrderStatusEntity.cooking),
            color: Colors.amber,
          ),
          const SizedBox(width: AppSizes.spacingSm),
          _buildFilterChip(
            context,
            label: 'Ready',
            isSelected: selectedStatus == OrderStatusEntity.ready,
            onTap: () => onStatusSelected(OrderStatusEntity.ready),
            color: AppColors.statusReady,
          ),
          const SizedBox(width: AppSizes.spacingSm),
          _buildFilterChip(
            context,
            label: 'Paid',
            isSelected: selectedStatus == OrderStatusEntity.paid,
            onTap: () => onStatusSelected(OrderStatusEntity.paid),
            color: Colors.blue,
          ),
          const SizedBox(width: AppSizes.spacingSm),
          _buildFilterChip(
            context,
            label: 'Cancelled',
            isSelected: selectedStatus == OrderStatusEntity.cancelled,
            onTap: () => onStatusSelected(OrderStatusEntity.cancelled),
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingMd,
          vertical: AppSizes.paddingSm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? (color ?? AppColors.primary)
              : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
