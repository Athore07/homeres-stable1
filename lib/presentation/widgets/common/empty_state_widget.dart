// lib/presentation/widgets/common/empty_state_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import 'custom_button.dart';

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;
  final String? actionLabel;
  final String? actionRoute;
  final Color? iconColor;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
    this.actionLabel,
    this.actionRoute,
    this.iconColor,
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
                color: (iconColor ?? AppColors.primary).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 56,
                color: iconColor ?? AppColors.primary.withOpacity(0.5),
              ),
            ).animate().fadeIn(duration: 400.ms).scale(
              begin: const Offset(0.5, 0.5),
              curve: Curves.elasticOut,
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ] else if (actionLabel != null && actionRoute != null) ...[
              const SizedBox(height: 24),
              CustomButton(
                label: actionLabel!,
                onPressed: () => context.push(actionRoute!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// No Data Widget
class NoDataWidget extends StatelessWidget {
  final String message;

  const NoDataWidget({
    super.key,
    this.message = 'No data available',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }
}

// No Results Widget
class NoResultsWidget extends StatelessWidget {
  final String query;

  const NoResultsWidget({super.key, this.query = ''});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No results found',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textHint,
            ),
          ),
          if (query.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'No results for "$query"',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textHint,
              ),
            ),
          ],
        ],
      ),
    );
  }
}