// lib/presentation/screens/settings/homeowner_settings_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/common/section_header.dart';

class HomeownerSettingsSection extends StatelessWidget {
  const HomeownerSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SectionHeader(title: 'Home Settings', accentColor: AppColors.success).animate().fadeIn(duration: 400.ms),
      _Tile(icon: Icons.home, title: 'Saved Addresses', subtitle: 'Manage your locations'),
      _Tile(icon: Icons.favorite, title: 'Favorite Technicians', subtitle: 'Your preferred pros'),
      _Tile(icon: Icons.history, title: 'Service History', subtitle: 'View past bookings'),
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
      leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: AppColors.success, size: 20)),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      subtitle: subtitle != null ? Text(subtitle!, style: const TextStyle(fontSize: 12)) : null,
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap, dense: true,
    );
  }
}