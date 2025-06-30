// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$AuthState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
            User user, String? message, bool hasCompletedProfile)
        authenticated,
    required TResult Function(String? message) unauthenticated,
    required TResult Function(String email, String? message)
        emailVerificationPending,
    required TResult Function(String email, String? message) emailVerified,
    required TResult Function(String email, String? message)
        passwordResetPending,
    required TResult Function(String email, String otp, String? message)
        passwordResetVerified,
    required TResult Function(String message) error,
    required TResult Function() guest,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(User user, String? message, bool hasCompletedProfile)?
        authenticated,
    TResult? Function(String? message)? unauthenticated,
    TResult? Function(String email, String? message)? emailVerificationPending,
    TResult? Function(String email, String? message)? emailVerified,
    TResult? Function(String email, String? message)? passwordResetPending,
    TResult? Function(String email, String otp, String? message)?
        passwordResetVerified,
    TResult? Function(String message)? error,
    TResult? Function()? guest,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(User user, String? message, bool hasCompletedProfile)?
        authenticated,
    TResult Function(String? message)? unauthenticated,
    TResult Function(String email, String? message)? emailVerificationPending,
    TResult Function(String email, String? message)? emailVerified,
    TResult Function(String email, String? message)? passwordResetPending,
    TResult Function(String email, String otp, String? message)?
        passwordResetVerified,
    TResult Function(String message)? error,
    TResult Function()? guest,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Authenticated value) authenticated,
    required TResult Function(_Unauthenticated value) unauthenticated,
    required TResult Function(_EmailVerificationPending value)
        emailVerificationPending,
    required TResult Function(_EmailVerified value) emailVerified,
    required TResult Function(_PasswordResetPending value) passwordResetPending,
    required TResult Function(_PasswordResetVerified value)
        passwordResetVerified,
    required TResult Function(_Error value) error,
    required TResult Function(_Guest value) guest,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Authenticated value)? authenticated,
    TResult? Function(_Unauthenticated value)? unauthenticated,
    TResult? Function(_EmailVerificationPending value)?
        emailVerificationPending,
    TResult? Function(_EmailVerified value)? emailVerified,
    TResult? Function(_PasswordResetPending value)? passwordResetPending,
    TResult? Function(_PasswordResetVerified value)? passwordResetVerified,
    TResult? Function(_Error value)? error,
    TResult? Function(_Guest value)? guest,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Authenticated value)? authenticated,
    TResult Function(_Unauthenticated value)? unauthenticated,
    TResult Function(_EmailVerificationPending value)? emailVerificationPending,
    TResult Function(_EmailVerified value)? emailVerified,
    TResult Function(_PasswordResetPending value)? passwordResetPending,
    TResult Function(_PasswordResetVerified value)? passwordResetVerified,
    TResult Function(_Error value)? error,
    TResult Function(_Guest value)? guest,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthStateCopyWith<$Res> {
  factory $AuthStateCopyWith(AuthState value, $Res Function(AuthState) then) =
      _$AuthStateCopyWithImpl<$Res, AuthState>;
}

