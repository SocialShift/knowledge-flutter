import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:knowledge/data/models/timeline.dart';
import 'package:knowledge/data/repositories/timeline_repository.dart';

part 'timeline_provider.g.dart';

@riverpod
class TimelineNotifier extends _$TimelineNotifier {
  @override
  FutureOr<Timeline> build(String timelineId) {
    return _fetchTimeline(timelineId);
  }

  Future<Timeline> _fetchTimeline(String timelineId) async {
    // TODO: Replace with actual API call
    return Timeline(/* ... */);
  }
}
