import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/printer/printer_service.dart';
import '../../../../data/local/entities/order_entity.dart';

class ReceiptPreviewDialog extends StatefulWidget {
  final OrderEntity order;
  final List<OrderItemEntity> items;

  const ReceiptPreviewDialog({
    super.key,
    required this.order,
    required this.items,
  });

  @override
  State<ReceiptPreviewDialog> createState() => _ReceiptPreviewDialogState();
}

class _ReceiptPreviewDialogState extends State<ReceiptPreviewDialog> {
  final PrinterService _printerService = PrinterService();
  bool _isPrinting = false;
  String? _printResult;

  String get _receiptText {
    return _printerService.generateReceiptText(
      order: widget.order,
      items: widget.items,
    );
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _receiptText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Struk disalin ke clipboard'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  Future<void> _printReceipt() async {
    if (!_printerService.isConnected) {
      setState(() {
        _printResult = 'Printer tidak terhubung. Hubungkan printer di Settings.';
      });
      return;
    }

    setState(() {
      _isPrinting = true;
      _printResult = null;
    });

    try {
      final bytes = await _printerService.generateReceiptBytes(
        order: widget.order,
        items: widget.items,
      );
      final success = await _printerService.printReceipt(bytes);

      if (mounted) {
        setState(() {
          _isPrinting = false;
          _printResult = success ? 'Struk berhasil dicetak!' : 'Gagal mencetak struk';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isPrinting = false;
          _printResult = 'Error: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Container(
        width: 420,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingMd),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppSizes.radiusMd),
                  topRight: Radius.circular(AppSizes.radiusMd),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.receipt_long, color: Colors.white),
                  const SizedBox(width: AppSizes.spacingSm),
                  const Expanded(
                    child: Text(
                      'Preview Struk',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Receipt preview
            Flexible(
              child: Container(
                margin: const EdgeInsets.all(AppSizes.paddingMd),
                padding: const EdgeInsets.all(AppSizes.paddingMd),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  border: Border.all(color: AppColors.border),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _receiptText,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            ),

            // Print result
            if (_printResult != null)
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingMd,
                ),
                padding: const EdgeInsets.all(AppSizes.paddingSm),
                decoration: BoxDecoration(
                  color: _printResult!.contains('berhasil')
                      ? AppColors.success.withValues(alpha: 0.1)
                      : AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                child: Row(
                  children: [
                    Icon(
                      _printResult!.contains('berhasil')
                          ? Icons.check_circle
                          : Icons.error,
                      color: _printResult!.contains('berhasil')
                          ? AppColors.success
                          : AppColors.error,
                      size: 20,
                    ),
                    const SizedBox(width: AppSizes.spacingSm),
                    Expanded(
                      child: Text(
                        _printResult!,
                        style: TextStyle(
                          color: _printResult!.contains('berhasil')
                              ? AppColors.success
                              : AppColors.error,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Actions
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingMd),
              child: Row(
                children: [
                  // Copy button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _copyToClipboard,
                      icon: const Icon(Icons.copy, size: 18),
                      label: const Text('Salin'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.spacingSm),
                  // Print button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isPrinting ? null : _printReceipt,
                      icon: _isPrinting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.print, size: 18),
                      label: Text(_isPrinting ? 'Mencetak...' : 'Cetak'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
