import '../entities/login.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<LoginEntity> execute(String email, String password) {
    return repository.login(email, password);
  }
}
