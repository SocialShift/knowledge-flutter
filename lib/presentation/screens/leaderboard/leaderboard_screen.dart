import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:knowledge/core/themes/app_theme.dart';
import 'package:knowledge/data/repositories/leaderboard_repository.dart';
import 'package:knowledge/data/models/leaderboard.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

class LeaderboardScreen extends HookConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get theme brightness
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDarkMode ? AppColors.darkBackground : Colors.white;
    final textColor = isDarkMode ? Colors.white : AppColors.navyBlue;

    // Fetch leaderboard data
    final leaderboardAsync = ref.watch(leaderboardProvider);

    // State for toggle between Weekly and All Time
    final ValueNotifier<bool> isWeekly = ValueNotifier(true);

    // Function to refresh leaderboard data
    void refreshLeaderboard() {
      ref.invalidate(leaderboardProvider);
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: RefreshIndicator(
        onRefresh: () async {
          refreshLeaderboard();
          await Future.delayed(const Duration(milliseconds: 500));
        },
        color: AppColors.limeGreen,
        backgroundColor: backgroundColor,
        child: Stack(
          children: [
            // Background gradient
            Container(
              height: MediaQuery.of(context).size.height * 0.6,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.navyBlue, // Gold/Yellow
                    AppColors.limeGreen, // Purple/Blue
                  ],
                  stops: const [0.0, 1.0],
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  // Header with logo and title
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        // App Logo
                        Image.asset(
                          'assets/images/logo/logo.png',
                          alignment: Alignment.center,
                          height: 32,
                          width: 32,
                        ),

                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Leaderboard',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Toggle buttons for Weekly/All Time
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  //   child: ValueListenableBuilder<bool>(
                  //     valueListenable: isWeekly,
                  //     builder: (context, weekly, _) {
                  //       return Container(
                  //         decoration: BoxDecoration(
                  //           color: Colors.white.withOpacity(0.2),
                  //           borderRadius: BorderRadius.circular(25),
                  //         ),
                  //         child: Row(
                  //           children: [
                  //             Expanded(
                  //               child: GestureDetector(
                  //                 onTap: () => isWeekly.value = true,
                  //                 child: Container(
                  //                   padding: const EdgeInsets.symmetric(
                  //                       vertical: 12),
                  //                   decoration: BoxDecoration(
                  //                     color: weekly
                  //                         ? Colors.white
                  //                         : Colors.transparent,
                  //                     borderRadius: BorderRadius.circular(25),
                  //                   ),
                  //                   child: Text(
                  //                     'Weekly',
                  //                     textAlign: TextAlign.center,
                  //                     style: TextStyle(
                  //                       color: weekly
                  //                           ? const Color(0xFF6366F1)
                  //                           : Colors.white,
                  //                       fontWeight: FontWeight.w600,
                  //                     ),
                  //                   ),
                  //                 ),
                  //               ),
                  //             ),
                  //             Expanded(
                  //               child: GestureDetector(
                  //                 onTap: () => isWeekly.value = false,
                  //                 child: Container(
                  //                   padding: const EdgeInsets.symmetric(
                  //                       vertical: 12),
                  //                   decoration: BoxDecoration(
                  //                     color: !weekly
                  //                         ? Colors.white
                  //                         : Colors.transparent,
                  //                     borderRadius: BorderRadius.circular(25),
                  //                   ),
                  //                   child: Text(
                  //                     'All Time',
                  //                     textAlign: TextAlign.center,
                  //                     style: TextStyle(
                  //                       color: !weekly
                  //                           ? const Color(0xFF6366F1)
                  //                           : Colors.white,
                  //                       fontWeight: FontWeight.w600,
                  //                     ),
                  //                   ),
                  //                 ),
                  //               ),
                  //             ),
                  //           ],
                  //         ),
                  //       );
                  //     },
                  //   ),
                  // ),

                  const SizedBox(height: 5),

                  // Podium section for top 3
                  leaderboardAsync.when(
                    data: (leaderboardData) {
                      final users = leaderboardData.leaderboard;
                      final top3 = users.take(3).toList();
                      final remaining = users.skip(3).toList();

                      return Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            children: [
                              // Podium (fixed height)
                              if (top3.isNotEmpty) _buildPodium(top3),

                              const SizedBox(height: 16),

                              // White container for remaining users
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: backgroundColor,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(24),
                                    topRight: Radius.circular(24),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, -2),
                                    ),
                                  ],
                                ),
                                child: remaining.isEmpty
                                    ? const Center(
                                        child: Padding(
                                          padding: EdgeInsets.all(32.0),
                                          child: Text(
                                            'No more users to show',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                      )
                                    : Column(
                                        children: List.generate(
                                          remaining.length,
                                          (index) {
                                            final user = remaining[index];
                                            return _LeaderboardListItem(
                                              rank: user.rank,
                                              user: user,
                                              isDarkMode: isDarkMode,
                                            ).animate().fadeIn(
                                                  delay: Duration(
                                                      milliseconds: index * 50),
                                                );
                                          },
                                        ),
                                      ),
                              ),
                              SizedBox(height: 32), // Extra space at bottom
                            ],
                          ),
                        ),
                      );
                    },
                    loading: () => const Expanded(
                        child: Center(
                            child: CircularProgressIndicator(
                                color: Colors.white))),
                    error: (error, _) => Expanded(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: Colors.white,
                                size: 64,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Error loading leaderboard',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                error.toString(),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPodium(List<LeaderboardUser> top3) {
    // Arrange users for podium display: [2nd, 1st, 3rd]
    final List<LeaderboardUser?> podiumUsers = [null, null, null];

    if (top3.isNotEmpty) podiumUsers[1] = top3[0]; // 1st place in center
    if (top3.length > 1) podiumUsers[0] = top3[1]; // 2nd place on left
    if (top3.length > 2) podiumUsers[2] = top3[2]; // 3rd place on right

    return Container(
      height: 300,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Podium platforms with enhanced design
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 2nd place platform
              Expanded(
                child: Container(
                  height: 90,
                  margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFFC0C0C0), // Silver
                        const Color(0xFF808080),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Shine effect
                      Positioned(
                        top: 8,
                        left: 8,
                        right: 8,
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const Center(
                        child: Text(
                          '2',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                offset: Offset(2, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // 1st place platform (tallest) - Gold
              Expanded(
                child: Container(
                  height: 130,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFFFFD700), // Gold
                        const Color(0xFFFFB300),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Crown icon at top
                      const Positioned(
                        top: 8,
                        left: 0,
                        right: 0,
                        child: Icon(
                          Icons.emoji_events,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      // Shine effect
                      Positioned(
                        top: 35,
                        left: 8,
                        right: 8,
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const Center(
                        child: Text(
                          '1',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                offset: Offset(2, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // 3rd place platform - Bronze
              Expanded(
                child: Container(
                  height: 70,
                  margin: const EdgeInsets.only(left: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFFCD7F32), // Bronze
                        const Color(0xFF8B4513),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Shine effect
                      Positioned(
                        top: 8,
                        left: 8,
                        right: 8,
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const Center(
                        child: Text(
                          '3',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                offset: Offset(2, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // User avatars and info
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // 2nd place user
                Expanded(
                  child: podiumUsers[0] != null
                      ? _PodiumUser(
                          user: podiumUsers[0]!,
                          rank: 2,
                          isCenter: false,
                        )
                      : const SizedBox.shrink(),
                ),
                // 1st place user (center, higher)
                Expanded(
                  child: podiumUsers[1] != null
                      ? _PodiumUser(
                          user: podiumUsers[1]!,
                          rank: 1,
                          isCenter: true,
                        )
                      : const SizedBox.shrink(),
                ),
                // 3rd place user
                Expanded(
                  child: podiumUsers[2] != null
                      ? _PodiumUser(
                          user: podiumUsers[2]!,
                          rank: 3,
                          isCenter: false,
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return const Center(
      child: CircularProgressIndicator(
        color: Colors.white,
      ),
    );
  }
}

class _PodiumUser extends StatelessWidget {
  final LeaderboardUser user;
  final int rank;
  final bool isCenter;

  const _PodiumUser({
    required this.user,
    required this.rank,
    required this.isCenter,
  });

  @override
  Widget build(BuildContext context) {
    final avatarSize = isCenter ? 90.0 : 70.0;
    final marginBottom = isCenter ? 130.0 : (rank == 2 ? 90.0 : 70.0);

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        context.push('/profile/${user.userId}');
      },
      child: Container(
        margin: EdgeInsets.only(bottom: marginBottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Avatar with enhanced styling
            Container(
              width: avatarSize,
              height: avatarSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: user.avatarUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.person, color: Colors.grey),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.person, color: Colors.grey),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Name
            Text(
              user.nickname,
              style: TextStyle(
                color: Colors.white,
                fontSize: isCenter ? 16 : 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            // Points badge with enhanced styling
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                '${user.points} P',
                style: TextStyle(
                  color: const Color(0xFF6366F1),
                  fontSize: isCenter ? 14 : 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LeaderboardListItem extends StatelessWidget {
  final int rank;
  final LeaderboardUser user;
  final bool isDarkMode;

  const _LeaderboardListItem({
    required this.rank,
    required this.user,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subtitleColor = isDarkMode ? Colors.white70 : Colors.black54;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        // Navigate to profile on tap
        context.push('/profile/${user.userId}');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Rank
            Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              child: Text(
                '$rank',
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Avatar
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: user.avatarUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.person, size: 20),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.person, size: 20),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Name and badge
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
                  // const SizedBox(height: 2),
                  // Text(
                  //   user.badge,
                  //   style: TextStyle(
                  //     color: subtitleColor,
                  //     fontSize: 14,
                  //   ),
                  // ),
                ],
              ),
            ),
            // Points badge on the right
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
      ),
    );
  }
}
