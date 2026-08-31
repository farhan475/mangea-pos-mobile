import 'package:collection/collection.dart';

import '../../../data/local/database/hive_database.dart';
import '../../../data/local/entities/product_entity.dart';

class StockRepository {
  /// Get all products with their stock information
  Future<List<ProductEntity>> getAllProducts() async {
    final box = HiveDatabase.productsBoxInstance;
    return box.values.toList();
  }

  /// Get products with low stock
  Future<List<ProductEntity>> getLowStockProducts() async {
    final box = HiveDatabase.productsBoxInstance;
    return box.values.where((product) => product.isLowStock).toList();
  }

  /// Get out of stock products
  Future<List<ProductEntity>> getOutOfStockProducts() async {
    final box = HiveDatabase.productsBoxInstance;
    return box.values.where((product) => product.isOutOfStock).toList();
  }

  /// Update product stock
  Future<void> updateStock(String productId, int newStock) async {
    final box = HiveDatabase.productsBoxInstance;
    final product = box.values
        .firstWhereOrNull((p) => p.id == productId);
    if (product == null) throw Exception('Product not found: $productId');

    product.setStock(newStock);
    await product.save();
  }

  /// Add stock to product
  Future<void> addStock(String productId, int quantity) async {
    final box = HiveDatabase.productsBoxInstance;
    final product = box.values
        .firstWhereOrNull((p) => p.id == productId);
    if (product == null) throw Exception('Product not found: $productId');

    product.addStock(quantity);
    await product.save();
  }

  /// Reduce stock from product (called when order is completed)
  Future<bool> reduceStock(String productId, int quantity) async {
    final box = HiveDatabase.productsBoxInstance;
    final product = box.values
        .firstWhereOrNull((p) => p.id == productId);
    if (product == null) return false;

    // Check if stock is sufficient
    if (product.stock < quantity) {
      return false;
    }
    
    product.reduceStock(quantity);
    await product.save();
    return true;
  }

  /// Reduce stock for multiple products (used in order processing)
  Future<bool> reduceStockBatch(Map<String, int> productQuantities) async {
    final box = HiveDatabase.productsBoxInstance;
    
    // First, verify all products exist and have sufficient stock
    final products = <String, ProductEntity>{};
    for (final entry in productQuantities.entries) {
      final product = box.values
          .firstWhereOrNull((p) => p.id == entry.key);
      if (product == null || product.stock < entry.value) {
        return false;
      }
      products[entry.key] = product;
    }
    
    // If all checks pass, reduce stock
    for (final entry in productQuantities.entries) {
      final product = products[entry.key]!;
      product.reduceStock(entry.value);
      await product.save();
    }
    
    return true;
  }

  /// Update low stock threshold for a product
  Future<void> updateLowStockThreshold(String productId, int threshold) async {
    final box = HiveDatabase.productsBoxInstance;
    final product = box.values
        .firstWhereOrNull((p) => p.id == productId);
    if (product == null) throw Exception('Product not found: $productId');
    
    product.lowStockThreshold = threshold;
    await product.save();
  }

  /// Get stock statistics
  Future<StockStatistics> getStockStatistics() async {
    final products = await getAllProducts();
    
    final totalProducts = products.length;
    final lowStock = products.where((p) => p.isLowStock).length;
    final outOfStock = products.where((p) => p.isOutOfStock).length;
    final inStock = products.where((p) => p.hasStock && !p.isLowStock).length;
    final totalStockValue = products.fold<double>(
      0,
      (sum, product) => sum + (product.price * product.stock),
    );
    
    return StockStatistics(
      totalProducts: totalProducts,
      inStock: inStock,
      lowStock: lowStock,
      outOfStock: outOfStock,
      totalStockValue: totalStockValue,
    );
  }
}

class StockStatistics {
  final int totalProducts;
  final int inStock;
  final int lowStock;
  final int outOfStock;
  final double totalStockValue;

  StockStatistics({
    required this.totalProducts,
    required this.inStock,
    required this.lowStock,
    required this.outOfStock,
    required this.totalStockValue,
  });
}
