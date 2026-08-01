import '../../../../../core/database/app_database.dart';
import '../../models/login_model.dart';

class AuthLocalDataSource {
  final AppDatabase appDatabase;

  AuthLocalDataSource(this.appDatabase);

  Future<void> saveToken(LoginModel loginModel) async {
    final db = await appDatabase.database;
    await db.insert('users', {
      'token': loginModel.token,
      'email': loginModel.email,
      'role': loginModel.role,
    });
  }

  Future<LoginModel?> getSavedUser() async {
    final db = await appDatabase.database;
    final result = await db.query('users', orderBy: 'id DESC', limit: 1);
    if (result.isNotEmpty) {
      final user = result.first;
      return LoginModel(
        token: user['token'] as String,
        email: user['email'] as String,
        role: user['role'] as String,
      );
    }
    return null;
  }

  Future<void> clearUser() async {
    final db = await appDatabase.database;
    await db.delete('users');
  }
}
