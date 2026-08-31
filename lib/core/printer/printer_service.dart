import 'dart:typed_data';

import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:intl/intl.dart';

import '../../data/local/entities/order_entity.dart';

class PrinterService {
  static final PrinterService _instance = PrinterService._internal();
  factory PrinterService() => _instance;
  PrinterService._internal();

  String? _connectedPrinterAddress;
  bool _isConnected = false;

  bool get isConnected => _isConnected;
  String? get connectedPrinterAddress => _connectedPrinterAddress;

  static const String storeName = 'MANGEA POS';
  static const String storeAddress = 'Jl. Contoh No. 123, Kota';

  // Discover printers (simulated)
  Future<List<PrinterDevice>> discoverPrinters() async {
    await Future.delayed(const Duration(seconds: 2));
    return [
      PrinterDevice(
        name: 'Thermal Printer 58mm',
        address: 'BT:00:11:22:33:44:55',
        type: PrinterType.bluetooth,
      ),
      PrinterDevice(
        name: 'Thermal Printer 80mm',
        address: 'BT:00:11:22:33:44:66',
        type: PrinterType.bluetooth,
      ),
      PrinterDevice(
        name: 'USB Printer',
        address: 'USB:/dev/usb/lp0',
        type: PrinterType.usb,
      ),
    ];
  }

