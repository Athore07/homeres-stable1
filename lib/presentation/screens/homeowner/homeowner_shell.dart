// lib/presentation/screens/homeowner/homeowner_shell.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/notification/notification_provider.dart';
import '../../widgets/drawer/app_drawer.dart';
import '../../widgets/common/badge_icon.dart';
import '../../../routing/route_names.dart';

class HomeownerShell extends ConsumerWidget {
  final Widget child;
  final int currentIndex;

  const HomeownerShell({
    super.key,
    required this.child,
    this.currentIndex = 0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(notificationProvider).unreadCount;

       return Scaffold(
         body: child,
         drawer: const AppDrawer(),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: NavigationBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              height: 60,
              selectedIndex: currentIndex,
              onDestinationSelected: (index) => _onNavTap(context, index),
              destinations: [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined, color: AppColors.textSecondary),
                  selectedIcon: Icon(Icons.home, color: AppColors.primary),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.build_outlined, color: AppColors.textSecondary),
                  selectedIcon: Icon(Icons.build, color: AppColors.primary),
                  label: 'Services',
                ),
                NavigationDestination(
                  icon: BadgeIcon(icon: Icons.notifications_outlined, count: unreadCount),
                  selectedIcon: BadgeIcon(icon: Icons.notifications, count: unreadCount),
                  label: 'Alerts',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outlined, color: AppColors.textSecondary),
                  selectedIcon: Icon(Icons.person, color: AppColors.primary),
                  label: 'Profile',
                ),
              ],
            ),
          ),
       );
  }

  void _onNavTap(BuildContext context, int index) {
    switch (index) {
      case 0: context.go(RouteNames.home); break;
      case 1: context.go(RouteNames.serviceList); break;
      case 2: context.go(RouteNames.notifications); break;
      case 3: context.go(RouteNames.settings); break;
    }
  }
}