import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:knowledge/data/models/social_user.dart';
import 'package:knowledge/data/repositories/social_repository.dart';

part 'social_provider.g.dart';

@riverpod
class SocialNotifier extends _$SocialNotifier {
  @override
  AsyncValue<List<SocialUser>> build() {
    return const AsyncValue.data([]);
  }

  Future<void> searchUsers(String query) async {
    if (query.isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }

    state = const AsyncValue.loading();
    try {
      final repository = ref.read(socialRepositoryProvider);
      final result = await repository.searchUsers(query);

      final List<dynamic> usersData = result['users'] ?? [];
      final users = usersData
          .map((userData) => SocialUser(
                userId: userData['user_id'] ?? 0,
                username: userData['username'] ?? '',
                profileId: userData['profile_id'] ?? 0,
                nickname: userData['nickname'] ?? '',
                avatarUrl:
                    userData['avatar_url'] ?? 'media/images/default.jpeg',
                isFollowing: userData['is_following'] ?? false,
              ))
          .toList();

      state = AsyncValue.data(users);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> followUser(int profileId) async {
    try {
      final repository = ref.read(socialRepositoryProvider);
      await repository.followUser(profileId);

      // Update the user in the list
      state.whenData((users) {
        final updatedUsers = users.map((user) {
          if (user.profileId == profileId) {
            return user.copyWith(isFollowing: true);
          }
          return user;
        }).toList();

        state = AsyncValue.data(updatedUsers);
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error following user: $e');
      }
    }
  }

  Future<void> unfollowUser(int profileId) async {
    try {
      final repository = ref.read(socialRepositoryProvider);
      await repository.unfollowUser(profileId);

      // Update the user in the list
      state.whenData((users) {
        final updatedUsers = users.map((user) {
          if (user.profileId == profileId) {
            return user.copyWith(isFollowing: false);
          }
          return user;
        }).toList();

        state = AsyncValue.data(updatedUsers);
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error unfollowing user: $e');
      }
    }
  }
}

// Provider for the social search input
@riverpod
class SearchQuery extends _$SearchQuery {
  @override
  String build() {
    return '';
  }

  void setQuery(String query) {
    state = query;
  }
}
