// import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:knowledge/core/network/api_service.dart';
import 'package:knowledge/data/models/profile.dart';

part 'social_repository.g.dart';

class SocialRepository {
  final ApiService _apiService;

  SocialRepository() : _apiService = ApiService();

  // Search for users
  Future<Map<String, dynamic>> searchUsers(String query) async {
    try {
      final response = await _apiService.get('/auth/search/?query=$query');

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw response.data['detail'] ?? 'Failed to search users';
      }
    } catch (e) {
      print('Error searching users: $e');
      throw 'Failed to search users: $e';
    }
  }

  // Follow a user
  Future<void> followUser(int profileId) async {
    try {
      final response = await _apiService.post(
        '/auth/follow',
        data: {
          'profile_id': profileId,
        },
      );

      if (response.statusCode != 200) {
        throw response.data['detail'] ?? 'Failed to follow user';
      }
    } catch (e) {
      print('Error following user: $e');
      throw 'Failed to follow user: $e';
    }
  }

  // Unfollow a user
  Future<void> unfollowUser(int profileId) async {
    try {
      final response = await _apiService.delete('/auth/unfollow/$profileId');

      if (response.statusCode != 200) {
        throw response.data['detail'] ?? 'Failed to unfollow user';
      }
    } catch (e) {
      print('Error unfollowing user: $e');
      throw 'Failed to unfollow user: $e';
    }
  }

  // Get user followers
  Future<List<dynamic>> getFollowers(int profileId) async {
    try {
      final response = await _apiService.get('/auth/followers/$profileId');

      if (response.statusCode == 200) {
        return response.data['followers'] ?? [];
      } else {
        throw response.data['detail'] ?? 'Failed to get followers';
      }
    } catch (e) {
      print('Error getting followers: $e');
      throw 'Failed to get followers: $e';
    }
  }

  // Get user following
  Future<List<dynamic>> getFollowing(int profileId) async {
    try {
      final response = await _apiService.get('/auth/following/$profileId');

      if (response.statusCode == 200) {
        return response.data['following'] ?? [];
      } else {
        throw response.data['detail'] ?? 'Failed to get following';
      }
    } catch (e) {
      print('Error getting following: $e');
      throw 'Failed to get following: $e';
    }
  }

  // Get user profile by ID
  Future<Profile> getUserProfile(int userId) async {
    try {
      final response = await _apiService.get('/auth/user/$userId');

      if (response.statusCode == 200) {
        return Profile.fromApiResponse(response.data);
      } else {
        throw response.data['detail'] ?? 'Failed to fetch profile';
      }
    } catch (e) {
      print('Error fetching profile: $e');
      throw 'Failed to fetch profile: $e';
    }
  }
}

@riverpod
SocialRepository socialRepository(SocialRepositoryRef ref) {
  return SocialRepository();
}

// Provider for searching users
@riverpod
Future<Map<String, dynamic>> searchUsers(
    SearchUsersRef ref, String query) async {
  if (query.isEmpty) {
    return {'users': [], 'total': 0, 'skip': 0, 'limit': 20, 'query': ''};
  }

  final repository = ref.watch(socialRepositoryProvider);
  return repository.searchUsers(query);
}

// Provider for getting a user profile by ID
@riverpod
Future<Profile> userProfileById(UserProfileByIdRef ref, int userId) async {
  final repository = ref.watch(socialRepositoryProvider);
  return repository.getUserProfile(userId);
}

// Provider for getting followers
@riverpod
Future<List<dynamic>> followers(FollowersRef ref, int profileId) async {
  final repository = ref.watch(socialRepositoryProvider);
  return repository.getFollowers(profileId);
}

// Provider for getting following
@riverpod
Future<List<dynamic>> following(FollowingRef ref, int profileId) async {
  final repository = ref.watch(socialRepositoryProvider);
  return repository.getFollowing(profileId);
}
