import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../data/local/entities/activity_log_entity.dart';

class ActivityTimelineItem extends StatelessWidget {
  final ActivityLogEntity log;
  final bool isLast;

  const ActivityTimelineItem({
    super.key,
    required this.log,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTimeline(),
          const SizedBox(width: AppSizes.spacingMd),
          Expanded(
            child: _buildContent(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getColorForType().withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(
              color: _getColorForType(),
              width: 2,
            ),
          ),
          child: Icon(
            _getIconForType(),
            size: 20,
            color: _getColorForType(),
          ),
        ),
        if (!isLast)
          Expanded(
            child: Container(
              width: 2,
              margin: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[300],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.spacingMd),
      padding: const EdgeInsets.all(AppSizes.paddingMd),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getColorForType().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  log.type.displayName,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: _getColorForType(),
                  ),
                ),
              ),
              const Spacer(),
              Text(
                DateFormat('HH:mm').format(log.timestamp),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacingSm),
          Text(
            log.action,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            log.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[700],
            ),
          ),
          if (log.metadata != null && log.metadata!.isNotEmpty) ...[
            const SizedBox(height: AppSizes.spacingSm),
            _buildMetadata(),
          ],
        ],
      ),
    );
  }

  Widget _buildMetadata() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingSm),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: log.metadata!.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Row(
              children: [
                Text(
                  '${entry.key}: ',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  entry.value.toString(),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Color _getColorForType() {
    switch (log.type) {
      case ActivityType.order:
        return AppColors.primary;
      case ActivityType.table:
        return Colors.purple;
      case ActivityType.product:
        return Colors.orange;
      case ActivityType.payment:
        return Colors.green;
      case ActivityType.system:
        return Colors.blue;
      case ActivityType.user:
        return Colors.pink;
    }
  }

  IconData _getIconForType() {
    switch (log.type) {
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
