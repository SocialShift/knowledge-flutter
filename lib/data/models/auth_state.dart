import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:knowledge/data/models/user.dart';

part 'auth_state.freezed.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.authenticated({
    required User user,
    String? message,
    @Default(false) bool hasCompletedProfile,
  }) = _Authenticated;
  const factory AuthState.unauthenticated({
    String? message,
  }) = _Unauthenticated;
  const factory AuthState.emailVerificationPending({
    required String email,
    String? message,
  }) = _EmailVerificationPending;
  const factory AuthState.emailVerified({
    required String email,
    String? message,
  }) = _EmailVerified;
  const factory AuthState.passwordResetPending({
    required String email,
    String? message,
  }) = _PasswordResetPending;
  const factory AuthState.passwordResetVerified({
    required String email,
    required String otp,
    String? message,
  }) = _PasswordResetVerified;
  const factory AuthState.error(String message) = _Error;
  const factory AuthState.guest() = _Guest;
}
