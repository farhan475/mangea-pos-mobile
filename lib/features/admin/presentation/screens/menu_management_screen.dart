import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../data/local/database/hive_database.dart';
import '../../../../data/local/entities/category_entity.dart';
import '../../../../data/local/entities/product_entity.dart';
import '../../../pos/presentation/bloc/product_bloc.dart';
import '../widgets/add_category_dialog.dart';
import '../widgets/add_edit_product_dialog.dart';

class MenuManagementScreen extends StatefulWidget {
  const MenuManagementScreen({super.key});

  @override
  State<MenuManagementScreen> createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends State<MenuManagementScreen> {
  String _searchQuery = '';
  String? _selectedCategoryId;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<CategoryEntity> _getCategories() {
    return HiveDatabase.categoriesBoxInstance.values.toList();
  }

  String _getCategoryName(String categoryId) {
    final cats = _getCategories();
    try {
      return cats.firstWhere((c) => c.id == categoryId).name;
    } catch (_) {
      return 'Tanpa Kategori';
    }
  }

  List<ProductEntity> _filterProducts(List<ProductEntity> products) {
    var filtered = products;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((p) =>
              p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    if (_selectedCategoryId != null) {
      filtered = filtered
          .where((p) => p.categoryId == _selectedCategoryId)
          .toList();
    }

    return filtered;
  }

  void _showAddCategoryDialog() async {
    final result = await showDialog<CategoryEntity>(
      context: context,
      builder: (_) => const AddCategoryDialog(),
    );
    if (result != null && mounted) {
      setState(() {});
    }
  }

  void _showAddProductDialog() {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<ProductBloc>(),
        child: const AddEditProductDialog(),
      ),
    );
  }

  void _showEditProductDialog(ProductEntity product) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<ProductBloc>(),
        child: AddEditProductDialog(product: product),
      ),
    );
  }

  void _confirmDelete(ProductEntity product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Produk'),
        content: Text(
            'Yakin ingin menghapus "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context
                  .read<ProductBloc>()
                  .add(DeleteProduct(product.id));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('"${product.name}" berhasil dihapus'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          _buildCategoryChips(),
          Expanded(child: _buildProductList()),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'add_category',
            mini: true,
            onPressed: _showAddCategoryDialog,
            backgroundColor: AppColors.secondary,
            child: const Icon(Icons.category, color: Colors.white),
          ),
          const SizedBox(height: AppSizes.spacingSm),
          FloatingActionButton(
            heroTag: 'add_product',
            onPressed: _showAddProductDialog,
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMd),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari menu...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppSizes.radiusSm),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingMd,
                ),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    final categories = _getCategories();

    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding:
            const EdgeInsets.symmetric(horizontal: AppSizes.paddingMd),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: AppSizes.spacingSm),
            child: FilterChip(
              label: const Text('Semua'),
              selected: _selectedCategoryId == null,
              onSelected: (_) {
                setState(() => _selectedCategoryId = null);
              },
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: _selectedCategoryId == null
                    ? Colors.white
                    : Colors.black87,
              ),
            ),
          ),
          ...categories.map((cat) => Padding(
                padding:
                    const EdgeInsets.only(right: AppSizes.spacingSm),
                child: FilterChip(
                  label: Text(cat.name),
                  selected: _selectedCategoryId == cat.id,
                  onSelected: (_) {
                    setState(() {
                      _selectedCategoryId =
                          _selectedCategoryId == cat.id ? null : cat.id;
                    });
                  },
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: _selectedCategoryId == cat.id
                        ? Colors.white
                        : Colors.black87,
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildProductList() {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        if (state is ProductLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ProductError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline,
                    size: 48, color: AppColors.error),
                const SizedBox(height: AppSizes.spacingMd),
                Text(state.message),
                const SizedBox(height: AppSizes.spacingMd),
                ElevatedButton(
                  onPressed: () {
                    context.read<ProductBloc>().add(LoadProducts());
                  },
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          );
        }

        if (state is ProductLoaded) {
          final filtered = _filterProducts(state.products);

          if (filtered.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.restaurant_menu,
                      size: 64,
                      color: Colors.grey.shade400),
                  const SizedBox(height: AppSizes.spacingMd),
                  Text(
                    _searchQuery.isNotEmpty
                        ? 'Tidak ada menu yang cocok'
                        : 'Belum ada menu. Tap + untuk menambahkan',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppSizes.paddingMd),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              return _buildProductCard(filtered[index]);
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildProductCard(ProductEntity product) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.spacingSm),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: product.isAvailable
                ? AppColors.primary.withValues(alpha: 0.1)
                : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          ),
          child: Center(
            child: product.imageUrl != null &&
                    product.imageUrl!.isNotEmpty
                ? ClipRRect(
                    borderRadius:
                        BorderRadius.circular(AppSizes.radiusSm),
                    child: Image.network(
                      product.imageUrl!,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.restaurant,
                        color: product.isAvailable
                            ? AppColors.primary
                            : Colors.grey,
                      ),
                    ),
                  )
                : Icon(
                    Icons.restaurant,
                    color: product.isAvailable
                        ? AppColors.primary
                        : Colors.grey,
                  ),
          ),
        ),
        title: Text(
          product.name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            decoration: product.isAvailable
                ? null
                : TextDecoration.lineThrough,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(
              formatRupiah(product.price),
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _getCategoryName(product.categoryId),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Stok: ${product.stock}',
                  style: TextStyle(
                    fontSize: 12,
                    color: product.isOutOfStock
                        ? AppColors.error
                        : product.isLowStock
                            ? Colors.orange
                            : Colors.grey.shade600,
                    fontWeight: product.isOutOfStock
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                if (!product.isAvailable) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Nonaktif',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _showEditProductDialog(product);
                break;
              case 'delete':
                _confirmDelete(product);
                break;
            }
          },
          itemBuilder: (_) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: AppColors.error),
                  SizedBox(width: 8),
                  Text('Hapus',
                      style: TextStyle(color: AppColors.error)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
