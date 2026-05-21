// lib/core/constants/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // Primary palette
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryLight = Color(0xFF60A5FA);
  static const Color primaryDark = Color(0xFF1E40AF);
  
  // Accent
  static const Color accent = Color(0xFFF59E0B);
  static const Color accentLight = Color(0xFFFCD34D);
  
  // Neutrals
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9);
  static const Color divider = Color(0xFFE2E8F0);
  
  // Text
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textHint = Color(0xFF94A3B8);
  
  // Status
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);
  
  // Gradients
  static const LinearGradient gradientPrimary = LinearGradient(
    colors: [primary, Color(0xFF4F46E5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static LinearGradient gradientCard = LinearGradient(
    colors: [
      primary.withOpacity(0.8),
      primaryDark,
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}