/// @nodoc
class _$AuthStateCopyWithImpl<$Res, $Val extends AuthState>
    implements $AuthStateCopyWith<$Res> {
  _$AuthStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$InitialImplCopyWith<$Res> {
  factory _$$InitialImplCopyWith(
          _$InitialImpl value, $Res Function(_$InitialImpl) then) =
      __$$InitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$InitialImplCopyWithImpl<$Res>
    extends _$AuthStateCopyWithImpl<$Res, _$InitialImpl>
    implements _$$InitialImplCopyWith<$Res> {
  __$$InitialImplCopyWithImpl(
      _$InitialImpl _value, $Res Function(_$InitialImpl) _then)
      : super(_value, _then);

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$InitialImpl implements _Initial {
  const _$InitialImpl();

  @override
  String toString() {
    return 'AuthState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$InitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
            User user, String? message, bool hasCompletedProfile)
        authenticated,
    required TResult Function(String? message) unauthenticated,
    required TResult Function(String email, String? message)
        emailVerificationPending,
    required TResult Function(String email, String? message) emailVerified,
    required TResult Function(String email, String? message)
        passwordResetPending,
    required TResult Function(String email, String otp, String? message)
        passwordResetVerified,
    required TResult Function(String message) error,
    required TResult Function() guest,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(User user, String? message, bool hasCompletedProfile)?
        authenticated,
    TResult? Function(String? message)? unauthenticated,
    TResult? Function(String email, String? message)? emailVerificationPending,
    TResult? Function(String email, String? message)? emailVerified,
    TResult? Function(String email, String? message)? passwordResetPending,
    TResult? Function(String email, String otp, String? message)?
        passwordResetVerified,
    TResult? Function(String message)? error,
    TResult? Function()? guest,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(User user, String? message, bool hasCompletedProfile)?
        authenticated,
    TResult Function(String? message)? unauthenticated,
    TResult Function(String email, String? message)? emailVerificationPending,
    TResult Function(String email, String? message)? emailVerified,
    TResult Function(String email, String? message)? passwordResetPending,
    TResult Function(String email, String otp, String? message)?
        passwordResetVerified,
    TResult Function(String message)? error,
    TResult Function()? guest,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Authenticated value) authenticated,
    required TResult Function(_Unauthenticated value) unauthenticated,
    required TResult Function(_EmailVerificationPending value)
        emailVerificationPending,
    required TResult Function(_EmailVerified value) emailVerified,
    required TResult Function(_PasswordResetPending value) passwordResetPending,
    required TResult Function(_PasswordResetVerified value)
        passwordResetVerified,
    required TResult Function(_Error value) error,
    required TResult Function(_Guest value) guest,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Authenticated value)? authenticated,
    TResult? Function(_Unauthenticated value)? unauthenticated,
    TResult? Function(_EmailVerificationPending value)?
        emailVerificationPending,
    TResult? Function(_EmailVerified value)? emailVerified,
    TResult? Function(_PasswordResetPending value)? passwordResetPending,
    TResult? Function(_PasswordResetVerified value)? passwordResetVerified,
    TResult? Function(_Error value)? error,
    TResult? Function(_Guest value)? guest,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Authenticated value)? authenticated,
    TResult Function(_Unauthenticated value)? unauthenticated,
    TResult Function(_EmailVerificationPending value)? emailVerificationPending,
    TResult Function(_EmailVerified value)? emailVerified,
    TResult Function(_PasswordResetPending value)? passwordResetPending,
    TResult Function(_PasswordResetVerified value)? passwordResetVerified,
    TResult Function(_Error value)? error,
    TResult Function(_Guest value)? guest,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class _Initial implements AuthState {
  const factory _Initial() = _$InitialImpl;
}

/// @nodoc
abstract class _$$LoadingImplCopyWith<$Res> {
  factory _$$LoadingImplCopyWith(
          _$LoadingImpl value, $Res Function(_$LoadingImpl) then) =
      __$$LoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$LoadingImplCopyWithImpl<$Res>
    extends _$AuthStateCopyWithImpl<$Res, _$LoadingImpl>
    implements _$$LoadingImplCopyWith<$Res> {
  __$$LoadingImplCopyWithImpl(
      _$LoadingImpl _value, $Res Function(_$LoadingImpl) _then)
      : super(_value, _then);

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$LoadingImpl implements _Loading {
  const _$LoadingImpl();

  @override
  String toString() {
    return 'AuthState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$LoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
            User user, String? message, bool hasCompletedProfile)
        authenticated,
    required TResult Function(String? message) unauthenticated,
    required TResult Function(String email, String? message)
        emailVerificationPending,
    required TResult Function(String email, String? message) emailVerified,
    required TResult Function(String email, String? message)
        passwordResetPending,
    required TResult Function(String email, String otp, String? message)
        passwordResetVerified,
    required TResult Function(String message) error,
    required TResult Function() guest,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(User user, String? message, bool hasCompletedProfile)?
        authenticated,
    TResult? Function(String? message)? unauthenticated,
    TResult? Function(String email, String? message)? emailVerificationPending,
    TResult? Function(String email, String? message)? emailVerified,
    TResult? Function(String email, String? message)? passwordResetPending,
    TResult? Function(String email, String otp, String? message)?
        passwordResetVerified,
    TResult? Function(String message)? error,
    TResult? Function()? guest,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(User user, String? message, bool hasCompletedProfile)?
        authenticated,
    TResult Function(String? message)? unauthenticated,
    TResult Function(String email, String? message)? emailVerificationPending,
    TResult Function(String email, String? message)? emailVerified,
    TResult Function(String email, String? message)? passwordResetPending,
    TResult Function(String email, String otp, String? message)?
        passwordResetVerified,
    TResult Function(String message)? error,
    TResult Function()? guest,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Authenticated value) authenticated,
    required TResult Function(_Unauthenticated value) unauthenticated,
    required TResult Function(_EmailVerificationPending value)
        emailVerificationPending,
    required TResult Function(_EmailVerified value) emailVerified,
    required TResult Function(_PasswordResetPending value) passwordResetPending,
    required TResult Function(_PasswordResetVerified value)
        passwordResetVerified,
    required TResult Function(_Error value) error,
    required TResult Function(_Guest value) guest,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Authenticated value)? authenticated,
    TResult? Function(_Unauthenticated value)? unauthenticated,
    TResult? Function(_EmailVerificationPending value)?
        emailVerificationPending,
    TResult? Function(_EmailVerified value)? emailVerified,
    TResult? Function(_PasswordResetPending value)? passwordResetPending,
    TResult? Function(_PasswordResetVerified value)? passwordResetVerified,
    TResult? Function(_Error value)? error,
    TResult? Function(_Guest value)? guest,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Authenticated value)? authenticated,
    TResult Function(_Unauthenticated value)? unauthenticated,
    TResult Function(_EmailVerificationPending value)? emailVerificationPending,
    TResult Function(_EmailVerified value)? emailVerified,
    TResult Function(_PasswordResetPending value)? passwordResetPending,
    TResult Function(_PasswordResetVerified value)? passwordResetVerified,
    TResult Function(_Error value)? error,
    TResult Function(_Guest value)? guest,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class _Loading implements AuthState {
  const factory _Loading() = _$LoadingImpl;
}

/// @nodoc
abstract class _$$AuthenticatedImplCopyWith<$Res> {
  factory _$$AuthenticatedImplCopyWith(
          _$AuthenticatedImpl value, $Res Function(_$AuthenticatedImpl) then) =
      __$$AuthenticatedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({User user, String? message, bool hasCompletedProfile});

  $UserCopyWith<$Res> get user;
}

/// @nodoc
class __$$AuthenticatedImplCopyWithImpl<$Res>
    extends _$AuthStateCopyWithImpl<$Res, _$AuthenticatedImpl>
    implements _$$AuthenticatedImplCopyWith<$Res> {
  __$$AuthenticatedImplCopyWithImpl(
      _$AuthenticatedImpl _value, $Res Function(_$AuthenticatedImpl) _then)
      : super(_value, _then);

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? user = null,
    Object? message = freezed,
    Object? hasCompletedProfile = null,
  }) {
    return _then(_$AuthenticatedImpl(
      user: null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as User,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
      hasCompletedProfile: null == hasCompletedProfile
          ? _value.hasCompletedProfile
          : hasCompletedProfile // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserCopyWith<$Res> get user {
    return $UserCopyWith<$Res>(_value.user, (value) {
      return _then(_value.copyWith(user: value));
    });
  }
}

/// @nodoc

class _$AuthenticatedImpl implements _Authenticated {
  const _$AuthenticatedImpl(
      {required this.user, this.message, this.hasCompletedProfile = false});

  @override
  final User user;
  @override
  final String? message;
  @override
  @JsonKey()
  final bool hasCompletedProfile;

  @override
  String toString() {
    return 'AuthState.authenticated(user: $user, message: $message, hasCompletedProfile: $hasCompletedProfile)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthenticatedImpl &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.hasCompletedProfile, hasCompletedProfile) ||
                other.hasCompletedProfile == hasCompletedProfile));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, user, message, hasCompletedProfile);

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthenticatedImplCopyWith<_$AuthenticatedImpl> get copyWith =>
      __$$AuthenticatedImplCopyWithImpl<_$AuthenticatedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
            User user, String? message, bool hasCompletedProfile)
        authenticated,
    required TResult Function(String? message) unauthenticated,
    required TResult Function(String email, String? message)
        emailVerificationPending,
    required TResult Function(String email, String? message) emailVerified,
    required TResult Function(String email, String? message)
        passwordResetPending,
    required TResult Function(String email, String otp, String? message)
        passwordResetVerified,
    required TResult Function(String message) error,
    required TResult Function() guest,
  }) {
    return authenticated(user, message, hasCompletedProfile);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(User user, String? message, bool hasCompletedProfile)?
        authenticated,
    TResult? Function(String? message)? unauthenticated,
    TResult? Function(String email, String? message)? emailVerificationPending,
    TResult? Function(String email, String? message)? emailVerified,
    TResult? Function(String email, String? message)? passwordResetPending,
    TResult? Function(String email, String otp, String? message)?
        passwordResetVerified,
    TResult? Function(String message)? error,
    TResult? Function()? guest,
  }) {
    return authenticated?.call(user, message, hasCompletedProfile);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(User user, String? message, bool hasCompletedProfile)?
        authenticated,
    TResult Function(String? message)? unauthenticated,
    TResult Function(String email, String? message)? emailVerificationPending,
    TResult Function(String email, String? message)? emailVerified,
    TResult Function(String email, String? message)? passwordResetPending,
    TResult Function(String email, String otp, String? message)?
        passwordResetVerified,
    TResult Function(String message)? error,
    TResult Function()? guest,
    required TResult orElse(),
  }) {
    if (authenticated != null) {
      return authenticated(user, message, hasCompletedProfile);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Authenticated value) authenticated,
    required TResult Function(_Unauthenticated value) unauthenticated,
    required TResult Function(_EmailVerificationPending value)
        emailVerificationPending,
    required TResult Function(_EmailVerified value) emailVerified,
    required TResult Function(_PasswordResetPending value) passwordResetPending,
    required TResult Function(_PasswordResetVerified value)
        passwordResetVerified,
    required TResult Function(_Error value) error,
    required TResult Function(_Guest value) guest,
  }) {
    return authenticated(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Authenticated value)? authenticated,
    TResult? Function(_Unauthenticated value)? unauthenticated,
    TResult? Function(_EmailVerificationPending value)?
        emailVerificationPending,
    TResult? Function(_EmailVerified value)? emailVerified,
    TResult? Function(_PasswordResetPending value)? passwordResetPending,
    TResult? Function(_PasswordResetVerified value)? passwordResetVerified,
    TResult? Function(_Error value)? error,
    TResult? Function(_Guest value)? guest,
  }) {
    return authenticated?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Authenticated value)? authenticated,
    TResult Function(_Unauthenticated value)? unauthenticated,
    TResult Function(_EmailVerificationPending value)? emailVerificationPending,
    TResult Function(_EmailVerified value)? emailVerified,
    TResult Function(_PasswordResetPending value)? passwordResetPending,
    TResult Function(_PasswordResetVerified value)? passwordResetVerified,
    TResult Function(_Error value)? error,
    TResult Function(_Guest value)? guest,
    required TResult orElse(),
  }) {
    if (authenticated != null) {
      return authenticated(this);
    }
    return orElse();
  }
}

