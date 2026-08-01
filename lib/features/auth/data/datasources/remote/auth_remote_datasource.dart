import '../../../../../core/services/api_service.dart';
import '../../models/login_model.dart';

class AuthRemoteDataSource {
  final ApiService apiService;

  AuthRemoteDataSource(this.apiService);

  Future<LoginModel> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    final responseData = {
      'token': 'QpwL5tke4Pnpja7X4',
    };

    if (email.isNotEmpty && password.isNotEmpty) {
      final role = email.toLowerCase() == 'admin@test.com' ? 'admin' : 'operator';
      return LoginModel.fromJson(responseData, email, role);
    } else {
      throw Exception('Failed to login: invalid credentials');
    }
  }
}
