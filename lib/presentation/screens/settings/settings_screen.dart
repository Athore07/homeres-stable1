// lib/presentation/screens/settings/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../domain/entities/user.dart';
import '../../providers/auth/auth_provider.dart';
import '../../providers/settings/settings_provider.dart';
import '../../widgets/common/section_header.dart';
import '../../widgets/common/confirmation_dialog.dart';
import '../../widgets/common/custom_button.dart';
import 'admin_settings_section.dart';
import 'technician_settings_section.dart';
import 'homeowner_settings_section.dart';
import '../../../routing/route_names.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use correct generated provider names
    final themeMode = ref.watch(themeModeProvider);
    final language = ref.watch(languageProvider);
    final biometricEnabled = ref.watch(biometricProvider);
    final notificationsEnabled = ref.watch(notificationSettingsProvider);
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final role = user?.role ?? 'homeowner';

    return Scaffold(
  appBar: AppBar(
    title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
    leading: IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => Navigator.pop(context),
    ),
  ),
      body: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 16),

          // Account Section
          SectionHeader(title: 'Account', accentColor: AppColors.primary).animate().fadeIn(duration: 400.ms),
          
          _ProfileTile(user: user, role: role, onTap: () => _navigateToProfile(context, role)).animate().fadeIn(duration: 400.ms, delay: 100.ms),
          
          // Role-based profile settings
          _SettingsTile(
            icon: _profileIcon(role),
            title: _profileTitle(role),
            onTap: () => _navigateToProfile(context, role),
          ),
          
          _SettingsTile(icon: Icons.lock_outline, title: 'Change Password', onTap: () => context.push(RouteNames.changePassword)),
          const SizedBox(height: 24),

          // Role-specific sections
          if (role == 'admin') ...[const AdminSettingsSection(), const SizedBox(height: 24)],
          if (role == 'technician') ...[const TechnicianSettingsSection(), const SizedBox(height: 24)],
          if (role == 'homeowner') ...[const HomeownerSettingsSection(), const SizedBox(height: 24)],

          // Preferences
          SectionHeader(title: 'Preferences', accentColor: AppColors.primary).animate().fadeIn(duration: 400.ms, delay: 400.ms),
          _SettingsTile(icon: Icons.palette_outlined, title: 'Theme', subtitle: _themeLabel(themeMode), onTap: () => context.push(RouteNames.theme)),
          _SettingsTile(icon: Icons.language, title: 'Language', subtitle: language == 'en' ? 'English' : 'Swahili', onTap: () => context.push(RouteNames.language)),
          _SettingsTile(
            icon: Icons.notifications_outlined, title: 'Notifications',
            trailing: Switch(value: notificationsEnabled, onChanged: (v) => ref.read(notificationSettingsProvider.notifier).toggleNotifications(v), activeColor: AppColors.primary),
          ),
          const SizedBox(height: 24),

          // Security
          SectionHeader(title: 'Security', accentColor: AppColors.primary).animate().fadeIn(duration: 400.ms, delay: 600.ms),
          _SettingsTile(
            icon: Icons.fingerprint, title: 'Biometric Login', subtitle: 'Use fingerprint or face',
            trailing: Switch(value: biometricEnabled, onChanged: (v) => _handleBiometric(context, ref, v), activeColor: AppColors.primary),
          ),
          _SettingsTile(icon: Icons.security, title: 'Two-Factor Authentication', subtitle: 'Add extra security', trailing: Switch(value: false, onChanged: (_) {}, activeColor: AppColors.primary)),
          _SettingsTile(icon: Icons.devices, title: 'Active Sessions', subtitle: 'Manage devices', onTap: () {}),
          const SizedBox(height: 24),

          // Support
          SectionHeader(title: 'Support', accentColor: AppColors.primary).animate().fadeIn(duration: 400.ms, delay: 800.ms),
          _SettingsTile(icon: Icons.help_outline, title: 'Help & Support', onTap: () => context.push(RouteNames.helpSupport)),
          _SettingsTile(icon: Icons.star_outline, title: 'Rate the App', onTap: () {}),
          _SettingsTile(icon: Icons.share_outlined, title: 'Share with Friends', onTap: () {}),
          const SizedBox(height: 24),

          // About
          SectionHeader(title: 'About', accentColor: AppColors.primary).animate().fadeIn(duration: 400.ms, delay: 1000.ms),
          _SettingsTile(icon: Icons.info_outline, title: 'About HOMERES', onTap: () => context.push(RouteNames.about)),
          _SettingsTile(icon: Icons.description_outlined, title: 'Terms & Conditions', onTap: () => context.push(RouteNames.termsConditions)),
          _SettingsTile(icon: Icons.privacy_tip_outlined, title: 'Privacy Policy', onTap: () => context.push(RouteNames.privacyPolicy)),
          _SettingsTile(icon: Icons.info_outline, title: 'App Version', subtitle: 'v1.0.0'),
          const SizedBox(height: 32),

          // Logout
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: CustomButton(
              label: 'Logout', icon: Icons.logout, isOutlined: true,
              foregroundColor: AppColors.error, borderColor: AppColors.error,
              onPressed: () => ConfirmationDialog.show(context, title: 'Logout', message: 'Are you sure?', confirmLabel: 'Logout', confirmColor: AppColors.error, icon: Icons.logout, isDestructive: true, onConfirm: () => ref.read(authProvider.notifier).logout()),
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 1250.ms),
          const SizedBox(height: 32),
        ]),
      ),
    );
  }

  // Helper methods for role-based profile
  IconData _profileIcon(String role) => switch (role) {
    'admin' => Icons.admin_panel_settings,
    'technician' => Icons.engineering,
    _ => Icons.person_outline,
  };

  String _profileTitle(String role) => switch (role) {
    'admin' => 'Admin Profile',
    'technician' => 'Technician Profile',
    _ => 'Edit Profile',
  };

  void _navigateToProfile(BuildContext context, String role) {
    switch (role) {
      case 'admin':
        context.push('/settings/admin-profile');
        break;
      case 'technician':
        context.push('/settings/technician-profile');
        break;
      default:
        context.push('/settings/homeowner-profile');
    }
  }

  String _themeLabel(ThemeMode mode) => switch (mode) { ThemeMode.light => 'Light', ThemeMode.dark => 'Dark', _ => 'System Default' };

  void _handleBiometric(BuildContext context, WidgetRef ref, bool value) async {
    if (value) {
      final auth = LocalAuthentication();
      if (!await auth.canCheckBiometrics) { context.showSnackBar('Not available'); return; }
      if (await auth.authenticate(localizedReason: 'Enable biometric login')) {
        ref.read(biometricProvider.notifier).toggleBiometric(true);
        context.showSnackBar('Biometric enabled');
      }
    } else {
      ref.read(biometricProvider.notifier).toggleBiometric(false);
      context.showSnackBar('Biometric disabled');
    }
  }
}

