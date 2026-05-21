// lib/domain/repositories/auth_repository.dart
import '../entities/user.dart';

abstract class AuthRepository {
  Future<UserEntity> login(String email, String password);
  Future<UserEntity> register(String name, String email, String password, String role);
  Future<void> logout();
  Future<UserEntity?> getCurrentUser();
  Future<bool> isLoggedIn();
  Future<void> sendPasswordResetEmail(String email);
}