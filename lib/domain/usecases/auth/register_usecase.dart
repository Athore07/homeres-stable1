// lib/domain/usecases/auth/register_usecase.dart
import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<UserEntity> call({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    return await repository.register(name, email, password, role);
  }
}