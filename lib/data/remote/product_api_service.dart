import '../../core/constants/api_constants.dart';
import '../local/entities/product_entity.dart';
import 'dio_client.dart';

class ProductApiService {
  final DioClient _dioClient;

  ProductApiService(this._dioClient);

  Future<List<ProductEntity>> getProducts() async {
    try {
      final response = await _dioClient.get(ApiConstants.products);
      
      if (response.data is List) {
        return (response.data as List)
            .map((json) => ProductEntity.fromJson(json))
            .toList();
      }
      
      throw Exception('Invalid response format');
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    }
  }

  Future<ProductEntity> getProductById(String id) async {
    try {
      final response = await _dioClient.get('${ApiConstants.products}/$id');
      return ProductEntity.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch product: $e');
    }
  }

  Future<ProductEntity> createProduct(ProductEntity product) async {
    try {
      final response = await _dioClient.post(
        ApiConstants.products,
        data: product.toJson(),
      );
      return ProductEntity.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create product: $e');
    }
  }

  Future<ProductEntity> updateProduct(ProductEntity product) async {
    try {
      final response = await _dioClient.put(
        '${ApiConstants.products}/${product.id}',
        data: product.toJson(),
      );
      return ProductEntity.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _dioClient.delete('${ApiConstants.products}/$id');
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }
}
