// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timeline.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MainCharacterImpl _$$MainCharacterImplFromJson(Map<String, dynamic> json) =>
    _$MainCharacterImpl(
      id: json['id'] as String,
      avatarUrl: json['avatarUrl'] as String,
      name: json['name'] as String,
      persona: json['persona'] as String,
      createdAt: json['createdAt'] as String?,
    );

Map<String, dynamic> _$$MainCharacterImplToJson(_$MainCharacterImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'avatarUrl': instance.avatarUrl,
      'name': instance.name,
      'persona': instance.persona,
      'createdAt': instance.createdAt,
    };

_$TimelineImpl _$$TimelineImplFromJson(Map<String, dynamic> json) =>
    _$TimelineImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String,
      year: (json['year'] as num).toInt(),
      mainCharacter: json['mainCharacter'] == null
          ? null
          : MainCharacter.fromJson(
              json['mainCharacter'] as Map<String, dynamic>),
      stories: (json['stories'] as List<dynamic>?)
              ?.map((e) => Story.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      categories: (json['categories'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      isSeen: json['isSeen'] as bool? ?? false,
    );

Map<String, dynamic> _$$TimelineImplToJson(_$TimelineImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'imageUrl': instance.imageUrl,
      'year': instance.year,
      'mainCharacter': instance.mainCharacter,
      'stories': instance.stories,
      'categories': instance.categories,
      'isSeen': instance.isSeen,
    };

_$StoryImpl _$$StoryImplFromJson(Map<String, dynamic> json) => _$StoryImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String,
      year: (json['year'] as num).toInt(),
      isCompleted: json['isCompleted'] as bool? ?? false,
      mediaType: json['mediaType'] as String? ?? '',
      mediaUrl: json['mediaUrl'] as String? ?? '',
      content: json['content'] as String? ?? '',
      timestamps: (json['timestamps'] as List<dynamic>?)
              ?.map((e) => Timestamp.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      likes: (json['likes'] as num?)?.toInt() ?? 0,
      views: (json['views'] as num?)?.toInt() ?? 0,
      subtitlesUrl: json['subtitlesUrl'] as String? ?? '',
      timelineId: json['timelineId'] as String?,
      createdAt: json['createdAt'] as String?,
      storyDate: json['storyDate'] as String?,
      isSeen: json['isSeen'] as bool? ?? false,
    );

Map<String, dynamic> _$$StoryImplToJson(_$StoryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'imageUrl': instance.imageUrl,
      'year': instance.year,
      'isCompleted': instance.isCompleted,
      'mediaType': instance.mediaType,
      'mediaUrl': instance.mediaUrl,
      'content': instance.content,
      'timestamps': instance.timestamps,
      'likes': instance.likes,
      'views': instance.views,
      'subtitlesUrl': instance.subtitlesUrl,
      'timelineId': instance.timelineId,
      'createdAt': instance.createdAt,
      'storyDate': instance.storyDate,
      'isSeen': instance.isSeen,
    };

_$TimestampImpl _$$TimestampImplFromJson(Map<String, dynamic> json) =>
    _$TimestampImpl(
      id: json['id'] as String?,
      storyId: json['storyId'] as String?,
      timeSec: (json['timeSec'] as num).toInt(),
      label: json['label'] as String,
    );

Map<String, dynamic> _$$TimestampImplToJson(_$TimestampImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'storyId': instance.storyId,
      'timeSec': instance.timeSec,
      'label': instance.label,
    };