abstract class _Authenticated implements AuthState {
  const factory _Authenticated(
      {required final User user,
      final String? message,
      final bool hasCompletedProfile}) = _$AuthenticatedImpl;

  User get user;
  String? get message;
  bool get hasCompletedProfile;

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AuthenticatedImplCopyWith<_$AuthenticatedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$UnauthenticatedImplCopyWith<$Res> {
  factory _$$UnauthenticatedImplCopyWith(_$UnauthenticatedImpl value,
          $Res Function(_$UnauthenticatedImpl) then) =
      __$$UnauthenticatedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String? message});
}

/// @nodoc
class __$$UnauthenticatedImplCopyWithImpl<$Res>
    extends _$AuthStateCopyWithImpl<$Res, _$UnauthenticatedImpl>
    implements _$$UnauthenticatedImplCopyWith<$Res> {
  __$$UnauthenticatedImplCopyWithImpl(
      _$UnauthenticatedImpl _value, $Res Function(_$UnauthenticatedImpl) _then)
      : super(_value, _then);

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = freezed,
  }) {
    return _then(_$UnauthenticatedImpl(
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$UnauthenticatedImpl implements _Unauthenticated {
  const _$UnauthenticatedImpl({this.message});

  @override
  final String? message;

  @override
  String toString() {
    return 'AuthState.unauthenticated(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UnauthenticatedImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UnauthenticatedImplCopyWith<_$UnauthenticatedImpl> get copyWith =>
      __$$UnauthenticatedImplCopyWithImpl<_$UnauthenticatedImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
            User user, String? message, bool hasCompletedProfile)
        authenticated,
    required TResult Function(String? message) unauthenticated,
    required TResult Function(String email, String? message)
        emailVerificationPending,
    required TResult Function(String email, String? message) emailVerified,
    required TResult Function(String email, String? message)
        passwordResetPending,
    required TResult Function(String email, String otp, String? message)
        passwordResetVerified,
    required TResult Function(String message) error,
    required TResult Function() guest,
  }) {
    return unauthenticated(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(User user, String? message, bool hasCompletedProfile)?
        authenticated,
    TResult? Function(String? message)? unauthenticated,
    TResult? Function(String email, String? message)? emailVerificationPending,
    TResult? Function(String email, String? message)? emailVerified,
    TResult? Function(String email, String? message)? passwordResetPending,
    TResult? Function(String email, String otp, String? message)?
        passwordResetVerified,
    TResult? Function(String message)? error,
    TResult? Function()? guest,
  }) {
    return unauthenticated?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(User user, String? message, bool hasCompletedProfile)?
        authenticated,
    TResult Function(String? message)? unauthenticated,
    TResult Function(String email, String? message)? emailVerificationPending,
    TResult Function(String email, String? message)? emailVerified,
    TResult Function(String email, String? message)? passwordResetPending,
    TResult Function(String email, String otp, String? message)?
        passwordResetVerified,
    TResult Function(String message)? error,
    TResult Function()? guest,
    required TResult orElse(),
  }) {
    if (unauthenticated != null) {
      return unauthenticated(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Authenticated value) authenticated,
    required TResult Function(_Unauthenticated value) unauthenticated,
    required TResult Function(_EmailVerificationPending value)
        emailVerificationPending,
    required TResult Function(_EmailVerified value) emailVerified,
    required TResult Function(_PasswordResetPending value) passwordResetPending,
    required TResult Function(_PasswordResetVerified value)
        passwordResetVerified,
    required TResult Function(_Error value) error,
    required TResult Function(_Guest value) guest,
  }) {
    return unauthenticated(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Authenticated value)? authenticated,
    TResult? Function(_Unauthenticated value)? unauthenticated,
    TResult? Function(_EmailVerificationPending value)?
        emailVerificationPending,
    TResult? Function(_EmailVerified value)? emailVerified,
    TResult? Function(_PasswordResetPending value)? passwordResetPending,
    TResult? Function(_PasswordResetVerified value)? passwordResetVerified,
    TResult? Function(_Error value)? error,
    TResult? Function(_Guest value)? guest,
  }) {
    return unauthenticated?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Authenticated value)? authenticated,
    TResult Function(_Unauthenticated value)? unauthenticated,
    TResult Function(_EmailVerificationPending value)? emailVerificationPending,
    TResult Function(_EmailVerified value)? emailVerified,
    TResult Function(_PasswordResetPending value)? passwordResetPending,
    TResult Function(_PasswordResetVerified value)? passwordResetVerified,
    TResult Function(_Error value)? error,
    TResult Function(_Guest value)? guest,
    required TResult orElse(),
  }) {
    if (unauthenticated != null) {
      return unauthenticated(this);
    }
    return orElse();
  }
}

