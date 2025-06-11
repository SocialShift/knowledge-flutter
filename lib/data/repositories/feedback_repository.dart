import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:knowledge/core/network/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:knowledge/core/utils/debug_utils.dart';

part 'feedback_repository.g.dart';

class FeedbackRepository {
  final ApiService _apiService = ApiService();
  static const String _feedbackShownKey = 'feedback_shown';
  static const String _lastFeedbackRatingKey = 'last_feedback_rating';
  static const String _lastFeedbackTextKey = 'last_feedback_text';

  // Submit feedback to backend
  Future<bool> submitFeedback({required String text}) async {
    try {
      final response = await _apiService.post(
        '/auth/create-feedback',
        data: {
          'text': text,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // If submission was successful, save the feedback locally
        // Extract rating from text (format is "Rating: Comment")
        final parts = text.split(':');
        if (parts.length >= 1) {
          final rating = parts[0].trim();
          final comment =
              parts.length > 1 ? parts.sublist(1).join(':').trim() : '';

          await saveLastFeedback(rating, comment);
        }
        return true;
      }

      return false;
    } catch (e) {
      DebugUtils.debugError('Error submitting feedback: $e');
      return false;
    }
  }

  // Check if feedback has been shown before
  Future<bool> hasFeedbackBeenShown() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_feedbackShownKey) ?? false;
    } catch (e) {
      DebugUtils.debugError('Error checking feedback status: $e');
      return false;
    }
  }

  // Mark feedback as shown
  Future<void> markFeedbackAsShown() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_feedbackShownKey, true);
    } catch (e) {
      DebugUtils.debugError('Error marking feedback as shown: $e');
    }
  }

  // Save the last submitted feedback
  Future<void> saveLastFeedback(String rating, String text) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastFeedbackRatingKey, rating);
      await prefs.setString(_lastFeedbackTextKey, text);
    } catch (e) {
      DebugUtils.debugError('Error saving last feedback: $e');
    }
  }

  // Get the last submitted feedback rating
  Future<String?> getLastFeedbackRating() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_lastFeedbackRatingKey);
    } catch (e) {
      DebugUtils.debugError('Error getting last feedback rating: $e');
      return null;
    }
  }

  // Get the last submitted feedback text
  Future<String?> getLastFeedbackText() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_lastFeedbackTextKey);
    } catch (e) {
      DebugUtils.debugError('Error getting last feedback text: $e');
      return null;
    }
  }
}

@riverpod
FeedbackRepository feedbackRepository(FeedbackRepositoryRef ref) {
  return FeedbackRepository();
}
