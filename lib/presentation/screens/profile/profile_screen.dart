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
// import 'package:knowledge/data/providers/subscription_provider.dart';
import 'package:knowledge/data/providers/feedback_provider.dart';
// import 'package:knowledge/presentation/screens/profile/delete_account_screen.dart';
import 'package:knowledge/presentation/widgets/feedback_dialog.dart';
import 'package:knowledge/presentation/widgets/bookmarked_timelines_widget.dart';
import 'package:intl/intl.dart';

// Create a cached profile provider to prevent unnecessary reloading
final cachedProfileProvider = Provider<AsyncValue<Profile>>((ref) {
  // Watch the user profile provider but keep its state in our cached provider
  return ref.watch(userProfileProvider);
}, name: 'cachedProfileProvider');

class ProfileScreen extends HookConsumerWidget {
  const ProfileScreen({super.key});

  // ignore: unused_element
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
    // Use the cached profile provider instead of the original
    final profileAsync = ref.watch(cachedProfileProvider);
    final authNotifier = ref.watch(authNotifierProvider.notifier);

    // Get theme brightness
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDarkMode ? AppColors.darkBackground : Colors.white;
    final textColor = isDarkMode ? Colors.white : AppColors.navyBlue;
    final secondaryTextColor = isDarkMode ? Colors.white70 : Colors.black87;
    final cardColor = isDarkMode ? AppColors.darkCard : Colors.white;
    final cardBorderColor =
        isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300;

