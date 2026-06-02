// lib/presentation/screens/settings/technician_settings_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/common/section_header.dart';

class TechnicianSettingsSection extends StatelessWidget {
  const TechnicianSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SectionHeader(title: 'Technician Settings', accentColor: AppColors.info).animate().fadeIn(duration: 400.ms),
      _Tile(icon: Icons.engineering, title: 'Technician Profile', subtitle: 'Manage your professional info', onTap: () => context.push('/settings/technician-profile')),
      _Tile(icon: Icons.build, title: 'Service Areas', subtitle: 'Manage your service locations'),
      _Tile(icon: Icons.work, title: 'Working Hours', subtitle: 'Set your availability'),
      _Tile(icon: Icons.attach_money, title: 'Rate Settings', subtitle: 'Update your hourly rate'),
      _Tile(icon: Icons.description, title: 'Certifications', subtitle: 'Manage your documents'),
      _Tile(icon: Icons.trending_up, title: 'Performance Stats', subtitle: 'View your ratings and earnings'),
    ]);
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  const _Tile({required this.icon, required this.title, this.subtitle, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.info.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: AppColors.info, size: 20)),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      subtitle: subtitle != null ? Text(subtitle!, style: const TextStyle(fontSize: 12)) : null,
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap, dense: true,
    );
  }
}