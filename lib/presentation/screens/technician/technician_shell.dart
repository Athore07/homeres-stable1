// lib/presentation/screens/technician/technician_shell.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/auth/auth_provider.dart';
import '../../providers/technician/job_requests_provider.dart';
import '../../providers/technician/technician_guard_provider.dart';
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
  @override
  void initState() {
    super.initState();
    _checkProfileCompletion();
  }

  Future<void> _checkProfileCompletion() async {
    final user = ref.read(authProvider).user;
    if (user == null || user.role != 'technician') return;

    final isComplete = await ref.read(technicianGuardProvider.notifier).isProfileComplete(user.id);
    
    if (!mounted) return;

    // If profile is not set up and we're not already on profile setup
    if (!isComplete) {
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

    return Scaffold(
      body: widget.child,
      drawer: const AppDrawer(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          final user = ref.read(authProvider).user;
          
          // Check profile before allowing navigation to other tabs
          if (index != 0 && user != null && user.role == 'technician') {
            ref.read(technicianGuardProvider.notifier).isProfileComplete(user.id).then((isComplete) {
              if (!isComplete) {
                context.go(RouteNames.profileSetup);
              }
            });
          }

          switch (index) {
            case 0:
              context.go(RouteNames.technicianHome);
              break;
            case 1:
              context.go(RouteNames.jobRequests);
              break;
            case 2:
              context.go(RouteNames.schedule);
              break;
            case 3:
              context.go(RouteNames.earnings);
              break;
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
}