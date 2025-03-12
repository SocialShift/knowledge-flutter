import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:knowledge/core/network/api_service.dart';
import 'package:knowledge/data/models/leaderboard.dart';

class LeaderboardRepository {
  final ApiService _apiService;

  LeaderboardRepository() : _apiService = ApiService();

  Future<LeaderboardResponse> getLeaderboard() async {
    try {
      final response = await _apiService.get('/leaderboard');

      if (response.statusCode == 401) {
        throw 'Please log in again to continue';
      }

      if (response.statusCode != 200) {
        final errorMessage = response.data['detail'] ??
            response.data['message'] ??
            'Failed to fetch leaderboard';
        throw errorMessage.toString();
      }

      // Parse the response data
      final Map<String, dynamic> responseData = response.data;
      return LeaderboardResponse(
        leaderboard: (responseData['leaderboard'] as List)
            .map((item) => LeaderboardUser.fromJson(item))
            .toList(),
        userRank: responseData['user_rank'] ?? 0,
      );
    } catch (e) {
      print('Error fetching leaderboard: $e');
      rethrow;
    }
  }
}

// Repository provider
final leaderboardRepositoryProvider = Provider<LeaderboardRepository>((ref) {
  return LeaderboardRepository();
});

// Leaderboard data provider
final leaderboardProvider = FutureProvider<LeaderboardResponse>((ref) async {
  final repository = ref.watch(leaderboardRepositoryProvider);
  return repository.getLeaderboard();
});
