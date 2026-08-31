import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/printer/printer_service.dart';

class PrinterDeviceTile extends StatelessWidget {
  final PrinterDevice printer;
  final bool isConnecting;
  final VoidCallback onConnect;

  const PrinterDeviceTile({
    super.key,
    required this.printer,
    required this.isConnecting,
    required this.onConnect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.spacingSm),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getPrinterTypeColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getPrinterIcon(),
            color: _getPrinterTypeColor(),
          ),
        ),
        title: Text(
          printer.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          printer.address,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        trailing: isConnecting
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : ElevatedButton(
                onPressed: onConnect,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Connect'),
              ),
      ),
    );
  }

  IconData _getPrinterIcon() {
    switch (printer.type) {
      case PrinterType.bluetooth:
        return Icons.bluetooth;
      case PrinterType.usb:
        return Icons.usb;
    }
  }

  Color _getPrinterTypeColor() {
    switch (printer.type) {
      case PrinterType.bluetooth:
        return Colors.blue;
      case PrinterType.usb:
        return Colors.purple;
    }
  }
}
