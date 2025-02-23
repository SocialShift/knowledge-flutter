// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProfileImpl _$$ProfileImplFromJson(Map<String, dynamic> json) =>
    _$ProfileImpl(
      nickname: json['nickname'] as String,
      email: json['email'] as String,
      pronouns: json['pronouns'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      languagePreference: json['languagePreference'] as String?,
      location: json['location'] as String?,
      personalizationQuestions:
          json['personalizationQuestions'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$ProfileImplToJson(_$ProfileImpl instance) =>
    <String, dynamic>{
      'nickname': instance.nickname,
      'email': instance.email,
      'pronouns': instance.pronouns,
      'avatarUrl': instance.avatarUrl,
      'languagePreference': instance.languagePreference,
      'location': instance.location,
      'personalizationQuestions': instance.personalizationQuestions,
    };
