import 'package:flutter/material.dart';

class LightTheme {
  static ThemeData buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: const Color(0xFF6200EE),
      scaffoldBackgroundColor: const Color(0xFFFAFAFA),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF6200EE),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF6200EE),
        secondary: Color(0xFF03DAC6),
        surface: Colors.white,
        background: Color(0xFFFAFAFA),
        error: Color(0xFFB00020),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        bodyLarge: TextStyle(fontSize: 16),
        bodyMedium: TextStyle(fontSize: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6200EE),
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}