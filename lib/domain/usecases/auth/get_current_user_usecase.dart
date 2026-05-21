// lib/domain/usecases/auth/get_current_user_usecase.dart
import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';

class GetCurrentUserUseCase {
  final AuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  Future<UserEntity?> call() async {
    return await repository.getCurrentUser();
  }
}