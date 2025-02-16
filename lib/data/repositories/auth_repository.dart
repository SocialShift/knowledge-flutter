import 'package:knowledge/core/network/api_service.dart';
import 'package:knowledge/data/models/user.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dio/dio.dart';

part 'auth_repository.g.dart';

class AuthRepository {
  final ApiService _apiService;

  AuthRepository() : _apiService = ApiService();

  Future<User> login(String email, String password) async {
    try {
      final response = await _apiService.post(
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
        final message = response.data['detail'] ??
            response.data['message'] ??
            'Authentication failed';
        throw message.toString();
      }
    } on DioException catch (e) {
      if (e.response?.data != null) {
        final message = e.response?.data['detail'] ??
            e.response?.data['message'] ??
            'Authentication failed';
        throw message.toString();
      }
      throw 'Connection error. Please try again.';
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  Future<void> signup(
      String email, String password, String confirmPassword) async {
    try {
      final response = await _apiService.post(
        '/auth/create-user',
        data: {
          'email': email,
          'password': password,
          'confirm_password': confirmPassword,
        },
      );

      print('Signup Response: ${response.data}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        return; // Successful registration
      } else {
        final message = response.data['detail'] ??
            response.data['message'] ??
            'Registration failed';
        throw message.toString();
      }
    } on DioException catch (e) {
      print('DioException in signup: ${e.response?.data}');

      if (e.response?.data != null) {
        final message =
            e.response?.data['detail'] ?? e.response?.data['message'];
        if (message != null) throw message.toString();
      }
      throw 'Connection error. Please try again.';
    }
  }

  Future<void> logout() async {
    await _apiService.post(dotenv.env['AUTH_LOGOUT_ENDPOINT']!);
  }

  Future<void> forgotPassword(String email) async {
    final response = await _apiService.post(
      '/auth/forgot-password',
      data: {'email': email},
    );

    if (response.statusCode != 200) {
      final message = response.data['detail'] ?? 'Password reset failed';
      throw message.toString();
    }
  }
}

@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  return AuthRepository();
}
