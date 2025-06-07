import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:knowledge/core/network/api_service.dart';
import 'package:knowledge/data/models/timeline.dart';
import 'dart:developer' as developer;

class BookmarkRepository {
  final ApiService _apiService = ApiService();

  // Bookmark or unbookmark a timeline
  Future<Map<String, dynamic>> toggleBookmark(String timelineId) async {
    try {
      final response = await _apiService.post(
        '/timeline/$timelineId/bookmark',
        data: {},
      );

      if (response.statusCode == 401) {
        throw 'Please log in again to continue';
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'timeline_id': response.data['timeline_id'],
          'bookmarked': response.data['bookmarked'],
        };
      } else {
        final errorMessage = response.data['detail'] ??
            response.data['message'] ??
            'Failed to toggle bookmark';
        throw errorMessage.toString();
      }
    } catch (e) {
      developer.log('Error toggling bookmark for timeline $timelineId: $e');
      rethrow;
    }
  }

  // Check if a timeline is bookmarked
  Future<bool> isBookmarked(String timelineId) async {
    try {
      final response =
          await _apiService.get('/timeline/$timelineId/bookmarked');

      if (response.statusCode == 401) {
        throw 'Please log in again to continue';
      }

      if (response.statusCode == 200) {
        return response.data['bookmarked'] ?? false;
      } else {
        final errorMessage = response.data['detail'] ??
            response.data['message'] ??
            'Failed to check bookmark status';
        throw errorMessage.toString();
      }
    } catch (e) {
      developer
          .log('Error checking bookmark status for timeline $timelineId: $e');
      rethrow;
    }
  }

  // Get all bookmarked timelines
  Future<List<Timeline>> getBookmarkedTimelines() async {
    try {
      final response = await _apiService.get('/user/bookmarked-timelines');

      if (response.statusCode == 401) {
        throw 'Please log in again to continue';
      }

      if (response.statusCode == 200) {
        final List<dynamic> timelinesList = response.data;
        return timelinesList
            .map((json) => Timeline.fromBookmarkApiResponse(json))
            .toList();
      } else {
        final errorMessage = response.data['detail'] ??
            response.data['message'] ??
            'Failed to fetch bookmarked timelines';
        throw errorMessage.toString();
      }
    } catch (e) {
      developer.log('Error fetching bookmarked timelines: $e');
      rethrow;
    }
  }
}

// Riverpod providers
final bookmarkRepositoryProvider = Provider<BookmarkRepository>((ref) {
  return BookmarkRepository();
});

final bookmarkStatusProvider =
    FutureProvider.family<bool, String>((ref, timelineId) async {
  final repository = ref.watch(bookmarkRepositoryProvider);
  return repository.isBookmarked(timelineId);
});

final bookmarkedTimelinesProvider = FutureProvider<List<Timeline>>((ref) async {
  final repository = ref.watch(bookmarkRepositoryProvider);
  return repository.getBookmarkedTimelines();
});

final toggleBookmarkProvider =
    Provider<Future<Map<String, dynamic>> Function(String)>((ref) {
  return (String timelineId) async {
    final repository = ref.watch(bookmarkRepositoryProvider);
    final result = await repository.toggleBookmark(timelineId);

    // Invalidate related providers to refresh the UI
    ref.invalidate(bookmarkStatusProvider(timelineId));
    ref.invalidate(bookmarkedTimelinesProvider);

    return result;
  };
});
