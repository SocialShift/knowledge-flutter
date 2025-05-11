// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'social_user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SocialUser _$SocialUserFromJson(Map<String, dynamic> json) {
  return _SocialUser.fromJson(json);
}

/// @nodoc
mixin _$SocialUser {
  int get userId => throw _privateConstructorUsedError;
  String get username => throw _privateConstructorUsedError;
  int get profileId => throw _privateConstructorUsedError;
  String get nickname => throw _privateConstructorUsedError;
  String get avatarUrl => throw _privateConstructorUsedError;
  bool get isFollowing => throw _privateConstructorUsedError;

  /// Serializes this SocialUser to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SocialUser
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SocialUserCopyWith<SocialUser> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SocialUserCopyWith<$Res> {
  factory $SocialUserCopyWith(
          SocialUser value, $Res Function(SocialUser) then) =
      _$SocialUserCopyWithImpl<$Res, SocialUser>;
  @useResult
  $Res call(
      {int userId,
      String username,
      int profileId,
      String nickname,
      String avatarUrl,
      bool isFollowing});
}

/// @nodoc
class _$SocialUserCopyWithImpl<$Res, $Val extends SocialUser>
    implements $SocialUserCopyWith<$Res> {
  _$SocialUserCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SocialUser
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? username = null,
    Object? profileId = null,
    Object? nickname = null,
    Object? avatarUrl = null,
    Object? isFollowing = null,
  }) {
    return _then(_value.copyWith(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int,
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      profileId: null == profileId
          ? _value.profileId
          : profileId // ignore: cast_nullable_to_non_nullable
              as int,
      nickname: null == nickname
          ? _value.nickname
          : nickname // ignore: cast_nullable_to_non_nullable
              as String,
      avatarUrl: null == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String,
      isFollowing: null == isFollowing
          ? _value.isFollowing
          : isFollowing // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SocialUserImplCopyWith<$Res>
    implements $SocialUserCopyWith<$Res> {
  factory _$$SocialUserImplCopyWith(
          _$SocialUserImpl value, $Res Function(_$SocialUserImpl) then) =
      __$$SocialUserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int userId,
      String username,
      int profileId,
      String nickname,
      String avatarUrl,
      bool isFollowing});
}

/// @nodoc
class __$$SocialUserImplCopyWithImpl<$Res>
    extends _$SocialUserCopyWithImpl<$Res, _$SocialUserImpl>
    implements _$$SocialUserImplCopyWith<$Res> {
  __$$SocialUserImplCopyWithImpl(
      _$SocialUserImpl _value, $Res Function(_$SocialUserImpl) _then)
      : super(_value, _then);

  /// Create a copy of SocialUser
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? username = null,
    Object? profileId = null,
    Object? nickname = null,
    Object? avatarUrl = null,
    Object? isFollowing = null,
  }) {
    return _then(_$SocialUserImpl(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int,
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      profileId: null == profileId
          ? _value.profileId
          : profileId // ignore: cast_nullable_to_non_nullable
              as int,
      nickname: null == nickname
          ? _value.nickname
          : nickname // ignore: cast_nullable_to_non_nullable
              as String,
      avatarUrl: null == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String,
      isFollowing: null == isFollowing
          ? _value.isFollowing
          : isFollowing // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SocialUserImpl implements _SocialUser {
  const _$SocialUserImpl(
      {required this.userId,
      required this.username,
      required this.profileId,
      required this.nickname,
      required this.avatarUrl,
      required this.isFollowing});

  factory _$SocialUserImpl.fromJson(Map<String, dynamic> json) =>
      _$$SocialUserImplFromJson(json);

  @override
  final int userId;
  @override
  final String username;
  @override
  final int profileId;
  @override
  final String nickname;
  @override
  final String avatarUrl;
  @override
  final bool isFollowing;

  @override
  String toString() {
    return 'SocialUser(userId: $userId, username: $username, profileId: $profileId, nickname: $nickname, avatarUrl: $avatarUrl, isFollowing: $isFollowing)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SocialUserImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.profileId, profileId) ||
                other.profileId == profileId) &&
            (identical(other.nickname, nickname) ||
                other.nickname == nickname) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.isFollowing, isFollowing) ||
                other.isFollowing == isFollowing));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, userId, username, profileId,
      nickname, avatarUrl, isFollowing);

  /// Create a copy of SocialUser
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SocialUserImplCopyWith<_$SocialUserImpl> get copyWith =>
      __$$SocialUserImplCopyWithImpl<_$SocialUserImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SocialUserImplToJson(
      this,
    );
  }
}

abstract class _SocialUser implements SocialUser {
  const factory _SocialUser(
      {required final int userId,
      required final String username,
      required final int profileId,
      required final String nickname,
      required final String avatarUrl,
      required final bool isFollowing}) = _$SocialUserImpl;

  factory _SocialUser.fromJson(Map<String, dynamic> json) =
      _$SocialUserImpl.fromJson;

  @override
  int get userId;
  @override
  String get username;
  @override
  int get profileId;
  @override
  String get nickname;
  @override
  String get avatarUrl;
  @override
  bool get isFollowing;

  /// Create a copy of SocialUser
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SocialUserImplCopyWith<_$SocialUserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
