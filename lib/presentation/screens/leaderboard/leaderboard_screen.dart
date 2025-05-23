import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:knowledge/core/themes/app_theme.dart';
import 'package:knowledge/data/repositories/leaderboard_repository.dart';
import 'package:knowledge/data/models/leaderboard.dart';
import 'package:cached_network_image/cached_network_image.dart';

class LeaderboardScreen extends HookConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get theme brightness
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDarkMode ? AppColors.darkBackground : Colors.white;
    final textColor = isDarkMode ? Colors.white : AppColors.navyBlue;
    final secondaryTextColor = isDarkMode ? Colors.white70 : Colors.black54;
    final cardColor = isDarkMode ? AppColors.darkCard : Colors.white;
    final cardBorderColor =
        isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300;

    // Fetch leaderboard data
    final leaderboardAsync = ref.watch(leaderboardProvider);

    // Function to refresh leaderboard data
    void refreshLeaderboard() {
      ref.invalidate(leaderboardProvider);
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: RefreshIndicator(
        onRefresh: () async {
          refreshLeaderboard();
          // Wait for the refresh to complete
          await Future.delayed(const Duration(milliseconds: 500));
        },
        color: AppColors.limeGreen,
        backgroundColor: cardColor,
        child: Stack(
          children: [
            // Background gradient only for the top section
            Container(
              height: 220, // Just enough for the header
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDarkMode
                      ? [
                          AppColors.darkSurface,
                          AppColors.darkBackground,
                        ]
                      : [
                          AppColors.lightPurple,
                          AppColors.navyBlue,
                        ],
                  stops: const [0.0, 0.7],
                ),
              ),
            ),
            CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                // Header
                SliverAppBar(
                  expandedHeight: 200,
                  pinned: true,
                  backgroundColor: Colors.transparent,
                  actions: [
                    // Refresh button
                    // IconButton(
                    //   icon: const Icon(
                    //     Icons.refresh,
                    //     color: Colors.white,
                    //   ),
                    //   onPressed: refreshLeaderboard,
                    // ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Trophy Background
                        Icon(
                          Icons.emoji_events,
                          size: 150,
                          color: Colors.white.withOpacity(0.1),
                        ),
                        // Content
                        leaderboardAsync.when(
                          data: (leaderboardData) => Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // App Logo
                              Image.asset(
                                'assets/images/logo/logo.png',
                                height: 50,
                                width: 50,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Your Achievements',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: AppColors.limeGreen,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Rank #${leaderboardData.userRank}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ).animate().fadeIn(),
                          loading: () => _buildHeaderSkeleton(),
                          error: (error, _) => Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                'Error loading leaderboard: $error',
                                style: const TextStyle(color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // White background container that scrolls with content
                SliverToBoxAdapter(
                  child: Container(
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Stats Section
                        leaderboardAsync.when(
                          data: (leaderboardData) {
                            // Get the current user data
                            final currentUserData =
                                leaderboardData.leaderboard.isNotEmpty
                                    ? leaderboardData.leaderboard.first
                                    : null;
                            final currentStreak =
                                currentUserData?.currentStreak.toString() ??
                                    '0';

                            return Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 24, 16, 16),
                              child: Row(
                                children: [
                                  _StatCard(
                                    icon: Icons.military_tech,
                                    value: '12',
                                    label: 'Medals',
                                    color: AppColors.limeGreen,
                                    isDarkMode: isDarkMode,
                                  ),
                                  _StatCard(
                                    icon: Icons.psychology,
                                    value: '85%',
                                    label: 'Quiz',
                                    color: AppColors.navyBlue,
                                    isDarkMode: isDarkMode,
                                  ),
                                  _StatCard(
                                    icon: Icons.local_fire_department,
                                    value: currentStreak,
                                    label: 'Streak',
                                    color: AppColors.lightPurple,
                                    isDarkMode: isDarkMode,
                                  ),
                                ],
                              ),
                            ).animate().fadeIn().slideY(begin: 0.2);
                          },
                          loading: () => _buildStatsSkeleton(isDarkMode),
                          error: (error, _) => Padding(
                            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                            child: Row(
                              children: [
                                _StatCard(
                                  icon: Icons.military_tech,
                                  value: '0',
                                  label: 'Medals',
                                  color: AppColors.limeGreen,
                                  isDarkMode: isDarkMode,
                                ),
                                _StatCard(
                                  icon: Icons.psychology,
                                  value: '0%',
                                  label: 'Quiz Score',
                                  color: AppColors.navyBlue,
                                  isDarkMode: isDarkMode,
                                ),
                                _StatCard(
                                  icon: Icons.local_fire_department,
                                  value: '0',
                                  label: 'Day Streak',
                                  color: AppColors.lightPurple,
                                  isDarkMode: isDarkMode,
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Achievements Section
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                          child: Row(
                            children: [
                              Text(
                                'Recent Achievements',
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              TextButton(
                                onPressed: () {
                                  // Navigate to all achievements
                                },
                                child: Text(
                                  '',
                                  style: TextStyle(
                                    color: AppColors.limeGreen,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Achievements Cards
                        SizedBox(
                          height: 180,
                          child: GridView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            scrollDirection: Axis.horizontal,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 1,
                              mainAxisSpacing: 16,
                              childAspectRatio: 1.2,
                            ),
                            itemCount: _demoAchievements.length,
                            itemBuilder: (context, index) {
                              final achievement = _demoAchievements[index];
                              return _AchievementCard(
                                achievement: achievement,
                                isDarkMode: isDarkMode,
                              ).animate().fadeIn(
                                    delay: Duration(milliseconds: index * 100),
                                  );
                            },
                          ),
                        ),

                        // Leaderboard Section
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                          child: Row(
                            children: [
                              Text(
                                'Top Learners',
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              TextButton(
                                onPressed: () {
                                  // Navigate to full leaderboard
                                },
                                child: Text(
                                  '',
                                  style: TextStyle(
                                    color: AppColors.limeGreen,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Leaderboard List
                        leaderboardAsync.when(
                          data: (leaderboardData) {
                            final users = leaderboardData.leaderboard;
                            return ListView.builder(
                              padding: const EdgeInsets.all(16),
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: users.length, // Display all users
                              itemBuilder: (context, index) {
                                final user = users[index];
                                return _LeaderboardItem(
                                  rank: user.rank,
                                  user: user,
                                  isDarkMode: isDarkMode,
                                ).animate().fadeIn(
                                      delay:
                                          Duration(milliseconds: index * 100),
                                    );
                              },
                            );
                          },
                          loading: () => _buildLeaderboardSkeleton(isDarkMode),
                          error: (error, _) => Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Center(
                              child: Text(
                                'Error loading leaderboard: $error',
                                style: TextStyle(color: textColor),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),

                        // Add bottom padding to account for navigation bar
                        SizedBox(
                            height: MediaQuery.of(context).padding.bottom + 70),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSkeleton() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Logo skeleton
        Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 8),
        // Title skeleton
        Container(
          height: 28,
          width: 200,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        const SizedBox(height: 12),
        // Rank badge skeleton
        Container(
          height: 36,
          width: 100,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ],
    ).animate().shimmer(
          delay: const Duration(milliseconds: 200),
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeInOut,
        );
  }

  Widget _buildStatsSkeleton(bool isDarkMode) {
    final skeletonColor =
        isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100;
    final skeletonHighlightColor =
        isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200;
    final borderColor =
        isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Row(
        children: List.generate(
          3,
          (index) => Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              height: 106,
              decoration: BoxDecoration(
                color: skeletonColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: borderColor,
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 32,
                    width: 32,
                    decoration: BoxDecoration(
                      color: skeletonHighlightColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 24,
                    width: 50,
                    decoration: BoxDecoration(
                      color: skeletonHighlightColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 12,
                    width: 60,
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
    ).animate().shimmer(
          delay: const Duration(milliseconds: 300),
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeInOut,
        );
  }

  Widget _buildLeaderboardSkeleton(bool isDarkMode) {
    final skeletonColor =
        isDarkMode ? Colors.grey.shade800 : Colors.grey.shade50;
    final skeletonHighlightColor =
        isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200;
    final borderColor =
        isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: List.generate(
          5,
          (index) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            height: 80,
            decoration: BoxDecoration(
              color: skeletonColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: borderColor,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                // Rank circle
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: skeletonHighlightColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 16),
                // Avatar
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: skeletonHighlightColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 16),
                // Name and badge
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 16,
                        width: 120,
                        decoration: BoxDecoration(
                          color: skeletonHighlightColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: 12,
                        width: 80,
                        decoration: BoxDecoration(
                          color: skeletonHighlightColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ],
                  ),
                ),
                // Points
                Container(
                  height: 28,
                  width: 70,
                  decoration: BoxDecoration(
                    color: skeletonHighlightColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().shimmer(
          delay: const Duration(milliseconds: 400),
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeInOut,
        );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final bool isDarkMode;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor =
        isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300;
    final labelColor = isDarkMode ? Colors.white70 : Colors.black87;

    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: labelColor,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Achievement {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const Achievement({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class _AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final bool isDarkMode;

  const _AchievementCard({
    required this.achievement,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor =
        isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300;
    final textColor = isDarkMode ? Colors.white70 : Colors.black87;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            achievement.icon,
            color: achievement.color,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            achievement.title,
            style: TextStyle(
              color: achievement.color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Flexible(
            child: Text(
              achievement.description,
              style: TextStyle(
                color: textColor,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardItem extends StatelessWidget {
  final int rank;
  final LeaderboardUser user;
  final bool isDarkMode;

  const _LeaderboardItem({
    required this.rank,
    required this.user,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor =
        isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300;
    final textColor = isDarkMode ? Colors.white : AppColors.navyBlue;
    final secondaryTextColor = isDarkMode ? Colors.white70 : Colors.black54;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getRankColor(rank),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _getRankColor(rank).withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(user.avatarUrl),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.nickname,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  user.badge,
                  style: TextStyle(
                    color: secondaryTextColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: AppColors.limeGreen.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${user.points} pts',
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return AppColors.limeGreen;
      case 2:
        return Colors.grey.shade400;
      case 3:
        return Colors.brown.shade300;
      default:
        return AppColors.navyBlue;
    }
  }
}

// Keep the demo achievements for now
final List<Achievement> _demoAchievements = [
  Achievement(
    title: 'History Buff',
    description: 'Complete 10 history quizzes',
    icon: Icons.history_edu,
    color: AppColors.navyBlue,
  ),
  Achievement(
    title: 'Perfect Score',
    description: 'Get 100% on any quiz',
    icon: Icons.grade,
    color: AppColors.limeGreen,
  ),
  Achievement(
    title: 'Early Bird',
    description: 'Study for 7 days in a row',
    icon: Icons.wb_sunny,
    color: Colors.orange,
  ),
  Achievement(
    title: 'Knowledge Seeker',
    description: 'Read 50 stories',
    icon: Icons.auto_stories,
    color: AppColors.lightPurple,
  ),
];
