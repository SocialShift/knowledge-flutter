import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:knowledge/core/themes/app_theme.dart';
import 'package:knowledge/data/models/social_user.dart';
import 'package:knowledge/data/providers/social_provider.dart';
import 'package:knowledge/data/repositories/social_repository.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

class FollowingScreen extends HookConsumerWidget {
  final int profileId;

  const FollowingScreen({
    super.key,
    required this.profileId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final followingAsync = ref.watch(followingProvider(profileId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Following'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: followingAsync.when(
        data: (following) {
          if (following.isEmpty) {
            return const Center(
              child: Text('Not following anyone yet'),
            );
          }

          return ListView.builder(
            itemCount: following.length,
            padding: const EdgeInsets.all(16.0),
            itemBuilder: (context, index) {
              final followedUser = following[index];
              return _buildUserListItem(
                context,
                ref,
                SocialUser(
                  userId: followedUser['user_id'] ?? 0,
                  username: followedUser['username'] ?? '',
                  profileId: followedUser['profile_id'] ?? 0,
                  nickname: followedUser['nickname'] ?? '',
                  avatarUrl:
                      followedUser['avatar_url'] ?? 'media/images/default.jpeg',
                  isFollowing:
                      true, // Since this is a following list, all are already followed
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: SelectableText.rich(
            TextSpan(
              text: 'Error: ',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
              children: [
                TextSpan(
                  text: error.toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.normal,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserListItem(
    BuildContext context,
    WidgetRef ref,
    SocialUser user,
  ) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => context.push('/profile/${user.userId}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Avatar
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CachedNetworkImage(
                  imageUrl: user.avatarUrl,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  errorWidget: (context, url, error) =>
                      const Icon(Icons.person),
                ),
              ),
              const SizedBox(width: 12),

              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.nickname,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '@${user.username}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              // Unfollow button (since this is the following screen)
              ElevatedButton(
                onPressed: () {
                  ref
                      .read(socialNotifierProvider.notifier)
                      .unfollowUser(user.profileId);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade200,
                  foregroundColor: Colors.black87,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                child: const Text(
                  'Unfollow',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
