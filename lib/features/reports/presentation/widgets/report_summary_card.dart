import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../data/daily_report_model.dart';

class ReportSummaryCard extends StatelessWidget {
  final DailyReportModel report;

  const ReportSummaryCard({
    super.key,
    required this.report,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Summary',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.spacingMd),
            _buildMetricRow(
              context,
              'Total Orders',
              report.totalOrders.toString(),
              Icons.receipt_long,
              AppColors.primary,
            ),
            const Divider(height: AppSizes.spacingMd),
            _buildMetricRow(
              context,
              'Completed Orders',
              report.completedOrders.toString(),
              Icons.check_circle,
              AppColors.success,
            ),
            const Divider(height: AppSizes.spacingMd),
            _buildMetricRow(
              context,
              'Cancelled Orders',
              report.cancelledOrders.toString(),
              Icons.cancel,
              AppColors.error,
            ),
            const Divider(height: AppSizes.spacingMd),
            _buildMetricRow(
              context,
              'Total Revenue',
              'Rp ${NumberFormat('#,###').format(report.totalRevenue)}',
              Icons.attach_money,
              AppColors.primary,
            ),
            const Divider(height: AppSizes.spacingMd),
            _buildMetricRow(
              context,
              'Total Tax',
              'Rp ${NumberFormat('#,###').format(report.totalTax)}',
              Icons.receipt,
              Colors.orange,
            ),
            const Divider(height: AppSizes.spacingMd),
            _buildMetricRow(
              context,
              'Avg Order Value',
              'Rp ${NumberFormat('#,###').format(report.averageOrderValue)}',
              Icons.trending_up,
              Colors.blue,
            ),
            const Divider(height: AppSizes.spacingMd),
            _buildMetricRow(
              context,
              'Completion Rate',
              '${report.completionRate.toStringAsFixed(1)}%',
              Icons.pie_chart,
              AppColors.success,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: AppSizes.spacingSm),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
