// lib/presentation/widgets/common/custom_button.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final bool isFullWidth;
  final IconData? icon;
  final Widget? prefixWidget;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final double? height;
  final double? width;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;

  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.isFullWidth = true,
    this.icon,
    this.prefixWidget,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.height,
    this.width,
    this.borderRadius = 12,
    this.padding,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || isLoading;

    if (isOutlined) {
      return SizedBox(
        width: isFullWidth ? double.infinity : width,
        height: height ?? 56,
        child: OutlinedButton(
          onPressed: isDisabled ? null : onPressed,
          style: OutlinedButton.styleFrom(
            backgroundColor: backgroundColor ?? Colors.transparent,
            foregroundColor: foregroundColor ?? AppColors.primary,
            side: BorderSide(
              color: borderColor ?? (isDisabled ? Colors.grey[300]! : AppColors.primary),
            ),
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            disabledBackgroundColor: Colors.grey[100],
            disabledForegroundColor: Colors.grey[400],
          ),
          child: _buildChild(context),
        ),
      );
    }

    return SizedBox(
      width: isFullWidth ? double.infinity : width,
      height: height ?? 56,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primary,
          foregroundColor: foregroundColor ?? Colors.white,
          elevation: 0,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          disabledBackgroundColor: Colors.grey[200],
          disabledForegroundColor: Colors.grey[400],
        ),
        child: _buildChild(context),
      ),
    );
  }

  Widget _buildChild(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        height: 22,
        width: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    if (icon != null || prefixWidget != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (prefixWidget != null)
            prefixWidget!
          else if (icon != null)
            Icon(icon, size: 20),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: textStyle ?? const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    return Text(
      label,
      style: textStyle ?? const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }
}

// Gradient Button Variant
class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final LinearGradient gradient;
  final double borderRadius;
  final double? height;

  const GradientButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.gradient = AppColors.gradientPrimary,
    this.borderRadius = 12,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height ?? 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: onPressed != null && !isLoading
              ? gradient
              : LinearGradient(
                  colors: [Colors.grey[300]!, Colors.grey[400]!],
                ),
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: onPressed != null && !isLoading
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
          child: _buildChild(),
        ),
      ),
    );
  }

  Widget _buildChild() {
    if (isLoading) {
      return const SizedBox(
        height: 22,
        width: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return Text(
      label,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

// Icon Button Variant
class CustomIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? backgroundColor;
  final double size;
  final String? tooltip;

  const CustomIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.color,
    this.backgroundColor,
    this.size = 24,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        color: backgroundColor ?? Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: backgroundColor != null
                  ? null
                  : Border.all(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                    ),
            ),
            child: Icon(
              icon,
              size: size,
              color: color ?? Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}