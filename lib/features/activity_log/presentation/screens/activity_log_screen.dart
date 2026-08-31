import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../data/local/entities/activity_log_entity.dart';
import '../bloc/activity_log_bloc.dart';
import '../widgets/activity_filter_chips.dart';
import '../widgets/activity_timeline_item.dart';

class ActivityLogScreen extends StatefulWidget {
  const ActivityLogScreen({super.key});

  @override
  State<ActivityLogScreen> createState() => _ActivityLogScreenState();
}

class _ActivityLogScreenState extends State<ActivityLogScreen> {
  ActivityType? _selectedType;

  @override
  void initState() {
    super.initState();
    context.read<ActivityLogBloc>().add(const LoadActivityLogs(limit: 100));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: AppSizes.spacingLg),
            ActivityFilterChips(
              selectedType: _selectedType,
              onTypeSelected: _onTypeFilterChanged,
            ),
            const SizedBox(height: AppSizes.spacingLg),
            Expanded(
              child: _buildActivityList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Activity Log',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.spacingSm),
            Text(
              'Track all system activities and changes',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              onPressed: () => _showClearLogsDialog(context),
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Clear Old Logs',
              style: IconButton.styleFrom(
                backgroundColor: Colors.red.withOpacity(0.1),
                foregroundColor: Colors.red,
              ),
            ),
            const SizedBox(width: AppSizes.spacingSm),
            IconButton(
              onPressed: () {
                context.read<ActivityLogBloc>().add(
                      LoadActivityLogs(limit: _selectedType == null ? 100 : null),
                    );
              },
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh',
              style: IconButton.styleFrom(
                backgroundColor: AppColors.primary.withOpacity(0.1),
                foregroundColor: AppColors.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActivityList() {
    return BlocBuilder<ActivityLogBloc, ActivityLogState>(
      builder: (context, state) {
        if (state is ActivityLogLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ActivityLogError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: AppSizes.spacingMd),
                Text('Error: ${state.message}'),
                const SizedBox(height: AppSizes.spacingMd),
                ElevatedButton(
                  onPressed: () {
                    context.read<ActivityLogBloc>().add(
                          const LoadActivityLogs(limit: 100),
                        );
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is ActivityLogLoaded) {
          final logs = state.logs;

          if (logs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: AppSizes.spacingMd),
                  Text(
                    'No activity logs found',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSizes.spacingSm),
                  Text(
                    'Activities will appear here as you use the system',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return _buildTimelineList(logs);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildTimelineList(List<ActivityLogEntity> logs) {
    // Group logs by date
    final groupedLogs = <String, List<ActivityLogEntity>>{};
    
    for (final log in logs) {
      final dateKey = DateFormat('yyyy-MM-dd').format(log.timestamp);
      if (!groupedLogs.containsKey(dateKey)) {
        groupedLogs[dateKey] = [];
      }
      groupedLogs[dateKey]!.add(log);
    }

    return ListView.builder(
      itemCount: groupedLogs.length,
      itemBuilder: (context, index) {
        final dateKey = groupedLogs.keys.elementAt(index);
        final logsForDate = groupedLogs[dateKey]!;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateHeader(dateKey),
            const SizedBox(height: AppSizes.spacingMd),
            ...logsForDate.asMap().entries.map((entry) {
              final isLast = entry.key == logsForDate.length - 1 &&
                  index == groupedLogs.length - 1;
              return ActivityTimelineItem(
                log: entry.value,
                isLast: isLast,
              );
            }),
            const SizedBox(height: AppSizes.spacingLg),
          ],
        );
      },
    );
  }

  Widget _buildDateHeader(String dateKey) {
    final date = DateTime.parse(dateKey);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    
    String displayText;
    if (date == today) {
      displayText = 'Today';
    } else if (date == yesterday) {
      displayText = 'Yesterday';
    } else {
      displayText = DateFormat('EEEE, MMMM d, y').format(date);
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingMd,
        vertical: AppSizes.paddingSm,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      ),
      child: Text(
        displayText,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  void _onTypeFilterChanged(ActivityType? type) {
    setState(() {
      _selectedType = type;
    });

    if (type == null) {
      context.read<ActivityLogBloc>().add(const LoadActivityLogs(limit: 100));
    } else {
      context.read<ActivityLogBloc>().add(LoadActivityLogsByType(type));
    }
  }

  void _showClearLogsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear Old Logs'),
        content: const Text(
          'This will delete all activity logs older than 30 days. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<ActivityLogBloc>().add(const ClearOldLogs());
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Old logs cleared successfully'),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
