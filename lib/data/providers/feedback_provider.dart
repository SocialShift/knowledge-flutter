import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:knowledge/data/repositories/feedback_repository.dart';

part 'feedback_provider.g.dart';

@riverpod
class FeedbackNotifier extends _$FeedbackNotifier {
  @override
  FutureOr<bool> build() async {
    // Check if feedback has been shown already
    final repository = ref.read(feedbackRepositoryProvider);
    return await repository.hasFeedbackBeenShown();
  }

  Future<void> markFeedbackAsShown() async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(feedbackRepositoryProvider);
      await repository.markFeedbackAsShown();
      state = const AsyncData(true);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<bool> submitFeedback(String text) async {
    try {
      final repository = ref.read(feedbackRepositoryProvider);
      final success = await repository.submitFeedback(text: text);

      if (success) {
        // Make sure feedback is marked as shown
        await markFeedbackAsShown();
      }

      return success;
    } catch (e) {
      return false;
    }
  }

  Future<String?> getLastFeedbackRating() async {
    final repository = ref.read(feedbackRepositoryProvider);
    return await repository.getLastFeedbackRating();
  }

  Future<String?> getLastFeedbackText() async {
    final repository = ref.read(feedbackRepositoryProvider);
    return await repository.getLastFeedbackText();
  }
}
