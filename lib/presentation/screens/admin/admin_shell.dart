// lib/presentation/screens/admin/admin_shell.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/admin/admin_dashboard_provider.dart';
import '../../widgets/drawer/app_drawer.dart';
import '../../widgets/common/badge_icon.dart';
import '../../../routing/route_names.dart';

class AdminShell extends ConsumerStatefulWidget {
  final Widget child;
  final int currentIndex;

  const AdminShell({
    super.key,
    required this.child,
    this.currentIndex = 0,
  });

  @override
  ConsumerState<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends ConsumerState<AdminShell> {
  // Track previous index for animation
  int _previousIndex = 0;
   
  // Navigation history stack for each tab (like WhatsApp)
  final Map<int, List<String>> _navigationStack = {
    0: [RouteNames.adminDashboard],
    1: [RouteNames.manageUsers],
    2: [RouteNames.manageTechnicians],
    3: [RouteNames.settings],
  };

  @override
  void initState() {
    super.initState();
    _previousIndex = widget.currentIndex;
  }

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
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _currentIndex(location);
    final dashState = ref.watch(dashboardProvider);

    return Scaffold(
      body: _buildBodyWithAnimation(currentIndex),
      drawer: const AppDrawer(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          if (index == currentIndex) {
            // If tapping the same tab, pop to root of that tab (like WhatsApp)
            _popToRootOfTab(index);
          } else {
            // Navigate to new tab
            _onNavTap(context, index);
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

  // Build body with cross-fade animation between tabs
  Widget _buildBodyWithAnimation(int currentIndex) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (Widget child, Animation<double> animation) {
        // Determine animation direction based on index change
        final isForward = currentIndex > _previousIndex;
        final offset = isForward ? 0.3 : -0.3;
        
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(offset, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          ),
        );
      },
      child: Container(
        key: ValueKey<int>(currentIndex),
        child: widget.child,
      ),
    );
  }

  void _onNavTap(BuildContext context, int index) {
    setState(() {
      _previousIndex = widget.currentIndex;
    });
    
    // Get the route for the selected tab
    final route = _getRouteForIndex(index);
    
    // Update navigation stack
    _updateNavigationStack(index, route);
    
    // Navigate to the new tab's root
    context.go(route);
  }

  // Pop to root of the current tab (like WhatsApp double-tap behavior)
  void _popToRootOfTab(int index) {
    final stack = _navigationStack[index];
    if (stack != null && stack.length > 1) {
      // If there's history, pop to root
      setState(() {
        _navigationStack[index] = [stack.first];
      });
      
      // Navigate to the root of this tab
      final rootRoute = _getRouteForIndex(index);
      context.go(rootRoute);
    } else {
      // If already at root, scroll to top (optional)
      _scrollToTopOfCurrentTab();
    }
  }

  // Update navigation stack when navigating to new tab
  void _updateNavigationStack(int index, String route) {
    final stack = _navigationStack[index];
    if (stack != null && stack.last != route) {
      _navigationStack[index] = [route];
    }
  }

  // Get the root route for each tab index
  String _getRouteForIndex(int index) {
    switch (index) {
      case 0: return RouteNames.adminDashboard;
      case 1: return RouteNames.manageUsers;
      case 2: return RouteNames.manageTechnicians;
      case 3: return RouteNames.settings;
      default: return RouteNames.adminDashboard;
    }
  }

  // Optional: Scroll to top of current tab's content
  void _scrollToTopOfCurrentTab() {
    // You can implement scroll-to-top functionality here
    // For example, using a GlobalKey or notification system
  }

  // Method to push a new route within the current tab (for internal navigation)
  void pushWithinTab(BuildContext context, String route, {Object? extra}) {
    final currentTabIndex = widget.currentIndex;
    final currentStack = _navigationStack[currentTabIndex] ?? [];
    
    // Add to stack
    setState(() {
      _navigationStack[currentTabIndex] = [...currentStack, route];
    });
    
    // Navigate
    context.push(route, extra: extra);
  }

  // Method to pop within current tab
  void popWithinTab(BuildContext context) {
    final currentTabIndex = widget.currentIndex;
    final currentStack = _navigationStack[currentTabIndex] ?? [];
    
    if (currentStack.length > 1) {
      setState(() {
        _navigationStack[currentTabIndex] = currentStack..removeLast();
      });
    }
    
    context.pop();
  }

  // Check if can pop within current tab
  bool canPopWithinTab() {
    final currentTabIndex = widget.currentIndex;
    final currentStack = _navigationStack[currentTabIndex] ?? [];
    return currentStack.length > 1;
  }
}