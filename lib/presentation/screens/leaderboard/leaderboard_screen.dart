import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:knowledge/core/themes/app_theme.dart';

class LeaderboardScreen extends HookConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.navyBlue,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Trophy Background
                  Icon(
                    Icons.emoji_events,
                    size: 150,
                    color: AppColors.navyBlue.withOpacity(0.3),
                  ),
                  // Content
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Your Achievements',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              color: AppColors.limeGreen,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Rank #42',
                              style: TextStyle(
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
                ],
              ),
            ),
          ),

          // Stats Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _StatCard(
                    icon: Icons.military_tech,
                    value: '12',
                    label: 'Medals',
                    color: AppColors.limeGreen,
                  ),
                  _StatCard(
                    icon: Icons.psychology,
                    value: '85%',
                    label: 'Quiz Score',
                    color: AppColors.navyBlue,
                  ),
                  _StatCard(
                    icon: Icons.local_fire_department,
                    value: '7',
                    label: 'Day Streak',
                    color: AppColors.lightPurple,
                  ),
                ],
              ),
            ).animate().fadeIn().slideY(begin: 0.2),
          ),

          // Achievements Section
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Recent Achievements',
                style: TextStyle(
                  color: AppColors.navyBlue,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.5,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final achievement = _demoAchievements[index];
                  return _AchievementCard(
                    achievement: achievement,
                  ).animate().fadeIn(
                        delay: Duration(milliseconds: index * 100),
                      );
                },
                childCount: _demoAchievements.length,
              ),
            ),
          ),

          // Leaderboard Section
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Top Learners',
                style: TextStyle(
                  color: AppColors.navyBlue,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final user = _demoUsers[index];
                  return _LeaderboardItem(
                    rank: index + 1,
                    user: user,
                  ).animate().fadeIn(
                        delay: Duration(milliseconds: index * 100),
                      );
                },
                childCount: _demoUsers.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
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
                color: Colors.black87,
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

  const _AchievementCard({required this.achievement});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: achievement.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: achievement.color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
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
          ),
          Text(
            achievement.description,
            style: TextStyle(
              color: Colors.black87,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class LeaderboardUser {
  final String name;
  final String avatarUrl;
  final int points;
  final String badge;

  const LeaderboardUser({
    required this.name,
    required this.avatarUrl,
    required this.points,
    required this.badge,
  });
}

class _LeaderboardItem extends StatelessWidget {
  final int rank;
  final LeaderboardUser user;

  const _LeaderboardItem({
    required this.rank,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.navyBlue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.navyBlue.withOpacity(0.1),
          width: 1,
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
            backgroundImage: NetworkImage(user.avatarUrl),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: TextStyle(
                    color: AppColors.navyBlue,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  user.badge,
                  style: TextStyle(
                    color: Colors.black54,
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
              style: const TextStyle(
                color: AppColors.navyBlue,
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

// Demo Data
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

final List<LeaderboardUser> _demoUsers = [
  LeaderboardUser(
    name: 'Sarah Johnson',
    avatarUrl: 'https://i.pravatar.cc/150?img=1',
    points: 2500,
    badge: 'History Master',
  ),
  LeaderboardUser(
    name: 'Michael Chen',
    avatarUrl: 'https://i.pravatar.cc/150?img=2',
    points: 2350,
    badge: 'Quiz Champion',
  ),
  LeaderboardUser(
    name: 'Emma Wilson',
    avatarUrl: 'https://i.pravatar.cc/150?img=3',
    points: 2200,
    badge: 'Knowledge Seeker',
  ),
  LeaderboardUser(
    name: 'James Miller',
    avatarUrl: 'https://i.pravatar.cc/150?img=4',
    points: 2100,
    badge: 'Rising Star',
  ),
  LeaderboardUser(
    name: 'Lisa Anderson',
    avatarUrl: 'https://i.pravatar.cc/150?img=5',
    points: 2000,
    badge: 'Dedicated Learner',
  ),
];
