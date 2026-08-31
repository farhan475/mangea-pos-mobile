import 'package:uuid/uuid.dart';

import '../../domain/repository_interfaces/product_repository.dart';
import '../local/database/hive_database.dart';
import '../local/entities/product_entity.dart';
import '../remote/product_api_service.dart';
import '../sync/sync_manager.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductApiService _apiService;
  final SyncManager _syncManager;
  final _uuid = const Uuid();

  ProductRepositoryImpl(this._apiService, this._syncManager);

  @override
  Future<ProductEntity> createProduct(ProductEntity product) async {
    try {
      final productsBox = HiveDatabase.productsBoxInstance;
      
      if (product.id.isEmpty) {
        product.id = _uuid.v4();
      }
      
      product.createdAt = DateTime.now();
      product.updatedAt = DateTime.now();
      
      await productsBox.put(product.id, product);

      if (await _syncManager.isOnline()) {
        try {
          final syncedProduct = await _apiService.createProduct(product);
          await productsBox.put(syncedProduct.id, syncedProduct);
          return syncedProduct;
        } catch (e) {
          // Continue with local product
        }
      }

      return product;
    } catch (e) {
      throw Exception('Failed to create product: $e');
    }
  }

  @override
  Future<void> deleteProduct(String id) async {
    try {
      final productsBox = HiveDatabase.productsBoxInstance;
      await productsBox.delete(id);

      if (await _syncManager.isOnline()) {
        try {
          await _apiService.deleteProduct(id);
        } catch (e) {
          // Ignore
        }
      }
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }

  @override
  Future<ProductEntity?> getProductById(String id) async {
    try {
      final productsBox = HiveDatabase.productsBoxInstance;
      return productsBox.get(id);
    } catch (e) {
      throw Exception('Failed to get product: $e');
    }
  }

  @override
  Future<List<ProductEntity>> getProducts() async {
    try {
      final productsBox = HiveDatabase.productsBoxInstance;
      
      if (await _syncManager.isOnline()) {
        try {
          final serverProducts = await _apiService.getProducts();
          
          for (var product in serverProducts) {
            await productsBox.put(product.id, product);
          }
        } catch (e) {
          // Continue with local data
        }
      }

      return productsBox.values.toList();
    } catch (e) {
      throw Exception('Failed to get products: $e');
    }
  }

  @override
  Future<List<ProductEntity>> getProductsByCategory(String categoryId) async {
    try {
      final productsBox = HiveDatabase.productsBoxInstance;
      return productsBox.values
          .where((product) => product.categoryId == categoryId)
          .toList();
    } catch (e) {
      throw Exception('Failed to get products by category: $e');
    }
  }

  @override
  Future<ProductEntity> updateProduct(ProductEntity product) async {
    try {
      final productsBox = HiveDatabase.productsBoxInstance;
      
      product.updatedAt = DateTime.now();
      await productsBox.put(product.id, product);

      if (await _syncManager.isOnline()) {
        try {
          final syncedProduct = await _apiService.updateProduct(product);
          await productsBox.put(syncedProduct.id, syncedProduct);
          return syncedProduct;
        } catch (e) {
          // Continue with local product
        }
      }

      return product;
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  @override
  Stream<List<ProductEntity>> watchProducts() async* {
    final productsBox = HiveDatabase.productsBoxInstance;
    
    yield productsBox.values.toList();
    
    await for (final _ in productsBox.watch()) {
      yield productsBox.values.toList();
    }
  }
}
