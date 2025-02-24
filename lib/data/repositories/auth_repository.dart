import 'package:knowledge/core/network/api_service.dart';
import 'package:knowledge/data/models/user.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:knowledge/data/models/user_profile.dart';

part 'auth_repository.g.dart';

class AuthRepository {
  final ApiService _apiService;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

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
        // Get the Set-Cookie header value directly
        final setCookieHeader = response.headers.map['set-cookie']?.first;
        if (setCookieHeader != null) {
          print('Login - Found Set-Cookie header: $setCookieHeader');
          // Store the complete session cookie
          await _storage.write(key: 'session_cookie', value: setCookieHeader);

          // Verify storage
          final storedCookie = await _storage.read(key: 'session_cookie');
          print('Login - Stored cookie verification: $storedCookie');
        } else {
          print('Login - No Set-Cookie header found in response');
          print('Login - All headers: ${response.headers.map}');
        }

        final userData = response.data['user'];
        return User(
          id: userData['id'].toString(),
          email: userData['email'],
          username: userData['email'].split('@')[0],
          isEmailVerified: false,
        );
      } else {
        final message = response.data['detail'] ??
            response.data['message'] ??
            'Authentication failed';
        throw message.toString();
      }
    } catch (e) {
      print('Login error: $e');
      throw 'Authentication failed: ${e.toString()}';
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
    try {
      await _apiService.post('/auth/logout');
      await _storage.delete(key: 'session_cookie');
    } catch (e) {
      throw 'Logout failed';
    }
  }

  Future<bool> checkSession() async {
    try {
      final response = await _apiService.get('/auth/user/me');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
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

  Future<bool> hasCompletedProfileSetup() async {
    try {
      final response = await _apiService.get('/auth/user/me');

      // Check if response is successful and has user data
      if (response.statusCode == 200 && response.data != null) {
        final userData = response.data['user'] ?? response.data;

        // Check if nickname exists and is not empty
        final nickname = userData['nickname'] as String?;
        return nickname != null && nickname.isNotEmpty;
      }
      return false;
    } catch (e) {
      print('Error checking profile setup: $e');
      return false;
    }
  }

  Future<UserProfile> getUserProfile() async {
    try {
      final response = await _apiService.get('/auth/user/me');

      if (response.statusCode == 200) {
        final userData = response.data['user'] ?? response.data;
        return UserProfile(
          email: userData['email'] ?? '',
          nickname: userData['nickname'],
          location: userData['location'],
          preferredLanguage: userData['preferred_language'] ?? 'English',
          pronouns: userData['pronouns'],
        );
      }
      throw 'Failed to load profile';
    } catch (e) {
      throw 'Error loading profile: $e';
    }
  }
}

@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  return AuthRepository();
}
