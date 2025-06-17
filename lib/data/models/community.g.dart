// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'community.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CommunityCategoryImpl _$$CommunityCategoryImplFromJson(
        Map<String, dynamic> json) =>
    _$CommunityCategoryImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      color: json['color'] as String,
    );

Map<String, dynamic> _$$CommunityCategoryImplToJson(
        _$CommunityCategoryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'icon': instance.icon,
      'color': instance.color,
    };

_$CommunityImpl _$$CommunityImplFromJson(Map<String, dynamic> json) =>
    _$CommunityImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String?,
      topics: json['topics'] as String?,
      bannerUrl: json['banner_url'] as String?,
      iconUrl: json['icon_url'] as String?,
      createdAt: json['created_at'] as String?,
      createdBy: (json['created_by'] as num?)?.toInt(),
      memberCount: (json['memberCount'] as num?)?.toInt() ?? 0,
      isJoined: json['isJoined'] as bool? ?? false,
    );

Map<String, dynamic> _$$CommunityImplToJson(_$CommunityImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'topics': instance.topics,
      'banner_url': instance.bannerUrl,
      'icon_url': instance.iconUrl,
      'created_at': instance.createdAt,
      'created_by': instance.createdBy,
      'memberCount': instance.memberCount,
      'isJoined': instance.isJoined,
    };
