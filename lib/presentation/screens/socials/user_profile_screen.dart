import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:knowledge/core/themes/app_theme.dart';
import 'package:knowledge/data/models/profile.dart';
// import 'package:knowledge/data/providers/social_provider.dart';
import 'package:knowledge/data/repositories/social_repository.dart';
import 'package:go_router/go_router.dart';
import 'package:knowledge/core/utils/debouncer.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
// import 'package:knowledge/presentation/widgets/user_avatar.dart';

class UserProfileScreen extends HookConsumerWidget {
  final int userId;

  const UserProfileScreen({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get theme brightness
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDarkMode ? AppColors.darkBackground : Colors.white;
    final textColor = isDarkMode ? Colors.white : AppColors.navyBlue;
    final secondaryTextColor = isDarkMode ? Colors.white70 : Colors.black87;
    final cardColor = isDarkMode ? AppColors.darkCard : Colors.white;
    final cardBorderColor =
        isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300;

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
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        centerTitle: true,
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: textColor,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: userProfileAsync.when(
        loading: () => _buildProfileSkeleton(ref, isDarkMode),
        error: (error, stack) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 48,
              ),
              const SizedBox(height: 16),
              SelectableText.rich(
                TextSpan(
                  children: [
                    const TextSpan(
                      text: 'Error loading profile: ',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: error.toString(),
                      style: TextStyle(color: secondaryTextColor),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.limeGreen,
                  foregroundColor: Colors.black,
                ),
                onPressed: () => ref.refresh(userProfileByIdProvider(userId)),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (profile) => UserProfileBody(
          profile: profile,
          userId: userId,
          isDarkMode: isDarkMode,
        ),
      ),
    );
  }

  // Build a skeleton loading UI for the profile screen
  Widget _buildProfileSkeleton(WidgetRef ref, bool isDarkMode) {
    final skeletonBaseColor =
        isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100;
    final skeletonHighlightColor =
        isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200;
    final cardGradientStart = isDarkMode
        ? AppColors.darkSurface.withOpacity(0.7)
        : AppColors.navyBlue.withOpacity(0.7);
    final cardGradientEnd = isDarkMode
        ? AppColors.darkBackground.withOpacity(0.5)
        : AppColors.navyBlue.withOpacity(0.5);

    return RefreshIndicator(
      onRefresh: () async {
        // Refresh the profile data
        await Future.delayed(Duration.zero);
        ref.refresh(userProfileByIdProvider(userId));
        return;
      },
      color: AppColors.limeGreen,
      backgroundColor: isDarkMode ? AppColors.darkCard : Colors.white,
      strokeWidth: 2.5,
      displacement: 40,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // Profile card skeleton
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    cardGradientStart,
                    cardGradientEnd,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  // Avatar skeleton
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Name skeleton
                  Container(
                    width: 150,
                    height: 22,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Join date skeleton
                  Container(
                    width: 120,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Social counts skeleton
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.blue.withOpacity(0.1),
                    Colors.purple.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDarkMode
                      ? Colors.grey.shade800.withOpacity(0.3)
                      : AppColors.navyBlue.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  // Followers skeleton
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          width: 50,
                          height: 24,
                          decoration: BoxDecoration(
                            color: skeletonHighlightColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 70,
                          height: 16,
                          decoration: BoxDecoration(
                            color: skeletonHighlightColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: isDarkMode
                        ? Colors.grey.shade700
                        : AppColors.navyBlue.withOpacity(0.1),
                  ),
                  // Following skeleton
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          width: 50,
                          height: 24,
                          decoration: BoxDecoration(
                            color: skeletonHighlightColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 70,
                          height: 16,
                          decoration: BoxDecoration(
                            color: skeletonHighlightColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Follow button skeleton
            Container(
              width: double.infinity,
              height: 48,
              margin: const EdgeInsets.only(top: 10, left: 16, right: 16),
              decoration: BoxDecoration(
                color: skeletonHighlightColor,
                borderRadius: BorderRadius.circular(16),
              ),
            ),

            const SizedBox(height: 24),

            // Overview section skeleton
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 16, 12),
              child: Row(
                children: [
                  Container(
                    width: 120,
                    height: 20,
                    decoration: BoxDecoration(
                      color: skeletonHighlightColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
            ),

            // Stat cards skeleton
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: List.generate(
                  3,
                  (index) => Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      height: 120,
                      decoration: BoxDecoration(
                        color: skeletonBaseColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDarkMode
                              ? Colors.grey.shade700
                              : Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: skeletonHighlightColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: 40,
                            height: 20,
                            decoration: BoxDecoration(
                              color: skeletonHighlightColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: 60,
                            height: 12,
                            decoration: BoxDecoration(
                              color: skeletonHighlightColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().shimmer(
          duration: const Duration(milliseconds: 1500),
          curve: Curves.easeInOut,
        );
  }
}

class UserProfileBody extends HookConsumerWidget {
  final Profile profile;
  final int userId;
  final bool isDarkMode;

  const UserProfileBody({
    super.key,
    required this.profile,
    required this.userId,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textColor = isDarkMode ? Colors.white : AppColors.navyBlue;
    final secondaryTextColor = isDarkMode ? Colors.white70 : Colors.black87;
    final cardColor = isDarkMode ? AppColors.darkCard : Colors.white;
    final cardBorderColor =
        isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300;

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

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          // Refresh the profile data
          await Future.delayed(Duration.zero);
          ref.refresh(userProfileByIdProvider(userId));
          return;
        },
        color: AppColors.limeGreen,
        backgroundColor: isDarkMode ? AppColors.darkCard : Colors.white,
        strokeWidth: 2.5,
        displacement: 40,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Profile card at the top
              ProfileCardWidget(
                profile: profile,
                isFollowing: isFollowingState.value,
                onToggleFollowStatus: toggleFollowStatus,
                isDarkMode: isDarkMode,
              ).animate().fadeIn(duration: const Duration(milliseconds: 500)),

              const SizedBox(height: 12),

              // Followers and Following section with Follow/Unfollow button below
              SocialCountsWidget(
                profile: profile,
                userId: userId,
                isFollowing: isFollowingState.value,
                onToggleFollowStatus: toggleFollowStatus,
                isDarkMode: isDarkMode,
              )
                  .animate()
                  .fadeIn(duration: const Duration(milliseconds: 500))
                  .slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuad),

              const SizedBox(height: 12),

              // Overview section with rank, journey and points
              OverviewWidget(
                profile: profile,
                isDarkMode: isDarkMode,
              )
                  .animate()
                  .fadeIn(
                    duration: const Duration(milliseconds: 500),
                    delay: const Duration(milliseconds: 100),
                  )
                  .slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuad),

              const SizedBox(height: 12),

              // Percentile rank
              if (profile.percentile != null)
                PercentileWidget(
                  profile: profile,
                  isDarkMode: isDarkMode,
                )
                    .animate()
                    .fadeIn(
                      duration: const Duration(milliseconds: 500),
                      delay: const Duration(milliseconds: 150),
                    )
                    .slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuad),

              const SizedBox(height: 12),

              // Streak information
              if (profile.currentLoginStreak != null)
                StreakInfoWidget(
                  profile: profile,
                  isDarkMode: isDarkMode,
                )
                    .animate()
                    .fadeIn(
                      duration: const Duration(milliseconds: 500),
                      delay: const Duration(milliseconds: 200),
                    )
                    .slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuad),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileCardWidget extends StatelessWidget {
  final Profile profile;
  final bool isFollowing;
  final VoidCallback onToggleFollowStatus;
  final bool isDarkMode;

  const ProfileCardWidget({
    super.key,
    required this.profile,
    required this.isFollowing,
    required this.onToggleFollowStatus,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final formattedDate = profile.joinedDate != null
        ? DateFormat("MMM d, yyyy").format(DateTime.parse(profile.joinedDate!))
        : "Unknown join date";

    final cardGradientStart = isDarkMode
        ? AppColors.darkSurface.withOpacity(0.9)
        : AppColors.navyBlue.withOpacity(0.9);
    final cardGradientEnd = isDarkMode
        ? AppColors.darkBackground.withOpacity(0.7)
        : AppColors.navyBlue.withOpacity(0.7);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cardGradientStart,
            cardGradientEnd,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.limeGreen.withOpacity(0.0),
          width: 0,
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.3)
                : AppColors.navyBlue.withOpacity(0.3),
            blurRadius: 0,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.navyBlue.withOpacity(0.0),
                          width: 0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.limeGreen.withOpacity(0.0),
                            blurRadius: 0,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDarkMode ? AppColors.darkCard : Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 5,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: profile.avatarUrl != null &&
                                  profile.avatarUrl!.isNotEmpty
                              ? Image.network(
                                  profile.avatarUrl!,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(
                                    Icons.person,
                                    size: 80,
                                    color: Colors.white70,
                                  ),
                                )
                              : const Icon(
                                  Icons.person,
                                  size: 80,
                                  color: Colors.white70,
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Nickname with pronouns
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text: profile.nickname ?? 'User',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (profile.pronouns != null) ...[
                  const TextSpan(text: ' '),
                  TextSpan(
                    text: '(${profile.pronouns})',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Join date only (no email)
          Text(
            "Joined $formattedDate",
            style: TextStyle(
              color: AppColors.limeGreen.withOpacity(0.9),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class SocialCountsWidget extends StatelessWidget {
  final Profile profile;
  final int userId;
  final bool isFollowing;
  final VoidCallback onToggleFollowStatus;
  final bool isDarkMode;

  const SocialCountsWidget({
    super.key,
    required this.profile,
    required this.userId,
    required this.isFollowing,
    required this.onToggleFollowStatus,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    // Get follower and following counts from profile
    final followerCount = profile.followers?['count'] ?? 0;
    final followingCount = profile.following?['count'] ?? 0;

    final textColor = isDarkMode ? Colors.white : AppColors.navyBlue;
    final cardBorderColor =
        isDarkMode ? Colors.grey.shade800 : AppColors.navyBlue.withOpacity(0.1);
    final dividerColor =
        isDarkMode ? Colors.grey.shade800 : AppColors.navyBlue.withOpacity(0.1);

    return Column(
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDarkMode
                  ? [
                      Colors.blue.withOpacity(0.1),
                      Colors.purple.withOpacity(0.05),
                    ]
                  : [
                      Colors.blue.withOpacity(0.2),
                      Colors.purple.withOpacity(0.1),
                    ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: cardBorderColor,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isDarkMode
                    ? Colors.black.withOpacity(0.2)
                    : AppColors.navyBlue.withOpacity(0.1),
                blurRadius: 8,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    if (userId > 0) {
                      context.push('/profile/$userId/followers');
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      children: [
                        Text(
                          followerCount.toString(),
                          style: TextStyle(
                            color: textColor,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Followers",
                          style: TextStyle(
                            color: textColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: dividerColor,
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    if (userId > 0) {
                      context.push('/profile/$userId/following');
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      children: [
                        Text(
                          followingCount.toString(),
                          style: TextStyle(
                            color: textColor,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Following",
                          style: TextStyle(
                            color: textColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Follow/Unfollow button with updated UI
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(
            top: 12,
            left: 16,
            right: 16,
            bottom: 8,
          ),
          child: ElevatedButton.icon(
            onPressed: onToggleFollowStatus,
            icon: Icon(
              isFollowing ? Icons.person_remove : Icons.person_add_alt,
              color: isFollowing
                  ? (isDarkMode ? Colors.white : AppColors.navyBlue)
                  : (isDarkMode ? Colors.black : Colors.black),
            ),
            label: Text(
              isFollowing ? 'Unfollow' : 'Follow',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isFollowing
                    ? (isDarkMode ? Colors.white : AppColors.navyBlue)
                    : (isDarkMode ? Colors.black : Colors.black),
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: isFollowing
                  ? (isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200)
                  : AppColors.limeGreen,
              foregroundColor: isFollowing
                  ? (isDarkMode ? Colors.white : AppColors.navyBlue)
                  : Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 12),
              elevation: 2,
              shadowColor: Colors.black26,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isFollowing
                      ? (isDarkMode
                          ? Colors.grey.shade700
                          : Colors.grey.shade400)
                      : AppColors.limeGreen.withOpacity(0.7),
                  width: 1,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class OverviewWidget extends StatelessWidget {
  final Profile profile;
  final bool isDarkMode;

  const OverviewWidget({
    super.key,
    required this.profile,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 28, 16, 12),
          child: Row(
            children: [
              Icon(
                Icons.insights,
                color: AppColors.navyBlue,
                size: 20,
              ),
              SizedBox(width: 6),
              Text(
                "Overview",
                style: TextStyle(
                  color: AppColors.navyBlue,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Rank
              Expanded(
                child: _buildStatCard(
                  label: "Rank",
                  value: profile.rank?.toString() ?? "N/A",
                  icon: Icons.emoji_events,
                  iconColor: Colors.amber,
                  gradientColors: [
                    Colors.amber.withOpacity(0.0),
                    Colors.orange.withOpacity(0.0),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Journey
              Expanded(
                child: _buildStatCard(
                  label: "Journey",
                  value: profile.completedQuizzes?.toString() ?? "N/A",
                  icon: Icons.history_edu,
                  iconColor: Colors.blue,
                  gradientColors: [
                    Colors.blue.withOpacity(0.0),
                    Colors.lightBlue.withOpacity(0.0),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Points
              Expanded(
                child: _buildStatCard(
                  label: "Points",
                  value: profile.points?.toString() ?? "0",
                  icon: Icons.stars,
                  iconColor: AppColors.limeGreen,
                  gradientColors: [
                    AppColors.limeGreen.withOpacity(0.0),
                    Colors.green.withOpacity(0.0),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
    required List<Color> gradientColors,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.navyBlue.withOpacity(0.1),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.navyBlue.withOpacity(0.0),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.navyBlue,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: AppColors.navyBlue.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class PercentileWidget extends StatelessWidget {
  final Profile profile;
  final bool isDarkMode;

  const PercentileWidget({
    super.key,
    required this.profile,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.amber.withOpacity(0.0),
            Colors.orange.withOpacity(0.0),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.navyBlue.withOpacity(0.1),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.navyBlue.withOpacity(0.0),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.0),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withOpacity(0.0),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Icon(
              Icons.emoji_events_outlined,
              color: Colors.amber[800],
              size: 28,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Top ${profile.percentile}%",
                  style: const TextStyle(
                    color: AppColors.navyBlue,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Rank ${profile.rank} out of ${profile.totalUsers} users",
                  style: TextStyle(
                    color: AppColors.navyBlue.withOpacity(0.7),
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          // Add a small trophy badge
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.amber,
                  Colors.amber[700]!,
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withOpacity(0.5),
                  blurRadius: 0,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Text(
              "#${profile.rank}",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StreakInfoWidget extends StatelessWidget {
  final Profile profile;
  final bool isDarkMode;

  const StreakInfoWidget({
    super.key,
    required this.profile,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final streakPercent =
        profile.currentLoginStreak != null && profile.nextMilestone != null
            ? (profile.currentLoginStreak! / profile.nextMilestone!)
            : 0.0;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.deepOrange.withOpacity(0.9),
            Colors.orange.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.orange.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_fire_department,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Login Streak",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              // Display the streak as a badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.3),
                      Colors.white.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Text(
                      "${profile.currentLoginStreak}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.whatshot,
                      color: Colors.white,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStreakStat(
                label: "Current",
                value: "${profile.currentLoginStreak ?? 0} days",
                icon: Icons.today,
              ),
              _buildStreakStat(
                label: "Maximum",
                value: "${profile.maxLoginStreak ?? 0} days",
                icon: Icons.star,
              ),
              _buildStreakStat(
                label: "Next Goal",
                value: "${profile.nextMilestone ?? 0} days",
                icon: Icons.flag,
              ),
            ],
          ),
          if (profile.daysToNextMilestone != null) ...[
            const SizedBox(height: 20),
            // Progress bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${profile.daysToNextMilestone} days to reach next milestone",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      "${(streakPercent * 100).toInt()}%",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Stack(
                  children: [
                    // Background
                    Container(
                      height: 12,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    // Progress
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      height: 12,
                      width: MediaQuery.of(context).size.width *
                          streakPercent *
                          0.7, // Adjust for margins
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.white,
                            AppColors.limeGreen,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.limeGreen.withOpacity(0.5),
                            blurRadius: 4,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStreakStat({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: Colors.white.withOpacity(0.8),
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
