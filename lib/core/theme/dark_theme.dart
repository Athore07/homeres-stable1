import 'package:flutter/material.dart';

class DarkTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: const Color(0xFF1F1F1F),
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1F1F1F),
        elevation: 0,
      ),
      cardTheme: const CardThemeData(
        color: Color(0xFF2C2C2C),
        elevation: 2,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: Colors.white),
        displayMedium: TextStyle(color: Colors.white),
        bodyLarge: TextStyle(color: Colors.white70),
        bodyMedium: TextStyle(color: Colors.white60),
      ),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF6200EE),
        secondary: Color(0xFF03DAC6),
        surface: Color(0xFF2C2C2C),
      ),
    );
  }
}