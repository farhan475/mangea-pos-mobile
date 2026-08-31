import 'package:flutter/material.dart';

/// Produk menu yang ditampilkan di grid layar Menu/POS.
class MenuProductModel {
  const MenuProductModel({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.price,
    required this.icon,
    this.isAvailable = true,
  });

  final String id;
  final String categoryId;
  final String name;
  final double price;
  final IconData icon;
  final bool isAvailable;
}
