import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../domain/models/popular_dish_model.dart';
import '../../../../shared_widgets/app_card.dart';

class PopularDishesWidget extends StatelessWidget {
  const PopularDishesWidget({super.key, required this.dishes});

  final List<PopularDishModel> dishes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Popular Dishes', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSizes.spacingMd),
          for (var i = 0; i < dishes.length; i++)
            Padding(
              padding: EdgeInsets.only(
                bottom: i == dishes.length - 1 ? 0 : AppSizes.spacingSm,
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${i + 1}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: AppSizes.spacingSm),
                  Expanded(
                    child: Text(
                      dishes[i].name,
                      style: theme.textTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${dishes[i].soldCount} terjual',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
