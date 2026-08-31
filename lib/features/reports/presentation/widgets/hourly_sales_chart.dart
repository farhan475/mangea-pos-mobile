import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../data/daily_report_model.dart';

class HourlySalesChart extends StatelessWidget {
  final List<HourlySalesModel> hourlySales;

  const HourlySalesChart({
    super.key,
    required this.hourlySales,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Find max revenue for scaling
    final maxRevenue = hourlySales
        .map((e) => e.revenue)
        .reduce((a, b) => a > b ? a : b);

    // Filter only hours with sales
    final activeSales = hourlySales.where((s) => s.orders > 0).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bar_chart, color: AppColors.primary),
                const SizedBox(width: AppSizes.spacingSm),
                Text(
                  'Hourly Sales',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.spacingMd),
            if (activeSales.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSizes.paddingMd),
                  child: Text('No sales data for today'),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: activeSales.length,
                itemBuilder: (context, index) {
                  final sale = activeSales[index];
                  final percentage = maxRevenue > 0 
                      ? (sale.revenue / maxRevenue) 
                      : 0.0;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.spacingSm),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${sale.hour.toString().padLeft(2, '0')}:00',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${sale.orders} orders • Rp ${NumberFormat('#,###').format(sale.revenue)}',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                          ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: percentage,
                            minHeight: 8,
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
