// lib/presentation/screens/admin/admin_shell.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/admin/admin_dashboard_provider.dart';
import '../../widgets/drawer/app_drawer.dart';
import '../../widgets/common/badge_icon.dart';
import '../../../routing/route_names.dart';

class AdminShell extends ConsumerWidget {
  final Widget child;

  const AdminShell({super.key, required this.child});

  int _currentIndex(String location) {
    // Admin routes
    if (location.contains('/admin/dashboard')) return 0;
    if (location.contains('/admin/users')) return 1;
    if (location.contains('/admin/technicians')) return 2;
    // Settings and other admin pages
    if (location.contains('/settings') || 
        location.contains('/profile') || 
        location.contains('/admin/services') || 
        location.contains('/admin/analytics')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _currentIndex(location);
    final dashState = ref.watch(dashboardProvider);

    return Scaffold(
      body: child,
      drawer: const AppDrawer(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go(RouteNames.adminDashboard);
              break;
            case 1:
              context.go(RouteNames.manageUsers);
              break;
            case 2:
              context.go(RouteNames.manageTechnicians);
              break;
            case 3:
              context.go(RouteNames.settings);
              break;
          }
        },
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard, color: AppColors.primary),
            label: 'Dashboard',
          ),
          const NavigationDestination(
            icon: Icon(Icons.people_outlined),
            selectedIcon: Icon(Icons.people, color: AppColors.primary),
            label: 'Users',
          ),
          NavigationDestination(
            icon: BadgeIcon(
              icon: Icons.engineering_outlined,
              count: dashState.pendingVerifications,
              badgeColor: AppColors.warning,
            ),
            selectedIcon: BadgeIcon(
              icon: Icons.engineering,
              count: dashState.pendingVerifications,
              iconColor: AppColors.primary,
              badgeColor: AppColors.warning,
            ),
            label: 'Techs',
          ),
          const NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings, color: AppColors.primary),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}