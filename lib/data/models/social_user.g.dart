// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'social_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SocialUserImpl _$$SocialUserImplFromJson(Map<String, dynamic> json) =>
    _$SocialUserImpl(
      userId: (json['userId'] as num).toInt(),
      username: json['username'] as String,
      profileId: (json['profileId'] as num).toInt(),
      nickname: json['nickname'] as String,
      avatarUrl: json['avatarUrl'] as String,
      isFollowing: json['isFollowing'] as bool,
    );

Map<String, dynamic> _$$SocialUserImplToJson(_$SocialUserImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'username': instance.username,
      'profileId': instance.profileId,
      'nickname': instance.nickname,
      'avatarUrl': instance.avatarUrl,
      'isFollowing': instance.isFollowing,
    };
