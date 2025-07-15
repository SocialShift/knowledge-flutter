// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'badge.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BadgeImpl _$$BadgeImplFromJson(Map<String, dynamic> json) => _$BadgeImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      path: json['path'] as String,
      tier: json['tier'] as String,
      description: json['description'] as String,
      iconUrl: json['icon_url'] as String,
      earnedAt: json['earned_at'] as String?,
    );

Map<String, dynamic> _$$BadgeImplToJson(_$BadgeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'path': instance.path,
      'tier': instance.tier,
      'description': instance.description,
      'icon_url': instance.iconUrl,
      'earned_at': instance.earnedAt,
    };
