import 'package:knowledge/core/network/api_service.dart';
import 'package:knowledge/data/models/user.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:knowledge/data/models/user_profile.dart';
import 'package:knowledge/data/repositories/profile_repository.dart';
import 'package:knowledge/core/utils/debug_utils.dart';

part 'auth_repository.g.dart';

class AuthRepository {
  final ApiService _apiService;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final ProfileRepository _profileRepository = ProfileRepository();

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
          DebugUtils.debugLog(
              'Login - Found Set-Cookie header: $setCookieHeader');
          // Store the complete session cookie
          await _storage.write(key: 'session_cookie', value: setCookieHeader);

          // Verify storage
          final storedCookie = await _storage.read(key: 'session_cookie');
          DebugUtils.debugLog(
              'Login - Stored cookie verification: $storedCookie');
        } else {
          DebugUtils.debugLog('Login - No Set-Cookie header found in response');
          DebugUtils.debugLog('Login - All headers: ${response.headers.map}');
        }

        // First get basic user data from login response
        final loginUserData = response.data['user'];
        final userId = loginUserData['id'].toString();
        final userEmail = loginUserData['email'];
        final username = userEmail.split('@')[0];

        // Now get the complete user profile with verification status
        try {
          final profileResponse = await _apiService.get('/auth/user/me');
          if (profileResponse.statusCode == 200) {
            final profileUserData = profileResponse.data['user'] ?? {};
            final isVerified = profileUserData['is_verified'] ?? false;

            print('Login - Profile API user data: $profileUserData');
            print('Login - Profile API is_verified: $isVerified');
            print(
                'Login - Login API is_verified: ${loginUserData['is_verified']}');

            // Use the verification status from the profile API
            return User(
              id: userId,
              email: userEmail,
              username: username,
              isEmailVerified: isVerified,
            );
          } else {
            print('Failed to fetch profile after login, using login data');
            // Fallback to login response data if profile fetch fails
            return User(
              id: userId,
              email: userEmail,
              username: username,
              isEmailVerified: loginUserData['is_verified'] ?? false,
            );
          }
        } catch (profileError) {
          print('Error fetching profile after login: $profileError');
          // Fallback to login response data if profile fetch fails
          return User(
            id: userId,
            email: userEmail,
            username: username,
            isEmailVerified: loginUserData['is_verified'] ?? false,
          );
        }
      } else {
        final message = response.data['detail'] ??
            response.data['message'] ??
            'Authentication failed';
        throw message.toString();
      }
    } catch (e) {
      DebugUtils.debugError('Login error: $e');
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

      DebugUtils.debugLog('Signup Response: ${response.data}');

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
      // Try to call logout API first
      await _apiService.post('/auth/logout');
    } catch (e) {
      // Log error but don't throw - we still want to clear local storage
      print('Logout API call failed: $e');
    } finally {
      // Always clear session storage regardless of API success/failure
      try {
        await _storage.delete(key: 'session_cookie');
      } catch (e) {
        print('Error clearing session storage: $e');
        // Don't throw here - logout should always succeed locally
      }
    }
  }

  Future<bool> checkSession() async {
    try {
      // Check if we have a session cookie
      final cookie = await _storage.read(key: 'session_cookie');
      if (cookie == null || cookie.isEmpty) {
        print('No session cookie found');
        return false;
      }

      // Verify the session with the server
      final response = await _apiService.get('/auth/user/me');
      return response.statusCode == 200;
    } catch (e) {
      print('Session check error: $e');
      return false;
    }
  }

  // Get user from existing session
  Future<User> getUserFromSession() async {
    try {
      final response = await _apiService.get('/auth/user/me');

      if (response.statusCode == 200) {
        final userData = response.data['user'] ?? {};
        final isVerified = userData['is_verified'] ?? false;

        print('getUserFromSession - User data: $userData');
        print('getUserFromSession - is_verified: $isVerified');

        return User(
          id: userData['id']?.toString() ?? '',
          email: userData['email'] ?? '',
          username: (userData['email'] ?? '').toString().split('@')[0],
          isEmailVerified: isVerified,
        );
      } else {
        throw 'Failed to get user data from session';
      }
    } catch (e) {
      print('Error getting user from session: $e');
      throw 'Failed to restore session: ${e.toString()}';
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

  Future<void> verifyEmail(String email, String otp) async {
    try {
      final response = await _apiService.post(
        '/auth/verify-email',
        data: {
          'email': email,
          'otp': otp,
        },
      );

      if (response.statusCode == 200) {
        return; // Successful verification
      } else {
        final message = response.data['detail'] ??
            response.data['message'] ??
            'Email verification failed';
        throw message.toString();
      }
    } on DioException catch (e) {
      print('DioException in verifyEmail: ${e.response?.data}');

      if (e.response?.data != null) {
        final message =
            e.response?.data['detail'] ?? e.response?.data['message'];
        if (message != null) throw message.toString();
      }
      throw 'Connection error. Please try again.';
    }
  }

  Future<void> resendVerificationEmail(String email) async {
    try {
      final response = await _apiService.post(
        '/auth/resend-verification',
        data: {
          'email': email,
        },
      );

      if (response.statusCode == 200) {
        return; // Successful resend
      } else {
        final message = response.data['detail'] ??
            response.data['message'] ??
            'Failed to resend verification email';
        throw message.toString();
      }
    } on DioException catch (e) {
      print('DioException in resendVerificationEmail: ${e.response?.data}');

      if (e.response?.data != null) {
        final message =
            e.response?.data['detail'] ?? e.response?.data['message'];
        if (message != null) throw message.toString();
      }
      throw 'Connection error. Please try again.';
    }
  }

  // Check if the current user's email is verified
  Future<bool> checkUserVerificationStatus() async {
    try {
      final response = await _apiService.get('/auth/user/me');

      if (response.statusCode == 200) {
        final userData = response.data['user'] ?? {};
        return userData['is_verified'] ?? false;
      } else {
        throw 'Failed to check verification status';
      }
    } catch (e) {
      print('Error checking user verification status: $e');
      throw 'Failed to check verification status: ${e.toString()}';
    }
  }

  // Get user email for verification purposes
  Future<String> getCurrentUserEmail() async {
    try {
      final response = await _apiService.get('/auth/user/me');

      if (response.statusCode == 200) {
        final userData = response.data['user'] ?? {};
        return userData['email'] ?? '';
      } else {
        throw 'Failed to get user email';
      }
    } catch (e) {
      print('Error getting current user email: $e');
      throw 'Failed to get user email: ${e.toString()}';
    }
  }

  Future<bool> hasCompletedProfileSetup() async {
    try {
      // Use the ProfileRepository's hasCompletedProfile method
      return await _profileRepository.hasCompletedProfile();
    } catch (e) {
      print('Error checking profile setup: $e');
      return false;
    }
  }

  Future<UserProfile> getUserProfile() async {
    try {
      final response = await _apiService.get('/auth/user/me');

      if (response.statusCode == 200) {
        // Handle the new nested response structure
        final userData = response.data['user'] ?? {};
        final profileData = response.data['profile'] ?? {};

        return UserProfile(
          email: userData['email'] ?? '',
          nickname: profileData['nickname'],
          location: profileData['location'],
          preferredLanguage: profileData['language_preference'] ?? 'English',
          pronouns: profileData['pronouns'],
        );
      }
      throw 'Failed to load profile';
    } catch (e) {
      throw 'Error loading profile: $e';
    }
  }

  Future<void> deleteAccount(String password,
      {Map<String, dynamic>? feedback}) async {
    try {
      Map<String, dynamic> data = {
        'password': password,
      };

      // Add feedback data if provided
      if (feedback != null && feedback.isNotEmpty) {
        // Add each feedback item individually to ensure type safety
        feedback.forEach((key, value) {
          data[key] = value;
        });
      }

      final response = await _apiService.delete(
        '/auth/delete-user',
        data: data,
      );

      print('Delete account response status: ${response.statusCode}');
      print('Delete account response data: ${response.data}');

      // Accept both 200 (OK) and 204 (No Content) as success for DELETE operations
      if (response.statusCode != 200 && response.statusCode != 204) {
        final message = response.data['detail'] ??
            response.data['message'] ??
            'Account deletion failed';
        throw message.toString();
      }

      // Clear session storage after successful deletion
      await _storage.delete(key: 'session_cookie');

      print('Account deleted successfully and session cleared');
    } on DioException catch (e) {
      print('DioException in deleteAccount: ${e.response?.statusCode}');
      print('DioException response data: ${e.response?.data}');

      if (e.response?.statusCode == 401) {
        throw 'Incorrect password. Please try again.';
      } else if (e.response?.statusCode == 204) {
        // 204 No Content is actually a success for DELETE operations
        // Clear session storage and return successfully
        await _storage.delete(key: 'session_cookie');
        print('Account deleted successfully (204 No Content)');
        return;
      } else if (e.response?.data != null) {
        final message = e.response?.data['detail'] ??
            e.response?.data['message'] ??
            'Account deletion failed';
        throw message.toString();
      }
      throw 'Connection error. Please try again.';
    } catch (e) {
      print('General error in deleteAccount: $e');
      throw 'Account deletion failed: ${e.toString()}';
    }
  }
}

@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  return AuthRepository();
}
