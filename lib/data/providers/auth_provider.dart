import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:knowledge/data/models/auth_state.dart';
import 'package:knowledge/data/repositories/auth_repository.dart';
import 'package:knowledge/data/models/user.dart';
import 'package:dio/dio.dart';
import 'dart:async';

part 'auth_provider.g.dart';

@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  Timer? _sessionCheckTimer;

  @override
  AuthState build() => const AuthState.initial();

  @override
  void dispose() {
    _sessionCheckTimer?.cancel();
  }

  // Restore user session from a valid session token
  Future<void> restoreSession(User user, bool hasCompletedProfile) async {
    // Set the state immediately to avoid the login screen flash
    state = AuthState.authenticated(
      user: user,
      message: 'Welcome back, ${user.email}!',
      hasCompletedProfile: hasCompletedProfile,
    );

    print('Session restored for user: ${user.email}');
  }

  Future<void> login(String email, String password) async {
    if (state.maybeMap(
      loading: (_) => true,
      orElse: () => false,
    )) {
      return;
    }

    state = const AuthState.loading();

    try {
      final user =
          await ref.read(authRepositoryProvider).login(email, password);

      // Check if email is verified
      if (!user.isEmailVerified) {
        // Show loading state for a moment
        await Future.delayed(const Duration(milliseconds: 500));

        state = AuthState.emailVerificationPending(
          email: email,
          message:
              'Please verify your email to continue. Check your inbox for verification code.',
        );
        return;
      }

      // Check if profile is setup
      final hasProfile =
          await ref.read(authRepositoryProvider).hasCompletedProfileSetup();

      // Show loading state for a moment
      await Future.delayed(const Duration(milliseconds: 500));

      // Set authenticated state with user and additional info
      state = AuthState.authenticated(
        user: user,
        message: 'Welcome back, ${user.email}!',
        hasCompletedProfile: hasProfile,
      );
    } on DioException catch (e) {
      await Future.delayed(const Duration(milliseconds: 500));
      final errorMessage = _handleDioError(e);
      state = AuthState.error(errorMessage);
    } catch (e) {
      await Future.delayed(const Duration(milliseconds: 500));
      state = AuthState.error(e.toString());
    }
  }

  String _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Connection timeout. Please check your internet and try again.';
    } else if (e.response?.statusCode == 401) {
      return 'Invalid email or password.';
    } else if (e.response?.data != null) {
      return e.response?.data['detail'] ??
          e.response?.data['message'] ??
          'Authentication failed. Please try again.';
    }
    return 'An unexpected error occurred. Please try again.';
  }

  Future<void> signup(
      String email, String password, String confirmPassword) async {
    if (state.maybeMap(
      loading: (_) => true,
      orElse: () => false,
    )) {
      return;
    }

    state = const AuthState.loading();

    try {
      await ref
          .read(authRepositoryProvider)
          .signup(email, password, confirmPassword);

      // Add a small delay to ensure the loading state is visible
      await Future.delayed(const Duration(milliseconds: 500));

      state = AuthState.emailVerificationPending(
        email: email,
        message:
            'Account created successfully! Please check your email for verification code.',
      );
    } on DioException catch (e) {
      String errorMessage;
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        errorMessage =
            'Connection timeout. Please check your internet and try again.';
      } else if (e.response?.statusCode == 409) {
        errorMessage = 'Email already exists. Please use a different email.';
      } else if (e.response?.data != null) {
        errorMessage = e.response?.data['detail'] ??
            e.response?.data['message'] ??
            'Registration failed. Please try again.';
      } else {
        errorMessage = 'An error occurred. Please try again.';
      }
      // Add a small delay to ensure the loading state is visible
      await Future.delayed(const Duration(milliseconds: 500));
      state = AuthState.error(errorMessage);
    } catch (e) {
      // Add a small delay to ensure the loading state is visible
      await Future.delayed(const Duration(milliseconds: 500));
      state = AuthState.error(e.toString());
    }
  }

  Future<void> verifyEmail(String email, String otp) async {
    if (state.maybeMap(
      loading: (_) => true,
      orElse: () => false,
    )) {
      return;
    }

    state = const AuthState.loading();

    try {
      await ref.read(authRepositoryProvider).verifyEmail(email, otp);

      // Add a small delay to ensure the loading state is visible
      await Future.delayed(const Duration(milliseconds: 500));

      state = AuthState.emailVerified(
        email: email,
        message: 'Email verified successfully! Setting up your account...',
      );
    } on DioException catch (e) {
      String errorMessage;
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        errorMessage =
            'Connection timeout. Please check your internet and try again.';
      } else if (e.response?.statusCode == 400) {
        errorMessage = 'Invalid verification code. Please try again.';
      } else if (e.response?.data != null) {
        errorMessage = e.response?.data['detail'] ??
            e.response?.data['message'] ??
            'Email verification failed. Please try again.';
      } else {
        errorMessage = 'An error occurred. Please try again.';
      }
      // Add a small delay to ensure the loading state is visible
      await Future.delayed(const Duration(milliseconds: 500));
      state = AuthState.error(errorMessage);
    } catch (e) {
      // Add a small delay to ensure the loading state is visible
      await Future.delayed(const Duration(milliseconds: 500));
      state = AuthState.error(e.toString());
    }
  }

  Future<void> resendVerificationEmail(String email) async {
    if (state.maybeMap(
      loading: (_) => true,
      orElse: () => false,
    )) {
      return;
    }

    state = const AuthState.loading();

    try {
      await ref.read(authRepositoryProvider).resendVerificationEmail(email);

      // Add a small delay to ensure the loading state is visible
      await Future.delayed(const Duration(milliseconds: 500));

      state = AuthState.emailVerificationPending(
        email: email,
        message: 'Verification email sent! Please check your inbox.',
      );
    } on DioException catch (e) {
      String errorMessage;
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        errorMessage =
            'Connection timeout. Please check your internet and try again.';
      } else if (e.response?.data != null) {
        errorMessage = e.response?.data['detail'] ??
            e.response?.data['message'] ??
            'Failed to resend verification email. Please try again.';
      } else {
        errorMessage = 'An error occurred. Please try again.';
      }
      // Add a small delay to ensure the loading state is visible
      await Future.delayed(const Duration(milliseconds: 500));
      state = AuthState.error(errorMessage);
    } catch (e) {
      // Add a small delay to ensure the loading state is visible
      await Future.delayed(const Duration(milliseconds: 500));
      state = AuthState.error(e.toString());
    }
  }

  void loginAsGuest() {
    state = const AuthState.guest();
  }

  Future<void> logout() async {
    try {
      await ref.read(authRepositoryProvider).logout();
      state = const AuthState.unauthenticated(
        message: 'You have been logged out successfully.',
      );
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> forgotPassword(String email) async {
    if (state.maybeMap(
      loading: (_) => true,
      orElse: () => false,
    )) {
      return;
    }

    state = const AuthState.loading();
    try {
      await ref.read(authRepositoryProvider).forgotPassword(email);
      state = const AuthState.unauthenticated(
        message: 'Password reset instructions have been sent to your email.',
      );
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> checkSession() async {
    try {
      final isValid = await ref.read(authRepositoryProvider).checkSession();
      if (!isValid) {
        state = const AuthState.unauthenticated();
      }
    } catch (_) {
      state = const AuthState.unauthenticated();
    }
  }

  // Start periodic session checks
  void startSessionCheck() {
    _sessionCheckTimer?.cancel();
    _sessionCheckTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => checkSession(),
    );
  }

  // Check session validity when app is resumed
  Future<void> checkSessionValidity() async {
    // Only check if user is already authenticated
    if (state.maybeMap(
      authenticated: (_) => true,
      orElse: () => false,
    )) {
      await checkSession();
    }
  }

  // Check if current user's email is verified and redirect if not
  Future<void> checkAndHandleEmailVerification() async {
    // Only check if user is authenticated
    if (!state.maybeMap(
      authenticated: (_) => true,
      orElse: () => false,
    )) {
      return;
    }

    try {
      final isVerified =
          await ref.read(authRepositoryProvider).checkUserVerificationStatus();

      // Only take action if user is NOT verified
      if (!isVerified) {
        // Get user email for verification
        final email =
            await ref.read(authRepositoryProvider).getCurrentUserEmail();

        // Set state to email verification pending WITHOUT sending resend email
        // The user can manually resend if needed from the verification screen
        state = AuthState.emailVerificationPending(
          email: email,
          message:
              'Please verify your email to continue. Check your inbox for verification code.',
        );
      }
      // If user IS verified, do nothing - keep current authenticated state
    } catch (e) {
      print('Error checking email verification: $e');
      // Don't change state on error, just log it
    }
  }

  Future<void> deleteAccount(String password,
      {Map<String, dynamic>? feedback}) async {
    if (state.maybeMap(
      loading: (_) => true,
      orElse: () => false,
    )) {
      return;
    }

    state = const AuthState.loading();

    try {
      await ref
          .read(authRepositoryProvider)
          .deleteAccount(password, feedback: feedback);

      // Add a small delay to ensure the loading state is visible
      await Future.delayed(const Duration(milliseconds: 500));

      state = const AuthState.unauthenticated(
        message: 'Your account has been deleted successfully.',
      );
    } catch (e) {
      // Add a small delay to ensure the loading state is visible
      await Future.delayed(const Duration(milliseconds: 500));
      state = AuthState.error(e.toString());
    }
  }
}