abstract class _Unauthenticated implements AuthState {
  const factory _Unauthenticated({final String? message}) =
      _$UnauthenticatedImpl;

  String? get message;

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UnauthenticatedImplCopyWith<_$UnauthenticatedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$EmailVerificationPendingImplCopyWith<$Res> {
  factory _$$EmailVerificationPendingImplCopyWith(
          _$EmailVerificationPendingImpl value,
          $Res Function(_$EmailVerificationPendingImpl) then) =
      __$$EmailVerificationPendingImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String email, String? message});
}

/// @nodoc
class __$$EmailVerificationPendingImplCopyWithImpl<$Res>
    extends _$AuthStateCopyWithImpl<$Res, _$EmailVerificationPendingImpl>
    implements _$$EmailVerificationPendingImplCopyWith<$Res> {
  __$$EmailVerificationPendingImplCopyWithImpl(
      _$EmailVerificationPendingImpl _value,
      $Res Function(_$EmailVerificationPendingImpl) _then)
      : super(_value, _then);

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? email = null,
    Object? message = freezed,
  }) {
    return _then(_$EmailVerificationPendingImpl(
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$EmailVerificationPendingImpl implements _EmailVerificationPending {
  const _$EmailVerificationPendingImpl({required this.email, this.message});

  @override
  final String email;
  @override
  final String? message;

  @override
  String toString() {
    return 'AuthState.emailVerificationPending(email: $email, message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EmailVerificationPendingImpl &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, email, message);

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EmailVerificationPendingImplCopyWith<_$EmailVerificationPendingImpl>
      get copyWith => __$$EmailVerificationPendingImplCopyWithImpl<
          _$EmailVerificationPendingImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
            User user, String? message, bool hasCompletedProfile)
        authenticated,
    required TResult Function(String? message) unauthenticated,
    required TResult Function(String email, String? message)
        emailVerificationPending,
    required TResult Function(String email, String? message) emailVerified,
    required TResult Function(String email, String? message)
        passwordResetPending,
    required TResult Function(String email, String otp, String? message)
        passwordResetVerified,
    required TResult Function(String message) error,
    required TResult Function() guest,
  }) {
    return emailVerificationPending(email, message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(User user, String? message, bool hasCompletedProfile)?
        authenticated,
    TResult? Function(String? message)? unauthenticated,
    TResult? Function(String email, String? message)? emailVerificationPending,
    TResult? Function(String email, String? message)? emailVerified,
    TResult? Function(String email, String? message)? passwordResetPending,
    TResult? Function(String email, String otp, String? message)?
        passwordResetVerified,
    TResult? Function(String message)? error,
    TResult? Function()? guest,
  }) {
    return emailVerificationPending?.call(email, message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(User user, String? message, bool hasCompletedProfile)?
        authenticated,
    TResult Function(String? message)? unauthenticated,
    TResult Function(String email, String? message)? emailVerificationPending,
    TResult Function(String email, String? message)? emailVerified,
    TResult Function(String email, String? message)? passwordResetPending,
    TResult Function(String email, String otp, String? message)?
        passwordResetVerified,
    TResult Function(String message)? error,
    TResult Function()? guest,
    required TResult orElse(),
  }) {
    if (emailVerificationPending != null) {
      return emailVerificationPending(email, message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Authenticated value) authenticated,
    required TResult Function(_Unauthenticated value) unauthenticated,
    required TResult Function(_EmailVerificationPending value)
        emailVerificationPending,
    required TResult Function(_EmailVerified value) emailVerified,
    required TResult Function(_PasswordResetPending value) passwordResetPending,
    required TResult Function(_PasswordResetVerified value)
        passwordResetVerified,
    required TResult Function(_Error value) error,
    required TResult Function(_Guest value) guest,
  }) {
    return emailVerificationPending(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Authenticated value)? authenticated,
    TResult? Function(_Unauthenticated value)? unauthenticated,
    TResult? Function(_EmailVerificationPending value)?
        emailVerificationPending,
    TResult? Function(_EmailVerified value)? emailVerified,
    TResult? Function(_PasswordResetPending value)? passwordResetPending,
    TResult? Function(_PasswordResetVerified value)? passwordResetVerified,
    TResult? Function(_Error value)? error,
    TResult? Function(_Guest value)? guest,
  }) {
    return emailVerificationPending?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Authenticated value)? authenticated,
    TResult Function(_Unauthenticated value)? unauthenticated,
    TResult Function(_EmailVerificationPending value)? emailVerificationPending,
    TResult Function(_EmailVerified value)? emailVerified,
    TResult Function(_PasswordResetPending value)? passwordResetPending,
    TResult Function(_PasswordResetVerified value)? passwordResetVerified,
    TResult Function(_Error value)? error,
    TResult Function(_Guest value)? guest,
    required TResult orElse(),
  }) {
    if (emailVerificationPending != null) {
      return emailVerificationPending(this);
    }
    return orElse();
  }
}

