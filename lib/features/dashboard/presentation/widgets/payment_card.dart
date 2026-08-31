import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../domain/models/order_model.dart';
import '../../../../shared_widgets/app_card.dart';

class PaymentCard extends StatelessWidget {
  const PaymentCard({super.key, required this.order, this.onPayNow});

  final OrderModel order;
  final VoidCallback? onPayNow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Meja ${order.tableCode}',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      order.customerName,
                      style: theme.textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
              Text(
                formatRupiah(order.totalAmount),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacingMd),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onPayNow,
              child: const Text('Pay Now'),
            ),
          ),
        ],
      ),
    );
  }
}
