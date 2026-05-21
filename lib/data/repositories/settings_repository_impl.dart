// lib/data/repositories/settings_repository_impl.dart
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SharedPreferences sharedPrefs;

  static const String _biometricKey = 'biometric_enabled';
  static const String _notificationsKey = 'notifications_enabled';
  static const String _themeKey = 'theme_mode';
  static const String _languageKey = 'language_code';

  SettingsRepositoryImpl({required this.sharedPrefs});

  @override
  Future<bool> getBiometricEnabled() async {
    return sharedPrefs.getBool(_biometricKey) ?? false;
  }

  @override
  Future<void> setBiometricEnabled(bool enabled) async {
    await sharedPrefs.setBool(_biometricKey, enabled);
  }

  @override
  Future<bool> getNotificationsEnabled() async {
    return sharedPrefs.getBool(_notificationsKey) ?? true;
  }

  @override
  Future<void> setNotificationsEnabled(bool enabled) async {
    await sharedPrefs.setBool(_notificationsKey, enabled);
  }

  @override
  Future<String> getThemeMode() async {
    return sharedPrefs.getString(_themeKey) ?? 'system';
  }

  @override
  Future<void> setThemeMode(String mode) async {
    await sharedPrefs.setString(_themeKey, mode);
  }

  @override
  Future<String> getLanguage() async {
    return sharedPrefs.getString(_languageKey) ?? 'en';
  }

  @override
  Future<void> setLanguage(String languageCode) async {
    await sharedPrefs.setString(_languageKey, languageCode);
  }

  @override
  Future<void> clearAllSettings() async {
    await sharedPrefs.clear();
  }
}