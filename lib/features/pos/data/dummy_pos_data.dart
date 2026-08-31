import 'package:flutter/material.dart';

import '../../../domain/models/category_model.dart';
import '../../../domain/models/menu_product_model.dart';

/// Data dummy sementara untuk preview UI Menu/POS.
/// Akan digantikan oleh repository (local/remote) pada fase integrasi data.
class DummyPosData {
  DummyPosData._();

  static const String allCategoryId = 'all';

  static const List<CategoryModel> categories = [
    CategoryModel(id: allCategoryId, name: 'Semua'),
    CategoryModel(id: 'makanan', name: 'Makanan'),
    CategoryModel(id: 'minuman', name: 'Minuman'),
    CategoryModel(id: 'snack', name: 'Snack'),
  ];

  static const List<MenuProductModel> products = [
    MenuProductModel(
      id: 'prod-1',
      categoryId: 'makanan',
      name: 'Nasi Goreng Spesial',
      price: 32000,
      icon: Icons.ramen_dining_rounded,
    ),
    MenuProductModel(
      id: 'prod-2',
      categoryId: 'makanan',
      name: 'Ayam Bakar Madu',
      price: 38000,
      icon: Icons.set_meal_rounded,
    ),
    MenuProductModel(
      id: 'prod-3',
      categoryId: 'makanan',
      name: 'Sate Ayam',
      price: 28000,
      icon: Icons.kebab_dining_rounded,
    ),
    MenuProductModel(
      id: 'prod-4',
      categoryId: 'makanan',
      name: 'Mie Goreng Jawa',
      price: 26000,
      icon: Icons.dinner_dining_rounded,
    ),
    MenuProductModel(
      id: 'prod-5',
      categoryId: 'makanan',
      name: 'Steak Sirloin',
      price: 65000,
      icon: Icons.lunch_dining_rounded,
      isAvailable: false,
    ),
    MenuProductModel(
      id: 'prod-6',
      categoryId: 'minuman',
      name: 'Es Teh Manis',
      price: 8000,
      icon: Icons.emoji_food_beverage_rounded,
    ),
    MenuProductModel(
      id: 'prod-7',
      categoryId: 'minuman',
      name: 'Jus Alpukat',
      price: 18000,
      icon: Icons.local_drink_rounded,
      isAvailable: false,
    ),
    MenuProductModel(
      id: 'prod-8',
      categoryId: 'minuman',
      name: 'Kopi Susu',
      price: 15000,
      icon: Icons.coffee_rounded,
    ),
    MenuProductModel(
      id: 'prod-9',
      categoryId: 'snack',
      name: 'Kentang Goreng',
      price: 17000,
      icon: Icons.fastfood_rounded,
    ),
    MenuProductModel(
      id: 'prod-10',
      categoryId: 'snack',
      name: 'Tahu Crispy',
      price: 14000,
      icon: Icons.tapas_rounded,
    ),
  ];
}
