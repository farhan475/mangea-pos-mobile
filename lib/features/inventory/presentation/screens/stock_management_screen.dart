import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../data/local/entities/product_entity.dart';
import '../../data/stock_repository.dart';

class StockManagementScreen extends StatefulWidget {
  const StockManagementScreen({super.key});

  @override
  State<StockManagementScreen> createState() => _StockManagementScreenState();
}

class _StockManagementScreenState extends State<StockManagementScreen> {
  final StockRepository _stockRepository = StockRepository();
  List<ProductEntity> _products = [];
  StockStatistics? _statistics;
  bool _isLoading = true;
  String _filterType = 'all'; // all, low_stock, out_of_stock

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final stats = await _stockRepository.getStockStatistics();
      List<ProductEntity> products;

      switch (_filterType) {
        case 'low_stock':
          products = await _stockRepository.getLowStockProducts();
          break;
        case 'out_of_stock':
          products = await _stockRepository.getOutOfStockProducts();
          break;
        default:
          products = await _stockRepository.getAllProducts();
      }

      setState(() {
        _statistics = stats;
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  void _showUpdateStockDialog(ProductEntity product) {
    final controller = TextEditingController(text: product.stock.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Stock: ${product.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current Stock: ${product.stock}'),
            const SizedBox(height: AppSizes.spacingMd),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'New Stock Quantity',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newStock = int.tryParse(controller.text) ?? 0;
              await _stockRepository.updateStock(product.id, newStock);
              if (context.mounted) {
                Navigator.pop(context);
                _loadData();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Stock updated successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showAddStockDialog(ProductEntity product) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Stock: ${product.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current Stock: ${product.stock}'),
            const SizedBox(height: AppSizes.spacingMd),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Quantity to Add',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final quantity = int.tryParse(controller.text) ?? 0;
              if (quantity > 0) {
                await _stockRepository.addStock(product.id, quantity);
                if (context.mounted) {
                  Navigator.pop(context);
                  _loadData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Added $quantity items to stock'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Statistics Cards
                if (_statistics != null) _buildStatisticsCards(),
                
                // Filter Tabs
                _buildFilterTabs(),

                // Product List
                Expanded(
                  child: _products.isEmpty
                      ? Center(
                          child: Text(
                            _getEmptyMessage(),
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(AppSizes.paddingMd),
                          itemCount: _products.length,
                          itemBuilder: (context, index) {
                            return _buildProductCard(_products[index]);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatisticsCards() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMd),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Total Products',
              _statistics!.totalProducts.toString(),
              Icons.inventory_2,
              Colors.blue,
            ),
          ),
          const SizedBox(width: AppSizes.spacingSm),
          Expanded(
            child: _buildStatCard(
              'In Stock',
              _statistics!.inStock.toString(),
              Icons.check_circle,
              Colors.green,
            ),
          ),
          const SizedBox(width: AppSizes.spacingSm),
          Expanded(
            child: _buildStatCard(
              'Low Stock',
              _statistics!.lowStock.toString(),
              Icons.warning,
              Colors.orange,
            ),
          ),
          const SizedBox(width: AppSizes.spacingSm),
          Expanded(
            child: _buildStatCard(
              'Out of Stock',
              _statistics!.outOfStock.toString(),
              Icons.error,
              Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMd),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: AppSizes.spacingSm),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMd),
      child: Row(
        children: [
          _buildFilterChip('All Products', 'all'),
          const SizedBox(width: AppSizes.spacingSm),
          _buildFilterChip('Low Stock', 'low_stock'),
          const SizedBox(width: AppSizes.spacingSm),
          _buildFilterChip('Out of Stock', 'out_of_stock'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String filterValue) {
    final isSelected = _filterType == filterValue;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _filterType = filterValue);
        _loadData();
      },
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildProductCard(ProductEntity product) {
    Color statusColor;
    String statusText;

    if (product.isOutOfStock) {
      statusColor = Colors.red;
      statusText = 'Out of Stock';
    } else if (product.isLowStock) {
      statusColor = Colors.orange;
      statusText = 'Low Stock';
    } else {
      statusColor = Colors.green;
      statusText = 'In Stock';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.spacingMd),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMd),
        child: Row(
          children: [
            // Product Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacingSm),
                  Text(
                    formatRupiah(product.price),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacingSm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: statusColor),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 12,
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Stock Quantity
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingMd),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              ),
              child: Column(
                children: [
                  Text(
                    product.stock.toString(),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                  const Text(
                    'units',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: AppSizes.spacingMd),

            // Action Buttons
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  color: Colors.green,
                  tooltip: 'Add Stock',
                  onPressed: () => _showAddStockDialog(product),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  color: Colors.blue,
                  tooltip: 'Update Stock',
                  onPressed: () => _showUpdateStockDialog(product),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getEmptyMessage() {
    switch (_filterType) {
      case 'low_stock':
        return 'No products with low stock';
      case 'out_of_stock':
        return 'No out of stock products';
      default:
        return 'No products found';
    }
  }
}
