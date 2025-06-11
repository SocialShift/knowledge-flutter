import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:knowledge/data/models/timeline.dart';
import 'package:knowledge/data/repositories/timeline_repository.dart';
import 'package:knowledge/data/models/history_item.dart';
import 'package:knowledge/data/providers/filter_provider.dart';
import 'package:knowledge/core/utils/debug_utils.dart';

// A simple class to hold pagination state
class PaginatedData<T> {
  final List<T> items;
  final bool hasMore;
  final bool isLoading;
  final String? error;

  PaginatedData({
    required this.items,
    this.hasMore = true,
    this.isLoading = false,
    this.error,
  });

  PaginatedData<T> copyWith({
    List<T>? items,
    bool? hasMore,
    bool? isLoading,
    String? error,
  }) {
    return PaginatedData<T>(
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Provider that filters and paginates timelines based on search query
final filteredPaginatedTimelinesProvider =
    Provider<PaginatedData<Timeline>>((ref) {
  final allTimelines = ref.watch(paginatedTimelinesProvider);
  final filterState = ref.watch(filterNotifierProvider);

  // Start with all timelines
  List<Timeline> filteredItems = allTimelines.items;

  // Apply all demographic and category filters
  if (filterState.hasActiveFilters) {
    filteredItems = filteredItems
        .where((timeline) => timeline.matchesAllFilters(filterState))
        .toList();
  }

  // Filter by search query if not empty
  if (filterState.searchQuery.isNotEmpty) {
    final searchQuery = filterState.searchQuery.toLowerCase();
    filteredItems = filteredItems.where((timeline) {
      // Check if the title contains the search query
      final matchesTitle = timeline.title.toLowerCase().contains(searchQuery);

      // Check if the year matches the search query
      // First, try to parse the search query as a year
      bool matchesYear = false;
      try {
        // Try to parse search as a year
        if (searchQuery.length == 4) {
          final searchYear = int.tryParse(searchQuery);
          if (searchYear != null) {
            // Check if the timeline year is close to the search year (within a 10-year range)
            matchesYear = (timeline.year - searchYear).abs() <= 10;
          }
        }
      } catch (_) {
        // If parsing fails, just continue with matchesYear as false
      }

      // Match also the timeline description
      final matchesDescription =
          timeline.description.toLowerCase().contains(searchQuery);

      return matchesTitle || matchesYear || matchesDescription;
    }).toList();
  }

  // Keep items sorted by year in descending order (newest first)
  filteredItems.sort((a, b) => b.year.compareTo(a.year));

  return PaginatedData<Timeline>(
    items: filteredItems,
    hasMore: false, // No more pagination for filtered results
    isLoading: allTimelines.isLoading,
    error: allTimelines.error,
  );
});

// Provider that filters stories for a timeline based on search query
final filteredTimelineStoriesProvider =
    Provider.family<AsyncValue<List<Story>>, String>((ref, timelineId) {
  final storiesAsync = ref.watch(timelineStoriesProvider(timelineId));
  final filterState = ref.watch(filterNotifierProvider);

  // If there's no search query or the stories are loading/error, return original stories
  if (filterState.searchQuery.isEmpty || !storiesAsync.hasValue) {
    return storiesAsync;
  }

  // If we have stories and a search query, filter them
  return storiesAsync.whenData((stories) {
    final searchQuery = filterState.searchQuery.toLowerCase();

    return stories.where((story) {
      // Check if the title contains the search query
      final matchesTitle = story.title.toLowerCase().contains(searchQuery);

      // Check if the year matches the search query
      bool matchesYear = false;
      try {
        // Try to parse search as a year
        if (searchQuery.length == 4) {
          final searchYear = int.tryParse(searchQuery);
          if (searchYear != null) {
            // Check if the story year is close to the search year (within a 5-year range)
            matchesYear = (story.year - searchYear).abs() <= 5;
          }
        }
      } catch (_) {
        // If parsing fails, just continue with matchesYear as false
      }

      // Match also the story description
      final matchesDescription =
          story.description.toLowerCase().contains(searchQuery);

      return matchesTitle || matchesYear || matchesDescription;
    }).toList();
  });
});

// Provider for paginated timelines
final paginatedTimelinesProvider =
    StateNotifierProvider<PaginatedTimelinesNotifier, PaginatedData<Timeline>>(
        (ref) {
  return PaginatedTimelinesNotifier(ref);
});

// Provider to find the first timeline with unseen stories
final firstUnseenTimelineIndexProvider = Provider<int>((ref) {
  final timelinesAsync = ref.watch(timelinesSortedByYearProvider);

  return timelinesAsync.when(
    data: (timelines) {
      // Find the first timeline that has unseen stories
      for (int i = 0; i < timelines.length; i++) {
        final timeline = timelines[i];
        final storiesAsync =
            ref.watch(filteredTimelineStoriesProvider(timeline.id));

        final hasUnseenStories = storiesAsync.when(
          data: (stories) => stories.any((story) => !story.isSeen),
          loading: () => false,
          error: (_, __) => false,
        );

        if (hasUnseenStories) {
          return i;
        }
      }

      // If no timeline has unseen stories, return 0 (first timeline)
      return 0;
    },
    loading: () => 0,
    error: (_, __) => 0,
  );
});

// Provider to check if all stories in a timeline are seen
final timelineAllStoriesSeenProvider =
    Provider.family<bool, String>((ref, timelineId) {
  final storiesAsync = ref.watch(filteredTimelineStoriesProvider(timelineId));

  return storiesAsync.when(
    data: (stories) {
      if (stories.isEmpty) return true;
      return stories.every((story) => story.isSeen);
    },
    loading: () => false,
    error: (_, __) => false,
  );
});

// Provider to get the next timeline index with unseen stories from a given index
final nextUnseenTimelineIndexProvider =
    Provider.family<int?, int>((ref, currentIndex) {
  final timelinesAsync = ref.watch(timelinesSortedByYearProvider);

  return timelinesAsync.when(
    data: (timelines) {
      // Look for the next timeline with unseen stories starting from currentIndex + 1
      for (int i = currentIndex + 1; i < timelines.length; i++) {
        final timeline = timelines[i];
        final storiesAsync =
            ref.watch(filteredTimelineStoriesProvider(timeline.id));

        final hasUnseenStories = storiesAsync.when(
          data: (stories) => stories.any((story) => !story.isSeen),
          loading: () => false,
          error: (_, __) => false,
        );

        if (hasUnseenStories) {
          return i;
        }
      }

      // If no timeline found after current index, check from beginning
      for (int i = 0; i < currentIndex; i++) {
        final timeline = timelines[i];
        final storiesAsync =
            ref.watch(filteredTimelineStoriesProvider(timeline.id));

        final hasUnseenStories = storiesAsync.when(
          data: (stories) => stories.any((story) => !story.isSeen),
          loading: () => false,
          error: (_, __) => false,
        );

        if (hasUnseenStories) {
          return i;
        }
      }

      return null; // No timeline with unseen stories found
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

// Enhanced provider to mark a story as seen and update the cache with real-time feedback
final markStorySeenProvider = Provider<Future<void> Function(String)>((ref) {
  return (String storyId) async {
    try {
      // Mark the story as seen via API
      final success = await ref.read(markStoryAsSeenProvider(storyId).future);

      if (success) {
        // Force immediate invalidation of all story-related providers for real-time updates
        ref.invalidate(timelineStoriesProvider);
        ref.invalidate(filteredTimelineStoriesProvider);
        ref.invalidate(storyDetailProvider);

        // Force refresh of timeline and story data

        // Wait a brief moment then invalidate UI state providers
        await Future.delayed(const Duration(milliseconds: 100));
        ref.invalidate(firstUnseenTimelineIndexProvider);
        ref.invalidate(timelineAllStoriesSeenProvider);
        ref.invalidate(nextUnseenTimelineIndexProvider);

        DebugUtils.debugLog(
            'Story $storyId marked as seen successfully with real-time updates');
      } else {
        DebugUtils.debugError('Failed to mark story $storyId as seen');
      }
    } catch (e) {
      DebugUtils.debugError('Error marking story $storyId as seen: $e');
    }
  };
});

class PaginatedTimelinesNotifier
    extends StateNotifier<PaginatedData<Timeline>> {
  final Ref _ref;
  static const int _pageSize = 10;
  int _currentPage = 0;
  List<Timeline> _allTimelines = [];

  PaginatedTimelinesNotifier(this._ref)
      : super(PaginatedData<Timeline>(items: [])) {
    loadNextPage();
  }

  Future<void> loadNextPage() async {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true);

    try {
      // If we're loading the first page, fetch all timelines
      if (_currentPage == 0) {
        final repository = _ref.read(timelineRepositoryProvider);
        _allTimelines = await repository.getTimelines();

        // Sort timelines in descending order by year (newest first)
        _allTimelines.sort((a, b) => b.year.compareTo(a.year));
      }

      // Simulate pagination by slicing the list
      final startIndex = _currentPage * _pageSize;
      final endIndex = startIndex + _pageSize;

      if (startIndex >= _allTimelines.length) {
        state = state.copyWith(
          isLoading: false,
          hasMore: false,
        );
        return;
      }

      final pageItems = _allTimelines.sublist(startIndex,
          endIndex < _allTimelines.length ? endIndex : _allTimelines.length);

      _currentPage++;

      state = state.copyWith(
        items: [...state.items, ...pageItems],
        isLoading: false,
        hasMore: endIndex < _allTimelines.length,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void refresh() {
    _currentPage = 0;
    _allTimelines = [];
    state = PaginatedData<Timeline>(items: []);
    loadNextPage();
  }

  // Convert Timeline to HistoryItem for use with HistoryCard
  static HistoryItem timelineToHistoryItem(Timeline timeline) {
    return HistoryItem(
      id: timeline.id,
      title: timeline.title,
      subtitle: timeline.description,
      imageUrl: timeline.imageUrl,
      year: timeline.year,
    );
  }
}