    // Hook to check if we need to show feedback dialog on first visit
    // useEffect(() {
    //   // Check on app launch if feedback should be shown
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     _showFeedbackDialog(context, ref, forceShow: false);
    //   });
    //   return null;
    // }, []);

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
            Icons.feedback_outlined,
            color: textColor,
          ),
          onPressed: () => _showFeedbackDialog(context, ref, forceShow: true),
          tooltip: 'Give Feedback',
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.settings,
              color: textColor,
            ),
            onPressed: () {
              // Navigate to settings screen
              context.push('/settings');
            },
            tooltip: 'Settings',
          ),
        ],
      ),
      body: profileAsync.when(
        loading: () => _buildProfileSkeleton(ref, isDarkMode),
        error: (error, stack) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
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
                onPressed: () => ref.refresh(userProfileProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (profile) => ProfileBody(
            profile: profile,
            authNotifier: authNotifier,
            isDarkMode: isDarkMode),
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
        ref.refresh(userProfileProvider);
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

            const SizedBox(height: 0),

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

            // Add Friend button skeleton
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

            const SizedBox(height: 20),

            // Add more skeleton items for additional sections as needed

            // A placeholder for the logout button
            Container(
              width: double.infinity,
              height: 50,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: skeletonHighlightColor,
                borderRadius: BorderRadius.circular(25),
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

class ProfileBody extends ConsumerStatefulWidget {
  final Profile profile;
  final dynamic authNotifier;
  final bool isDarkMode;

  const ProfileBody({
    super.key,
    required this.profile,
    required this.authNotifier,
    required this.isDarkMode,
  });

  @override
  ConsumerState<ProfileBody> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends ConsumerState<ProfileBody>
    with AutomaticKeepAliveClientMixin {
  // Keep the widget alive when navigating away
  @override
  bool get wantKeepAlive => true;

  // State for switching between overview and bookmarked sections
  bool _showBookmarked = false;

  Widget _buildToggleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Toggle buttons
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: widget.isDarkMode ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.navyBlue.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _showBookmarked = false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: !_showBookmarked
                          ? AppColors.navyBlue
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.insights,
                          color: !_showBookmarked
                              ? Colors.white
                              : AppColors.navyBlue,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Overview',
                          style: TextStyle(
                            color: !_showBookmarked
                                ? Colors.white
                                : AppColors.navyBlue,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _showBookmarked = true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _showBookmarked
                          ? AppColors.navyBlue
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bookmark,
                          color: _showBookmarked
                              ? Colors.white
                              : AppColors.navyBlue,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Bookmarked',
                          style: TextStyle(
                            color: _showBookmarked
                                ? Colors.white
                                : AppColors.navyBlue,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
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
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          // Refresh the profile data
          await Future.delayed(Duration.zero);
          ref.invalidate(userProfileProvider);
          return;
        },
        color: AppColors.limeGreen,
        backgroundColor: Colors.white,
        strokeWidth: 2.5,
        displacement: 40,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Profile card at the top
              ProfileCardWidget(profile: widget.profile)
                  .animate()
                  .fadeIn(duration: const Duration(milliseconds: 500)),

              const SizedBox(height: 12),

              // Followers and Following section
              SocialCountsWidget(profile: widget.profile)
                  .animate()
                  .fadeIn(duration: const Duration(milliseconds: 500))
                  .slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuad),

              const SizedBox(height: 12),

              // Toggle section header with overview and bookmarked options
              _buildToggleSection()
                  .animate()
                  .fadeIn(
                    duration: const Duration(milliseconds: 500),
                    delay: const Duration(milliseconds: 100),
                  )
                  .slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuad),

              // Content section with smooth transitions
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.0, 0.1),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      )),
                      child: child,
                    ),
                  );
                },
                child: _showBookmarked
                    ? Column(
                        key: const ValueKey('bookmarked'),
                        children: [
                          // Bookmarked timelines section - no fixed height, integrates with main scroll
                          const BookmarkedTimelinesWidget(),
                          const SizedBox(height: 20),
                          // Only logout button when in bookmark tab
                          LogoutButtonWidget(authNotifier: widget.authNotifier),
                          const SizedBox(height: 16),
                        ],
                      )
                    : Column(
                        key: const ValueKey('overview'),
                        children: [
                          // Overview section with rank, journey and points
                          OverviewWidget(profile: widget.profile),
                          const SizedBox(height: 12),

                          // Percentile rank
                          if (widget.profile.percentile != null) ...[
                            PercentileWidget(profile: widget.profile),
                            const SizedBox(height: 12),
                          ],

                          // Streak information
                          if (widget.profile.currentLoginStreak != null) ...[
                            StreakInfoWidget(profile: widget.profile),
                            const SizedBox(height: 12),
                          ],

                          // Logout button
                          LogoutButtonWidget(authNotifier: widget.authNotifier),
                          const SizedBox(height: 16),
                        ],
                      ),
              ),
            ],
          ),
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
      margin: const EdgeInsets.all(12),
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
          color: AppColors.limeGreen.withOpacity(0.0),
          width: 0,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.navyBlue.withOpacity(0.3),
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
                    // Positioned(
                    //   top: 0,
                    //   right: 0,
                    //   child: Container(
                    //     decoration: BoxDecoration(
                    //       shape: BoxShape.circle,
                    //       color: AppColors.limeGreen,
                    //       boxShadow: [
                    //         BoxShadow(
                    //           color: Colors.black.withOpacity(0.2),
                    //           blurRadius: 4,
                    //           spreadRadius: 0,
                    //         ),
                    //       ],
                    //     ),
                    //     child: IconButton(
                    //       icon: const Icon(
                    //         Icons.edit_outlined,
                    //         color: AppColors.navyBlue,
                    //         size: 20,
                    //       ),
                    //       onPressed: () => context.push('/profile/edit'),
                    //       padding: EdgeInsets.zero,
                    //       constraints: const BoxConstraints(
                    //         minWidth: 36,
                    //         minHeight: 36,
                    //       ),
                    //     ),
                    //   ),
                    // ),
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

    // Get profile ID for navigation
    final profileId = profile.followers?['profile_id'] as int? ?? 0;

    return Column(
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 15),
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
                child: InkWell(
                  onTap: () {
                    if (profileId > 0) {
                      context.push('/profile/$profileId/followers');
                    }
                  },
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
              ),
              Container(
                width: 1,
                height: 40,
                color: AppColors.navyBlue.withOpacity(0.1),
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    if (profileId > 0) {
                      context.push('/profile/$profileId/following');
                    }
                  },
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
              ),
            ],
          ),
        ),

        // Add Friend Button with Share Icon
        Container(
          margin: const EdgeInsets.only(top: 10, left: 16, right: 16),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to add friends screen
                    context.push('/add-friends');
                  },
                  icon: const Icon(Icons.person_add_alt),
                  label: const Text(
                    'Add Friend',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: AppColors.navyBlue,
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 1,
                    shadowColor: Colors.black.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: AppColors.navyBlue.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(
                      duration: const Duration(milliseconds: 400),
                      delay: const Duration(milliseconds: 300),
                    )
                    .slideY(begin: 0.2, end: 0),
              ),
              const SizedBox(width: 8),
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.navyBlue.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.share_outlined,
                    size: 18,
                    color: AppColors.navyBlue,
                  ),
                  onPressed: () {
                    // Share profile functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Coming soon!'),
                        backgroundColor: AppColors.navyBlue,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        margin: const EdgeInsets.all(12),
                      ),
                    );
                  },
                  tooltip: 'Share Profile',
                  padding: EdgeInsets.zero,
                ),
              ).animate().fadeIn(
                    duration: const Duration(milliseconds: 400),
                    delay: const Duration(milliseconds: 350),
                  ),
            ],
          ),
        ),
      ],
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
          padding: EdgeInsets.fromLTRB(20, 10, 16, 12),
          // child: Row(
          //   children: [
          //     Icon(
          //       Icons.insights,
          //       color: AppColors.navyBlue,
          //       size: 20,
          //     ),
          //     SizedBox(width: 6),
          //     Text(
          //       "Overview",
          //       style: TextStyle(
          //         color: AppColors.navyBlue,
          //         fontSize: 18,
          //         fontWeight: FontWeight.bold,
          //       ),
          //     ),
          //   ],
          // ),
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
      margin: const EdgeInsets.all(10),
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
                // Show loading state
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text('Logging out...'),
                      ],
                    ),
                    backgroundColor: AppColors.navyBlue,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: const EdgeInsets.all(12),
                    duration: const Duration(seconds: 2),
                  ),
                );

                // Perform logout
                await authNotifier.logout();

                // Wait a brief moment to ensure state is updated
                await Future.delayed(const Duration(milliseconds: 100));

                if (context.mounted) {
                  // Clear any existing snackbars
                  ScaffoldMessenger.of(context).clearSnackBars();

                  // Navigate to login page and clear navigation stack
                  context.go('/login');
                }
              } catch (e) {
                if (context.mounted) {
                  // Clear loading snackbar
                  ScaffoldMessenger.of(context).clearSnackBars();

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

class StatsCard extends StatelessWidget {
  final int? followers;
  final int? following;
  final int? completedQuizzes;
  final Profile profile;

  const StatsCard({
    super.key,
    this.followers,
    this.following,
    this.completedQuizzes,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    // Get the Profile ID from the profile object
    final profileId = profile.followers != null
        ? profile.followers!['profile_id'] as int? ?? 0
        : 0;

    return Container(
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: 4,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Followers
              InkWell(
                onTap: () {
                  if (profileId > 0) {
                    context.push('/profile/$profileId/followers');
                  }
                },
                child: _buildStatItem(
                  context,
                  followers?.toString() ?? '0',
                  'Followers',
                  Icons.people,
                ),
              ),
              // Following
              InkWell(
                onTap: () {
                  if (profileId > 0) {
                    context.push('/profile/$profileId/following');
                  }
                },
                child: _buildStatItem(
                  context,
                  following?.toString() ?? '0',
                  'Following',
                  Icons.people_outline,
                ),
              ),
              // Quizzes
              _buildStatItem(
                context,
                completedQuizzes?.toString() ?? '0',
                'Quizzes',
                Icons.quiz,
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String value,
    String label,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.navyBlue,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.navyBlue,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
