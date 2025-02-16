import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:knowledge/data/models/auth_state.dart';
import 'package:knowledge/data/repositories/auth_repository.dart';
import 'package:dio/dio.dart';

part 'auth_provider.g.dart';

@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  @override
  AuthState build() => const AuthState.initial();

  Future<void> login(String email, String password) async {
    if (state.maybeMap(
      loading: (_) => true,
      orElse: () => false,
    )) return;

    state = const AuthState.loading();
    try {
      final user =
          await ref.read(authRepositoryProvider).login(email, password);
      state = AuthState.authenticated(
        user: user,
        message: 'Login successful! Welcome back.',
      );
    } on DioException catch (e) {
      String errorMessage;
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        errorMessage =
            'Connection timeout. Please check your internet and try again.';
      } else if (e.response?.statusCode == 401) {
        errorMessage = 'Invalid email or password.';
      } else if (e.response?.data != null) {
        errorMessage = e.response?.data['detail'] ??
            e.response?.data['message'] ??
            'Login failed. Please try again.';
      } else {
        errorMessage = 'An error occurred. Please try again.';
      }
      state = AuthState.error(errorMessage);
    } catch (e) {
      state =
          AuthState.error('An unexpected error occurred. Please try again.');
    }
  }

  Future<void> signup(
      String email, String password, String confirmPassword) async {
    if (state.maybeMap(
      loading: (_) => true,
      orElse: () => false,
    )) return;

    state = const AuthState.loading();
    try {
      await ref
          .read(authRepositoryProvider)
          .signup(email, password, confirmPassword);
      state = const AuthState.unauthenticated(
        message: 'Registration successful! Please login to continue.',
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
      state = AuthState.error(errorMessage);
    } catch (e) {
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
    )) return;

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
}