abstract class _EmailVerificationPending implements AuthState {
  const factory _EmailVerificationPending(
      {required final String email,
      final String? message}) = _$EmailVerificationPendingImpl;

  String get email;
  String? get message;

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EmailVerificationPendingImplCopyWith<_$EmailVerificationPendingImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$EmailVerifiedImplCopyWith<$Res> {
  factory _$$EmailVerifiedImplCopyWith(
          _$EmailVerifiedImpl value, $Res Function(_$EmailVerifiedImpl) then) =
      __$$EmailVerifiedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String email, String? message});
}

/// @nodoc
class __$$EmailVerifiedImplCopyWithImpl<$Res>
    extends _$AuthStateCopyWithImpl<$Res, _$EmailVerifiedImpl>
    implements _$$EmailVerifiedImplCopyWith<$Res> {
  __$$EmailVerifiedImplCopyWithImpl(
      _$EmailVerifiedImpl _value, $Res Function(_$EmailVerifiedImpl) _then)
      : super(_value, _then);

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? email = null,
    Object? message = freezed,
  }) {
    return _then(_$EmailVerifiedImpl(
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$EmailVerifiedImpl implements _EmailVerified {
  const _$EmailVerifiedImpl({required this.email, this.message});

  @override
  final String email;
  @override
  final String? message;

  @override
  String toString() {
    return 'AuthState.emailVerified(email: $email, message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EmailVerifiedImpl &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, email, message);

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EmailVerifiedImplCopyWith<_$EmailVerifiedImpl> get copyWith =>
      __$$EmailVerifiedImplCopyWithImpl<_$EmailVerifiedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
            User user, String? message, bool hasCompletedProfile)
        authenticated,
    required TResult Function(String? message) unauthenticated,
    required TResult Function(String email, String? message)
        emailVerificationPending,
    required TResult Function(String email, String? message) emailVerified,
    required TResult Function(String email, String? message)
        passwordResetPending,
    required TResult Function(String email, String otp, String? message)
        passwordResetVerified,
    required TResult Function(String message) error,
    required TResult Function() guest,
  }) {
    return emailVerified(email, message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(User user, String? message, bool hasCompletedProfile)?
        authenticated,
    TResult? Function(String? message)? unauthenticated,
    TResult? Function(String email, String? message)? emailVerificationPending,
    TResult? Function(String email, String? message)? emailVerified,
    TResult? Function(String email, String? message)? passwordResetPending,
    TResult? Function(String email, String otp, String? message)?
        passwordResetVerified,
    TResult? Function(String message)? error,
    TResult? Function()? guest,
  }) {
    return emailVerified?.call(email, message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(User user, String? message, bool hasCompletedProfile)?
        authenticated,
    TResult Function(String? message)? unauthenticated,
    TResult Function(String email, String? message)? emailVerificationPending,
    TResult Function(String email, String? message)? emailVerified,
    TResult Function(String email, String? message)? passwordResetPending,
    TResult Function(String email, String otp, String? message)?
        passwordResetVerified,
    TResult Function(String message)? error,
    TResult Function()? guest,
    required TResult orElse(),
  }) {
    if (emailVerified != null) {
      return emailVerified(email, message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Authenticated value) authenticated,
    required TResult Function(_Unauthenticated value) unauthenticated,
    required TResult Function(_EmailVerificationPending value)
        emailVerificationPending,
    required TResult Function(_EmailVerified value) emailVerified,
    required TResult Function(_PasswordResetPending value) passwordResetPending,
    required TResult Function(_PasswordResetVerified value)
        passwordResetVerified,
    required TResult Function(_Error value) error,
    required TResult Function(_Guest value) guest,
  }) {
    return emailVerified(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Authenticated value)? authenticated,
    TResult? Function(_Unauthenticated value)? unauthenticated,
    TResult? Function(_EmailVerificationPending value)?
        emailVerificationPending,
    TResult? Function(_EmailVerified value)? emailVerified,
    TResult? Function(_PasswordResetPending value)? passwordResetPending,
    TResult? Function(_PasswordResetVerified value)? passwordResetVerified,
    TResult? Function(_Error value)? error,
    TResult? Function(_Guest value)? guest,
  }) {
    return emailVerified?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Authenticated value)? authenticated,
    TResult Function(_Unauthenticated value)? unauthenticated,
    TResult Function(_EmailVerificationPending value)? emailVerificationPending,
    TResult Function(_EmailVerified value)? emailVerified,
    TResult Function(_PasswordResetPending value)? passwordResetPending,
    TResult Function(_PasswordResetVerified value)? passwordResetVerified,
    TResult Function(_Error value)? error,
    TResult Function(_Guest value)? guest,
    required TResult orElse(),
  }) {
    if (emailVerified != null) {
      return emailVerified(this);
    }
    return orElse();
  }
}

abstract class _EmailVerified implements AuthState {
  const factory _EmailVerified(
      {required final String email,
      final String? message}) = _$EmailVerifiedImpl;

