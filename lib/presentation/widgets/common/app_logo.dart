// lib/presentation/widgets/common/app_logo.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final Color? color;

  const AppLogo({
    super.key,
    this.size = 100,
    this.showText = true,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: color != null ? null : AppColors.gradientPrimary,
            color: color,
            borderRadius: BorderRadius.circular(size * 0.25),
            boxShadow: [
              BoxShadow(
                color: (color ?? AppColors.primary).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Icon(
            Icons.home_repair_service,
            size: size * 0.5,
            color: Colors.white,
          ),
        ),
        if (showText) ...[
          const SizedBox(height: 16),
          Text(
            'HOMERES',
            style: TextStyle(
              fontSize: size * 0.24,
              fontWeight: FontWeight.bold,
              letterSpacing: 4,
              color: color ?? AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Home Repair Experts',
            style: TextStyle(
              fontSize: size * 0.12,
              color: AppColors.textHint,
              letterSpacing: 2,
            ),
          ),
        ],
      ],
    );
  }
}