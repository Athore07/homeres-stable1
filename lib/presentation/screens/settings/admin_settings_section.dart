// lib/presentation/screens/settings/admin_settings_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/common/section_header.dart';
import '../../../routing/route_names.dart';

class AdminSettingsSection extends StatelessWidget {
  const AdminSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SectionHeader(title: 'Administration', accentColor: AppColors.warning).animate().fadeIn(duration: 400.ms),
      _Tile(icon: Icons.people, title: 'Manage Users', subtitle: 'View and manage all users', onTap: () => context.push(RouteNames.manageUsers)),
      _Tile(icon: Icons.engineering, title: 'Technician Verification', subtitle: 'Approve new technicians', trailing: _pendingBadge(), onTap: () => context.push(RouteNames.manageTechnicians)),
      _Tile(icon: Icons.miscellaneous_services, title: 'Manage Services', subtitle: 'Add or edit services', onTap: () => context.push(RouteNames.manageServices)),
      _Tile(icon: Icons.analytics, title: 'View Analytics', subtitle: 'Reports and statistics', onTap: () => context.push(RouteNames.analytics)),
      _Tile(icon: Icons.system_update_alt, title: 'System Status', subtitle: 'All systems operational', trailing: Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle))),
    ]);
  }

  Widget _pendingBadge() => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: AppColors.warning.withOpacity(0.2), borderRadius: BorderRadius.circular(10)), child: const Text('0', style: TextStyle(color: AppColors.warning, fontSize: 11, fontWeight: FontWeight.bold)));
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  const _Tile({required this.icon, required this.title, this.subtitle, this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.warning.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: AppColors.warning, size: 20)),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      subtitle: subtitle != null ? Text(subtitle!, style: const TextStyle(fontSize: 12)) : null,
      trailing: trailing ?? const Icon(Icons.chevron_right, size: 20),
      onTap: onTap, dense: true,
    );
  }
}