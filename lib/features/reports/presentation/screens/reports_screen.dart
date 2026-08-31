import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../data/daily_report_model.dart';
import '../bloc/report_bloc.dart';
import '../bloc/report_event.dart';
import '../bloc/report_state.dart';
import '../widgets/report_summary_card.dart';
import '../widgets/top_products_card.dart';
import '../widgets/hourly_sales_chart.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  void _loadReport() {
    context.read<ReportBloc>().add(LoadDailyReport(_selectedDate));
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadReport();
    }
  }

  void _exportCSV(DailyReportModel report) {
    context.read<ReportBloc>().add(ExportReportToCSV(report));
  }

  void _exportPDF(DailyReportModel report) {
    context.read<ReportBloc>().add(ExportReportToPDF(report));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _selectDate,
            tooltip: 'Select Date',
          ),
        ],
      ),
      body: BlocConsumer<ReportBloc, ReportState>(
        listener: (context, state) {
          if (state is ReportExported) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${state.fileType} exported successfully!'),
                backgroundColor: AppColors.success,
                action: SnackBarAction(
                  label: 'View',
                  textColor: Colors.white,
                  onPressed: () {
                    // Open file
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('File saved to: ${state.filePath}'),
                      ),
                    );
                  },
                ),
              ),
            );
            // Reload report after export
            _loadReport();
          } else if (state is ReportError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ReportLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ReportError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                  const SizedBox(height: AppSizes.spacingMd),
                  Text(
                    'Error loading report',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSizes.spacingSm),
                  Text(state.message),
                  const SizedBox(height: AppSizes.spacingMd),
                  ElevatedButton(
                    onPressed: _loadReport,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is! ReportLoaded) {
            return const Center(child: Text('No report loaded'));
          }

          final report = state.report;

          return RefreshIndicator(
            onRefresh: () async => _loadReport(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSizes.paddingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date selector
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.date_range),
                      title: Text(
                        DateFormat('EEEE, dd MMMM yyyy').format(_selectedDate),
                        style: theme.textTheme.titleMedium,
                      ),
                      trailing: const Icon(Icons.arrow_drop_down),
                      onTap: _selectDate,
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacingMd),

                  // Export buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _exportCSV(report),
                          icon: const Icon(Icons.table_chart),
                          label: const Text('Export CSV'),
                        ),
                      ),
                      const SizedBox(width: AppSizes.spacingSm),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _exportPDF(report),
                          icon: const Icon(Icons.picture_as_pdf),
                          label: const Text('Export PDF'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.spacingMd),

                  // Summary
                  ReportSummaryCard(report: report),
                  const SizedBox(height: AppSizes.spacingMd),

                  // Top Products
                  TopProductsCard(products: report.topProducts),
                  const SizedBox(height: AppSizes.spacingMd),

                  // Hourly Sales Chart
                  HourlySalesChart(hourlySales: report.hourlySales),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
