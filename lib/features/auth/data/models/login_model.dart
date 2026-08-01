import '../../domain/entities/login.dart';

class LoginModel extends LoginEntity {
  LoginModel({
    required super.token,
    required super.email,
    required super.role,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json, String email, String role) {
    return LoginModel(
      token: json['token'] ?? '',
      email: email, 
      role: role,
    );
  }
}
