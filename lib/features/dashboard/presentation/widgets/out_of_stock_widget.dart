import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../domain/models/stock_alert_model.dart';
import '../../../../shared_widgets/app_card.dart';

class OutOfStockWidget extends StatelessWidget {
  const OutOfStockWidget({super.key, required this.alerts});

  final List<StockAlertModel> alerts;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Out of Stock', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSizes.spacingMd),
          for (var i = 0; i < alerts.length; i++)
            Padding(
              padding: EdgeInsets.only(
                bottom: i == alerts.length - 1 ? 0 : AppSizes.spacingSm,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    size: 18,
                    color: AppColors.danger,
                  ),
                  const SizedBox(width: AppSizes.spacingSm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          alerts[i].productName,
                          style: theme.textTheme.bodyMedium,
                        ),
                        Text(
                          alerts[i].availabilityNote,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
