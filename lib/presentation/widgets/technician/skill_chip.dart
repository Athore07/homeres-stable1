// lib/presentation/widgets/technician/skill_chip.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class SkillChip extends StatelessWidget {
  final String skill;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool isVerified;

  const SkillChip({
    super.key,
    required this.skill,
    this.isSelected = false,
    this.onTap,
    this.isVerified = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              skill,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected ? AppColors.primary : null,
              ),
            ),
            if (isVerified) ...[
              const SizedBox(width: 4),
              const Icon(Icons.verified, size: 14, color: AppColors.success),
            ],
          ],
        ),
      ),
    );
  }
}