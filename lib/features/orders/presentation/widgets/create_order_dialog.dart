import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../data/local/entities/order_entity.dart';
import '../../../../data/local/entities/product_entity.dart';
import '../../../dashboard/presentation/bloc/order_bloc.dart';
import '../../../pos/presentation/bloc/product_bloc.dart';

class CreateOrderDialog extends StatefulWidget {
  final String? tableNumber;

  const CreateOrderDialog({super.key, this.tableNumber});

  @override
  State<CreateOrderDialog> createState() => _CreateOrderDialogState();
}

class _CreateOrderDialogState extends State<CreateOrderDialog> {
  final _formKey = GlobalKey<FormState>();
  final _customerNameController = TextEditingController();
  final _tableNumberController = TextEditingController();
  final _uuid = const Uuid();
  
  final Map<String, OrderItemEntity> _cartItems = {};
  
  @override
  void initState() {
    super.initState();
    if (widget.tableNumber != null) {
      _tableNumberController.text = widget.tableNumber!;
    }
    context.read<ProductBloc>().add(LoadProducts());
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _tableNumberController.dispose();
    super.dispose();
  }

  double get _totalAmount {
    return _cartItems.values.fold(0, (sum, item) => sum + item.subtotal);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.85,
        padding: const EdgeInsets.all(AppSizes.paddingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: AppSizes.spacingLg),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildProductList(),
                  ),
                  const SizedBox(width: AppSizes.spacingLg),
                  Expanded(
                    child: _buildOrderSummary(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.add_shopping_cart, color: Colors.white),
        ),
        const SizedBox(width: AppSizes.spacingMd),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create New Order',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Select products and fill order details',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }

  Widget _buildProductList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSizes.paddingMd),
            child: Text(
              'Select Products',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          Expanded(
            child: BlocBuilder<ProductBloc, ProductState>(
              builder: (context, state) {
                if (state is ProductLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is ProductError) {
                  return Center(child: Text('Error: ${state.message}'));
                }

                if (state is ProductLoaded) {
                  final products = state.products;

                  return GridView.builder(
                    padding: const EdgeInsets.all(AppSizes.paddingMd),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.85,
                      crossAxisSpacing: AppSizes.spacingMd,
                      mainAxisSpacing: AppSizes.spacingMd,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return _buildProductCard(product);
                    },
                  );
                }

                return const Center(child: Text('No products available'));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(ProductEntity product) {
    final isInCart = _cartItems.containsKey(product.id);
    
    return InkWell(
      onTap: () => _addToCart(product),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          border: Border.all(
            color: isInCart ? AppColors.primary : Colors.grey[300]!,
            width: isInCart ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fastfood,
              size: 40,
              color: isInCart ? AppColors.primary : Colors.grey[400],
            ),
            const SizedBox(height: AppSizes.spacingSm),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                product.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: isInCart ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Rp ${product.price.toStringAsFixed(0)}',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (isInCart)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_cartItems[product.id]!.quantity}x',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingMd),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppSizes.radiusMd),
                topRight: Radius.circular(AppSizes.radiusMd),
              ),
            ),
            child: const Text(
              'Order Summary',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSizes.paddingMd),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _customerNameController,
                    decoration: const InputDecoration(
                      labelText: 'Customer Name',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter customer name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSizes.spacingMd),
                  TextFormField(
                    controller: _tableNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Table Number',
                      prefixIcon: Icon(Icons.table_restaurant),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter table number';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          const Divider(),
          Expanded(
            child: _cartItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_cart_outlined,
                            size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 8),
                        Text(
                          'No items in cart',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingMd,
                    ),
                    itemCount: _cartItems.length,
                    itemBuilder: (context, index) {
                      final item = _cartItems.values.toList()[index];
                      return _buildCartItem(item);
                    },
                  ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(AppSizes.paddingMd),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Rp ${_totalAmount.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.spacingMd),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _cartItems.isEmpty ? null : _createOrder,
                    icon: const Icon(Icons.check),
                    label: const Text('Create Order'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(OrderItemEntity item) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.spacingSm),
      padding: const EdgeInsets.all(AppSizes.paddingSm),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  'Rp ${item.price.toStringAsFixed(0)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () => _decreaseQuantity(item.productId),
                icon: const Icon(Icons.remove_circle_outline),
                iconSize: 20,
                color: Colors.red,
              ),
              Text(
                '${item.quantity}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () => _increaseQuantity(item.productId),
                icon: const Icon(Icons.add_circle_outline),
                iconSize: 20,
                color: AppColors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _addToCart(ProductEntity product) {
    setState(() {
      if (_cartItems.containsKey(product.id)) {
        _increaseQuantity(product.id);
      } else {
        _cartItems[product.id] = OrderItemEntity(
          id: _uuid.v4(),
          orderId: '',
          productId: product.id,
          productName: product.name,
          price: product.price,
          quantity: 1,
          subtotal: product.price,
        );
      }
    });
  }

  void _increaseQuantity(String productId) {
    setState(() {
      final item = _cartItems[productId]!;
      item.quantity++;
      item.subtotal = item.price * item.quantity;
    });
  }

  void _decreaseQuantity(String productId) {
    setState(() {
      final item = _cartItems[productId]!;
      if (item.quantity > 1) {
        item.quantity--;
        item.subtotal = item.price * item.quantity;
      } else {
        _cartItems.remove(productId);
      }
    });
  }

  void _createOrder() {
    if (_formKey.currentState!.validate()) {
      final orderId = _uuid.v4();
      
      final order = OrderEntity(
        id: orderId,
        customerName: _customerNameController.text.trim(),
        tableNumber: _tableNumberController.text.trim(),
        totalAmount: _totalAmount,
        status: OrderStatusEntity.pending,
        syncStatus: SyncStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        items: _cartItems.values.map((item) {
          item.orderId = orderId;
          return item;
        }).toList(),
      );

      context.read<OrderBloc>().add(CreateOrder(order));
      
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order created for ${order.customerName}!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
