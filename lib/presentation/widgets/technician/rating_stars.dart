// lib/presentation/widgets/technician/rating_stars.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  final double size;
  final bool interactive;
  final ValueChanged<double>? onRatingChanged;
  final Color? activeColor;
  final Color? inactiveColor;

  const RatingStars({
    super.key,
    required this.rating,
    this.size = 24,
    this.interactive = false,
    this.onRatingChanged,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = index + 1.0;
        final filled = starValue <= rating;
        final halfFilled = !filled && starValue - 0.5 <= rating;
        
        return GestureDetector(
          onTap: interactive ? () => onRatingChanged?.call(starValue) : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(horizontal: size / 12),
            child: Icon(
              filled
                  ? Icons.star
                  : (halfFilled ? Icons.star_half : Icons.star_border),
              size: size,
              color: filled || halfFilled
                  ? (activeColor ?? AppColors.accent)
                  : (inactiveColor ?? Colors.grey[300]),
            ),
          ),
        );
      }),
    );
  }
}

