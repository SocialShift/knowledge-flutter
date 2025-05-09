import 'package:flutter/material.dart';
// import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:knowledge/core/themes/app_theme.dart';
import 'package:knowledge/data/models/timeline.dart';
import 'package:knowledge/data/repositories/timeline_repository.dart';
import 'package:knowledge/data/providers/timeline_provider.dart';
import 'package:knowledge/presentation/widgets/story_list_item.dart';
import 'package:knowledge/presentation/widgets/circular_timeline.dart';
// import 'package:knowledge/presentation/widgets/search_bar_widget.dart';
import 'package:knowledge/presentation/widgets/filter_bottom_sheet.dart';
// import 'package:knowledge/data/providers/filter_provider.dart';
import 'package:knowledge/data/providers/profile_provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Create cached versions of providers with keepAlive set to true
final cachedTimelinesSortedProvider =
    Provider<AsyncValue<List<Timeline>>>((ref) {
  // Keep the data alive even when no longer listening
  final timelinesAsync = ref.watch(timelinesSortedByYearProvider);
  return timelinesAsync;
}, name: 'cachedTimelinesSortedProvider');

// Create a family provider for cached stories that will be kept alive
final cachedTimelineStoriesProvider =
    Provider.family<AsyncValue<List<dynamic>>, String>((ref, timelineId) {
  // Keep the data alive even when no longer listening
  final storiesAsync = ref.watch(filteredTimelineStoriesProvider(timelineId));
  return storiesAsync;
}, name: 'cachedTimelineStoriesProvider');

