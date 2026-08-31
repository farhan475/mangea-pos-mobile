import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../domain/models/menu_product_model.dart';
import '../../../../shared_widgets/app_card.dart';

class MenuProductCard extends StatelessWidget {
  const MenuProductCard({super.key, required this.product, this.onTap});

  final MenuProductModel product;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAvailable = product.isAvailable;

    return Opacity(
      opacity: isAvailable ? 1 : 0.5,
      child: InkWell(
        onTap: isAvailable ? onTap : null,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: AppCard(
          padding: const EdgeInsets.all(AppSizes.paddingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                child: Icon(product.icon, color: AppColors.primary),
              ),
              const SizedBox(height: AppSizes.spacingSm),
              Text(
                product.name,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                isAvailable ? formatRupiah(product.price) : 'Stok habis',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isAvailable
                      ? AppColors.primary
                      : AppColors.danger,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
