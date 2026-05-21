// lib/presentation/screens/settings/admin_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../routing/route_names.dart';

class AdminSettingsScreen extends ConsumerWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Settings'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          _buildSectionHeader(context, 'System Configuration'),
          _buildTile(context, Icons.settings, 'General Settings', () {}),
          _buildTile(context, Icons.email, 'Email Templates', () {}),
          _buildTile(context, Icons.payment, 'Payment Settings', () {}),
          _buildTile(context, Icons.map, 'Service Areas', () {}),
          
          const SizedBox(height: 16),
          _buildSectionHeader(context, 'Content Management'),
          _buildTile(context, Icons.article, 'Terms & Conditions', () => context.push(RouteNames.termsConditions)),
          _buildTile(context, Icons.privacy_tip, 'Privacy Policy', () => context.push(RouteNames.privacyPolicy)),
          _buildTile(context, Icons.campaign, 'Push Notifications', () {}),
          _buildTile(context, Icons.local_offer, 'Promotions', () {}),
          
          const SizedBox(height: 16),
          _buildSectionHeader(context, 'Data Management'),
          _buildTile(context, Icons.backup, 'Database Backup', () {}),
          _buildTile(context, Icons.restore, 'Restore Data', () {}),
          _buildTile(context, Icons.delete_sweep, 'Clear Cache', () {}),
          _buildTile(context, Icons.download, 'Export Reports', () {}),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: AppColors.warning,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildTile(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.warning),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}