  String get email;
  String? get message;

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EmailVerifiedImplCopyWith<_$EmailVerifiedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$PasswordResetPendingImplCopyWith<$Res> {
  factory _$$PasswordResetPendingImplCopyWith(_$PasswordResetPendingImpl value,
          $Res Function(_$PasswordResetPendingImpl) then) =
      __$$PasswordResetPendingImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String email, String? message});
}

/// @nodoc
class __$$PasswordResetPendingImplCopyWithImpl<$Res>
    extends _$AuthStateCopyWithImpl<$Res, _$PasswordResetPendingImpl>
    implements _$$PasswordResetPendingImplCopyWith<$Res> {
  __$$PasswordResetPendingImplCopyWithImpl(_$PasswordResetPendingImpl _value,
      $Res Function(_$PasswordResetPendingImpl) _then)
      : super(_value, _then);

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? email = null,
    Object? message = freezed,
  }) {
    return _then(_$PasswordResetPendingImpl(
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$PasswordResetPendingImpl implements _PasswordResetPending {
  const _$PasswordResetPendingImpl({required this.email, this.message});

  @override
  final String email;
  @override
  final String? message;

  @override
  String toString() {
    return 'AuthState.passwordResetPending(email: $email, message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PasswordResetPendingImpl &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, email, message);

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PasswordResetPendingImplCopyWith<_$PasswordResetPendingImpl>
      get copyWith =>
          __$$PasswordResetPendingImplCopyWithImpl<_$PasswordResetPendingImpl>(
              this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
            User user, String? message, bool hasCompletedProfile)
        authenticated,
    required TResult Function(String? message) unauthenticated,
    required TResult Function(String email, String? message)
        emailVerificationPending,
    required TResult Function(String email, String? message) emailVerified,
    required TResult Function(String email, String? message)
        passwordResetPending,
    required TResult Function(String email, String otp, String? message)
        passwordResetVerified,
    required TResult Function(String message) error,
    required TResult Function() guest,
  }) {
    return passwordResetPending(email, message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(User user, String? message, bool hasCompletedProfile)?
        authenticated,
    TResult? Function(String? message)? unauthenticated,
    TResult? Function(String email, String? message)? emailVerificationPending,
    TResult? Function(String email, String? message)? emailVerified,
    TResult? Function(String email, String? message)? passwordResetPending,
    TResult? Function(String email, String otp, String? message)?
        passwordResetVerified,
    TResult? Function(String message)? error,
    TResult? Function()? guest,
  }) {
    return passwordResetPending?.call(email, message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(User user, String? message, bool hasCompletedProfile)?
        authenticated,
    TResult Function(String? message)? unauthenticated,
    TResult Function(String email, String? message)? emailVerificationPending,
    TResult Function(String email, String? message)? emailVerified,
    TResult Function(String email, String? message)? passwordResetPending,
    TResult Function(String email, String otp, String? message)?
        passwordResetVerified,
    TResult Function(String message)? error,
    TResult Function()? guest,
    required TResult orElse(),
  }) {
    if (passwordResetPending != null) {
      return passwordResetPending(email, message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Authenticated value) authenticated,
    required TResult Function(_Unauthenticated value) unauthenticated,
    required TResult Function(_EmailVerificationPending value)
        emailVerificationPending,
    required TResult Function(_EmailVerified value) emailVerified,
    required TResult Function(_PasswordResetPending value) passwordResetPending,
    required TResult Function(_PasswordResetVerified value)
        passwordResetVerified,
    required TResult Function(_Error value) error,
    required TResult Function(_Guest value) guest,
  }) {
    return passwordResetPending(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Authenticated value)? authenticated,
    TResult? Function(_Unauthenticated value)? unauthenticated,
    TResult? Function(_EmailVerificationPending value)?
        emailVerificationPending,
    TResult? Function(_EmailVerified value)? emailVerified,
    TResult? Function(_PasswordResetPending value)? passwordResetPending,
    TResult? Function(_PasswordResetVerified value)? passwordResetVerified,
    TResult? Function(_Error value)? error,
    TResult? Function(_Guest value)? guest,
  }) {
    return passwordResetPending?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Authenticated value)? authenticated,
    TResult Function(_Unauthenticated value)? unauthenticated,
    TResult Function(_EmailVerificationPending value)? emailVerificationPending,
    TResult Function(_EmailVerified value)? emailVerified,
    TResult Function(_PasswordResetPending value)? passwordResetPending,
    TResult Function(_PasswordResetVerified value)? passwordResetVerified,
    TResult Function(_Error value)? error,
    TResult Function(_Guest value)? guest,
    required TResult orElse(),
  }) {
    if (passwordResetPending != null) {
      return passwordResetPending(this);
    }
    return orElse();
  }
}

abstract class _PasswordResetPending implements AuthState {
  const factory _PasswordResetPending(
      {required final String email,
      final String? message}) = _$PasswordResetPendingImpl;

  String get email;
  String? get message;

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PasswordResetPendingImplCopyWith<_$PasswordResetPendingImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$PasswordResetVerifiedImplCopyWith<$Res> {
  factory _$$PasswordResetVerifiedImplCopyWith(
          _$PasswordResetVerifiedImpl value,
          $Res Function(_$PasswordResetVerifiedImpl) then) =
      __$$PasswordResetVerifiedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String email, String otp, String? message});
}

