import 'package:shared_preferences/shared_preferences.dart';

abstract class SettingsLocalDataSource {
  Future<void> saveThemeMode(String themeMode);
  Future<String?> getThemeMode();
  Future<void> saveLanguage(String language);
  Future<String?> getLanguage();
  Future<void> clear();
}

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  static const String _themeModeKey = 'theme_mode';
  static const String _languageKey = 'language';

  final SharedPreferences _sharedPreferences;

  SettingsLocalDataSourceImpl(this._sharedPreferences);

  @override
  Future<void> saveThemeMode(String themeMode) async {
    await _sharedPreferences.setString(_themeModeKey, themeMode);
  }

  @override
  Future<String?> getThemeMode() async {
    return _sharedPreferences.getString(_themeModeKey);
  }

  @override
  Future<void> saveLanguage(String language) async {
    await _sharedPreferences.setString(_languageKey, language);
  }

  @override
  Future<String?> getLanguage() async {
    return _sharedPreferences.getString(_languageKey);
  }

  @override
  Future<void> clear() async {
    await _sharedPreferences.clear();
  }
}