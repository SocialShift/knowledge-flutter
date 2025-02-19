// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timeline.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TimelineImpl _$$TimelineImplFromJson(Map<String, dynamic> json) =>
    _$TimelineImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String,
      year: (json['year'] as num).toInt(),
      stories: (json['stories'] as List<dynamic>)
          .map((e) => Story.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$TimelineImplToJson(_$TimelineImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'imageUrl': instance.imageUrl,
      'year': instance.year,
      'stories': instance.stories,
    };

_$StoryImpl _$$StoryImplFromJson(Map<String, dynamic> json) => _$StoryImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String,
      year: (json['year'] as num).toInt(),
      isCompleted: json['isCompleted'] as bool,
      mediaType: json['mediaType'] as String,
      mediaUrl: json['mediaUrl'] as String,
      content: json['content'] as String,
      timestamps: (json['timestamps'] as List<dynamic>)
          .map((e) => Timestamp.fromJson(e as Map<String, dynamic>))
          .toList(),
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
    };

_$TimestampImpl _$$TimestampImplFromJson(Map<String, dynamic> json) =>
    _$TimestampImpl(
      time: json['time'] as String,
      title: json['title'] as String,
    );

Map<String, dynamic> _$$TimestampImplToJson(_$TimestampImpl instance) =>
    <String, dynamic>{
      'time': instance.time,
      'title': instance.title,
    };
