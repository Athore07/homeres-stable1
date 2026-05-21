// lib/presentation/widgets/drawer/app_drawer.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/firebase_constants.dart';
import '../../../domain/entities/user.dart';
import '../../providers/auth/auth_provider.dart';
import '../../../routing/route_names.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final role = user?.role ?? FirebaseConstants.roleHomeowner;

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.82,
      child: SafeArea(
        child: Column(children: [
          _DrawerHeader(user: user, isDark: isDark, role: role),
          Expanded(
            child: ListView(padding: const EdgeInsets.symmetric(vertical: 8), children: [
              ..._menuItems(context, role),
              const Divider(indent: 16, endIndent: 16, height: 32),
              _MenuItem(icon: Icons.settings_outlined, title: 'Settings', onTap: () { Navigator.pop(context); context.push('/settings'); }),
              _MenuItem(icon: Icons.help_outline, title: 'Help & Support', onTap: () { Navigator.pop(context); context.push('/settings/help'); }),
              _MenuItem(icon: Icons.info_outline, title: 'About', onTap: () { Navigator.pop(context); context.push('/settings/about'); }),
            ]),
          ),
          _LogoutTile(ref: ref),
          _VersionInfo(),
          const SizedBox(height: 12),
        ]),
      ),
    );
  }

  List<Widget> _menuItems(BuildContext context, String role) {
    final items = switch (role) {
      FirebaseConstants.roleTechnician => [
        _MenuItem(icon: Icons.dashboard_rounded, title: 'Dashboard', onTap: () { Navigator.pop(context); context.go(RouteNames.technicianHome); }),
        _MenuItem(icon: Icons.person_rounded, title: 'My Profile', onTap: () { Navigator.pop(context); context.push('/technician/profile'); }),
        _MenuItem(icon: Icons.work_rounded, title: 'Job Requests', onTap: () { Navigator.pop(context); context.push(RouteNames.jobRequests); }),
        _MenuItem(icon: Icons.calendar_month_rounded, title: 'Schedule', onTap: () { Navigator.pop(context); context.push(RouteNames.schedule); }),
        _MenuItem(icon: Icons.account_balance_wallet_rounded, title: 'Earnings', onTap: () { Navigator.pop(context); context.push(RouteNames.earnings); }),
      ],
      FirebaseConstants.roleAdmin => [
        _MenuItem(icon: Icons.dashboard_rounded, title: 'Dashboard', onTap: () { Navigator.pop(context); context.go(RouteNames.adminDashboard); }, trailing: _StatusDot(AppColors.success)),
        _MenuItem(icon: Icons.person_rounded, title: 'Admin Profile', onTap: () { Navigator.pop(context); context.push('/admin/profile'); }),
        _MenuItem(icon: Icons.people_rounded, title: 'Manage Users', onTap: () { Navigator.pop(context); context.push(RouteNames.manageUsers); }),
        _MenuItem(icon: Icons.engineering_rounded, title: 'Technicians', onTap: () { Navigator.pop(context); context.push(RouteNames.manageTechnicians); }),
        _MenuItem(icon: Icons.miscellaneous_services_rounded, title: 'Services', onTap: () { Navigator.pop(context); context.push(RouteNames.manageServices); }),
        _MenuItem(icon: Icons.analytics_rounded, title: 'Analytics', onTap: () { Navigator.pop(context); context.push(RouteNames.analytics); }),
      ],
      _ => [
        _MenuItem(icon: Icons.home_rounded, title: 'Home', onTap: () { Navigator.pop(context); context.go(RouteNames.home); }),
        _MenuItem(icon: Icons.person_rounded, title: 'My Profile', onTap: () { Navigator.pop(context); context.push('/homeowner/profile'); }),
        _MenuItem(icon: Icons.build_rounded, title: 'Services', onTap: () { Navigator.pop(context); context.push(RouteNames.serviceList); }),
        _MenuItem(icon: Icons.history_rounded, title: 'Booking History', onTap: () { Navigator.pop(context); context.push(RouteNames.bookingHistory); }),
        _MenuItem(icon: Icons.favorite_rounded, title: 'Favorites', onTap: () { Navigator.pop(context); context.push(RouteNames.favorites); }),
        _MenuItem(icon: Icons.notifications_rounded, title: 'Notifications', onTap: () { Navigator.pop(context); context.push(RouteNames.notifications); }),
      ],
    };

    return items;
  }
}

// Drawer Header
class _DrawerHeader extends StatelessWidget {
  final UserEntity? user;
  final bool isDark;
  final String role;
  const _DrawerHeader({this.user, required this.isDark, required this.role});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 36, 20, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryDark], begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(0.4), width: 3)),
            child: CircleAvatar(
              radius: 36,
              backgroundColor: Colors.white.withOpacity(0.15),
              backgroundImage: user?.profileImage != null ? NetworkImage(user!.profileImage!) : null,
              child: user?.profileImage == null ? Text(
                user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : '?',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
              ) : null,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 6, height: 6, decoration: BoxDecoration(color: _roleColor(role), shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Text(role.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1)),
            ]),
          ),
        ]),
        const SizedBox(height: 16),
        Text(user?.name ?? 'Welcome', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(user?.email ?? '', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
      ]),
    );
  }

  Color _roleColor(String role) => switch (role) {
    'admin' => AppColors.warning,
    'technician' => AppColors.info,
    _ => AppColors.success,
  };
}

// Menu Item
class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Widget? trailing;

  const _MenuItem({required this.icon, required this.title, required this.onTap, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        leading: Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, size: 20, color: AppColors.primary),
        ),
        title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        trailing: trailing,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        onTap: onTap,
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      ),
    );
  }
}

// Logout Tile
class _LogoutTile extends StatelessWidget {
  final WidgetRef ref;
  const _LogoutTile({required this.ref});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ListTile(
        leading: Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: AppColors.error.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.logout_rounded, size: 20, color: AppColors.error),
        ),
        title: const Text('Logout', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.error)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        onTap: () async {
          Navigator.pop(context);
          await ref.read(authProvider.notifier).logout();
          if (context.mounted) context.go(RouteNames.login);
        },
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      ),
    );
  }
}

// Version Info
class _VersionInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text('HOMERES v1.0.0', style: TextStyle(color: Colors.grey[400], fontSize: 11, fontWeight: FontWeight.w500)),
      const SizedBox(height: 2),
      Text('© 2024 All rights reserved', style: TextStyle(color: Colors.grey[400], fontSize: 10)),
    ]);
  }
}

// Status Dot
class _StatusDot extends StatelessWidget {
  final Color color;
  const _StatusDot(this.color);

  @override
  Widget build(BuildContext context) {
    return Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle));
  }
}