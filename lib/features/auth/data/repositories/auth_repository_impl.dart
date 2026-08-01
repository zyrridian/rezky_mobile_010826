import '../../domain/entities/login.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local/auth_local_datasource.dart';
import '../datasources/remote/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<LoginEntity> login(String email, String password) async {
    final userModel = await remoteDataSource.login(email, password);
    await localDataSource.saveToken(userModel);
    return userModel;
  }

  @override
  Future<void> logout() async {
    await localDataSource.clearUser();
  }

  @override
  Future<LoginEntity?> getLoggedInUser() async {
    return await localDataSource.getSavedUser();
  }
}