/// @nodoc
class __$$PasswordResetVerifiedImplCopyWithImpl<$Res>
    extends _$AuthStateCopyWithImpl<$Res, _$PasswordResetVerifiedImpl>
    implements _$$PasswordResetVerifiedImplCopyWith<$Res> {
  __$$PasswordResetVerifiedImplCopyWithImpl(_$PasswordResetVerifiedImpl _value,
      $Res Function(_$PasswordResetVerifiedImpl) _then)
      : super(_value, _then);

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? email = null,
    Object? otp = null,
    Object? message = freezed,
  }) {
    return _then(_$PasswordResetVerifiedImpl(
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      otp: null == otp
          ? _value.otp
          : otp // ignore: cast_nullable_to_non_nullable
              as String,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$PasswordResetVerifiedImpl implements _PasswordResetVerified {
  const _$PasswordResetVerifiedImpl(
      {required this.email, required this.otp, this.message});

  @override
  final String email;
  @override
  final String otp;
  @override
  final String? message;

  @override
  String toString() {
    return 'AuthState.passwordResetVerified(email: $email, otp: $otp, message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PasswordResetVerifiedImpl &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.otp, otp) || other.otp == otp) &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, email, otp, message);

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PasswordResetVerifiedImplCopyWith<_$PasswordResetVerifiedImpl>
      get copyWith => __$$PasswordResetVerifiedImplCopyWithImpl<
          _$PasswordResetVerifiedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
            User user, String? message, bool hasCompletedProfile)
        authenticated,
    required TResult Function(String? message) unauthenticated,
    required TResult Function(String email, String? message)
        emailVerificationPending,
    required TResult Function(String email, String? message) emailVerified,
    required TResult Function(String email, String? message)
        passwordResetPending,
    required TResult Function(String email, String otp, String? message)
        passwordResetVerified,
    required TResult Function(String message) error,
    required TResult Function() guest,
  }) {
    return passwordResetVerified(email, otp, message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(User user, String? message, bool hasCompletedProfile)?
        authenticated,
    TResult? Function(String? message)? unauthenticated,
    TResult? Function(String email, String? message)? emailVerificationPending,
    TResult? Function(String email, String? message)? emailVerified,
    TResult? Function(String email, String? message)? passwordResetPending,
    TResult? Function(String email, String otp, String? message)?
        passwordResetVerified,
    TResult? Function(String message)? error,
    TResult? Function()? guest,
  }) {
    return passwordResetVerified?.call(email, otp, message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(User user, String? message, bool hasCompletedProfile)?
        authenticated,
    TResult Function(String? message)? unauthenticated,
    TResult Function(String email, String? message)? emailVerificationPending,
    TResult Function(String email, String? message)? emailVerified,
    TResult Function(String email, String? message)? passwordResetPending,
    TResult Function(String email, String otp, String? message)?
        passwordResetVerified,
    TResult Function(String message)? error,
    TResult Function()? guest,
    required TResult orElse(),
  }) {
    if (passwordResetVerified != null) {
      return passwordResetVerified(email, otp, message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Authenticated value) authenticated,
    required TResult Function(_Unauthenticated value) unauthenticated,
    required TResult Function(_EmailVerificationPending value)
        emailVerificationPending,
    required TResult Function(_EmailVerified value) emailVerified,
    required TResult Function(_PasswordResetPending value) passwordResetPending,
    required TResult Function(_PasswordResetVerified value)
        passwordResetVerified,
    required TResult Function(_Error value) error,
    required TResult Function(_Guest value) guest,
  }) {
    return passwordResetVerified(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Authenticated value)? authenticated,
    TResult? Function(_Unauthenticated value)? unauthenticated,
    TResult? Function(_EmailVerificationPending value)?
        emailVerificationPending,
    TResult? Function(_EmailVerified value)? emailVerified,
    TResult? Function(_PasswordResetPending value)? passwordResetPending,
    TResult? Function(_PasswordResetVerified value)? passwordResetVerified,
    TResult? Function(_Error value)? error,
    TResult? Function(_Guest value)? guest,
  }) {
    return passwordResetVerified?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Authenticated value)? authenticated,
    TResult Function(_Unauthenticated value)? unauthenticated,
    TResult Function(_EmailVerificationPending value)? emailVerificationPending,
    TResult Function(_EmailVerified value)? emailVerified,
    TResult Function(_PasswordResetPending value)? passwordResetPending,
    TResult Function(_PasswordResetVerified value)? passwordResetVerified,
    TResult Function(_Error value)? error,
    TResult Function(_Guest value)? guest,
    required TResult orElse(),
  }) {
    if (passwordResetVerified != null) {
      return passwordResetVerified(this);
    }
    return orElse();
  }
}

abstract class _PasswordResetVerified implements AuthState {
  const factory _PasswordResetVerified(
      {required final String email,
      required final String otp,
      final String? message}) = _$PasswordResetVerifiedImpl;

