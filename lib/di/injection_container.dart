// lib/di/injection_container.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/network/network_info.dart';
import '../core/services/firebase_service.dart';
import '../core/services/secure_storage_service.dart';
import '../data/datasources/remote/auth_remote_datasource.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../data/repositories/booking_repository_impl.dart';
import '../data/repositories/notification_repository_impl.dart';
import '../data/repositories/review_repository_impl.dart';
import '../data/repositories/chat_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/booking_repository.dart';
import '../domain/repositories/notification_repository.dart';
import '../domain/repositories/review_repository.dart';
import '../domain/repositories/chat_repository.dart';
import '../domain/usecases/auth/login_usecase.dart';
import '../domain/usecases/auth/register_usecase.dart';
import '../domain/usecases/auth/logout_usecase.dart';
import '../domain/usecases/auth/get_current_user_usecase.dart';
import '../domain/usecases/auth/check_auth_usecase.dart';

// ==================== Singleton Instances ====================
SharedPreferences? _sharedPrefs;
FlutterSecureStorage? _secureStorage;
FirebaseAuth? _firebaseAuth;
FirebaseFirestore? _firestore;
FirebaseStorage? _firebaseStorage;
Connectivity? _connectivity;
NetworkInfo? _networkInfo;

// ==================== Data Sources ====================
AuthRemoteDataSource? _authRemoteDataSource;

// ==================== Services ====================
FirebaseService? _firebaseService;
SecureStorageService? _secureStorageService;

// ==================== Repositories ====================
AuthRepository? _authRepository;
BookingRepository? _bookingRepository;
NotificationRepository? _notificationRepository;
ReviewRepository? _reviewRepository;
ChatRepository? _chatRepository;

// ==================== Initialization ====================
Future<void> initializeDependencies() async {
  print('🔄 Initializing dependencies...');

  // Initialize local storage
  _sharedPrefs = await SharedPreferences.getInstance();
  _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // Initialize Firebase instances
  _firebaseAuth = FirebaseAuth.instance;
  _firestore = FirebaseFirestore.instance;
  _firebaseStorage = FirebaseStorage.instance;

  // Configure Firestore
  _firestore!.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  // Initialize connectivity
  _connectivity = Connectivity();
  _networkInfo = NetworkInfoImpl(connectivity: _connectivity!);

  // Initialize services
  _firebaseService = FirebaseService();
  _secureStorageService = SecureStorageService();

  // Initialize data sources
  _authRemoteDataSource = AuthRemoteDataSourceImpl(
    firebaseAuth: _firebaseAuth!,
    firestore: _firestore!,
  );

  // Initialize repositories
  _authRepository = AuthRepositoryImpl(
    remoteDataSource: _authRemoteDataSource!,
    secureStorage: _secureStorageService!,
  );

  _bookingRepository = BookingRepositoryImpl(firestore: _firestore!);
  _notificationRepository = NotificationRepositoryImpl(firestore: _firestore!);
  _reviewRepository = ReviewRepositoryImpl(firestore: _firestore!);
  _chatRepository = ChatRepositoryImpl(firestore: _firestore!);

  print('✅ Dependencies initialized successfully');
}

// ==================== Getters ====================
SharedPreferences get sharedPrefs {
  if (_sharedPrefs == null) throw StateError('Call initializeDependencies() first');
  return _sharedPrefs!;
}

FlutterSecureStorage get secureStorage {
  if (_secureStorage == null) throw StateError('Call initializeDependencies() first');
  return _secureStorage!;
}

FirebaseAuth get firebaseAuth {
  if (_firebaseAuth == null) throw StateError('Call initializeDependencies() first');
  return _firebaseAuth!;
}

FirebaseFirestore get firestore {
  if (_firestore == null) throw StateError('Call initializeDependencies() first');
  return _firestore!;
}

FirebaseStorage get firebaseStorage {
  if (_firebaseStorage == null) throw StateError('Call initializeDependencies() first');
  return _firebaseStorage!;
}

Connectivity get connectivity {
  if (_connectivity == null) throw StateError('Call initializeDependencies() first');
  return _connectivity!;
}

NetworkInfo get networkInfo {
  if (_networkInfo == null) throw StateError('Call initializeDependencies() first');
  return _networkInfo!;
}

FirebaseService get firebaseService {
  if (_firebaseService == null) throw StateError('Call initializeDependencies() first');
  return _firebaseService!;
}

SecureStorageService get secureStorageService {
  if (_secureStorageService == null) throw StateError('Call initializeDependencies() first');
  return _secureStorageService!;
}

AuthRepository get authRepository {
  if (_authRepository == null) throw StateError('Call initializeDependencies() first');
  return _authRepository!;
}

BookingRepository get bookingRepository {
  if (_bookingRepository == null) throw StateError('Call initializeDependencies() first');
  return _bookingRepository!;
}

NotificationRepository get notificationRepository {
  if (_notificationRepository == null) throw StateError('Call initializeDependencies() first');
  return _notificationRepository!;
}

ReviewRepository get reviewRepository {
  if (_reviewRepository == null) throw StateError('Call initializeDependencies() first');
  return _reviewRepository!;
}

ChatRepository get chatRepository {
  if (_chatRepository == null) throw StateError('Call initializeDependencies() first');
  return _chatRepository!;
}

// ==================== Riverpod Providers ====================

final firebaseServiceProvider = Provider<FirebaseService>((ref) => firebaseService);
final secureStorageProvider = Provider<SecureStorageService>((ref) => secureStorageService);
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => firebaseAuth);
final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) => firestore);
final firebaseStorageProvider = Provider<FirebaseStorage>((ref) => firebaseStorage);
final sharedPrefsProvider = Provider<SharedPreferences>((ref) => sharedPrefs);
final connectivityProvider = Provider<Connectivity>((ref) => connectivity);

final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return networkInfo;
});

final authRepositoryProvider = Provider<AuthRepository>((ref) => authRepository);
final bookingRepositoryProvider = Provider<BookingRepository>((ref) => bookingRepository);
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) => notificationRepository);
final reviewRepositoryProvider = Provider<ReviewRepository>((ref) => reviewRepository);
final chatRepositoryProvider = Provider<ChatRepository>((ref) => chatRepository);

final loginUseCaseProvider = Provider<LoginUseCase>((ref) => LoginUseCase(ref.watch(authRepositoryProvider)));
final registerUseCaseProvider = Provider<RegisterUseCase>((ref) => RegisterUseCase(ref.watch(authRepositoryProvider)));
final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) => LogoutUseCase(ref.watch(authRepositoryProvider)));
final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) => GetCurrentUserUseCase(ref.watch(authRepositoryProvider)));
final checkAuthUseCaseProvider = Provider<CheckAuthUseCase>((ref) => CheckAuthUseCase(ref.watch(authRepositoryProvider)));