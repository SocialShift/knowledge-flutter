// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserProfileImpl _$$UserProfileImplFromJson(Map<String, dynamic> json) =>
    _$UserProfileImpl(
      email: json['email'] as String,
      nickname: json['nickname'] as String?,
      location: json['location'] as String?,
      preferredLanguage: json['preferredLanguage'] as String? ?? 'English',
      pronouns: json['pronouns'] as String?,
    );

Map<String, dynamic> _$$UserProfileImplToJson(_$UserProfileImpl instance) =>
    <String, dynamic>{
      'email': instance.email,
      'nickname': instance.nickname,
      'location': instance.location,
      'preferredLanguage': instance.preferredLanguage,
      'pronouns': instance.pronouns,
    };
