// lib/presentation/widgets/common/error_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import 'custom_button.dart';

class AppErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData? icon;
  final String? retryLabel;

  const AppErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.icon,
    this.retryLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon ?? Icons.error_outline,
                size: 56,
                color: AppColors.error.withOpacity(0.7),
              ),
            ).animate().fadeIn(duration: 400.ms).scale(
              begin: const Offset(0.5, 0.5),
              curve: Curves.elasticOut,
            ),
            const SizedBox(height: 24),
            Text(
              'Oops! Something went wrong',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              CustomButton(
                label: retryLabel ?? 'Try Again',
                icon: Icons.refresh,
                onPressed: onRetry,
              ).animate().fadeIn(duration: 400.ms, delay: 400.ms),
            ],
          ],
        ),
      ),
    );
  }
}

// Network Error Widget
class NetworkErrorWidget extends StatelessWidget {
  final VoidCallback onRetry;

  const NetworkErrorWidget({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.wifi_off,
                size: 56,
                color: AppColors.warning,
              ),
            ).animate().fadeIn(duration: 400.ms),
            const SizedBox(height: 24),
            Text(
              'No Internet Connection',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Please check your internet connection and try again',
              style: TextStyle(color: AppColors.textHint),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            CustomButton(
              label: 'Retry',
              icon: Icons.refresh,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}