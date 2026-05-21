// lib/presentation/providers/auth/auth_providers.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/firebase_service.dart';
import '../../../data/datasources/remote/auth_remote_datasource.dart';
import '../../../data/repositories/auth_repository_impl.dart';
import '../../../domain/usecases/auth/login_usecase.dart';
import '../../../domain/usecases/auth/register_usecase.dart';
import '../../../domain/usecases/auth/logout_usecase.dart';
import '../../../domain/usecases/auth/get_current_user_usecase.dart';
import '../../../domain/usecases/auth/check_auth_usecase.dart';
import '../../providers/storage/secure_storage_provider.dart';

// Provider for FirebaseService (singleton)
final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService();
});

// Provider for FirebaseAuth
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

// Provider for FirebaseFirestore
final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

// Provider for AuthRemoteDataSource
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSourceImpl>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  final firestore = ref.watch(firebaseFirestoreProvider);
  return AuthRemoteDataSourceImpl(
    firebaseAuth: auth,
    firestore: firestore,
  );
});

// Provider for AuthRepositoryImpl
final authRepositoryProvider = Provider<AuthRepositoryImpl>((ref) {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  final secureStorage = ref.watch(secureStorageServiceProvider);
  return AuthRepositoryImpl(
    remoteDataSource: remoteDataSource,
    secureStorage: secureStorage,
  );
});

// Provider for LoginUseCase
final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return LoginUseCase(authRepository);
});

// Provider for RegisterUseCase
final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return RegisterUseCase(authRepository);
});

// Provider for LogoutUseCase
final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return LogoutUseCase(authRepository);
});

// Provider for GetCurrentUserUseCase
final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return GetCurrentUserUseCase(authRepository);
});

// Provider for CheckAuthUseCase
final checkAuthUseCaseProvider = Provider<CheckAuthUseCase>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return CheckAuthUseCase(authRepository);
});