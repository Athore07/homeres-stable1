// lib/presentation/screens/homeowner/homeowner_shell.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/notification/notification_provider.dart';
import '../../widgets/drawer/app_drawer.dart';
import '../../widgets/common/badge_icon.dart';
import '../../../routing/route_names.dart';

class HomeownerShell extends ConsumerStatefulWidget {
  final Widget child;
  final int currentIndex;

  const HomeownerShell({
    super.key,
    required this.child,
    this.currentIndex = 0,
  });

  @override
  ConsumerState<HomeownerShell> createState() => _HomeownerShellState();
}

class _HomeownerShellState extends ConsumerState<HomeownerShell> {
  // Track previous index for animation
  int _previousIndex = 0;
  
  // Navigation history stack for each tab (like WhatsApp)
  final Map<int, List<String>> _navigationStack = {
    0: [RouteNames.home],
    1: [RouteNames.serviceList],
    2: [RouteNames.notifications],
    3: [RouteNames.settings],
  };

  @override
  void initState() {
    super.initState();
    _previousIndex = widget.currentIndex;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _currentIndex(location);
    final unreadCount = ref.watch(notificationProvider).unreadCount;
    final theme = Theme.of(context);

    return Scaffold(
      body: _buildBodyWithAnimation(currentIndex),
      drawer: const AppDrawer(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: NavigationBar(
          backgroundColor: theme.colorScheme.surface,
          elevation: 0,
          height: 65,
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
          indicatorColor: AppColors.primary.withOpacity(0.1),
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.home_outlined, color: theme.colorScheme.onSurfaceVariant),
              selectedIcon: Icon(Icons.home, color: AppColors.primary),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.build_outlined, color: theme.colorScheme.onSurfaceVariant),
              selectedIcon: Icon(Icons.build, color: AppColors.primary),
              label: 'Services',
            ),
            NavigationDestination(
              icon: BadgeIcon(
                icon: Icons.notifications_outlined, 
                count: unreadCount,
                iconColor: theme.colorScheme.onSurfaceVariant,
              ),
              selectedIcon: BadgeIcon(
                icon: Icons.notifications, 
                count: unreadCount,
                iconColor: AppColors.primary,
              ),
              label: 'Alerts',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outlined, color: theme.colorScheme.onSurfaceVariant),
              selectedIcon: Icon(Icons.person, color: AppColors.primary),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  // Get the root route for each tab index
  int _currentIndex(String location) {
    // Homeowner routes
    if (location.contains('/home')) return 0;
    if (location.contains('/service-list')) return 1;
    if (location.contains('/notifications')) return 2;
    if (location.contains('/settings')) return 3;
    return 0;
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
      case 0: return RouteNames.home;
      case 1: return RouteNames.serviceList;
      case 2: return RouteNames.notifications;
      case 3: return RouteNames.settings;
      default: return RouteNames.home;
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