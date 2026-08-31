import 'dart:typed_data';

import 'package:esc_pos_utils/esc_pos_utils.dart';

class PrinterService {
  static final PrinterService _instance = PrinterService._internal();
  factory PrinterService() => _instance;
  PrinterService._internal();

  String? _connectedPrinterAddress;
  bool _isConnected = false;

  bool get isConnected => _isConnected;
  String? get connectedPrinterAddress => _connectedPrinterAddress;

  // Simulate printer discovery (Bluetooth/USB)
  Future<List<PrinterDevice>> discoverPrinters() async {
    // In real implementation, use flutter_blue_plus or flutter_pos_printer_platform
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
      // Simulate connection
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

  // Generate receipt bytes
  Future<Uint8List> generateReceipt({
    required String storeName,
    required String storeAddress,
    required String orderId,
    required String tableNumber,
    required List<ReceiptItem> items,
    required double subtotal,
    required double tax,
    required double total,
  }) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    List<int> bytes = [];

    // Header - Store Name (Center, Bold)
    bytes += generator.text(
      storeName,
      styles: const PosStyles(
        align: PosAlign.center,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
        bold: true,
      ),
    );

    // Store Address (Center)
    bytes += generator.text(
      storeAddress,
      styles: const PosStyles(align: PosAlign.center),
    );
    
    bytes += generator.hr();
    bytes += generator.text('Order #$orderId');
    bytes += generator.text('Table: $tableNumber');
    bytes += generator.text('Date: ${DateTime.now().toString().substring(0, 16)}');
    bytes += generator.hr();

    // Items
    for (var item in items) {
      bytes += generator.row([
        PosColumn(
          text: '${item.quantity}x ${item.name}',
          width: 8,
          styles: const PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: 'Rp ${item.price.toStringAsFixed(0)}',
          width: 4,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    }

    bytes += generator.hr();

    // Totals
    bytes += generator.row([
      PosColumn(text: 'Subtotal:', width: 8),
      PosColumn(
        text: 'Rp ${subtotal.toStringAsFixed(0)}',
        width: 4,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.row([
      PosColumn(text: 'Tax:', width: 8),
      PosColumn(
        text: 'Rp ${tax.toStringAsFixed(0)}',
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
        text: 'Rp ${total.toStringAsFixed(0)}',
        width: 4,
        styles: const PosStyles(align: PosAlign.right, bold: true),
      ),
    ]);

    bytes += generator.hr();

    // Footer
    bytes += generator.text(
      'Thank you for your visit!',
      styles: const PosStyles(align: PosAlign.center),
    );
    
    bytes += generator.feed(2);
    bytes += generator.cut();

    return Uint8List.fromList(bytes);
  }

  // Print receipt
  Future<bool> printReceipt(Uint8List receiptBytes) async {
    if (!_isConnected) {
      throw Exception('Printer not connected');
    }

    try {
      // In real implementation, send bytes to printer via Bluetooth/USB
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

    // Generate test print data
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
      // Simulate sending to printer
      await Future.delayed(const Duration(milliseconds: 500));
      return true;
    } catch (e) {
      return false;
    }
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
