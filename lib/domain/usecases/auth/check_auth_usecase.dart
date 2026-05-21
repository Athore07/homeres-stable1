// lib/domain/usecases/auth/check_auth_usecase.dart
import '../../repositories/auth_repository.dart';
    
class CheckAuthUseCase {
  final AuthRepository repository;

  CheckAuthUseCase(this.repository);

  Future<bool> call() async {
    return await repository.isLoggedIn();
  }
}