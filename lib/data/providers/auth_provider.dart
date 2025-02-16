import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:knowledge/data/models/auth_state.dart';
import 'package:knowledge/data/repositories/auth_repository.dart';

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
    } catch (e) {
      state = AuthState.error(e.toString());
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
