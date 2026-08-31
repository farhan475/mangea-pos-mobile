import 'package:hive/hive.dart';

part 'product_entity.g.dart';

@HiveType(typeId: 1)
class ProductEntity extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String categoryId;

  @HiveField(2)
  String name;

  @HiveField(3)
  double price;

  @HiveField(4)
  int stock;

  @HiveField(5)
  String? imageUrl;

  @HiveField(6)
  bool isAvailable;

  @HiveField(7)
  DateTime createdAt;

  @HiveField(8)
  DateTime updatedAt;

  @HiveField(9)
  int lowStockThreshold;

  ProductEntity({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.price,
    this.stock = 0,
    this.imageUrl,
    this.isAvailable = true,
    required this.createdAt,
    required this.updatedAt,
    this.lowStockThreshold = 10,
  });

  // Stock management helper methods
  bool get isLowStock => stock <= lowStockThreshold && stock > 0;
  bool get isOutOfStock => stock <= 0;
  bool get hasStock => stock > 0;

  void reduceStock(int quantity) {
    stock = (stock - quantity).clamp(0, double.infinity).toInt();
    updatedAt = DateTime.now();
  }

  void addStock(int quantity) {
    stock += quantity;
    updatedAt = DateTime.now();
  }

  void setStock(int quantity) {
    stock = quantity.clamp(0, double.infinity).toInt();
    updatedAt = DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'name': name,
      'price': price,
      'stock': stock,
      'image_url': imageUrl,
      'is_available': isAvailable,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'low_stock_threshold': lowStockThreshold,
    };
  }

  factory ProductEntity.fromJson(Map<String, dynamic> json) {
    return ProductEntity(
      id: json['id'],
      categoryId: json['category_id'],
      name: json['name'],
      price: (json['price'] as num).toDouble(),
      stock: json['stock'] ?? 0,
      imageUrl: json['image_url'],
      isAvailable: json['is_available'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      lowStockThreshold: json['low_stock_threshold'] ?? 10,
    );
  }
}