// Profile Tile with role-based navigation
class _ProfileTile extends StatelessWidget {
  final UserEntity? user;
  final String role;
  final VoidCallback onTap;
  const _ProfileTile({this.user, required this.role, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
        ),
        child: Row(children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            backgroundImage: user?.profileImage != null ? NetworkImage(user!.profileImage!) : null,
            child: user?.profileImage == null ? Text(
              user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : '?',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary),
            ) : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Flexible(child: Text(user?.name ?? 'User', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: _roleColor(role).withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                  child: Text(role.toUpperCase(), style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: _roleColor(role))),
                ),
              ]),
              const SizedBox(height: 2),
              Text(user?.email ?? '', style: TextStyle(color: Colors.grey[500], fontSize: 11), overflow: TextOverflow.ellipsis),
            ]),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
            child: const Text('Edit', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600)),
          ),
        ]),
      ),
    );
  }

  Color _roleColor(String r) => switch (r) { 'admin' => AppColors.warning, 'technician' => AppColors.info, _ => AppColors.success };
}

// Settings Tile
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  const _SettingsTile({required this.icon, required this.title, this.subtitle, this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        width: 38, height: 38,
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceVariant, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, size: 18),
      ),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      subtitle: subtitle != null ? Text(subtitle!, style: const TextStyle(fontSize: 11)) : null,
      trailing: trailing ?? const Icon(Icons.chevron_right, size: 18),
      onTap: onTap, dense: true, visualDensity: VisualDensity.compact,
    );
  }
}