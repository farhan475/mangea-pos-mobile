import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/local/entities/user_entity.dart';
import '../../features/activity_log/presentation/screens/activity_log_screen.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/orders/presentation/screens/orders_screen.dart';
import '../../features/pos/presentation/screens/pos_screen.dart';
import '../../features/reports/presentation/screens/reports_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/tables/presentation/screens/tables_screen.dart';
import '../../shared_widgets/app_shell.dart';
import '../../shared_widgets/coming_soon_placeholder.dart';
import 'role_based_nav_items.dart';

/// Mengatur perpindahan antar layar utama (Dashboard, POS, dst) di dalam [AppShell].
class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _selectedIndex = 0;
  UserEntity? _currentUser;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          // Navigate to login if logged out
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        } else if (state is Authenticated) {
          // Reset selected tab when the user changes (different roles have
          // different nav lists — a stale index can crash with RangeError)
          final userChanged = _currentUser?.id != state.user.id;
          setState(() {
            _currentUser = state.user;
            if (userChanged) {
              _selectedIndex = 0;
            }
          });
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is! Authenticated) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          _currentUser = state.user;
          final navItems = getNavItemsForRole(_currentUser!.role);

          // Guard against out-of-range index after role/user switch
          if (_selectedIndex >= navItems.length) {
            _selectedIndex = 0;
          }

          return AppShell(
            selectedIndex: _selectedIndex,
            onSelect: (index) => setState(() => _selectedIndex = index),
            body: _buildBody(navItems),
            currentUser: _currentUser,
            navItems: navItems,
          );
        },
      ),
    );
  }

  Widget _buildBody(List<NavItemData> navItems) {
    if (_currentUser == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // IndexedStack keeps every tab alive, so in-progress work (e.g. a filled
    // POS cart) survives switching tabs and switching back.
    final screens = <Widget>[
      for (final item in navItems) _screenForLabel(item.label),
    ];

    return IndexedStack(
      index: _selectedIndex,
      children: screens,
    );
  }

  Widget _screenForLabel(String label) {
    switch (label) {
      case 'Dashboard':
        return const DashboardScreen();
      case 'Menu/POS':
        return const PosScreen();
      case 'Orders':
        return const OrdersScreen();
      case 'Table':
        return const TablesScreen();
      case 'Reports':
        return const ReportsScreen();
      case 'Activity Log':
        return const ActivityLogScreen();
      case 'Users':
        return const ComingSoonPlaceholder(label: 'User Management');
      case 'Settings':
        return const SettingsScreen();
      default:
        return ComingSoonPlaceholder(label: label);
    }
  }
}
