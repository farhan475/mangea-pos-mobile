import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../data/local/entities/order_entity.dart';

class PaymentDialog extends StatefulWidget {
  final double totalAmount;
  final Function(PaymentMethod method, double paidAmount, double changeAmount) onPaymentConfirmed;

  const PaymentDialog({
    super.key,
    required this.totalAmount,
    required this.onPaymentConfirmed,
  });

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  PaymentMethod _selectedMethod = PaymentMethod.cash;
  final TextEditingController _paidAmountController = TextEditingController();
  double _changeAmount = 0.0;
  String? _errorMessage;

  @override
  void dispose() {
    _paidAmountController.dispose();
    super.dispose();
  }

  void _calculateChange() {
    final paidAmount = double.tryParse(_paidAmountController.text) ?? 0.0;
    setState(() {
      _changeAmount = paidAmount - widget.totalAmount;
      
      // Validate amount
      if (paidAmount < widget.totalAmount) {
        _errorMessage = 'Jumlah bayar kurang dari total';
      } else {
        _errorMessage = null;
      }
    });
  }

  void _setQuickAmount(double amount) {
    _paidAmountController.text = amount.toStringAsFixed(0);
    _calculateChange();
  }

  void _handlePayment() {
    if (_selectedMethod == PaymentMethod.cash) {
      final paidAmount = double.tryParse(_paidAmountController.text) ?? 0.0;
      
      if (paidAmount < widget.totalAmount) {
        setState(() {
          _errorMessage = 'Jumlah bayar tidak mencukupi';
        });
        return;
      }
      
      widget.onPaymentConfirmed(_selectedMethod, paidAmount, _changeAmount);
    } else {
      // Non-cash payments: exact amount
      widget.onPaymentConfirmed(_selectedMethod, widget.totalAmount, 0.0);
    }
    
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(AppSizes.paddingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Pembayaran',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.spacingLg),

            // Total Amount
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingMd),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Pembayaran',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Rp ${widget.totalAmount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.spacingLg),

            // Payment Method Selection
            const Text(
              'Metode Pembayaran',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSizes.spacingMd),

            Wrap(
              spacing: AppSizes.spacingSm,
              runSpacing: AppSizes.spacingSm,
              children: [
                _buildPaymentMethodChip(
                  PaymentMethod.cash,
                  'Cash',
                  Icons.money,
                ),
                _buildPaymentMethodChip(
                  PaymentMethod.card,
                  'Card',
                  Icons.credit_card,
                ),
                _buildPaymentMethodChip(
                  PaymentMethod.ewallet,
                  'E-Wallet',
                  Icons.account_balance_wallet,
                ),
                _buildPaymentMethodChip(
                  PaymentMethod.qris,
                  'QRIS',
                  Icons.qr_code_2,
                ),
              ],
            ),
            const SizedBox(height: AppSizes.spacingLg),

            // Cash Payment Section
            if (_selectedMethod == PaymentMethod.cash) ...[
              const Text(
                'Jumlah Dibayar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSizes.spacingMd),

              // Paid Amount Input
              TextField(
                controller: _paidAmountController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: InputDecoration(
                  hintText: 'Masukkan jumlah uang',
                  prefixText: 'Rp ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  ),
                  errorText: _errorMessage,
                ),
                onChanged: (value) => _calculateChange(),
              ),
              const SizedBox(height: AppSizes.spacingMd),

              // Quick Amount Buttons
              Wrap(
                spacing: AppSizes.spacingSm,
                runSpacing: AppSizes.spacingSm,
                children: [
                  _buildQuickAmountButton(widget.totalAmount),
                  _buildQuickAmountButton(50000),
                  _buildQuickAmountButton(100000),
                  _buildQuickAmountButton(150000),
                  _buildQuickAmountButton(200000),
                ],
              ),
              const SizedBox(height: AppSizes.spacingLg),

              // Change Amount Display
              Container(
                padding: const EdgeInsets.all(AppSizes.paddingMd),
                decoration: BoxDecoration(
                  color: _changeAmount >= 0 
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  border: Border.all(
                    color: _changeAmount >= 0 ? Colors.green : Colors.red,
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Kembalian',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Rp ${_changeAmount.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _changeAmount >= 0 ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Non-Cash Payment Info
            if (_selectedMethod != PaymentMethod.cash) ...[
              Container(
                padding: const EdgeInsets.all(AppSizes.paddingMd),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.blue),
                    const SizedBox(width: AppSizes.spacingSm),
                    Expanded(
                      child: Text(
                        _getPaymentMethodInfo(),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: AppSizes.spacingLg),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Batal'),
                  ),
                ),
                const SizedBox(width: AppSizes.spacingMd),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _selectedMethod == PaymentMethod.cash && _errorMessage != null
                        ? null
                        : _handlePayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Konfirmasi Pembayaran',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodChip(PaymentMethod method, String label, IconData icon) {
    final isSelected = _selectedMethod == method;
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: isSelected ? Colors.white : AppColors.primary),
          const SizedBox(width: AppSizes.spacingSm),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedMethod = method;
          _errorMessage = null;
          if (method != PaymentMethod.cash) {
            _paidAmountController.clear();
            _changeAmount = 0.0;
          }
        });
      },
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildQuickAmountButton(double amount) {
    return OutlinedButton(
      onPressed: () => _setQuickAmount(amount),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Text('Rp ${amount.toStringAsFixed(0)}'),
    );
  }

  String _getPaymentMethodInfo() {
    switch (_selectedMethod) {
      case PaymentMethod.card:
        return 'Pastikan mesin EDC sudah siap dan customer sudah melakukan tap/swipe kartu';
      case PaymentMethod.ewallet:
        return 'Minta customer untuk scan QR code atau kirim pembayaran ke nomor e-wallet kasir';
      case PaymentMethod.qris:
        return 'Tampilkan QR code QRIS untuk di-scan oleh customer';
      default:
        return '';
    }
  }
}
