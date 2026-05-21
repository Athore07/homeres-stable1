// lib/presentation/screens/settings/theme_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/settings/theme_provider.dart';

class ThemeScreen extends ConsumerWidget {
  const ThemeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildThemeOption(
              context,
              ref,
              icon: Icons.brightness_auto,
              title: 'System Default',
              subtitle: 'Follow your device settings',
              value: ThemeMode.system,
              currentTheme: currentTheme,
            ).animate().fadeIn(duration: 400.ms).slideX(begin: -20),
            const SizedBox(height: 8),
            _buildThemeOption(
              context,
              ref,
              icon: Icons.light_mode,
              title: 'Light Mode',
              subtitle: 'Bright and clean interface',
              value: ThemeMode.light,
              currentTheme: currentTheme,
            ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideX(begin: 20),
            const SizedBox(height: 8),
            _buildThemeOption(
              context,
              ref,
              icon: Icons.dark_mode,
              title: 'Dark Mode',
              subtitle: 'Easy on the eyes, saves battery',
              value: ThemeMode.dark,
              currentTheme: currentTheme,
            ).animate().fadeIn(duration: 400.ms, delay: 200.ms).slideX(begin: -20),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    WidgetRef ref, {
    required IconData icon,
    required String title,
    required String subtitle,
    required ThemeMode value,
    required ThemeMode currentTheme,
  }) {
    final isSelected = currentTheme == value;
    
    return GestureDetector(
      onTap: () => ref.read(themeProvider.notifier).setThemeMode(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : Theme.of(context).colorScheme.outline.withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withOpacity(0.2)
                    : Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.primary : Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppColors.primary : null,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}