  String get email;
  String get otp;
  String? get message;

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PasswordResetVerifiedImplCopyWith<_$PasswordResetVerifiedImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ErrorImplCopyWith<$Res> {
  factory _$$ErrorImplCopyWith(
          _$ErrorImpl value, $Res Function(_$ErrorImpl) then) =
      __$$ErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$ErrorImplCopyWithImpl<$Res>
    extends _$AuthStateCopyWithImpl<$Res, _$ErrorImpl>
    implements _$$ErrorImplCopyWith<$Res> {
  __$$ErrorImplCopyWithImpl(
      _$ErrorImpl _value, $Res Function(_$ErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_$ErrorImpl(
      null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$ErrorImpl implements _Error {
  const _$ErrorImpl(this.message);

  @override
  final String message;

  @override
  String toString() {
    return 'AuthState.error(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ErrorImplCopyWith<_$ErrorImpl> get copyWith =>
      __$$ErrorImplCopyWithImpl<_$ErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
            User user, String? message, bool hasCompletedProfile)
        authenticated,
    required TResult Function(String? message) unauthenticated,
    required TResult Function(String email, String? message)
        emailVerificationPending,
    required TResult Function(String email, String? message) emailVerified,
    required TResult Function(String email, String? message)
        passwordResetPending,
    required TResult Function(String email, String otp, String? message)
        passwordResetVerified,
    required TResult Function(String message) error,
    required TResult Function() guest,
  }) {
    return error(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(User user, String? message, bool hasCompletedProfile)?
        authenticated,
    TResult? Function(String? message)? unauthenticated,
    TResult? Function(String email, String? message)? emailVerificationPending,
    TResult? Function(String email, String? message)? emailVerified,
    TResult? Function(String email, String? message)? passwordResetPending,
    TResult? Function(String email, String otp, String? message)?
        passwordResetVerified,
    TResult? Function(String message)? error,
    TResult? Function()? guest,
  }) {
    return error?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(User user, String? message, bool hasCompletedProfile)?
        authenticated,
    TResult Function(String? message)? unauthenticated,
    TResult Function(String email, String? message)? emailVerificationPending,
    TResult Function(String email, String? message)? emailVerified,
    TResult Function(String email, String? message)? passwordResetPending,
    TResult Function(String email, String otp, String? message)?
        passwordResetVerified,
    TResult Function(String message)? error,
    TResult Function()? guest,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Authenticated value) authenticated,
    required TResult Function(_Unauthenticated value) unauthenticated,
    required TResult Function(_EmailVerificationPending value)
        emailVerificationPending,
    required TResult Function(_EmailVerified value) emailVerified,
    required TResult Function(_PasswordResetPending value) passwordResetPending,
    required TResult Function(_PasswordResetVerified value)
        passwordResetVerified,
    required TResult Function(_Error value) error,
    required TResult Function(_Guest value) guest,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Authenticated value)? authenticated,
    TResult? Function(_Unauthenticated value)? unauthenticated,
    TResult? Function(_EmailVerificationPending value)?
        emailVerificationPending,
    TResult? Function(_EmailVerified value)? emailVerified,
    TResult? Function(_PasswordResetPending value)? passwordResetPending,
    TResult? Function(_PasswordResetVerified value)? passwordResetVerified,
    TResult? Function(_Error value)? error,
    TResult? Function(_Guest value)? guest,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Authenticated value)? authenticated,
    TResult Function(_Unauthenticated value)? unauthenticated,
    TResult Function(_EmailVerificationPending value)? emailVerificationPending,
    TResult Function(_EmailVerified value)? emailVerified,
    TResult Function(_PasswordResetPending value)? passwordResetPending,
    TResult Function(_PasswordResetVerified value)? passwordResetVerified,
    TResult Function(_Error value)? error,
    TResult Function(_Guest value)? guest,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class _Error implements AuthState {
  const factory _Error(final String message) = _$ErrorImpl;

  String get message;

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ErrorImplCopyWith<_$ErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$GuestImplCopyWith<$Res> {
  factory _$$GuestImplCopyWith(
          _$GuestImpl value, $Res Function(_$GuestImpl) then) =
      __$$GuestImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$GuestImplCopyWithImpl<$Res>
    extends _$AuthStateCopyWithImpl<$Res, _$GuestImpl>
    implements _$$GuestImplCopyWith<$Res> {
  __$$GuestImplCopyWithImpl(
      _$GuestImpl _value, $Res Function(_$GuestImpl) _then)
      : super(_value, _then);

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$GuestImpl implements _Guest {
  const _$GuestImpl();

  @override
  String toString() {
    return 'AuthState.guest()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$GuestImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
            User user, String? message, bool hasCompletedProfile)
        authenticated,
    required TResult Function(String? message) unauthenticated,
    required TResult Function(String email, String? message)
        emailVerificationPending,
    required TResult Function(String email, String? message) emailVerified,
    required TResult Function(String email, String? message)
        passwordResetPending,
    required TResult Function(String email, String otp, String? message)
        passwordResetVerified,
    required TResult Function(String message) error,
    required TResult Function() guest,
  }) {
    return guest();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(User user, String? message, bool hasCompletedProfile)?
        authenticated,
    TResult? Function(String? message)? unauthenticated,
    TResult? Function(String email, String? message)? emailVerificationPending,
    TResult? Function(String email, String? message)? emailVerified,
    TResult? Function(String email, String? message)? passwordResetPending,
    TResult? Function(String email, String otp, String? message)?
        passwordResetVerified,
    TResult? Function(String message)? error,
    TResult? Function()? guest,
  }) {
    return guest?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(User user, String? message, bool hasCompletedProfile)?
        authenticated,
    TResult Function(String? message)? unauthenticated,
    TResult Function(String email, String? message)? emailVerificationPending,
    TResult Function(String email, String? message)? emailVerified,
    TResult Function(String email, String? message)? passwordResetPending,
    TResult Function(String email, String otp, String? message)?
        passwordResetVerified,
    TResult Function(String message)? error,
    TResult Function()? guest,
    required TResult orElse(),
  }) {
    if (guest != null) {
      return guest();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Authenticated value) authenticated,
    required TResult Function(_Unauthenticated value) unauthenticated,
    required TResult Function(_EmailVerificationPending value)
        emailVerificationPending,
    required TResult Function(_EmailVerified value) emailVerified,
    required TResult Function(_PasswordResetPending value) passwordResetPending,
    required TResult Function(_PasswordResetVerified value)
        passwordResetVerified,
    required TResult Function(_Error value) error,
    required TResult Function(_Guest value) guest,
  }) {
    return guest(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Authenticated value)? authenticated,
    TResult? Function(_Unauthenticated value)? unauthenticated,
    TResult? Function(_EmailVerificationPending value)?
        emailVerificationPending,
    TResult? Function(_EmailVerified value)? emailVerified,
    TResult? Function(_PasswordResetPending value)? passwordResetPending,
    TResult? Function(_PasswordResetVerified value)? passwordResetVerified,
    TResult? Function(_Error value)? error,
    TResult? Function(_Guest value)? guest,
  }) {
    return guest?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Authenticated value)? authenticated,
    TResult Function(_Unauthenticated value)? unauthenticated,
    TResult Function(_EmailVerificationPending value)? emailVerificationPending,
    TResult Function(_EmailVerified value)? emailVerified,
    TResult Function(_PasswordResetPending value)? passwordResetPending,
    TResult Function(_PasswordResetVerified value)? passwordResetVerified,
    TResult Function(_Error value)? error,
    TResult Function(_Guest value)? guest,
    required TResult orElse(),
  }) {
    if (guest != null) {
      return guest(this);
    }
    return orElse();
  }
}

abstract class _Guest implements AuthState {
  const factory _Guest() = _$GuestImpl;
}
