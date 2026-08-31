import 'menu_product_model.dart';

/// Baris item di keranjang belanja POS (produk + jumlah).
class CartItemModel {
  const CartItemModel({required this.product, required this.quantity});

  final MenuProductModel product;
  final int quantity;

  double get subtotal => product.price * quantity;

  CartItemModel copyWith({int? quantity}) {
    return CartItemModel(
      product: product,
      quantity: quantity ?? this.quantity,
    );
  }
}
