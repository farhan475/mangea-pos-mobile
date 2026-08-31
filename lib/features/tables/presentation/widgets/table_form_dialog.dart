import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../data/local/entities/table_entity.dart';
import '../bloc/table_bloc.dart';

class TableFormDialog extends StatefulWidget {
  final TableEntity? table;

  const TableFormDialog({super.key, this.table});

  @override
  State<TableFormDialog> createState() => _TableFormDialogState();
}

class _TableFormDialogState extends State<TableFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _tableNumberController = TextEditingController();
  final _capacityController = TextEditingController();
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    if (widget.table != null) {
      _tableNumberController.text = widget.table!.tableNumber;
      _capacityController.text = widget.table!.capacity.toString();
    }
  }

  @override
  void dispose() {
    _tableNumberController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.table != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Table' : 'Add New Table'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _tableNumberController,
              decoration: const InputDecoration(
                labelText: 'Table Number',
                hintText: 'e.g., A1, B2, C3',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter table number';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSizes.spacingMd),
            TextFormField(
              controller: _capacityController,
              decoration: const InputDecoration(
                labelText: 'Capacity (people)',
                hintText: 'e.g., 2, 4, 6',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter capacity';
                }
                final capacity = int.tryParse(value);
                if (capacity == null || capacity <= 0) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submitForm,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: Text(isEditing ? 'Update' : 'Add'),
        ),
      ],
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final tableNumber = _tableNumberController.text.trim();
      final capacity = int.parse(_capacityController.text.trim());

      final table = TableEntity(
        id: widget.table?.id ?? _uuid.v4(),
        tableNumber: tableNumber,
        capacity: capacity,
        status: widget.table?.status ?? TableStatus.available,
        currentOrderId: widget.table?.currentOrderId,
        createdAt: widget.table?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.table != null) {
        context.read<TableBloc>().add(UpdateTable(table));
      } else {
        context.read<TableBloc>().add(CreateTable(table));
      }

      Navigator.pop(context);
    }
  }
}
