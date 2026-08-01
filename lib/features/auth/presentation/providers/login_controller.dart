import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/database/app_database.dart';
import '../../data/datasources/remote/auth_remote_datasource.dart';
import '../../data/datasources/local/auth_local_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/usecases/login_usecase.dart';

import 'login_state.dart';

final apiServiceProvider = Provider((ref) => ApiService());
final databaseProvider = Provider((ref) => AppDatabase());

final remoteDataSourceProvider = Provider((ref) {
  return AuthRemoteDataSource(ref.watch(apiServiceProvider));
});

final localDataSourceProvider = Provider((ref) {
  return AuthLocalDataSource(ref.watch(databaseProvider));
});

final authRepositoryProvider = Provider((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(remoteDataSourceProvider),
    localDataSource: ref.watch(localDataSourceProvider),
  );
});

final loginUseCaseProvider = Provider((ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
});

class LoginController extends Notifier<AuthState> {
  @override
  AuthState build() {
    return AuthInitial();
  }

  Future<void> login(String email, String password) async {
    state = AuthLoading();
    try {
      final user = await ref.read(loginUseCaseProvider).execute(email, password);
      state = AuthSuccess(user);
    } catch (e) {
      state = AuthError(e.toString());
    }
  }
}

final loginControllerProvider = NotifierProvider<LoginController, AuthState>(LoginController.new);

