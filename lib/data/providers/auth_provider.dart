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
    print('Session restore started for user: ${user.email}');
    print('User email verification status: ${user.isEmailVerified}');

    // Check if email is verified before setting authenticated state
    if (!user.isEmailVerified) {
      // If email is not verified, set to email verification pending state
      state = AuthState.emailVerificationPending(
        email: user.email,
        message:
            'Please verify your email to continue. Check your inbox for verification code.',
      );
      print('Session restored - redirecting to email verification');
      return;
    }

    // Set the state to authenticated only if email is verified
    state = AuthState.authenticated(
      user: user,
      message: 'Welcome back, ${user.email}!',
      hasCompletedProfile: hasCompletedProfile,
    );

    print('Session restored successfully for verified user: ${user.email}');
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
    print('Logout process started');

    try {
      // Stop session checks first
      _sessionCheckTimer?.cancel();

      // Call logout API and clear storage
      await ref.read(authRepositoryProvider).logout();

      // Immediately set state to unauthenticated to prevent any race conditions
      state = const AuthState.unauthenticated(
        message: 'You have been logged out successfully.',
      );

      // Additional cleanup - invalidate auth repository to clear any cached state
      ref.invalidate(authRepositoryProvider);

      print('Logout completed successfully');
    } catch (e) {
      print('Logout error: $e');
      // Even if logout API fails, clear local state and storage
      _sessionCheckTimer?.cancel();

      try {
        // Try to force logout again which includes storage cleanup
        await ref.read(authRepositoryProvider).logout();
      } catch (_) {
        // Ignore secondary logout errors
      }

      // Set to unauthenticated state regardless of API error
      state = const AuthState.unauthenticated(
        message: 'You have been logged out.',
      );

      // Invalidate auth repository to clear any cached state
      ref.invalidate(authRepositoryProvider);

      print('Logout completed with local cleanup');
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

      print('Account deletion successful, setting unauthenticated state');
      state = const AuthState.unauthenticated(
        message: 'Account deleted successfully. Thank you for your feedback.',
      );
    } catch (e) {
      print('Account deletion failed: $e');
      // Add a small delay to ensure the loading state is visible
      await Future.delayed(const Duration(milliseconds: 500));
      state = AuthState.error(e.toString());
    }
  }

  // Force clear all authentication state - useful for troubleshooting
  Future<void> forceLogout() async {
    // Cancel any running timers
    _sessionCheckTimer?.cancel();

    // Clear storage directly
    try {
      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.logout();
    } catch (_) {
      // Ignore errors, we're force clearing
    }

    // Set unauthenticated state
    state = const AuthState.unauthenticated(
      message: 'Logged out successfully.',
    );

    // Invalidate providers to clear any cached data
    ref.invalidate(authRepositoryProvider);
  }

  // Clear current verification state to allow email change
  Future<void> clearVerificationState() async {
    print('Clearing verification state to allow email change');

    // Cancel any running timers
    _sessionCheckTimer?.cancel();

    // Clear storage to remove current session
    try {
      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.logout();
    } catch (_) {
      // Ignore errors, we're clearing state
    }

    // Set to initial state to allow fresh login
    state = const AuthState.initial();

    // Invalidate providers to clear any cached data
    ref.invalidate(authRepositoryProvider);

    print('Verification state cleared - user can now use different email');
  }

  // Mark profile setup as completed
  Future<void> markProfileSetupCompleted() async {
    // Only update if user is currently authenticated
    state.maybeMap(
      authenticated: (authState) {
        state = AuthState.authenticated(
          user: authState.user,
          message: authState.message,
          hasCompletedProfile: true,
        );
        print(
            'Profile setup marked as completed for user: ${authState.user.email}');
      },
      orElse: () {
        print(
            'Cannot mark profile setup as completed - user not authenticated');
      },
    );
  }

  // Clear any message from auth state (useful after account deletion)
  void clearMessage() {
    state.maybeMap(
      unauthenticated: (currentState) {
        state = const AuthState.unauthenticated();
        print('Auth message cleared');
      },
      orElse: () {
        // Don't clear messages for other states
      },
    );
  }
}
