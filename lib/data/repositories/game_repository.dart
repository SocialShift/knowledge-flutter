import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:knowledge/core/network/api_service.dart';
import 'package:dio/dio.dart';
import 'package:knowledge/core/config/app_config.dart';
import 'package:knowledge/core/utils/debug_utils.dart';

part 'game_repository.g.dart';

class GameRepository {
  final ApiService _apiService;

  GameRepository() : _apiService = ApiService();

  Future<Map<String, dynamic>> getGameQuestions(int gameType) async {
    try {
      // Create a new Dio instance for this request to support query parameters
      final dio = Dio();
      dio.options.baseUrl = AppConfig.baseUrl;

      // Add cookie and other headers from storage if needed
      // Set longer timeout for potentially slow API responses
      dio.options.connectTimeout = const Duration(seconds: 15);
      dio.options.receiveTimeout = const Duration(seconds: 15);

      DebugUtils.debugLog('Fetching game questions for game type: $gameType');
      DebugUtils.debugLog(
          'Request URL: ${AppConfig.baseUrl}/game/questions/?game_type=$gameType');

      final response = await dio.get(
        '/game/questions/',
        queryParameters: {'game_type': gameType},
        options: Options(
          followRedirects: true,
          validateStatus: (status) {
            return status != null && status < 500;
          },
        ),
      );

      // Log response status
      DebugUtils.debugLog('Response status code: ${response.statusCode}');
      DebugUtils.debugLog('Response data: ${response.data}');

      if (response.statusCode == 200) {
        return response.data;
      } else if (response.statusCode == 307 || response.statusCode == 302) {
        // Handle redirect
        DebugUtils.debugLog(
            'Received redirect. Location: ${response.headers['location']}');
        final redirectUrl = response.headers['location']?.first;
        if (redirectUrl != null) {
          final redirectResponse = await dio.get(redirectUrl);
          if (redirectResponse.statusCode == 200) {
            return redirectResponse.data;
          }
        }
        throw 'Failed to follow redirect for game questions';
      } else {
        throw 'Failed to load questions with status code: ${response.statusCode}';
      }
    } catch (e) {
      DebugUtils.debugError('Error fetching game questions: $e');
      // More detailed error logging
      if (e is DioException) {
        DebugUtils.debugError('DioException type: ${e.type}');
        DebugUtils.debugError('DioException message: ${e.message}');
        DebugUtils.debugError('DioException response: ${e.response?.data}');
        DebugUtils.debugError(
            'DioException status code: ${e.response?.statusCode}');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> submitGameAttempt(
      int questionId, int selectedOptionId) async {
    try {
      final response = await _apiService.post(
        '/game/attempt',
        data: {
          'standalone_question_id': questionId,
          'selected_option_id': selectedOptionId,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw 'Failed to submit attempt with status code: ${response.statusCode}';
      }
    } catch (e) {
      DebugUtils.debugError('Error submitting game attempt: $e');
      rethrow;
    }
  }
}

@riverpod
GameRepository gameRepository(GameRepositoryRef ref) {
  return GameRepository();
}
