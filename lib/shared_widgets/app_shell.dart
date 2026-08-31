import 'package:flutter/material.dart';

import '../core/constants/app_sizes.dart';
import '../core/navigation/role_based_nav_items.dart';
import '../data/local/entities/user_entity.dart';
import 'sidebar_nav.dart';

/// Kerangka layout responsif: sidebar di tablet/desktop, bottom nav di mobile.
/// Menyatukan logika navigasi agar tidak diduplikasi di tiap layar fitur.
class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
    required this.body,
    this.currentUser,
    this.navItems,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final Widget body;
  final UserEntity? currentUser;
  final List<NavItemData>? navItems;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth >= AppSizes.tabletBreakpoint;

        return Scaffold(
          body: SafeArea(
            child: isTablet
                ? Row(
                    children: [
                      SidebarNav(
                        selectedIndex: selectedIndex,
                        onSelect: onSelect,
                        currentUser: currentUser,
                        navItems: navItems,
                      ),
                      Expanded(child: body),
                    ],
                  )
                : body,
          ),
          bottomNavigationBar: isTablet
              ? null
              : MobileBottomNav(
                  selectedIndex: selectedIndex,
                  onSelect: onSelect,
                  navItems: navItems,
                ),
        );
      },
    );
  }
}
