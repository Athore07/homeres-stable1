// lib/presentation/providers/storage/secure_storage_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/secure_storage_service.dart';

// Provider for SecureStorageService (singleton)
final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

// Provider for auth token
final authTokenProvider = FutureProvider<String?>((ref) async {
  final storage = ref.watch(secureStorageServiceProvider);
  return await storage.readToken();
});

// Provider for refresh token
final refreshTokenProvider = FutureProvider<String?>((ref) async {
  final storage = ref.watch(secureStorageServiceProvider);
  return await storage.readRefreshToken();
});

// Provider for user ID
final storedUserIdProvider = FutureProvider<String?>((ref) async {
  final storage = ref.watch(secureStorageServiceProvider);
  return await storage.readUserId();
});

// Provider for user role
final storedUserRoleProvider = FutureProvider<String?>((ref) async {
  final storage = ref.watch(secureStorageServiceProvider);
  return await storage.readUserRole();
});

// Provider for user email
final storedUserEmailProvider = FutureProvider<String?>((ref) async {
  final storage = ref.watch(secureStorageServiceProvider);
  return await storage.readUserEmail();
});

// Provider for biometric enabled
final biometricEnabledProvider = FutureProvider<bool>((ref) async {
  final storage = ref.watch(secureStorageServiceProvider);
  return await storage.readBiometricEnabled();
});

// Provider for login status
final isLoggedInProvider = FutureProvider<bool>((ref) async {
  final storage = ref.watch(secureStorageServiceProvider);
  return await storage.isLoggedIn();
});