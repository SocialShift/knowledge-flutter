import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'timeline.freezed.dart';
part 'timeline.g.dart';

@freezed
class Timeline with _$Timeline {
  factory Timeline({
    required String id,
    required String title,
    required String description,
    required String imageUrl,
    required int year,
    @Default([]) List<Story> stories,
  }) = _Timeline;

  factory Timeline.fromJson(Map<String, dynamic> json) =>
      _$TimelineFromJson(json);

  // Factory constructor to create a Timeline from the API response
  static Timeline fromApiResponse(Map<String, dynamic> json) {
    final mediaBaseUrl = dotenv.env['MEDIA_BASE_URL'] ?? '';

    // Get the thumbnail URL and prepend the base URL if it's a relative path
    String thumbnailUrl = json['thumbnail_url'] ?? '';
    if (thumbnailUrl.isNotEmpty && !thumbnailUrl.startsWith('http')) {
      thumbnailUrl = '$mediaBaseUrl/$thumbnailUrl';
    }

    return Timeline(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      description: json['overview'] ?? '',
      imageUrl: thumbnailUrl,
      year: _parseYearRange(json['year_range'] ?? ''),
    );
  }

  // Helper method to extract the start year from a year range string like "2024 - 2030"
  static int _parseYearRange(String yearRange) {
    try {
      print('Parsing year range: $yearRange');

      // If the year range is empty, return default
      if (yearRange.isEmpty) {
        return 2000;
      }

      // Check for all possible separator formats: hyphen, en dash, or spaces
      // Handle special dash character (en dash) in "1920–1935"
      String normalizedRange = yearRange
          .replaceAll('–', '-') // Replace en dash with regular hyphen
          .replaceAll('—', '-'); // Replace em dash with regular hyphen

      if (normalizedRange.contains('-')) {
        // Split by hyphen and handle both formats with or without spaces
        final parts = normalizedRange.split('-');
        if (parts.isNotEmpty) {
          // Trim any whitespace and parse
          final yearStr = parts[0].trim();
          return int.parse(yearStr);
        }
      } else {
        // If it's just a single year
        return int.parse(normalizedRange.trim());
      }

      return 2000; // Default year if parsing fails
    } catch (e) {
      print('Error parsing year range: $e');
      return 2000; // Default year if parsing fails
    }
  }
}

@freezed
class Story with _$Story {
  factory Story({
    required String id,
    required String title,
    required String description,
    required String imageUrl,
    required int year,
    @Default(false) bool isCompleted,
    @Default('') String mediaType,
    @Default('') String mediaUrl,
    @Default('') String content,
    @Default([]) List<Timestamp> timestamps,
    @Default(0) int likes,
    @Default(0) int views,
    String? timelineId,
    String? createdAt,
    String? storyDate,
  }) = _Story;

  factory Story.fromJson(Map<String, dynamic> json) => _$StoryFromJson(json);

  // Factory constructor to create a Story from the API response
  static Story fromApiResponse(Map<String, dynamic> json) {
    final mediaBaseUrl = dotenv.env['MEDIA_BASE_URL'] ?? '';

    // Get the thumbnail URL and prepend the base URL if it's a relative path
    String thumbnailUrl = json['thumbnail_url'] ?? '';
    if (thumbnailUrl.isNotEmpty && !thumbnailUrl.startsWith('http')) {
      thumbnailUrl = '$mediaBaseUrl/$thumbnailUrl';
    }

    // Get the video URL and prepend the base URL if it's a relative path
    String videoUrl = json['video_url'] ?? '';
    if (videoUrl.isNotEmpty && !videoUrl.startsWith('http')) {
      videoUrl = '$mediaBaseUrl/$videoUrl';
    }

    // Debug print to check the video URL
    print('Story ID: ${json['id']} - Video URL: $videoUrl');

    // Get the story date
    String storyDate = json['story_date'] ?? '';

    // Parse year from story_date (format: "YYYY-MM-DD")
    int year = 2024;
    if (storyDate.isNotEmpty) {
      try {
        year = int.parse(storyDate.split('-')[0]);
      } catch (e) {
        print('Error parsing year from story_date: $e');
      }
    }

    return Story(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      description: json['desc'] ?? '',
      imageUrl: thumbnailUrl,
      mediaUrl: videoUrl,
      mediaType: videoUrl.isNotEmpty ? 'video' : 'image',
      likes: json['likes'] ?? 0,
      views: json['views'] ?? 0,
      timelineId: json['timeline_id']?.toString(),
      createdAt: json['created_at'],
      storyDate: storyDate,
      year: year, // Use the parsed year from story_date
    );
  }
}

@freezed
class Timestamp with _$Timestamp {
  const factory Timestamp({
    String? id,
    String? storyId,
    required int timeSec,
    required String label,
  }) = _Timestamp;

  factory Timestamp.fromJson(Map<String, dynamic> json) =>
      _$TimestampFromJson(json);
}
