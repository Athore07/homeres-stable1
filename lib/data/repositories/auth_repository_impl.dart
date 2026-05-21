// lib/data/repositories/auth_repository_impl.dart
import '../../../core/services/secure_storage_service.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/remote/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final SecureStorageService? secureStorage;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    this.secureStorage,
  });

  @override
  Future<UserEntity> login(String email, String password) async {
    final user = await remoteDataSource.login(email, password);
    
    // Save user data to secure storage
    if (secureStorage != null) {
      await secureStorage!.saveUserData(
        token: user.id, // Using user ID as token for now
        userId: user.id,
        role: user.role,
        email: user.email,
      );
    }
    
    return user;
  }

  @override
  Future<UserEntity> register(String name, String email, String password, String role) async {
    final user = await remoteDataSource.register(name, email, password, role);
    
    // Save user data to secure storage
    if (secureStorage != null) {
      await secureStorage!.saveUserData(
        token: user.id,
        userId: user.id,
        role: user.role,
        email: user.email,
      );
    }
    
    return user;
  }

  @override
  Future<void> logout() async {
    await remoteDataSource.logout();
    
    // Clear auth data from secure storage
    if (secureStorage != null) {
      await secureStorage!.clearAuthData();
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    // Try to get from remote first
    try {
      final user = await remoteDataSource.getCurrentUser();
      return user;
    } catch (e) {
      // If remote fails, try to get from cache
      return null;
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    if (secureStorage != null) {
      return await secureStorage!.isLoggedIn();
    }
    return false;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await remoteDataSource.sendPasswordResetEmail(email);
  }
}