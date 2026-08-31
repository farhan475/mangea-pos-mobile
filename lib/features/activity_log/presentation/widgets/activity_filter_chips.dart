import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../data/local/entities/activity_log_entity.dart';

class ActivityFilterChips extends StatelessWidget {
  final ActivityType? selectedType;
  final Function(ActivityType?) onTypeSelected;

  const ActivityFilterChips({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip(
            label: 'All',
            icon: Icons.all_inclusive,
            isSelected: selectedType == null,
            onTap: () => onTypeSelected(null),
          ),
          const SizedBox(width: AppSizes.spacingSm),
          ...ActivityType.values.map((type) {
            return Padding(
              padding: const EdgeInsets.only(right: AppSizes.spacingSm),
              child: _buildFilterChip(
                label: type.displayName,
                icon: _getIconForType(type),
                isSelected: selectedType == type,
                onTap: () => onTypeSelected(type),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingMd,
          vertical: AppSizes.paddingSm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.grey[200],
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : Colors.grey[700],
            ),
            const SizedBox(width: AppSizes.spacingXs),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForType(ActivityType type) {
    switch (type) {
      case ActivityType.order:
        return Icons.shopping_bag;
      case ActivityType.table:
        return Icons.table_restaurant;
      case ActivityType.product:
        return Icons.fastfood;
      case ActivityType.payment:
        return Icons.payment;
      case ActivityType.system:
        return Icons.settings;
      case ActivityType.user:
        return Icons.person;
    }
  }
}
