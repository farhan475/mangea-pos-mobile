import 'package:flutter/material.dart';

class NavItemData {
  const NavItemData({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

const List<NavItemData> kSidebarNavItems = [
  NavItemData(icon: Icons.dashboard_rounded, label: 'Dashboard'),
  NavItemData(icon: Icons.restaurant_menu_rounded, label: 'Menu/POS'),
  NavItemData(icon: Icons.receipt_long_rounded, label: 'Orders'),
  NavItemData(icon: Icons.table_bar_rounded, label: 'Table'),
  NavItemData(icon: Icons.bar_chart_rounded, label: 'Reports'),
  NavItemData(icon: Icons.history_rounded, label: 'Activity Log'),
  NavItemData(icon: Icons.settings_rounded, label: 'Settings'),
];
