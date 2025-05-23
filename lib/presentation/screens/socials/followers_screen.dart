import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:knowledge/core/themes/app_theme.dart';
import 'package:knowledge/data/models/social_user.dart';
// import 'package:knowledge/data/providers/social_provider.dart';
import 'package:knowledge/data/repositories/social_repository.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:knowledge/data/providers/auth_provider.dart';

class FollowersScreen extends HookConsumerWidget {
  final int profileId;

  const FollowersScreen({
    super.key,
    required this.profileId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final followersAsync = ref.watch(followersProvider(profileId));

    // State to track which users have had their follow status updated
    final updatedUsers = useState<Map<int, bool>>({});

    // Get the current logged-in user state
    final authState = ref.watch(authNotifierProvider);

    // Extract current user ID from auth state
    final currentUserId = authState.maybeWhen(
      authenticated: (user, _, __) => user.id,
      orElse: () => '-1', // Default value when not authenticated
    );

    // Function to refresh followers list
    void refreshFollowers() {
      ref.refresh(followersProvider(profileId));
    }

    // Use effect to refresh on first build
    useEffect(() {
      Future.microtask(() => refreshFollowers());
      return null;
    }, []);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Followers'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: refreshFollowers,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: followersAsync.when(
        data: (followers) {
          if (followers.isEmpty) {
            return const Center(
              child: Text('No followers yet'),
            );
          }

          return ListView.builder(
            itemCount: followers.length,
            padding: const EdgeInsets.all(16.0),
            itemBuilder: (context, index) {
              final follower = followers[index];
              final userId = follower['user_id'] ?? 0;
              final profileId = follower['id'] ?? 0;

              // Convert user_id to string for comparison with currentUserId
              final userIdString = userId.toString();
              final isCurrentUser = userIdString == currentUserId;

              // Check if this user's follow status has been manually updated
              bool isFollowing = updatedUsers.value.containsKey(profileId)
                  ? updatedUsers.value[profileId]!
                  : follower['is_following'] ?? false;

              final user = SocialUser(
                userId: userId,
                username: follower['username'] ?? '',
                profileId: profileId,
                nickname: isCurrentUser ? 'You' : (follower['nickname'] ?? ''),
                avatarUrl:
                    follower['avatar_url'] ?? 'media/images/default.jpeg',
                isFollowing: isFollowing,
              );

              return _UserListItem(
                user: user,
                isCurrentUser: isCurrentUser,
                onFollowPressed: () async {
                  try {
                    // Immediately update the UI with the new state
                    final newFollowingState = !isFollowing;
                    updatedUsers.value = {
                      ...updatedUsers.value,
                      profileId: newFollowingState,
                    };

                    // Execute the actual API call
                    if (!newFollowingState) {
                      // Unfollow
                      await ref
                          .read(socialRepositoryProvider)
                          .unfollowUser(profileId);
                    } else {
                      // Follow
                      await ref
                          .read(socialRepositoryProvider)
                          .followUser(profileId);
                    }

                    // Show success message
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(newFollowingState
                              ? 'Successfully followed ${user.nickname}'
                              : 'Successfully unfollowed ${user.nickname}'),
                          backgroundColor: AppColors.limeGreen,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  } catch (e) {
                    // Revert the UI update if the API call fails
                    updatedUsers.value = {
                      ...updatedUsers.value,
                      profileId: isFollowing,
                    };

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: $e'),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }
                },
                onTap: () {
                  // Don't navigate if it's the current user
                  if (!isCurrentUser) {
                    context.push('/profile/$userId');
                  }
                },
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
}

class _UserListItem extends StatelessWidget {
  final SocialUser user;
  final VoidCallback onFollowPressed;
  final VoidCallback onTap;
  final bool isCurrentUser;

  const _UserListItem({
    required this.user,
    required this.onFollowPressed,
    required this.onTap,
    this.isCurrentUser = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
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
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isCurrentUser ? AppColors.limeGreen : null,
                      ),
                    ),
                    // Text(
                    //   '@${user.username}',
                    //   style: TextStyle(
                    //     color: Colors.grey.shade600,
                    //     fontSize: 14,
                    //   ),
                    // ),
                  ],
                ),
              ),

              // Follow button - hide for current user
              // if (!isCurrentUser)
              //   ElevatedButton(
              //     onPressed: onFollowPressed,
              //     style: ElevatedButton.styleFrom(
              //       backgroundColor: user.isFollowing
              //           ? Colors.grey.shade200
              //           : AppColors.navyBlue,
              //       foregroundColor:
              //           user.isFollowing ? Colors.black87 : Colors.white,
              //       elevation: 0,
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(20),
              //       ),
              //       padding: const EdgeInsets.symmetric(
              //         horizontal: 16,
              //         vertical: 8,
              //       ),
              //     ),
              //     child: Text(
              //       user.isFollowing ? 'Unfollow' : 'Follow',
              //       style: const TextStyle(fontSize: 14),
              //     ),
              //   ),
            ],
          ),
        ),
      ),
    );
  }
}
