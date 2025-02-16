import 'package:dio/dio.dart';
import 'package:knowledge/core/config/app_config.dart';
import 'package:knowledge/data/models/user.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

part 'auth_repository.g.dart';

class AuthRepository {
  final Dio _dio;

  AuthRepository() : _dio = Dio() {
    _dio.options.baseUrl = dotenv.env['API_BASE_URL']!;
    _dio.options.headers = AppConfig.headers;
    _dio.options.validateStatus = (status) => status! < 500;
  }

  Future<User> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final userData = response.data['user'] ?? response.data;
        return User.fromJson(userData);
      } else {
        final message = response.data['detail'] ?? 'Authentication failed';
        throw message.toString();
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  String _handleDioError(DioException e) {
    if (e.response != null) {
      // Handle specific API error messages
      final message = e.response?.data['detail'] ?? e.response?.data['message'];
      if (message != null) return message.toString();
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.badResponse:
        return 'Server error. Please try again later.';
      case DioExceptionType.connectionError:
        return 'No internet connection. Please check your network.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  Future<User> signup(
      String email, String password, String confirmPassword) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {
          'email': email,
          'password': password,
          'confirm_password': confirmPassword,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Return a success message instead of user data
        throw 'Registration successful! Please login to continue.';
      } else {
        final message = response.data['detail'] ?? 'Registration failed';
        throw message.toString();
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<void> logout() async {
    // If your API has a logout endpoint, implement it here
    await Future.delayed(const Duration(milliseconds: 100));
  }

  Future<void> forgotPassword(String email) async {
    try {
      final response = await _dio.post(
        AppConfig.forgotPasswordEndpoint,
        data: {
          'email': email,
        },
      );

      if (response.statusCode != 200) {
        final message = response.data['detail'] ?? 'Password reset failed';
        throw message.toString();
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }
}

@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  return AuthRepository();
}
