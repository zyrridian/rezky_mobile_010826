import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio;

  ApiService() : _dio = Dio(BaseOptions(
    baseUrl: 'https://reqres.in/api', // test API
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  Future<Response> post(String path, {dynamic data}) async {
    try {
      final response = await _dio.post(path, data: data);
      return response;
    } on DioException catch (e) {
      throw Exception(e.response?.data['error'] ?? 'API Error: ${e.message}');
    }
  }

  Future<Response> get(String path) async {
    try {
      final response = await _dio.get(path);
      return response;
    } on DioException catch (e) {
      throw Exception(e.response?.data['error'] ?? 'API Error: ${e.message}');
    }
  }
}
