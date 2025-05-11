import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:knowledge/core/themes/app_theme.dart';
import 'package:knowledge/data/models/profile.dart';
import 'package:knowledge/data/providers/social_provider.dart';
import 'package:knowledge/data/repositories/social_repository.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:knowledge/core/utils/debouncer.dart';

class UserProfileScreen extends HookConsumerWidget {
  final int userId;

  const UserProfileScreen({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsync = ref.watch(userProfileByIdProvider(userId));

    // Create a debounced refresh function
    final debouncer = useMemoized(() => Debouncer(milliseconds: 500));

    // Use effect to refresh user profile when mounted
    useEffect(() {
      debouncer.run(() {
        ref.refresh(userProfileByIdProvider(userId));
      });
      return null;
    }, []);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: userProfileAsync.when(
        data: (profile) => _buildProfileContent(context, ref, profile),
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

  Widget _buildProfileContent(
    BuildContext context,
    WidgetRef ref,
    Profile profile,
  ) {
    // Check the JSON directly for the profile_id and is_following fields
    final profileData = profile.followers ?? {};

    // First try to get profileId from the followers map, then fall back to accessing it
    // directly from the profile['id'] field that we added in the fromApiResponse method
    int profileId = 0;

    if (profileData.containsKey('profile_id') &&
        profileData['profile_id'] != null) {
      profileId = profileData['profile_id'] as int;
    }

    // Get is_following field
    final isFollowing = profileData.containsKey('is_following')
        ? profileData['is_following'] as bool? ?? false
        : false;

    print('ProfileID: $profileId, IsFollowing: $isFollowing'); // Debug log

    // Create a state notifier to track follow status
    final isFollowingState = useState(isFollowing);

    // Function to update following status
    Future<void> toggleFollowStatus() async {
      try {
        if (profileId <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cannot follow/unfollow: Invalid profile ID'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        if (isFollowingState.value) {
          // Unfollow
          await ref.read(socialRepositoryProvider).unfollowUser(profileId);
          isFollowingState.value = false;
        } else {
          // Follow
          await ref.read(socialRepositoryProvider).followUser(profileId);
          isFollowingState.value = true;
        }

        // Show success message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isFollowingState.value
                  ? 'Successfully followed ${profile.nickname ?? "user"}'
                  : 'Successfully unfollowed ${profile.nickname ?? "user"}'),
              backgroundColor: AppColors.limeGreen,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }

        // Refresh user profile to get updated data
        if (context.mounted) {
          ref.refresh(userProfileByIdProvider(userId));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Profile header with avatar
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            color: AppColors.navyBlue.withOpacity(0.05),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: profile.avatarUrl != null &&
                          profile.avatarUrl!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: CachedNetworkImage(
                            imageUrl: profile.avatarUrl!,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                const CircularProgressIndicator(),
                            errorWidget: (context, url, error) => const Icon(
                              Icons.person,
                              size: 60,
                              color: AppColors.navyBlue,
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.person,
                          size: 60,
                          color: AppColors.navyBlue,
                        ),
                ),
                const SizedBox(height: 12),
                Text(
                  profile.nickname ?? 'User',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  profile.email,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (profile.pronouns != null &&
                    profile.pronouns!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    profile.pronouns!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                ],
                const SizedBox(height: 16),

                // Follow button
                ElevatedButton(
                  onPressed: toggleFollowStatus,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isFollowingState.value
                        ? Colors.grey.shade200
                        : AppColors.navyBlue,
                    foregroundColor:
                        isFollowingState.value ? Colors.black87 : Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: Text(
                    isFollowingState.value ? 'Unfollow' : 'Follow',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),

          // Social stats
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  context,
                  profile.followers != null
                      ? (profile.followers!['count'] ?? 0).toString()
                      : '0',
                  'Followers',
                  () => context.push(
                    '/profile/$userId/followers',
                  ),
                ),
                _buildStatItem(
                  context,
                  profile.following != null
                      ? (profile.following!['count'] ?? 0).toString()
                      : '0',
                  'Following',
                  () => context.push(
                    '/profile/$userId/following',
                  ),
                ),
                _buildStatItem(
                  context,
                  profile.completedQuizzes?.toString() ?? '0',
                  'Quizzes',
                  () {},
                ),
              ],
            ),
          ),

          const Divider(),

          // User info sections
          if (profile.location != null && profile.location!.isNotEmpty)
            _buildInfoSection(
              context,
              'Location',
              profile.location!,
              Icons.location_on_outlined,
            ),

          if (profile.languagePreference != null &&
              profile.languagePreference!.isNotEmpty)
            _buildInfoSection(
              context,
              'Language',
              profile.languagePreference!,
              Icons.language,
            ),

          if (profile.joinedDate != null && profile.joinedDate!.isNotEmpty)
            _buildInfoSection(
              context,
              'Joined',
              _formatDate(profile.joinedDate!),
              Icons.calendar_today_outlined,
            ),

          // Points and streak info
          if (profile.points != null)
            _buildInfoSection(
              context,
              'Points',
              '${profile.points}',
              Icons.star_outline,
            ),

          if (profile.currentLoginStreak != null)
            _buildInfoSection(
              context,
              'Current Streak',
              '${profile.currentLoginStreak} days',
              Icons.local_fire_department_outlined,
            ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String count,
    String label,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              count,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.navyBlue,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 8.0,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: AppColors.navyBlue,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}
