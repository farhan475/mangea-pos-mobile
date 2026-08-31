import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../domain/models/cart_item_model.dart';
import '../../../../shared_widgets/app_card.dart';
import 'cart_item_tile.dart';

class CartPanel extends StatelessWidget {
  const CartPanel({
    super.key,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.onIncrement,
    required this.onDecrement,
    required this.onCheckout,
  });

  final List<CartItemModel> items;
  final double subtotal;
  final double tax;
  final double total;
  final ValueChanged<String> onIncrement;
  final ValueChanged<String> onDecrement;
  final VoidCallback? onCheckout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Keranjang', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSizes.spacingMd),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingLg),
              child: Text(
                'Belum ada item dipilih.',
                style: theme.textTheme.bodySmall,
              ),
            )
          else
            Column(
              children: [
                for (final item in items)
                  CartItemTile(
                    item: item,
                    onIncrement: () => onIncrement(item.product.id),
                    onDecrement: () => onDecrement(item.product.id),
                  ),
              ],
            ),
          const Divider(height: AppSizes.spacingLg),
          _SummaryRow(label: 'Subtotal', value: subtotal),
          const SizedBox(height: 4),
          _SummaryRow(label: 'Pajak (10%)', value: tax),
          const SizedBox(height: 8),
          _SummaryRow(label: 'Total', value: total, isBold: true),
          const SizedBox(height: AppSizes.spacingMd),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: items.isEmpty ? null : onCheckout,
              child: const Text('Checkout'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  final String label;
  final double value;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    final style = isBold
        ? Theme.of(context).textTheme.titleMedium
        : Theme.of(context).textTheme.bodySmall;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isBold
              ? style
              : style?.copyWith(color: AppColors.textSecondary),
        ),
        Text(formatRupiah(value), style: style),
      ],
    );
  }
}
