// lib/presentation/widgets/common/badge_icon.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class BadgeIcon extends StatelessWidget {
  final IconData icon;
  final int count;
  final Color? iconColor;
  final Color? badgeColor;
  final double size;
  final VoidCallback? onTap;

  const BadgeIcon({
    super.key,
    required this.icon,
    required this.count,
    this.iconColor,
    this.badgeColor,
    this.size = 24,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Icon(
            icon,
            size: size,
            color: iconColor ?? Theme.of(context).colorScheme.onSurface,
          ),
          if (count > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: badgeColor ?? AppColors.error,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    width: 2,
                  ),
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Text(
                  count > 99 ? '99+' : count.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
