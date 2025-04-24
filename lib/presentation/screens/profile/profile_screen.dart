import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:knowledge/data/providers/profile_provider.dart';
import 'package:knowledge/presentation/widgets/user_avatar.dart';
import 'package:go_router/go_router.dart';
import 'package:knowledge/data/providers/auth_provider.dart';
import 'package:knowledge/core/themes/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:knowledge/data/models/profile.dart';
import 'package:knowledge/data/providers/subscription_provider.dart';
import 'package:knowledge/data/providers/feedback_provider.dart';
import 'package:knowledge/presentation/screens/profile/delete_account_screen.dart';
import 'package:knowledge/presentation/widgets/feedback_dialog.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends HookConsumerWidget {
  const ProfileScreen({super.key});

  Future<bool> _showLogoutConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'Confirm Logout',
                style: TextStyle(
                  color: AppColors.navyBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: const Text(
                'Are you sure you want to logout?',
                style: TextStyle(
                  color: Colors.black87,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Logout'),
                ),
              ],
            );
          },
        ) ??
        false; // Return false if dialog is dismissed
  }

  Future<void> _showFeedbackDialog(BuildContext context, WidgetRef ref,
      {bool forceShow = false}) async {
    // Use the feedback provider to check if feedback has been shown before
    final feedbackState = await ref.read(feedbackNotifierProvider.future);

    // If feedback has already been shown and not forcing display, don't show again
    // When button is clicked explicitly (forceShow=true), show regardless of previous submissions
    if (feedbackState && !forceShow && context.mounted) return;

    // Mark feedback as shown using the notifier (if not already shown)
    if (!feedbackState) {
      ref.read(feedbackNotifierProvider.notifier).markFeedbackAsShown();
    }

    if (context.mounted) {
      final result = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => const FeedbackDialog(),
      );

      if (result == true && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Thank you for your feedback!'),
            backgroundColor: AppColors.limeGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(12),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final authNotifier = ref.watch(authNotifierProvider.notifier);

    // Hook to check if we need to show feedback dialog on first visit
    useEffect(() {
      // Check on app launch if feedback should be shown
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showFeedbackDialog(context, ref, forceShow: false);
      });
      return null;
    }, []);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.navyBlue,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.feedback_outlined,
            color: AppColors.navyBlue,
          ),
          onPressed: () => _showFeedbackDialog(context, ref, forceShow: true),
          tooltip: 'Give Feedback',
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.settings,
              color: AppColors.navyBlue,
            ),
            onPressed: () {
              // Show settings menu
            },
            tooltip: 'Settings',
          ),
        ],
      ),
      body: profileAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.limeGreen),
          ),
        ),
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
                      style: const TextStyle(color: Colors.white70),
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
                onPressed: () => ref.refresh(userProfileProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (profile) =>
            ProfileBody(profile: profile, authNotifier: authNotifier),
      ),
    );
  }
}

class ProfileBody extends StatelessWidget {
  final Profile profile;
  final dynamic authNotifier;

  const ProfileBody({
    super.key,
    required this.profile,
    required this.authNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // Profile card at the top
            ProfileCardWidget(profile: profile)
                .animate()
                .fadeIn(duration: const Duration(milliseconds: 500)),

            const SizedBox(height: 12),

            // Followers and Following section
            SocialCountsWidget(profile: profile)
                .animate()
                .fadeIn(duration: const Duration(milliseconds: 500))
                .slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuad),

            const SizedBox(height: 12),

            // Overview section with rank, journey and points
            OverviewWidget(profile: profile)
                .animate()
                .fadeIn(
                  duration: const Duration(milliseconds: 500),
                  delay: const Duration(milliseconds: 100),
                )
                .slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuad),

            const SizedBox(height: 12),

