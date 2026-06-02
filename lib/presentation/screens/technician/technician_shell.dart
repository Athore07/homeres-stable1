// lib/presentation/screens/technician/technician_shell.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/auth/auth_provider.dart';
import '../../providers/technician/job_requests_provider.dart';
import '../../providers/technician/technician_guard_provider.dart';
import '../../providers/technician/profile_setup_provider.dart';
import '../../widgets/drawer/app_drawer.dart';
import '../../widgets/common/badge_icon.dart';
import '../../../routing/route_names.dart';

class TechnicianShell extends ConsumerStatefulWidget {
  final Widget child;
  final int currentIndex;

  const TechnicianShell({
    super.key,
    required this.child,
    this.currentIndex = 0,
  });

  @override
  ConsumerState<TechnicianShell> createState() => _TechnicianShellState();
}

class _TechnicianShellState extends ConsumerState<TechnicianShell> {
  bool _hasCheckedProfile = false;
  
  // Track previous index for animation
  int _previousIndex = 0;
   
  // Navigation history stack for each tab (like WhatsApp)
  final Map<int, List<String>> _navigationStack = {
    0: [RouteNames.technicianHome],
    1: [RouteNames.jobRequests],
    2: [RouteNames.schedule],
    3: [RouteNames.earnings],
  };

  @override
  void initState() {
    super.initState();
    _previousIndex = widget.currentIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkProfileCompletion();
    });
  }

  Future<void> _checkProfileCompletion() async {
    final user = ref.read(authProvider).user;
    if (user == null || user.role != 'technician') return;

    final isComplete = await ref.read(technicianGuardProvider.notifier).isProfileComplete(user.id);
    
    if (!mounted) return;

    // If profile is not set up and we're not already on profile setup
    if (!isComplete && !_hasCheckedProfile) {
      _hasCheckedProfile = true;
      final location = GoRouterState.of(context).uri.toString();
      if (!location.contains('/technician/profile-setup')) {
        context.go(RouteNames.profileSetup);
      }
    }
  }

  int _currentIndex(String location) {
    // Always show Dashboard tab active when on profile setup
    if (location.contains('/technician/profile-setup')) return 0;
    if (location.contains('/technician/home')) return 0;
    if (location.contains('/technician/jobs')) return 1;
    if (location.contains('/technician/schedule')) return 2;
    if (location.contains('/technician/earnings')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _currentIndex(location);
    final jobState = ref.watch(jobRequestsProvider);
    final profileState = ref.watch(profileSetupProvider);

    // Re-check profile completion when coming back from profile setup
    if (profileState.isSuccess) {
      _hasCheckedProfile = false;
    }

    return Scaffold(
      body: _buildBodyWithAnimation(currentIndex),
      drawer: const AppDrawer(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          final user = ref.read(authProvider).user;
          
          // For navigation to non-dashboard tabs, check profile completion
          if (index != 0 && user != null && user.role == 'technician') {
            final isComplete = ref.read(technicianGuardProvider).value ?? false;
            if (!isComplete) {
              context.go(RouteNames.profileSetup);
              return;
            }
          }

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
          NavigationDestination(
            icon: BadgeIcon(icon: Icons.work_outline, count: jobState.requests.length, badgeColor: AppColors.warning),
            selectedIcon: BadgeIcon(icon: Icons.work, count: jobState.requests.length, iconColor: AppColors.primary, badgeColor: AppColors.warning),
            label: 'Jobs',
          ),
          const NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month, color: AppColors.primary),
            label: 'Schedule',
          ),
          const NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet, color: AppColors.primary),
            label: 'Earnings',
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
      case 0: return RouteNames.technicianHome;
      case 1: return RouteNames.jobRequests;
      case 2: return RouteNames.schedule;
      case 3: return RouteNames.earnings;
      default: return RouteNames.technicianHome;
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