// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Profile _$ProfileFromJson(Map<String, dynamic> json) {
  return _Profile.fromJson(json);
}

/// @nodoc
mixin _$Profile {
  String get nickname => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String? get pronouns => throw _privateConstructorUsedError;
  String? get avatarUrl => throw _privateConstructorUsedError;
  String? get languagePreference => throw _privateConstructorUsedError;
  String? get location => throw _privateConstructorUsedError;
  Map<String, dynamic>? get personalizationQuestions =>
      throw _privateConstructorUsedError;

  /// Serializes this Profile to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Profile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProfileCopyWith<Profile> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProfileCopyWith<$Res> {
  factory $ProfileCopyWith(Profile value, $Res Function(Profile) then) =
      _$ProfileCopyWithImpl<$Res, Profile>;
  @useResult
  $Res call(
      {String nickname,
      String email,
      String? pronouns,
      String? avatarUrl,
      String? languagePreference,
      String? location,
      Map<String, dynamic>? personalizationQuestions});
}

/// @nodoc
class _$ProfileCopyWithImpl<$Res, $Val extends Profile>
    implements $ProfileCopyWith<$Res> {
  _$ProfileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Profile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? nickname = null,
    Object? email = null,
    Object? pronouns = freezed,
    Object? avatarUrl = freezed,
    Object? languagePreference = freezed,
    Object? location = freezed,
    Object? personalizationQuestions = freezed,
  }) {
    return _then(_value.copyWith(
      nickname: null == nickname
          ? _value.nickname
          : nickname // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      pronouns: freezed == pronouns
          ? _value.pronouns
          : pronouns // ignore: cast_nullable_to_non_nullable
              as String?,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      languagePreference: freezed == languagePreference
          ? _value.languagePreference
          : languagePreference // ignore: cast_nullable_to_non_nullable
              as String?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      personalizationQuestions: freezed == personalizationQuestions
          ? _value.personalizationQuestions
          : personalizationQuestions // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProfileImplCopyWith<$Res> implements $ProfileCopyWith<$Res> {
  factory _$$ProfileImplCopyWith(
          _$ProfileImpl value, $Res Function(_$ProfileImpl) then) =
      __$$ProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String nickname,
      String email,
      String? pronouns,
      String? avatarUrl,
      String? languagePreference,
      String? location,
      Map<String, dynamic>? personalizationQuestions});
}

/// @nodoc
class __$$ProfileImplCopyWithImpl<$Res>
    extends _$ProfileCopyWithImpl<$Res, _$ProfileImpl>
    implements _$$ProfileImplCopyWith<$Res> {
  __$$ProfileImplCopyWithImpl(
      _$ProfileImpl _value, $Res Function(_$ProfileImpl) _then)
      : super(_value, _then);

  /// Create a copy of Profile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? nickname = null,
    Object? email = null,
    Object? pronouns = freezed,
    Object? avatarUrl = freezed,
    Object? languagePreference = freezed,
    Object? location = freezed,
    Object? personalizationQuestions = freezed,
  }) {
    return _then(_$ProfileImpl(
      nickname: null == nickname
          ? _value.nickname
          : nickname // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      pronouns: freezed == pronouns
          ? _value.pronouns
          : pronouns // ignore: cast_nullable_to_non_nullable
              as String?,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      languagePreference: freezed == languagePreference
          ? _value.languagePreference
          : languagePreference // ignore: cast_nullable_to_non_nullable
              as String?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      personalizationQuestions: freezed == personalizationQuestions
          ? _value._personalizationQuestions
          : personalizationQuestions // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ProfileImpl implements _Profile {
  const _$ProfileImpl(
      {required this.nickname,
      required this.email,
      this.pronouns,
      this.avatarUrl,
      this.languagePreference,
      this.location,
      final Map<String, dynamic>? personalizationQuestions})
      : _personalizationQuestions = personalizationQuestions;

  factory _$ProfileImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProfileImplFromJson(json);

  @override
  final String nickname;
  @override
  final String email;
  @override
  final String? pronouns;
  @override
  final String? avatarUrl;
  @override
  final String? languagePreference;
  @override
  final String? location;
  final Map<String, dynamic>? _personalizationQuestions;
  @override
  Map<String, dynamic>? get personalizationQuestions {
    final value = _personalizationQuestions;
    if (value == null) return null;
    if (_personalizationQuestions is EqualUnmodifiableMapView)
      return _personalizationQuestions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'Profile(nickname: $nickname, email: $email, pronouns: $pronouns, avatarUrl: $avatarUrl, languagePreference: $languagePreference, location: $location, personalizationQuestions: $personalizationQuestions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProfileImpl &&
            (identical(other.nickname, nickname) ||
                other.nickname == nickname) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.pronouns, pronouns) ||
                other.pronouns == pronouns) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.languagePreference, languagePreference) ||
                other.languagePreference == languagePreference) &&
            (identical(other.location, location) ||
                other.location == location) &&
            const DeepCollectionEquality().equals(
                other._personalizationQuestions, _personalizationQuestions));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      nickname,
      email,
      pronouns,
      avatarUrl,
      languagePreference,
      location,
      const DeepCollectionEquality().hash(_personalizationQuestions));

  /// Create a copy of Profile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProfileImplCopyWith<_$ProfileImpl> get copyWith =>
      __$$ProfileImplCopyWithImpl<_$ProfileImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProfileImplToJson(
      this,
    );
  }
}

abstract class _Profile implements Profile {
  const factory _Profile(
      {required final String nickname,
      required final String email,
      final String? pronouns,
      final String? avatarUrl,
      final String? languagePreference,
      final String? location,
      final Map<String, dynamic>? personalizationQuestions}) = _$ProfileImpl;

  factory _Profile.fromJson(Map<String, dynamic> json) = _$ProfileImpl.fromJson;

  @override
  String get nickname;
  @override
  String get email;
  @override
  String? get pronouns;
  @override
  String? get avatarUrl;
  @override
  String? get languagePreference;
  @override
  String? get location;
  @override
  Map<String, dynamic>? get personalizationQuestions;

  /// Create a copy of Profile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProfileImplCopyWith<_$ProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
