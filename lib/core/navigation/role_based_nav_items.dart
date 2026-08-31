import 'package:flutter/material.dart';

import '../../../data/local/entities/user_entity.dart';

class NavItemData {
  const NavItemData({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

// Navigation items untuk ADMIN (full access)
const List<NavItemData> kAdminNavItems = [
  NavItemData(icon: Icons.dashboard_rounded, label: 'Dashboard'),
  NavItemData(icon: Icons.restaurant_menu_rounded, label: 'Menu/POS'),
  NavItemData(icon: Icons.receipt_long_rounded, label: 'Orders'),
  NavItemData(icon: Icons.table_bar_rounded, label: 'Table'),
  NavItemData(icon: Icons.bar_chart_rounded, label: 'Reports'),
  NavItemData(icon: Icons.history_rounded, label: 'Activity Log'),
  NavItemData(icon: Icons.people_rounded, label: 'Users'),
  NavItemData(icon: Icons.settings_rounded, label: 'Settings'),
];

// Navigation items untuk KASIR (POS focused)
const List<NavItemData> kKasirNavItems = [
  NavItemData(icon: Icons.restaurant_menu_rounded, label: 'Menu/POS'),
  NavItemData(icon: Icons.receipt_long_rounded, label: 'Orders'),
  NavItemData(icon: Icons.table_bar_rounded, label: 'Table'),
  NavItemData(icon: Icons.dashboard_rounded, label: 'Dashboard'),
];

// Navigation items untuk OWNER (reporting focused)
const List<NavItemData> kOwnerNavItems = [
  NavItemData(icon: Icons.dashboard_rounded, label: 'Dashboard'),
  NavItemData(icon: Icons.bar_chart_rounded, label: 'Reports'),
  NavItemData(icon: Icons.settings_rounded, label: 'Settings'),
];

// Default navigation items (fallback)
const List<NavItemData> kSidebarNavItems = kAdminNavItems;

// Helper function to get navigation items based on user role
List<NavItemData> getNavItemsForRole(UserRole role) {
  switch (role) {
    case UserRole.admin:
      return kAdminNavItems;
    case UserRole.kasir:
      return kKasirNavItems;
    case UserRole.owner:
      return kOwnerNavItems;
  }
}
