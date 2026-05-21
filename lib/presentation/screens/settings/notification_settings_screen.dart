// lib/presentation/screens/settings/notification_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends ConsumerState<NotificationSettingsScreen> {
  bool _pushNotifications = true;
  bool _bookingUpdates = true;
  bool _chatMessages = true;
  bool _promotionalEmails = false;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Push Notifications
            _buildSectionTitle(context, 'General').animate().fadeIn(duration: 400.ms),
            _buildSwitchTile(
              context,
              icon: Icons.notifications_active,
              title: 'Push Notifications',
              subtitle: 'Receive push notifications from the app',
              value: _pushNotifications,
              onChanged: (value) => setState(() => _pushNotifications = value),
            ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
            
            const SizedBox(height: 24),
            // Notification Types
            _buildSectionTitle(context, 'Notification Types').animate().fadeIn(duration: 400.ms, delay: 200.ms),
            _buildSwitchTile(
              context,
              icon: Icons.calendar_today,
              title: 'Booking Updates',
              subtitle: 'Status changes, reminders, and confirmations',
              value: _bookingUpdates,
              onChanged: (value) => setState(() => _bookingUpdates = value),
            ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
            _buildSwitchTile(
              context,
              icon: Icons.chat,
              title: 'Chat Messages',
              subtitle: 'New messages from technicians',
              value: _chatMessages,
              onChanged: (value) => setState(() => _chatMessages = value),
            ).animate().fadeIn(duration: 400.ms, delay: 400.ms),
            _buildSwitchTile(
              context,
              icon: Icons.local_offer,
              title: 'Promotional Offers',
              subtitle: 'Special deals, discounts, and promotions',
              value: _promotionalEmails,
              onChanged: (value) => setState(() => _promotionalEmails = value),
            ).animate().fadeIn(duration: 400.ms, delay: 500.ms),
            
            const SizedBox(height: 24),
            // Alert Style
            _buildSectionTitle(context, 'Alert Style').animate().fadeIn(duration: 400.ms, delay: 600.ms),
            _buildSwitchTile(
              context,
              icon: Icons.volume_up,
              title: 'Sound',
              subtitle: 'Play sound for notifications',
              value: _soundEnabled,
              onChanged: (value) => setState(() => _soundEnabled = value),
            ).animate().fadeIn(duration: 400.ms, delay: 700.ms),
            _buildSwitchTile(
              context,
              icon: Icons.vibration,
              title: 'Vibration',
              subtitle: 'Vibrate for notifications',
              value: _vibrationEnabled,
              onChanged: (value) => setState(() => _vibrationEnabled = value),
            ).animate().fadeIn(duration: 400.ms, delay: 800.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.05),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.bodyLarge),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textHint,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}