// Create a cached profile provider to prevent unnecessary reloading of profile data
final cachedProfileProvider = Provider<AsyncValue<dynamic>>((ref) {
  // Watch the user profile provider but keep its state in our cached provider
  return ref.watch(userProfileProvider);
}, name: 'cachedProfileProvider');

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  int _selectedTimelineIndex = 0; // Default to first timeline

  // Override to keep the state alive when navigating away
  @override
  bool get wantKeepAlive => true;

  // Timeline info text based on selected timeline
  String _getTimelineInfo(List<Timeline> timelines, int index) {
    if (timelines.isEmpty || index >= timelines.length) {
      return '';
    }
    return timelines[index].description;
  }

  // Convert Timeline to TimelinePeriod for the CircularTimeline widget
  List<TimelinePeriod> _convertToTimelinePeriods(List<Timeline> timelines) {
    return timelines
        .map((timeline) => TimelinePeriod(
              year: timeline.year,
              imageUrl: timeline.imageUrl,
            ))
        .toList();
  }

  // Extract timeline IDs from the timelines list
  List<String> _extractTimelineIds(List<Timeline> timelines) {
    return timelines.map((timeline) => timeline.id).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    // Get the bottom padding to account for the navigation bar
    final bottomPadding = MediaQuery.of(context).padding.bottom + 80;
    final topPadding = MediaQuery.of(context).padding.top;

    // Watch cached timelines provider instead of directly watching the original provider
    final timelinesAsync = ref.watch(cachedTimelinesSortedProvider);

    return Scaffold(
      backgroundColor: AppColors.navyBlue,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.lightPurple,
              AppColors.navyBlue,
            ],
            stops: [0.0, 0.3],
          ),
        ),
        child: timelinesAsync.when(
          data: (timelines) {
            // Ensure we don't go out of bounds
            if (_selectedTimelineIndex >= timelines.length &&
                timelines.isNotEmpty) {
              _selectedTimelineIndex = 0;
            }

            if (timelines.isEmpty) {
              return const Center(
                child: Text(
                  'No timelines available',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            final timelinePeriods = _convertToTimelinePeriods(timelines);
            final selectedTimeline = timelines[_selectedTimelineIndex];

            // Watch the cached stories provider for the selected timeline
            final storiesAsync =
                ref.watch(cachedTimelineStoriesProvider(selectedTimeline.id));

            return RefreshIndicator(
              onRefresh: () async {
                // Refresh all the data - invalidate the original providers, not the cached ones
                ref.invalidate(timelinesProvider);
                ref.invalidate(timelineStoriesProvider(selectedTimeline.id));
                // Add a small delay for better UX
                await Future.delayed(const Duration(milliseconds: 800));
              },
              color: AppColors.limeGreen,
              backgroundColor: Colors.white,
              displacement: 70,
              strokeWidth: 3,
              child: CustomScrollView(
                // Use ClampingScrollPhysics to prevent overscrolling at the bottom
                physics: const AlwaysScrollableScrollPhysics(
                  parent: ClampingScrollPhysics(),
                ),
                slivers: [
                  // Add padding for status bar
                  SliverPadding(
                    padding: EdgeInsets.only(top: topPadding),
                    sliver: SliverToBoxAdapter(child: Container()),
                  ),

                  // Header with welcome message and notification icon
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Row(
                        children: [
                          // Logo
                          GestureDetector(
                            onTap: () => context.go('/home'),
                            child: SizedBox(
                              height: 40,
                              width: 40,
                              child: Image.asset(
                                'assets/images/logo/logo.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ).animate().fadeIn().scale(
                                delay: const Duration(milliseconds: 200),
                                duration: const Duration(milliseconds: 500),
                              ),
                          const SizedBox(width: 12),
                          // Welcome text
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'The History Erased',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  'Now in Your Hands',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ).animate().fadeIn().slideX(
                                  begin: -0.2,
                                  delay: const Duration(milliseconds: 300),
                                  duration: const Duration(milliseconds: 500),
                                ),
                          ),

                          // Streak display (non-clickable)
                          Consumer(
                            builder: (context, ref, child) {
                              // Watch the user profile to get streak data
                              final profileAsync =
                                  ref.watch(cachedProfileProvider);

                              return profileAsync.when(
                                data: (profile) {
                                  final currentStreak =
                                      profile.currentLoginStreak ?? 0;

                                  return Container(
                                    height: 40,
                                    margin: const EdgeInsets.only(right: 12),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        // Scroll image
                                        SvgPicture.asset(
                                          'assets/icons/scroll.svg',
                                          height: 30,
                                          width: 30,
                                          fit: BoxFit.contain,
                                          colorFilter: const ColorFilter.mode(
                                            Colors.white,
                                            BlendMode.srcIn,
                                          ),
                                        ),
                                        // Streak text
                                        Positioned(
                                          top: 12,
                                          child: Text(
                                            '$currentStreak',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ).animate().fadeIn(
                                        delay:
                                            const Duration(milliseconds: 300),
                                      );
                                },
                                loading: () => Container(
                                  height: 40,
                                  width: 60,
                                  margin: const EdgeInsets.only(right: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                error: (_, __) => Container(
                                  height: 40,
                                  margin: const EdgeInsets.only(right: 12),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // Scroll image
                                      SvgPicture.asset(
                                        'assets/icons/scroll.svg',
                                        height: 40,
                                        width: 60,
                                        fit: BoxFit.contain,
                                        colorFilter: const ColorFilter.mode(
                                          Colors.white,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                      // Streak text
                                      const Positioned(
                                        child: Text(
                                          '0',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),

                          // Lightbulb icon
                          GestureDetector(
                            onTap: () {
                              // Show monetization coming soon dialog
                              _showMonetizationDialog(context);
                            },
                            child: Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.lightbulb_outline,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ).animate().fadeIn().scale(
                                delay: const Duration(milliseconds: 400),
                                duration: const Duration(milliseconds: 500),
                              ),
                        ],
                      ),
                    ),
                  ),

                  // Timeline circles
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: CircularTimeline(
                        periods: timelinePeriods,
                        selectedIndex: _selectedTimelineIndex,
                        timelineIds: _extractTimelineIds(timelines),
                        onPeriodSelected: (index) {
                          setState(() {
                            _selectedTimelineIndex = index;
                          });
                        },
                      )
                          .animate()
                          .fadeIn(duration: const Duration(milliseconds: 900)),
                    ),
                  ),

                  // White background container with stories
                  SliverToBoxAdapter(
                    child: storiesAsync.when(
                      data: (stories) {
                        if (stories.isEmpty) {
                          return Container(
                            height: 300,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(30),
                                topRight: Radius.circular(30),
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                'No stories available for this timeline',
                              ),
                            ),
                          );
                        }

                        return Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 10,
                                offset: Offset(0, -2),
                              ),
                            ],
                          ),
                          // Calculate appropriate minimum height to prevent over-scrolling and ensure full coverage on tablet
                          constraints: BoxConstraints(
                            minHeight: MediaQuery.of(context).size.height *
                                0.7, // Increased from 0.6 to 0.7
                          ),
                          // Add minimum width to ensure full coverage
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Stories header
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 16, 20, 8),
                                child: Row(
                                  children: [
                                    Container(
                                      height: 24,
                                      width: 4,
                                      decoration: BoxDecoration(
                                        color: AppColors.limeGreen,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Stories',
                                      style: TextStyle(
                                        color: AppColors.navyBlue,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Stories list items
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                padding: EdgeInsets.only(
                                  bottom: bottomPadding,
                                  left: 16,
                                  right: 16,
                                ),
                                itemCount: stories.length,
                                itemBuilder: (context, index) {
                                  final story = stories[index];
                                  return Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 6),
                                    child: StoryListItem(
                                      story: story,
                                      onTap: () {
                                        context.push('/story/${story.id}');
                                      },
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      },
                      loading: () => Container(
                        height: MediaQuery.of(context).size.height * 0.7,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Skeleton header
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                              child: Row(
                                children: [
                                  Container(
                                    height: 24,
                                    width: 4,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade300,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    height: 22,
                                    width: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade300,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Skeleton list items
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: Column(
                                children: List.generate(
                                  5,
                                  (index) => _buildStorySkeleton(index),
                                ),
                              ),
                            ),
                          ],
                        ).animate().shimmer(
                              delay: const Duration(milliseconds: 200),
                              duration: const Duration(milliseconds: 1000),
                              curve: Curves.easeInOut,
                            ),
                      ),
                      error: (error, stack) => Container(
                        height: MediaQuery.of(context).size.height * 0.7,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Error loading stories: $error',
                            style: const TextStyle(
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => Column(
            children: [
              // Skeleton header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    // Logo skeleton
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Text skeleton
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 16,
                            width: 150,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            height: 14,
                            width: 100,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Icon skeleton
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),

              // Timeline circles skeleton
              SizedBox(
                height: 150,
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      5,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Stories container skeleton
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Skeleton header
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                        child: Row(
                          children: [
                            Container(
                              height: 24,
                              width: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              height: 22,
                              width: 80,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Skeleton list items
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: List.generate(
                            5,
                            (index) => _buildStorySkeleton(index),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ).animate().shimmer(
                delay: const Duration(milliseconds: 200),
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeInOut,
              ),
          error: (error, stack) => Center(
            child: Text(
              'Error loading timelines: $error',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to build a story skeleton loading item
  Widget _buildStorySkeleton(int index) {
    // Add staggered delay based on index
    final shimmerDelay = Duration(milliseconds: 100 * index);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 100,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Image placeholder
          Container(
            width: 100,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Text placeholders
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 16,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 14,
                    width: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        height: 12,
                        width: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        height: 24,
                        width: 24,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
    ).animate(delay: shimmerDelay).fadeIn(
          duration: const Duration(milliseconds: 500),
        );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const FilterBottomSheet(),
    );
  }

  void _showMonetizationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 8,
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with lightbulb icon
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: AppColors.limeGreen.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lightbulb,
                  color: AppColors.limeGreen,
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),

              // Title
              const Text(
                "Monetization Coming Soon!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.navyBlue,
                ),
              ),
              const SizedBox(height: 16),

              // Description
              Text(
                "Earn rewards, unlock premium content, and support our app with our upcoming monetization features.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),

              // Features list
              _buildFeatureItem(
                icon: Icons.star_border,
                title: "Premium Content",
                subtitle: "Unlock exclusive stories and timelines",
              ),
              const SizedBox(height: 12),
              _buildFeatureItem(
                icon: Icons.notifications_none,
                title: "Notification Control",
                subtitle: "Get notified about new content",
              ),
              const SizedBox(height: 12),
              _buildFeatureItem(
                icon: Icons.workspace_premium,
                title: "Ad-Free Experience",
                subtitle: "Enjoy uninterrupted learning",
              ),
              const SizedBox(height: 32),

              // Got it button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.limeGreen,
                    foregroundColor: AppColors.navyBlue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Got it!",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.limeGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: AppColors.limeGreen,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.navyBlue,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