            // Percentile rank
            if (profile.percentile != null)
              PercentileWidget(profile: profile)
                  .animate()
                  .fadeIn(
                    duration: const Duration(milliseconds: 500),
                    delay: const Duration(milliseconds: 150),
                  )
                  .slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuad),

            const SizedBox(height: 12),

            // Streak information
            if (profile.currentLoginStreak != null)
              StreakInfoWidget(profile: profile)
                  .animate()
                  .fadeIn(
                    duration: const Duration(milliseconds: 500),
                    delay: const Duration(milliseconds: 200),
                  )
                  .slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuad),

            // Logout button
            const SizedBox(height: 32),
            LogoutButtonWidget(authNotifier: authNotifier).animate().fadeIn(
                  duration: const Duration(milliseconds: 500),
                  delay: const Duration(milliseconds: 250),
                ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class ProfileCardWidget extends StatelessWidget {
  final Profile profile;

  const ProfileCardWidget({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    final formattedDate = profile.joinedDate != null
        ? DateFormat("MMM d, yyyy").format(DateTime.parse(profile.joinedDate!))
        : "Unknown join date";

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.navyBlue.withOpacity(0.9),
            AppColors.navyBlue.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.limeGreen.withOpacity(0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.navyBlue.withOpacity(0.3),
            blurRadius: 10,
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
                          color: AppColors.limeGreen,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.limeGreen.withOpacity(0.5),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 5,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: UserAvatar(size: 100),
                      ),
                    ),
                    // Edit icon in top right
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.limeGreen,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.edit_outlined,
                            color: AppColors.navyBlue,
                            size: 20,
                          ),
                          onPressed: () => context.push('/profile/edit'),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
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

  const SocialCountsWidget({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    // Get follower and following counts from profile
    final followerCount = profile.followers?['count'] ?? 0;
    final followingCount = profile.following?['count'] ?? 0;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.withOpacity(0.2),
            Colors.purple.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.navyBlue.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.navyBlue.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  Text(
                    followerCount.toString(),
                    style: const TextStyle(
                      color: AppColors.navyBlue,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Followers",
                    style: TextStyle(
                      color: AppColors.navyBlue,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.navyBlue.withOpacity(0.1),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  Text(
                    followingCount.toString(),
                    style: const TextStyle(
                      color: AppColors.navyBlue,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Following",
                    style: TextStyle(
                      color: AppColors.navyBlue,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OverviewWidget extends StatelessWidget {
  final Profile profile;

  const OverviewWidget({
    super.key,
    required this.profile,
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
                    Colors.amber.withOpacity(0.2),
                    Colors.orange.withOpacity(0.1),
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
                    Colors.blue.withOpacity(0.2),
                    Colors.lightBlue.withOpacity(0.1),
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
                    AppColors.limeGreen.withOpacity(0.2),
                    Colors.green.withOpacity(0.1),
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
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.navyBlue.withOpacity(0.1),
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

  const PercentileWidget({
    super.key,
    required this.profile,
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
            Colors.amber.withOpacity(0.2),
            Colors.orange.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.navyBlue.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.navyBlue.withOpacity(0.1),
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
              color: Colors.amber.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withOpacity(0.3),
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
                  blurRadius: 8,
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

  const StreakInfoWidget({
    super.key,
    required this.profile,
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

class LogoutButtonWidget extends StatelessWidget {
  final dynamic authNotifier;

  const LogoutButtonWidget({
    super.key,
    required this.authNotifier,
  });

  Future<bool> _showLogoutConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'Confirm Logout',
                style: TextStyle(
                  color: AppColors.navyBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: const Text(
                'Are you sure you want to logout?',
                style: TextStyle(
                  color: Colors.black87,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Logout'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.red,
            side: const BorderSide(color: Colors.red),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          onPressed: () async {
            final shouldLogout = await _showLogoutConfirmationDialog(context);
            if (shouldLogout && context.mounted) {
              try {
                await authNotifier.logout();
                if (context.mounted) {
                  context.go('/login');
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error logging out: $e'),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      margin: const EdgeInsets.all(12),
                    ),
                  );
                }
              }
            }
          },
          icon: const Icon(Icons.logout),
          label: const Text(
            'Logout',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
