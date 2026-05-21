// lib/presentation/providers/auth/auth_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../domain/entities/user.dart';
import 'auth_providers.dart';

part 'auth_provider.g.dart';

// Auth State
class AuthState {
  final UserEntity? user;
  final bool isLoading;
  final String? error;

  const AuthState({this.user, this.isLoading = false, this.error});

  AuthState copyWith({UserEntity? user, bool? isLoading, String? error}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  factory AuthState.initial() => const AuthState();
}

@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AuthState build() {
    _checkAuthStatus();
    return const AuthState(isLoading: false);
  }

  Future<void> _checkAuthStatus() async {
    try {
      final checkAuthUseCase = ref.read(checkAuthUseCaseProvider);
      final isLoggedIn = await checkAuthUseCase();
      
      if (isLoggedIn) {
        final getCurrentUserUseCase = ref.read(getCurrentUserUseCaseProvider);
        final user = await getCurrentUserUseCase();
        state = state.copyWith(user: user);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final loginUseCase = ref.read(loginUseCaseProvider);
      final user = await loginUseCase(email.trim(), password);
      
      // Save login state
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', true);
      await prefs.setBool('onboarding_complete', true);
      await prefs.setString('user_role', user.role);
      
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      final errorMessage = _parseAuthError(e.toString());
      state = state.copyWith(error: errorMessage, isLoading: false);
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final registerUseCase = ref.read(registerUseCaseProvider);
      final user = await registerUseCase(
        name: name.trim(),
        email: email.trim(),
        password: password,
        role: role,
      );
      
      // Save login state
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', true);
      await prefs.setBool('onboarding_complete', true);
      await prefs.setString('user_role', user.role);
      
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> logout() async {
    try {
      final logoutUseCase = ref.read(logoutUseCaseProvider);
      await logoutUseCase();
      state = AuthState.initial();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void clearError() {
    if (state.error != null) {
      state = state.copyWith(error: null);
    }
  }

  String _parseAuthError(String error) {
    if (error.contains('user-not-found') || error.contains('wrong-password')) {
      return 'Invalid email or password';
    }
    if (error.contains('user-disabled')) {
      return 'This account has been disabled';
    }
    if (error.contains('network-request-failed')) {
      return 'No internet connection. Please check your network';
    }
    return error;
  }
}