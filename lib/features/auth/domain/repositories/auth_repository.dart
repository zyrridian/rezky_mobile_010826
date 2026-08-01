import '../entities/login.dart';

abstract class AuthRepository {
  Future<LoginEntity> login(String email, String password);
  Future<void> logout();
  Future<LoginEntity?> getLoggedInUser();
}
