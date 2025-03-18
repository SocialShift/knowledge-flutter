import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:knowledge/core/network/api_service.dart';
import 'package:knowledge/data/models/timeline.dart';

part 'timeline_repository.g.dart';

class TimelineRepository {
  final ApiService _apiService;

  TimelineRepository() : _apiService = ApiService();

  Future<List<Timeline>> getTimelines() async {
    try {
      final response = await _apiService.get('/list/timelines');

      if (response.statusCode == 401) {
        throw 'Please log in again to continue';
      }

      if (response.statusCode != 200) {
        final errorMessage = response.data['detail'] ??
            response.data['message'] ??
            'Failed to fetch timelines';
        throw errorMessage.toString();
      }

      // Parse the response data - the response is a direct list, not wrapped in a 'timelines' key
      final List<dynamic> timelinesData = response.data ?? [];

      // Convert the API response to our Timeline model using the fromApiResponse constructor
      return timelinesData
          .map((json) => Timeline.fromApiResponse(json))
          .toList();
    } catch (e) {
      print('Error fetching timelines: $e');
      rethrow;
    }
  }

  // Fetch stories for a specific timeline
  Future<List<Story>> getTimelineStories(String timelineId) async {
    try {
      final response = await _apiService.get('/timeline/$timelineId/stories');

      if (response.statusCode == 401) {
        throw 'Please log in again to continue';
      }

      if (response.statusCode != 200) {
        final errorMessage = response.data['detail'] ??
            response.data['message'] ??
            'Failed to fetch stories';
        throw errorMessage.toString();
      }

      // Parse the response data
      final List<dynamic> storiesData = response.data ?? [];

      // Convert the API response to our Story model using the fromApiResponse constructor
      return storiesData.map((json) => Story.fromApiResponse(json)).toList();
    } catch (e) {
      print('Error fetching stories for timeline $timelineId: $e');
      rethrow;
    }
  }

  // Fetch a story by ID
  Future<Story> getStoryById(String storyId) async {
    try {
      final response = await _apiService.get('/story/$storyId');

      if (response.statusCode == 401) {
        throw 'Please log in again to continue';
      }

      if (response.statusCode != 200) {
        final errorMessage = response.data['detail'] ??
            response.data['message'] ??
            'Failed to fetch story';
        throw errorMessage.toString();
      }

      // Handle the new nested response format
      if (response.data is Map<String, dynamic>) {
        // Extract story data from the nested structure
        final storyData = response.data['story'];
        if (storyData == null) {
          throw 'Invalid response format for story';
        }

        // Get timestamps from the timestamps array if available
        List<Timestamp> timestamps = [];
        if (response.data['timestamps'] is List) {
          final timestampsData = response.data['timestamps'];
          timestamps = timestampsData
              .map<Timestamp>((json) => Timestamp(
                    id: json['id']?.toString(),
                    storyId: json['story_id']?.toString(),
                    timeSec: json['time_sec'] ?? 0,
                    label: json['label'] ?? '',
                  ))
              .toList();
        }

        // Create the story with timestamps
        final story = Story.fromApiResponse(storyData);
        return story.copyWith(timestamps: timestamps);
      } else {
        throw 'Invalid response format for story';
      }
    } catch (e) {
      print('Error fetching story $storyId: $e');
      rethrow;
    }
  }

  // Helper method to extract the start year from a year range string like "2024 - 2030"
  int _parseYearRange(String yearRange) {
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

@riverpod
TimelineRepository timelineRepository(TimelineRepositoryRef ref) {
  return TimelineRepository();
}

@riverpod
Future<List<Timeline>> timelines(TimelinesRef ref) async {
  final repository = ref.watch(timelineRepositoryProvider);
  return repository.getTimelines();
}

// Provider for fetching stories for a specific timeline
@riverpod
Future<List<Story>> timelineStories(
    TimelineStoriesRef ref, String timelineId) async {
  final repository = ref.watch(timelineRepositoryProvider);
  return repository.getTimelineStories(timelineId);
}

// Provider for fetching a story by ID
@riverpod
Future<Story> storyDetail(StoryDetailRef ref, String storyId) async {
  final repository = ref.watch(timelineRepositoryProvider);
  return repository.getStoryById(storyId);
}
