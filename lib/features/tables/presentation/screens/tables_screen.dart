import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../data/local/entities/table_entity.dart';
import '../bloc/table_bloc.dart';
import '../widgets/table_card.dart';
import '../widgets/table_form_dialog.dart';

class TablesScreen extends StatefulWidget {
  const TablesScreen({super.key});

  @override
  State<TablesScreen> createState() => _TablesScreenState();
}

class _TablesScreenState extends State<TablesScreen> {
  TableStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    context.read<TableBloc>().add(LoadTables());
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
            _buildFilterChips(),
            const SizedBox(height: AppSizes.spacingLg),
            Expanded(
              child: _buildTablesList(),
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
              'Table Management',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.spacingSm),
            Text(
              'Manage restaurant tables and seating',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () => _showAddTableDialog(context),
          icon: const Icon(Icons.add),
          label: const Text('Add Table'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingLg,
              vertical: AppSizes.paddingMd,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip(
            label: 'All Tables',
            isSelected: _selectedStatus == null,
            onTap: () {
              setState(() => _selectedStatus = null);
              context.read<TableBloc>().add(LoadTables());
            },
          ),
          const SizedBox(width: AppSizes.spacingSm),
          _buildFilterChip(
            label: 'Available',
            isSelected: _selectedStatus == TableStatus.available,
            onTap: () {
              setState(() => _selectedStatus = TableStatus.available);
              context.read<TableBloc>().add(
                    const LoadTablesByStatus(TableStatus.available),
                  );
            },
            color: AppColors.statusReady,
          ),
          const SizedBox(width: AppSizes.spacingSm),
          _buildFilterChip(
            label: 'Occupied',
            isSelected: _selectedStatus == TableStatus.occupied,
            onTap: () {
              setState(() => _selectedStatus = TableStatus.occupied);
              context.read<TableBloc>().add(
                    const LoadTablesByStatus(TableStatus.occupied),
                  );
            },
            color: Colors.red,
          ),
          const SizedBox(width: AppSizes.spacingSm),
          _buildFilterChip(
            label: 'Reserved',
            isSelected: _selectedStatus == TableStatus.reserved,
            onTap: () {
              setState(() => _selectedStatus = TableStatus.reserved);
              context.read<TableBloc>().add(
                    const LoadTablesByStatus(TableStatus.reserved),
                  );
            },
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingMd,
          vertical: AppSizes.paddingSm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? (color ?? AppColors.primary) : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildTablesList() {
    return BlocBuilder<TableBloc, TableState>(
      builder: (context, state) {
        if (state is TableLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is TableError) {
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
                    context.read<TableBloc>().add(LoadTables());
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is TableLoaded) {
          final tables = state.tables;

          if (tables.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.table_restaurant_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: AppSizes.spacingMd),
                  Text(
                    'No tables found',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSizes.spacingSm),
                  Text(
                    'Add a table to get started',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              childAspectRatio: 1,
              crossAxisSpacing: AppSizes.spacingMd,
              mainAxisSpacing: AppSizes.spacingMd,
            ),
            itemCount: tables.length,
            itemBuilder: (context, index) {
              final table = tables[index];
              return TableCard(
                table: table,
                onTap: () => _showTableDetailDialog(context, table),
                onStatusChange: (newStatus) =>
                    _updateTableStatus(context, table, newStatus),
              );
            },
          );
        }

        return const Center(child: Text('No data'));
      },
    );
  }

  void _showAddTableDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<TableBloc>(),
        child: const TableFormDialog(),
      ),
    );
  }

  void _showTableDetailDialog(BuildContext context, TableEntity table) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Table ${table.tableNumber}'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDetailRow('Capacity', '${table.capacity} people'),
            _buildDetailRow('Status', table.status.name),
            if (table.currentOrderId != null)
              _buildDetailRow('Order ID', table.currentOrderId!),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showEditTableDialog(context, table);
            },
            child: const Text('Edit'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteTable(context, table);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showEditTableDialog(BuildContext context, TableEntity table) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<TableBloc>(),
        child: TableFormDialog(table: table),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spacingSm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(value),
        ],
      ),
    );
  }

  void _updateTableStatus(
    BuildContext context,
    TableEntity table,
    TableStatus newStatus,
  ) {
    context.read<TableBloc>().add(UpdateTableStatus(table.id, newStatus));
  }

  void _deleteTable(BuildContext context, TableEntity table) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Table'),
        content: Text(
          'Are you sure you want to delete Table ${table.tableNumber}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<TableBloc>().add(DeleteTable(table.id));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
