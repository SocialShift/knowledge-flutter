import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:knowledge/data/providers/filter_provider.dart';

part 'timeline.freezed.dart';
part 'timeline.g.dart';

@freezed
class MainCharacter with _$MainCharacter {
  const factory MainCharacter({
    required String id,
    required String avatarUrl,
    required String name,
    required String persona,
    String? createdAt,
  }) = _MainCharacter;

  factory MainCharacter.fromJson(Map<String, dynamic> json) =>
      _$MainCharacterFromJson(json);

  // Factory constructor to create a MainCharacter from the API response
  static MainCharacter fromApiResponse(Map<String, dynamic> json) {
    final mediaBaseUrl = dotenv.env['MEDIA_BASE_URL'] ?? '';

    // Get the avatar URL and prepend the base URL if it's a relative path
    String avatarUrl = json['avatar_url'] ?? '';
    if (avatarUrl.isNotEmpty && !avatarUrl.startsWith('http')) {
      avatarUrl = '$mediaBaseUrl/$avatarUrl';
    }

    return MainCharacter(
      id: json['id'].toString(),
      avatarUrl: avatarUrl,
      name: json['name'] ?? '',
      persona: json['persona'] ?? '',
      createdAt: json['created_at'],
    );
  }
}

@freezed
class Timeline with _$Timeline {
  factory Timeline({
    required String id,
    required String title,
    required String description,
    required String imageUrl,
    required int year,
    MainCharacter? mainCharacter,
    @Default([]) List<Story> stories,
    @Default([]) List<String> categories,
    @Default(false) bool isSeen,
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

    // Parse main character if available
    MainCharacter? mainCharacter;
    if (json['main_character'] != null) {
      mainCharacter = MainCharacter.fromApiResponse(json['main_character']);
    }

    // Parse categories if available
    List<String> categories = [];
    if (json['categories'] != null && json['categories'] is List) {
      categories =
          List<String>.from(json['categories'].map((c) => c.toString()));
    }

    return Timeline(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      description: json['overview'] ?? '',
      imageUrl: thumbnailUrl,
      year: _parseYearRange(json['year_range'] ?? ''),
      mainCharacter: mainCharacter,
      categories: categories,
      isSeen: json['is_seen'] ?? false,
    );
  }

  // Factory constructor to create a Timeline from the bookmark API response
  static Timeline fromBookmarkApiResponse(Map<String, dynamic> json) {
    final mediaBaseUrl = dotenv.env['MEDIA_BASE_URL'] ?? '';

    // Get the thumbnail URL and prepend the base URL if it's a relative path
    String thumbnailUrl = json['thumbnail_url'] ?? '';
    if (thumbnailUrl.isNotEmpty && !thumbnailUrl.startsWith('http')) {
      thumbnailUrl = '$mediaBaseUrl/$thumbnailUrl';
    }

    // Parse main character if available
    MainCharacter? mainCharacter;
    if (json['main_character'] != null) {
      mainCharacter = MainCharacter.fromApiResponse(json['main_character']);
    }

    // Parse categories if available
    List<String> categories = [];
    if (json['categories'] != null && json['categories'] is List) {
      categories =
          List<String>.from(json['categories'].map((c) => c.toString()));
    }

    return Timeline(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      description: json['overview'] ?? '',
      imageUrl: thumbnailUrl,
      year: _parseYearRange(json['year_range'] ?? ''),
      mainCharacter: mainCharacter,
      categories: categories,
      isSeen: json['is_seen'] ?? false,
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

// Extension methods for Timeline filtering
extension TimelineFilters on Timeline {
  // Helper method to check if the timeline matches demographic filters
  bool matchesDemographicFilter(String filter) {
    // Check if the filter is in the categories
    return categories.contains(filter);
  }

  // Helper method to check if the timeline matches any of the selected interests
  bool matchesInterests(List<String> selectedInterests) {
    if (selectedInterests.isEmpty) return true;
    // Check if any selected interest is in the categories
    return selectedInterests.any((interest) => categories.contains(interest));
  }

  // Helper method to check if the timeline matches all filters
  bool matchesAllFilters(FilterState filters) {
    // Check if the timeline matches the race filter
    if (filters.race.isNotEmpty && !matchesDemographicFilter(filters.race)) {
      return false;
    }

    // Check if the timeline matches the gender filter
    if (filters.gender.isNotEmpty &&
        !matchesDemographicFilter(filters.gender)) {
      return false;
    }

    // Check if the timeline matches the sexual orientation filter
    if (filters.sexualOrientation.isNotEmpty &&
        !matchesDemographicFilter(filters.sexualOrientation)) {
      return false;
    }

    // Check if the timeline matches the interests filter
    if (filters.interests.isNotEmpty && !matchesInterests(filters.interests)) {
      return false;
    }

    // Check if the timeline matches the categories filter
    if (filters.categories.isNotEmpty &&
        !categories.any((category) => filters.categories.contains(category))) {
      return false;
    }

    return true;
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
    @Default('') String subtitlesUrl,
    String? timelineId,
    String? createdAt,
    String? storyDate,
    @Default(false) bool isSeen,
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

    // Get the subtitles URL and prepend the base URL if it's a relative path
    String subtitlesUrl = json['subtitles_url'] ?? '';
    if (subtitlesUrl.isNotEmpty && !subtitlesUrl.startsWith('http')) {
      subtitlesUrl = '$mediaBaseUrl/$subtitlesUrl';
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
      subtitlesUrl: subtitlesUrl,
      timelineId: json['timeline_id']?.toString(),
      createdAt: json['created_at'],
      storyDate: storyDate,
      year: year, // Use the parsed year from story_date
      isSeen: json['is_seen'] ?? false,
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
