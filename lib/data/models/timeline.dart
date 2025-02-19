import 'package:freezed_annotation/freezed_annotation.dart';

part 'timeline.freezed.dart';
part 'timeline.g.dart';

@freezed
class Timeline with _$Timeline {
  const factory Timeline({
    required String id,
    required String title,
    required String description,
    required String imageUrl,
    required int year,
    required List<Story> stories,
  }) = _Timeline;

  factory Timeline.fromJson(Map<String, dynamic> json) =>
      _$TimelineFromJson(json);
}

@freezed
class Story with _$Story {
  const factory Story({
    required String id,
    required String title,
    required String description,
    required String imageUrl,
    required int year,
    required bool isCompleted,
    required String mediaType, // 'video' or 'image'
    required String mediaUrl,
    required String content,
    required List<Timestamp> timestamps,
  }) = _Story;

  factory Story.fromJson(Map<String, dynamic> json) => _$StoryFromJson(json);
}

@freezed
class Timestamp with _$Timestamp {
  const factory Timestamp({
    required String time,
    required String title,
  }) = _Timestamp;

  factory Timestamp.fromJson(Map<String, dynamic> json) =>
      _$TimestampFromJson(json);
}
