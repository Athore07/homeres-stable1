// lib/core/services/secure_storage_service.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static final SecureStorageService _instance = SecureStorageService._internal();
  factory SecureStorageService() => _instance;
  SecureStorageService._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Storage keys
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _userRoleKey = 'user_role';
  static const String _userEmailKey = 'user_email';
  static const String _biometricKey = 'biometric_enabled';
  static const String _pinCodeKey = 'pin_code';

  // Write methods
  Future<void> writeToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<void> writeRefreshToken(String refreshToken) async {
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  Future<void> writeUserId(String userId) async {
    await _storage.write(key: _userIdKey, value: userId);
  }

  Future<void> writeUserRole(String role) async {
    await _storage.write(key: _userRoleKey, value: role);
  }

  Future<void> writeUserEmail(String email) async {
    await _storage.write(key: _userEmailKey, value: email);
  }

  Future<void> writeBiometricEnabled(bool enabled) async {
    await _storage.write(key: _biometricKey, value: enabled.toString());
  }

  Future<void> writePinCode(String pin) async {
    await _storage.write(key: _pinCodeKey, value: pin);
  }

  // Read methods
  Future<String?> readToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<String?> readRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  Future<String?> readUserId() async {
    return await _storage.read(key: _userIdKey);
  }

  Future<String?> readUserRole() async {
    return await _storage.read(key: _userRoleKey);
  }

  Future<String?> readUserEmail() async {
    return await _storage.read(key: _userEmailKey);
  }

  Future<bool> readBiometricEnabled() async {
    final value = await _storage.read(key: _biometricKey);
    return value?.toLowerCase() == 'true';
  }

  Future<String?> readPinCode() async {
    return await _storage.read(key: _pinCodeKey);
  }

  // Check methods
  Future<bool> hasToken() async {
    final token = await readToken();
    return token != null && token.isNotEmpty;
  }

  Future<bool> hasPinCode() async {
    final pin = await readPinCode();
    return pin != null && pin.isNotEmpty;
  }

  // Save all user data
  Future<void> saveUserData({
    required String token,
    String? refreshToken,
    required String userId,
    required String role,
    String? email,
  }) async {
    await Future.wait([
      writeToken(token),
      if (refreshToken != null) writeRefreshToken(refreshToken),
      writeUserId(userId),
      writeUserRole(role),
      if (email != null) writeUserEmail(email),
    ]);
  }

  // Save auth tokens
  Future<void> saveTokens({
    required String token,
    String? refreshToken,
  }) async {
    await writeToken(token);
    if (refreshToken != null) {
      await writeRefreshToken(refreshToken);
    }
  }

  // Delete methods
  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  Future<void> deleteRefreshToken() async {
    await _storage.delete(key: _refreshTokenKey);
  }

  Future<void> deleteUserId() async {
    await _storage.delete(key: _userIdKey);
  }

  Future<void> deleteUserRole() async {
    await _storage.delete(key: _userRoleKey);
  }

  Future<void> deleteUserEmail() async {
    await _storage.delete(key: _userEmailKey);
  }

  Future<void> deletePinCode() async {
    await _storage.delete(key: _pinCodeKey);
  }

  // Clear all data
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  // Clear auth data only
  Future<void> clearAuthData() async {
    await Future.wait([
      deleteToken(),
      deleteRefreshToken(),
      deleteUserId(),
      deleteUserRole(),
      deleteUserEmail(),
    ]);
  }

  // Read all stored data
  Future<Map<String, String?>> readAll() async {
    return await _storage.readAll();
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final hasToken = await this.hasToken();
    final hasUserId = await readUserId() != null;
    return hasToken && hasUserId;
  }
}