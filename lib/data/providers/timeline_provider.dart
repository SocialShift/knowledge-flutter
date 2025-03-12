import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:knowledge/data/models/timeline.dart';
import 'package:knowledge/data/repositories/timeline_repository.dart';
import 'package:knowledge/data/models/history_item.dart';

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

// Provider for paginated timelines
final paginatedTimelinesProvider =
    StateNotifierProvider<PaginatedTimelinesNotifier, PaginatedData<Timeline>>(
        (ref) {
  return PaginatedTimelinesNotifier(ref);
});

class PaginatedTimelinesNotifier
    extends StateNotifier<PaginatedData<Timeline>> {
  final Ref _ref;
  static const int _pageSize = 10;
  int _currentPage = 0;

  PaginatedTimelinesNotifier(this._ref)
      : super(PaginatedData<Timeline>(items: [])) {
    loadNextPage();
  }

  Future<void> loadNextPage() async {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true);

    try {
      final repository = _ref.read(timelineRepositoryProvider);
      final timelines = await repository.getTimelines();

      // In a real implementation, you would pass the page parameter to the API
      // For now, we'll simulate pagination by slicing the list
      final startIndex = _currentPage * _pageSize;
      final endIndex = startIndex + _pageSize;

      if (startIndex >= timelines.length) {
        state = state.copyWith(
          isLoading: false,
          hasMore: false,
        );
        return;
      }

      final pageItems = timelines.sublist(startIndex,
          endIndex < timelines.length ? endIndex : timelines.length);

      _currentPage++;

      state = state.copyWith(
        items: [...state.items, ...pageItems],
        isLoading: false,
        hasMore: endIndex < timelines.length,
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
