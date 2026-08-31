import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../data/local/database/hive_database.dart';
import '../../../../data/local/entities/order_entity.dart';
import '../../../../data/local/entities/product_entity.dart';
import '../../../../domain/models/cart_item_model.dart';
import '../../../../domain/models/menu_product_model.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../dashboard/presentation/bloc/order_bloc.dart';
import '../../../orders/presentation/widgets/receipt_preview_dialog.dart';
import '../../presentation/bloc/product_bloc.dart';
import '../widgets/cart_panel.dart';
import '../widgets/category_chip.dart';
import '../widgets/menu_product_card.dart';
import '../widgets/payment_dialog.dart';

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  static const String _allCategoryId = 'all';
  static const double _taxRate = 0.1;

  String _searchQuery = '';
  String _selectedCategoryId = _allCategoryId;
  final List<CartItemModel> _cartItems = [];
  final _uuid = const Uuid();

  /// Maps ProductEntity to the UI model, picking an icon by category.
  MenuProductModel _toMenuProduct(ProductEntity product) {
    return MenuProductModel(
      id: product.id,
      categoryId: product.categoryId,
      name: product.name,
      price: product.price,
      icon: _iconForCategory(product.categoryId),
      isAvailable: product.isAvailable && product.stock > 0,
    );
  }

  IconData _iconForCategory(String categoryId) {
    switch (categoryId) {
      case 'makanan':
      case 'food':
        return Icons.ramen_dining_rounded;
      case 'minuman':
      case 'drink':
        return Icons.local_cafe_rounded;
      case 'snack':
        return Icons.cookie_rounded;
      default:
        return Icons.restaurant_menu_rounded;
    }
  }

  double get _subtotal =>
      _cartItems.fold(0, (sum, item) => sum + item.subtotal);
  double get _tax => _subtotal * _taxRate;
  double get _total => _subtotal + _tax;

  void _addToCart(MenuProductModel product) {
    setState(() => _incrementOrInsert(product));
  }

  void _incrementItem(String productId) {
    setState(() => _changeQuantity(productId, 1));
  }

  void _decrementItem(String productId) {
    setState(() => _changeQuantity(productId, -1));
  }

  void _incrementOrInsert(MenuProductModel product) {
    final index = _cartItems.indexWhere((i) => i.product.id == product.id);
    if (index >= 0) {
      _cartItems[index] = _cartItems[index].copyWith(
        quantity: _cartItems[index].quantity + 1,
      );
    } else {
      _cartItems.add(CartItemModel(product: product, quantity: 1));
    }
  }

  void _changeQuantity(String productId, int delta) {
    final index = _cartItems.indexWhere((i) => i.product.id == productId);
    if (index < 0) return;

    final newQuantity = _cartItems[index].quantity + delta;
    if (newQuantity <= 0) {
      _cartItems.removeAt(index);
    } else {
      _cartItems[index] = _cartItems[index].copyWith(quantity: newQuantity);
    }
  }

  void _checkout() {
    if (_cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Keranjang masih kosong'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => PaymentDialog(
        totalAmount: _total,
        onPaymentConfirmed: (paymentMethod, paidAmount, changeAmount) {
          _handlePaymentSuccess(paymentMethod, paidAmount, changeAmount);
        },
      ),
    );
  }

  /// Builds the order from the current cart and persists it (offline-first,
  /// synced to the backend by OrderBloc -> repository -> SyncManager).
  void _handlePaymentSuccess(
    PaymentMethod paymentMethod,
    double paidAmount,
    double changeAmount,
  ) {
    final authState = context.read<AuthBloc>().state;
    final user = authState is Authenticated ? authState.user : null;

    final now = DateTime.now();
    final orderId = _uuid.v4();

    final items = _cartItems.map((cartItem) {
      return OrderItemEntity(
        id: _uuid.v4(),
        orderId: orderId,
        productId: cartItem.product.id,
        productName: cartItem.product.name,
        price: cartItem.product.price,
        quantity: cartItem.quantity,
        subtotal: cartItem.subtotal,
      );
    }).toList();

    final order = OrderEntity(
      id: orderId,
      userId: user?.id,
      customerName: 'Walk-in',
      tableNumber: null,
      totalAmount: _total,
      status: OrderStatusEntity.paid,
      syncStatus: SyncStatus.pending,
      createdAt: now,
      updatedAt: now,
      items: items,
      paymentMethod: paymentMethod,
      paidAmount: paidAmount,
      changeAmount: changeAmount,
    );

    context.read<OrderBloc>().add(CreateOrder(order));

    // Clear cart
    setState(() {
      _cartItems.clear();
    });

    // Show receipt preview dialog after a brief delay
    if (mounted) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          showDialog(
            context: context,
            builder: (_) => ReceiptPreviewDialog(
              order: order,
              items: items,
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth >= AppSizes.tabletBreakpoint;
        return isTablet ? _buildTabletLayout() : _buildMobileLayout();
      },
    );
  }

  Widget _buildTabletLayout() {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingLg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 3, child: _buildMenuArea(crossAxisCount: 3)),
          const SizedBox(width: AppSizes.spacingLg),
          SizedBox(
            width: 340,
            child: SingleChildScrollView(child: _buildCartPanel()),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingLg),
      child: Column(
        children: [
          Expanded(
            child: _buildMenuArea(crossAxisCount: 2),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuArea({required int crossAxisCount}) {
    final theme = Theme.of(context);

    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, productState) {
        final products = productState is ProductLoaded
            ? productState.products.map(_toMenuProduct).toList()
            : <MenuProductModel>[];

        final filteredProducts = products.where((product) {
          final matchesCategory = _selectedCategoryId == _allCategoryId ||
              product.categoryId == _selectedCategoryId;
          final matchesSearch = _searchQuery.isEmpty ||
              product.name.toLowerCase().contains(_searchQuery.toLowerCase());
          return matchesCategory && matchesSearch;
        }).toList();

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Menu / POS', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text(
                    'Pilih menu untuk ditambahkan ke pesanan',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: AppSizes.spacingLg),
                  TextField(
                    onChanged: (value) => setState(() => _searchQuery = value),
                    decoration: const InputDecoration(
                      hintText: 'Cari nama menu',
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacingMd),
                  _buildCategoryChips(products),
                  if (productState is ProductLoading) ...[
                    const SizedBox(height: AppSizes.spacingLg),
                    const Center(child: CircularProgressIndicator()),
                  ] else if (productState is ProductError) ...[
                    const SizedBox(height: AppSizes.spacingLg),
                    Center(
                      child: Text(
                        'Gagal memuat menu: ${productState.message}',
                        style: const TextStyle(color: AppColors.error),
                      ),
                    ),
                  ] else if (filteredProducts.isEmpty) ...[
                    const SizedBox(height: AppSizes.spacingLg),
                    const Center(child: Text('Tidak ada menu tersedia')),
                  ],
                  const SizedBox(height: AppSizes.spacingMd),
                ],
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.only(bottom: AppSizes.paddingLg),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: AppSizes.spacingMd,
                  crossAxisSpacing: AppSizes.spacingMd,
                  childAspectRatio: 0.85,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final product = filteredProducts[index];
                    return MenuProductCard(
                      product: product,
                      onTap: () => _addToCart(product),
                    );
                  },
                  childCount: filteredProducts.length,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Category chips from the real categories box, falling back to "Semua".
  Widget _buildCategoryChips(List<MenuProductModel> products) {
    final categoriesBox = HiveDatabase.categoriesBoxInstance;

    final chips = <Widget>[
      Padding(
        padding: const EdgeInsets.only(right: AppSizes.spacingSm),
        child: CategoryChip(
          label: 'Semua',
          selected: _selectedCategoryId == _allCategoryId,
          onTap: () => setState(() => _selectedCategoryId = _allCategoryId),
        ),
      ),
    ];

    final categoryIds = products.map((p) => p.categoryId).toSet();
    for (final category in categoriesBox.values) {
      if (!categoryIds.contains(category.id)) continue;
      chips.add(
        Padding(
          padding: const EdgeInsets.only(right: AppSizes.spacingSm),
          child: CategoryChip(
            label: category.name,
            selected: _selectedCategoryId == category.id,
            onTap: () => setState(() => _selectedCategoryId = category.id),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: chips),
    );
  }

  Widget _buildCartPanel() {
    return CartPanel(
      items: _cartItems,
      subtotal: _subtotal,
      tax: _tax,
      total: _total,
      onIncrement: _incrementItem,
      onDecrement: _decrementItem,
      onCheckout: _checkout,
    );
  }
}