  // Connect to printer
  Future<bool> connectToPrinter(String address) async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      _connectedPrinterAddress = address;
      _isConnected = true;
      return true;
    } catch (e) {
      _isConnected = false;
      return false;
    }
  }

  // Disconnect printer
  Future<void> disconnect() async {
    _connectedPrinterAddress = null;
    _isConnected = false;
  }

  // Generate receipt text for preview (plain text, no ESC/POS)
  String generateReceiptText({
    required OrderEntity order,
    required List<OrderItemEntity> items,
  }) {
    final buffer = StringBuffer();
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    buffer.writeln('================================');
    buffer.writeln(storeName.toUpperCase());
    buffer.writeln(storeAddress);
    buffer.writeln('================================');
    buffer.writeln();
    buffer.writeln('Order #${order.id.substring(0, 8).toUpperCase()}');
    buffer.writeln('Table: ${order.tableNumber ?? 'N/A'}');
    buffer.writeln('Date: ${dateFormat.format(order.createdAt)}');
    buffer.writeln('Payment: ${_paymentMethodName(order.paymentMethod)}');
    buffer.writeln('--------------------------------');

    for (final item in items) {
      final name = item.productName.length > 20
          ? '${item.productName.substring(0, 17)}...'
          : item.productName;
      buffer.writeln(
        '${item.quantity}x ${name.padRight(20)} ${formatPrice(item.subtotal)}',
      );
    }

    buffer.writeln('--------------------------------');

    final subtotal = items.fold(0.0, (sum, i) => sum + i.subtotal);
    final tax = subtotal * 0.1;
    final total = subtotal + tax;

    buffer.writeln('Subtotal:${''.padLeft(12)}${formatPrice(subtotal)}');
    buffer.writeln('Tax (10%):${''.padLeft(11)}${formatPrice(tax)}');
    buffer.writeln('TOTAL:${''.padLeft(15)}${formatPrice(total)}');
    buffer.writeln('--------------------------------');
    buffer.writeln();

    if (order.paidAmount != null) {
      buffer.writeln(
        'Paid:${''.padLeft(16)}${formatPrice(order.paidAmount!)}',
      );
    }
    if (order.changeAmount != null && order.changeAmount! > 0) {
      buffer.writeln(
        'Change:${''.padLeft(14)}${formatPrice(order.changeAmount!)}',
      );
      buffer.writeln();
    }

    buffer.writeln('  Terima kasih atas kunjungan Anda!');
    buffer.writeln();
    buffer.writeln();
    buffer.writeln();

    return buffer.toString();
  }

  // Generate ESC/POS bytes from OrderEntity
  Future<Uint8List> generateReceiptBytes({
    required OrderEntity order,
    required List<OrderItemEntity> items,
  }) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    List<int> bytes = [];

    // Header
    bytes += generator.text(
      storeName,
      styles: const PosStyles(
        align: PosAlign.center,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
        bold: true,
      ),
    );
    bytes += generator.text(
      storeAddress,
      styles: const PosStyles(align: PosAlign.center),
    );

    bytes += generator.hr();
    bytes += generator.text('Order #${order.id.substring(0, 8).toUpperCase()}');
    bytes += generator.text('Table: ${order.tableNumber ?? 'N/A'}');
    bytes += generator.text('Date: ${dateFormat.format(order.createdAt)}');
    bytes += generator.text(
      'Payment: ${_paymentMethodName(order.paymentMethod)}',
    );
    bytes += generator.hr();

    // Items
    for (final item in items) {
      bytes += generator.row([
        PosColumn(
          text: '${item.quantity}x ${item.productName}',
          width: 8,
          styles: const PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: formatPrice(item.subtotal),
          width: 4,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    }

    bytes += generator.hr();

    // Totals
    final subtotal = items.fold(0.0, (sum, i) => sum + i.subtotal);
    final tax = subtotal * 0.1;
    final total = subtotal + tax;

    bytes += generator.row([
      PosColumn(text: 'Subtotal:', width: 8),
      PosColumn(
        text: formatPrice(subtotal),
        width: 4,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(text: 'Tax (10%):', width: 8),
      PosColumn(
        text: formatPrice(tax),
        width: 4,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'TOTAL:',
        width: 8,
        styles: const PosStyles(bold: true),
      ),
      PosColumn(
        text: formatPrice(total),
        width: 4,
        styles: const PosStyles(align: PosAlign.right, bold: true),
      ),
    ]);

    bytes += generator.hr();

    // Payment info
    if (order.paidAmount != null) {
      bytes += generator.row([
        PosColumn(text: 'Paid:', width: 8),
        PosColumn(
          text: formatPrice(order.paidAmount!),
          width: 4,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    }
    if (order.changeAmount != null && order.changeAmount! > 0) {
      bytes += generator.row([
        PosColumn(text: 'Change:', width: 8),
        PosColumn(
          text: formatPrice(order.changeAmount!),
          width: 4,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    }

    bytes += generator.hr();

    // Footer
    bytes += generator.text(
      'Terima kasih atas kunjungan Anda!',
      styles: const PosStyles(align: PosAlign.center),
    );

    bytes += generator.feed(2);
    bytes += generator.cut();

    return Uint8List.fromList(bytes);
  }

  // Print receipt bytes to connected printer
  Future<bool> printReceipt(Uint8List receiptBytes) async {
    if (!_isConnected) {
      throw Exception('Printer not connected');
    }

    try {
      // Simulate sending to thermal printer
      await Future.delayed(const Duration(seconds: 1));
      return true;
    } catch (e) {
      return false;
    }
  }

  // Test print
  Future<bool> testPrint() async {
    if (!_isConnected) {
      throw Exception('Printer not connected');
    }

    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);

    generator.text(
      'TEST PRINT',
      styles: const PosStyles(
        align: PosAlign.center,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
        bold: true,
      ),
    );
    generator.text(
      'Printer is working correctly!',
      styles: const PosStyles(align: PosAlign.center),
    );
    generator.feed(2);
    generator.cut();

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get products from Hive by IDs for receipt
  List<OrderItemEntity> getItemsWithProductInfo(List<OrderItemEntity> items) {
    return items;
  }

  String _paymentMethodName(PaymentMethod? method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.card:
        return 'Card';
      case PaymentMethod.ewallet:
        return 'E-Wallet';
      case PaymentMethod.qris:
        return 'QRIS';
      default:
        return 'N/A';
    }
  }

  String formatPrice(double amount) {
    final digits = amount.round().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      final positionFromEnd = digits.length - i;
      buffer.write(digits[i]);
      if (positionFromEnd > 1 && positionFromEnd % 3 == 1) {
        buffer.write('.');
      }
    }
    return 'Rp$buffer';
  }
}

class PrinterDevice {
  final String name;
  final String address;
  final PrinterType type;

  PrinterDevice({
    required this.name,
    required this.address,
    required this.type,
  });
}

enum PrinterType {
  bluetooth,
  usb,
}

class ReceiptItem {
  final String name;
  final int quantity;
  final double price;

  ReceiptItem({
    required this.name,
    required this.quantity,
    required this.price,
  });
}
