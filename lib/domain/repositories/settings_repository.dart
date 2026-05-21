// lib/domain/repositories/settings_repository.dart
abstract class SettingsRepository {
  Future<bool> getBiometricEnabled();
  Future<void> setBiometricEnabled(bool enabled);
  Future<bool> getNotificationsEnabled();
  Future<void> setNotificationsEnabled(bool enabled);
  Future<String> getThemeMode();
  Future<void> setThemeMode(String mode);
  Future<String> getLanguage();
  Future<void> setLanguage(String languageCode);
  Future<void> clearAllSettings();
}