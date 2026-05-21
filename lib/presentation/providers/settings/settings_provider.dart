// lib/presentation/providers/settings/settings_provider.dart
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'settings_provider.g.dart';

@riverpod
class ThemeModeNotifier extends _$ThemeModeNotifier {
  @override
  ThemeMode build() {
    _loadTheme();
    return ThemeMode.system;
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeStr = prefs.getString('theme_mode') ?? 'system';
    state = _stringToThemeMode(themeStr);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', mode.name);
  }

  ThemeMode _stringToThemeMode(String mode) {
    return ThemeMode.values.firstWhere(
      (e) => e.name == mode,
      orElse: () => ThemeMode.system,
    );
  }
}

@riverpod
class LanguageNotifier extends _$LanguageNotifier {
  @override
  String build() {
    _loadLanguage();
    return 'en';
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString('language') ?? 'en';
  }

  Future<void> setLanguage(String languageCode) async {
    state = languageCode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', languageCode);
  }
}

@riverpod
class BiometricNotifier extends _$BiometricNotifier {
  @override
  bool build() {
    _loadBiometric();
    return false;
  }

  Future<void> _loadBiometric() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool('biometric') ?? false;
  }

  Future<void> toggleBiometric(bool enabled) async {
    state = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometric', enabled);
  }
}

@riverpod
class NotificationSettingsNotifier extends _$NotificationSettingsNotifier {
  @override
  bool build() {
    _loadNotificationSettings();
    return true;
  }

  Future<void> _loadNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool('notifications') ?? true;
  }

  Future<void> toggleNotifications(bool enabled) async {
    state = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications', enabled);
  }
}