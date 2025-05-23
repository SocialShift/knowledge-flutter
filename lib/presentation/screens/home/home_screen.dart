import 'dart:math' as math;
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
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  int _selectedTimelineIndex = 0; // Default to first timeline

  // Animation controller for the swipe transition
  late AnimationController _animationController;

  // Direction of animation (1 for forward/next, -1 for reverse/previous)
  int _animationDirection = 1;

  // ScrollController for the timeline to center the selected item
  final ScrollController _timelineScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  // Override to keep the state alive when navigating away
  @override
  bool get wantKeepAlive => true;

  // Timeline info text based on selected timeline
  // ignore: unused_element
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

  // Change timeline and handle boundary conditions
  void _changeTimeline(List<Timeline> timelines, int delta) {
    if (timelines.isEmpty) return;

    // Set animation direction
    _animationDirection = delta;

    // Reset the animation controller
    _animationController.reset();

    // Start the animation
    _animationController.forward();

    setState(() {
      _selectedTimelineIndex =
          (_selectedTimelineIndex + delta) % timelines.length;
      if (_selectedTimelineIndex < 0)
        _selectedTimelineIndex = timelines.length - 1;
    });

    // Scroll the timeline to center the selected item
    _scrollToSelectedTimeline();
  }

  // Scroll to center the selected timeline
  void _scrollToSelectedTimeline() {
    // Calculate the position to scroll to (each item is approximately 150 wide)
    final itemWidth = 150.0;
    final screenWidth = MediaQuery.of(context).size.width;
    final offset = _selectedTimelineIndex * itemWidth -
        (screenWidth / 2) +
        (itemWidth / 2);

    // Animate to that position
    if (_timelineScrollController.hasClients) {
      _timelineScrollController.animateTo(
        math.max(0, offset),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _timelineScrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    // Get the bottom padding to account for the navigation bar
    final bottomPadding = MediaQuery.of(context).padding.bottom + 80;
    final topPadding = MediaQuery.of(context).padding.top;

    // Get theme colors
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDarkMode ? AppColors.darkBackground : AppColors.navyBlue;
    final cardColor = isDarkMode ? AppColors.darkCard : Colors.white;
    final textColor = isDarkMode ? Colors.white : AppColors.navyBlue;
    final secondaryTextColor = isDarkMode ? Colors.white70 : Colors.black87;

    // Watch cached timelines provider instead of directly watching the original provider
    final timelinesAsync = ref.watch(cachedTimelinesSortedProvider);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Container(
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
            stops: const [0.0, 0.3],
          ),
        ),
        child: Stack(
          children: [
            // Modern curvy background structure for entire screen
            Positioned.fill(
              child: Container(
                child: Stack(
                  children: [
                    // Abstract curved shape 1 - Top Left
                    Positioned(
                      top: -50,
                      left: -100,
                      child: Container(
                        width: 300,
                        height: 200,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.limeGreen.withOpacity(0.08),
                              AppColors.lightPurple.withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.only(
                            topRight: Radius.elliptical(200, 120),
                            bottomRight: Radius.elliptical(150, 100),
                          ),
                        ),
                      ),
                    ),

                    // Abstract curved shape 2 - Top Right
                    Positioned(
                      top: 100,
                      right: -120,
                      child: Container(
                        width: 250,
                        height: 180,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            colors: [
                              Colors.white.withOpacity(0.1),
                              AppColors.navyBlue.withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.elliptical(180, 100),
                            bottomLeft: Radius.elliptical(120, 80),
                          ),
                        ),
                      ),
                    ),

                    // Abstract curved shape 3 - Middle Left
                    Positioned(
                      top: MediaQuery.of(context).size.height * 0.4,
                      left: -80,
                      child: Container(
                        width: 200,
                        height: 150,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              AppColors.limeGreen.withOpacity(0.06),
                              Colors.transparent,
                            ],
                          ),
                          borderRadius: BorderRadius.only(
                            topRight: Radius.elliptical(120, 80),
                            bottomRight: Radius.elliptical(100, 70),
                          ),
                        ),
                      ),
                    ),

                    // Abstract curved shape 4 - Bottom Right
                    Positioned(
                      bottom: -60,
                      right: -90,
                      child: Container(
                        width: 220,
                        height: 160,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomRight,
                            end: Alignment.topLeft,
                            colors: [
                              Colors.white.withOpacity(0.08),
                              AppColors.lightPurple.withOpacity(0.04),
                            ],
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.elliptical(160, 90),
                            bottomLeft: Radius.elliptical(130, 70),
                          ),
                        ),
                      ),
                    ),

                    // Floating circular decorations
                    Positioned(
                      top: MediaQuery.of(context).size.height * 0.15,
                      left: MediaQuery.of(context).size.width * 0.25,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: AppColors.limeGreen.withOpacity(0.3),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.limeGreen.withOpacity(0.2),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),

                    Positioned(
                      top: MediaQuery.of(context).size.height * 0.3,
                      right: MediaQuery.of(context).size.width * 0.2,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.4),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),

                    Positioned(
                      bottom: MediaQuery.of(context).size.height * 0.2,
                      left: MediaQuery.of(context).size.width * 0.15,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: AppColors.lightPurple.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),

                    // Modern wavy line decorations
                    Positioned(
                      top: MediaQuery.of(context).size.height * 0.25,
                      left: 50,
                      right: 50,
                      child: CustomPaint(
                        size: Size(double.infinity, 40),
                        painter: WavyLinePainter(
                          color: Colors.white.withOpacity(0.08),
                          strokeWidth: 1.5,
                        ),
                      ),
                    ),

                    Positioned(
                      bottom: MediaQuery.of(context).size.height * 0.15,
                      left: 80,
                      right: 80,
                      child: CustomPaint(
                        size: Size(double.infinity, 30),
                        painter: WavyLinePainter(
                          color: AppColors.limeGreen.withOpacity(0.06),
                          strokeWidth: 1.8,
                        ),
                      ),
                    ),

                    // Glass morphism effect overlay
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white.withOpacity(0.02),
                              Colors.transparent,
                              Colors.white.withOpacity(0.01),
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Main content
            timelinesAsync.when(
              data: (timelines) {
                // Ensure we don't go out of bounds
                if (_selectedTimelineIndex >= timelines.length &&
                    timelines.isNotEmpty) {
                  _selectedTimelineIndex = 0;
                }

                if (timelines.isEmpty) {
                  return Center(
                    child: Text(
                      'No timelines available',
                      style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.white),
                    ),
                  );
                }

                final timelinePeriods = _convertToTimelinePeriods(timelines);
                final selectedTimeline = timelines[_selectedTimelineIndex];

                // Watch the cached stories provider for the selected timeline
                final storiesAsync = ref
                    .watch(cachedTimelineStoriesProvider(selectedTimeline.id));

                // Ensure the selected timeline is centered when page loads
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToSelectedTimeline();
                });

                return GestureDetector(
                  onHorizontalDragEnd: (details) {
                    // Detect swipe direction based on velocity
                    if (details.primaryVelocity != null) {
                      if (details.primaryVelocity! > 0) {
                        // Swipe right - go to previous timeline
                        _changeTimeline(timelines, -1);
                      } else if (details.primaryVelocity! < 0) {
                        // Swipe left - go to next timeline
                        _changeTimeline(timelines, 1);
                      }
                    }
                  },
                  child: RefreshIndicator(
                    onRefresh: () async {
                      // Refresh all the data - invalidate the original providers, not the cached ones
                      ref.invalidate(timelinesProvider);
                      ref.invalidate(
                          timelineStoriesProvider(selectedTimeline.id));
                      // Add a small delay for better UX
                      await Future.delayed(const Duration(milliseconds: 800));
                    },
                    color: AppColors.limeGreen,
                    backgroundColor: cardColor,
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
                                      duration:
                                          const Duration(milliseconds: 500),
                                    ),
                                const SizedBox(width: 12),
                                // Welcome text
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'The History Erased',
                                        style: TextStyle(
                                          color: isDarkMode
                                              ? Colors.white.withOpacity(0.9)
                                              : Colors.white.withOpacity(0.9),
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 1),
                                      Text(
                                        'Now in Your Hands',
                                        style: TextStyle(
                                          color: isDarkMode
                                              ? Colors.white.withOpacity(0.7)
                                              : Colors.white.withOpacity(0.7),
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ).animate().fadeIn().slideX(
                                        begin: -0.2,
                                        delay:
                                            const Duration(milliseconds: 300),
                                        duration:
                                            const Duration(milliseconds: 500),
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
                                          margin:
                                              const EdgeInsets.only(right: 12),
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              // Circular background
                                              Container(
                                                height: 40,
                                                width: 40,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: isDarkMode
                                                      ? Colors.white
                                                          .withOpacity(0.1)
                                                      : Colors.white
                                                          .withOpacity(0.2),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.1),
                                                      blurRadius: 4,
                                                      offset:
                                                          const Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              // Scroll image
                                              SvgPicture.asset(
                                                'assets/icons/scroll.svg',
                                                height: 24,
                                                width: 24,
                                                fit: BoxFit.contain,
                                                colorFilter:
                                                    const ColorFilter.mode(
                                                  Colors.white,
                                                  BlendMode.srcIn,
                                                ),
                                              ),
                                              // Streak text
                                              Positioned(
                                                top: 13,
                                                child: Center(
                                                  child: Text(
                                                    '$currentStreak',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ).animate().fadeIn(
                                              delay: const Duration(
                                                  milliseconds: 300),
                                            );
                                      },
                                      loading: () => Container(
                                        height: 40,
                                        width: 60,
                                        margin:
                                            const EdgeInsets.only(right: 12),
                                        decoration: BoxDecoration(
                                          color: isDarkMode
                                              ? Colors.white.withOpacity(0.05)
                                              : Colors.white.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                      ),
                                      error: (_, __) => Container(
                                        height: 40,
                                        margin:
                                            const EdgeInsets.only(right: 12),
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            // Circular background
                                            Container(
                                              height: 40,
                                              width: 40,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: isDarkMode
                                                    ? Colors.white
                                                        .withOpacity(0.1)
                                                    : Colors.white
                                                        .withOpacity(0.2),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.1),
                                                    blurRadius: 4,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // Scroll image
                                            SvgPicture.asset(
                                              'assets/icons/scroll.svg',
                                              height: 24,
                                              width: 24,
                                              fit: BoxFit.contain,
                                              colorFilter:
                                                  const ColorFilter.mode(
                                                Colors.white,
                                                BlendMode.srcIn,
                                              ),
                                            ),
                                            // Streak text
                                            const Center(
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
                                      color: isDarkMode
                                          ? Colors.white.withOpacity(0.1)
                                          : Colors.white.withOpacity(0.2),
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
                                      color: AppColors.limeGreen,
                                      size: 24,
                                    ),
                                  ),
                                ).animate().fadeIn().scale(
                                      delay: const Duration(milliseconds: 400),
                                      duration:
                                          const Duration(milliseconds: 500),
                                    ),
                              ],
                            ),
                          ),
                        ),

                        // Timeline circles (simplified without extra background)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: CircularTimeline(
                              periods: timelinePeriods,
                              selectedIndex: _selectedTimelineIndex,
                              timelineIds: _extractTimelineIds(timelines),
                              scrollController: _timelineScrollController,
                              onPeriodSelected: (index) {
                                if (index != _selectedTimelineIndex) {
                                  _animationDirection =
                                      index > _selectedTimelineIndex ? 1 : -1;
                                  _animationController.reset();
                                  _animationController.forward();

                                  setState(() {
                                    _selectedTimelineIndex = index;
                                  });

                                  _scrollToSelectedTimeline();
                                }
                              },
                            ).animate().fadeIn(
                                duration: const Duration(milliseconds: 900)),
                          ),
                        ),

                        // White background container with stories - Paper Cut-out Effect
                        SliverToBoxAdapter(
                          child: storiesAsync.when(
                            data: (stories) {
                              if (stories.isEmpty) {
                                return Stack(
                                  children: [
                                    // Layer 3 - Bottom layer (darkest shadow)
                                    Container(
                                      height: 300,
                                      margin: const EdgeInsets.only(top: 8),
                                      decoration: BoxDecoration(
                                        color: isDarkMode
                                            ? Colors.black.withOpacity(0.1)
                                            : Colors.grey.shade300
                                                .withOpacity(0.4),
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(35),
                                          topRight: Radius.circular(28),
                                        ),
                                      ),
                                    ),
                                    // Layer 2 - Middle layer (medium shadow)
                                    Container(
                                      height: 300,
                                      margin: const EdgeInsets.only(top: 4),
                                      decoration: BoxDecoration(
                                        color: isDarkMode
                                            ? Colors.black.withOpacity(0.05)
                                            : Colors.grey.shade200
                                                .withOpacity(0.6),
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(32),
                                          topRight: Radius.circular(25),
                                        ),
                                      ),
                                    ),
                                    // Layer 1 - Top layer (main content)
                                    Container(
                                      height: 300,
                                      decoration: BoxDecoration(
                                        color: cardColor,
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(30),
                                          topRight: Radius.circular(30),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.08),
                                            blurRadius: 12,
                                            offset: const Offset(0, -4),
                                            spreadRadius: 1,
                                          ),
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.04),
                                            blurRadius: 6,
                                            offset: const Offset(0, -2),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          'No stories available for this timeline',
                                          style: TextStyle(color: textColor),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }

                              return Stack(
                                children: [
                                  // Layer 4 - Deepest shadow layer
                                  Container(
                                    margin: const EdgeInsets.only(top: 12),
                                    constraints: BoxConstraints(
                                      minHeight:
                                          MediaQuery.of(context).size.height *
                                              0.7,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isDarkMode
                                          ? Colors.black.withOpacity(0.12)
                                          : const Color(0xFFE2E8F0)
                                              .withOpacity(0.5),
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(38),
                                        topRight: Radius.circular(31),
                                      ),
                                    ),
                                  ),

                                  // Layer 3 - Third shadow layer
                                  Container(
                                    margin: const EdgeInsets.only(top: 8),
                                    constraints: BoxConstraints(
                                      minHeight:
                                          MediaQuery.of(context).size.height *
                                              0.7,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isDarkMode
                                          ? Colors.black.withOpacity(0.08)
                                          : const Color(0xFFF1F5F9)
                                              .withOpacity(0.7),
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(35),
                                        topRight: Radius.circular(28),
                                      ),
                                    ),
                                  ),

                                  // Layer 2 - Second shadow layer
                                  Container(
                                    margin: const EdgeInsets.only(top: 4),
                                    constraints: BoxConstraints(
                                      minHeight:
                                          MediaQuery.of(context).size.height *
                                              0.7,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isDarkMode
                                          ? Colors.black.withOpacity(0.04)
                                          : const Color(0xFFF8FAFC)
                                              .withOpacity(0.8),
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(32),
                                        topRight: Radius.circular(25),
                                      ),
                                    ),
                                  ),

                                  // Layer 1 - Main content layer with enhanced shadows
                                  Container(
                                    constraints: BoxConstraints(
                                      minHeight:
                                          MediaQuery.of(context).size.height *
                                              0.7,
                                    ),
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      gradient: isDarkMode
                                          ? LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                AppColors.darkCard,
                                                AppColors.darkCard
                                                    .withOpacity(0.98),
                                              ],
                                            )
                                          : LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Colors.white,
                                                const Color(0xFFFDFDFD),
                                              ],
                                            ),
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(30),
                                        topRight: Radius.circular(30),
                                      ),
                                      boxShadow: [
                                        // Primary shadow
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.12),
                                          blurRadius: 20,
                                          offset: const Offset(0, -6),
                                          spreadRadius: 2,
                                        ),
                                        // Secondary shadow for depth
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.06),
                                          blurRadius: 10,
                                          offset: const Offset(0, -3),
                                          spreadRadius: 1,
                                        ),
                                        // Subtle highlight on top edge
                                        BoxShadow(
                                          color: Colors.white.withOpacity(0.8),
                                          blurRadius: 1,
                                          offset: const Offset(0, 1),
                                          spreadRadius: 0,
                                        ),
                                      ],
                                    ),
                                    child: Stack(
                                      children: [
                                        // Subtle paper texture overlay
                                        Positioned.fill(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  const BorderRadius.only(
                                                topLeft: Radius.circular(30),
                                                topRight: Radius.circular(30),
                                              ),
                                              gradient: LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [
                                                  Colors.white
                                                      .withOpacity(0.02),
                                                  Colors.transparent,
                                                  Colors.black
                                                      .withOpacity(0.01),
                                                ],
                                                stops: const [0.0, 0.5, 1.0],
                                              ),
                                            ),
                                          ),
                                        ),

                                        // Main content
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Stories header with paper cut effect
                                            Container(
                                              margin: const EdgeInsets.fromLTRB(
                                                  20, 16, 20, 8),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.centerLeft,
                                                  end: Alignment.centerRight,
                                                  colors: [
                                                    Colors.transparent,
                                                    isDarkMode
                                                        ? Colors.white
                                                            .withOpacity(0.03)
                                                        : Colors.grey
                                                            .withOpacity(0.02),
                                                    Colors.transparent,
                                                  ],
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Row(
                                                children: [
                                                  // Enhanced accent bar with gradient
                                                  Container(
                                                    height: 24,
                                                    width: 4,
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        begin:
                                                            Alignment.topCenter,
                                                        end: Alignment
                                                            .bottomCenter,
                                                        colors: [
                                                          AppColors.limeGreen,
                                                          AppColors.limeGreen
                                                              .withOpacity(0.8),
                                                        ],
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              2),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: AppColors
                                                              .limeGreen
                                                              .withOpacity(0.3),
                                                          blurRadius: 4,
                                                          offset: const Offset(
                                                              1, 0),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Text(
                                                    'Stories',
                                                    style: TextStyle(
                                                      color: textColor,
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      letterSpacing: 0.5,
                                                      shadows: [
                                                        Shadow(
                                                          color: Colors.black
                                                              .withOpacity(
                                                                  0.05),
                                                          offset: const Offset(
                                                              0, 1),
                                                          blurRadius: 2,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            // Stories list with enhanced layered effect
                                            AnimatedBuilder(
                                              animation: _animationController,
                                              builder: (context, child) {
                                                // Enhanced platform-specific animation curves
                                                final isIOS = Theme.of(context)
                                                        .platform ==
                                                    TargetPlatform.iOS;

                                                // Different animation curves for iOS and Android
                                                final curveValue = isIOS
                                                    ? Curves.easeOutCubic
                                                        .transform(
                                                            _animationController
                                                                .value)
                                                    : Curves.fastOutSlowIn
                                                        .transform(
                                                            _animationController
                                                                .value);

                                                // Fix: Only apply slide animation during timeline change
                                                // Start with no offset when animation controller is at 1.0 (completed)
                                                final slideMultiplier =
                                                    isIOS ? 0.4 : 0.35;
                                                final slideValue =
                                                    _animationController
                                                            .isAnimating
                                                        ? _animationDirection *
                                                            (1.0 - curveValue) *
                                                            slideMultiplier
                                                        : 0.0; // No offset when not animating

                                                // Enhanced opacity with smoother transitions
                                                final opacityValue =
                                                    _animationController
                                                            .isAnimating
                                                        ? (isIOS
                                                            ? 0.2 +
                                                                (curveValue *
                                                                    0.8)
                                                            : 0.1 +
                                                                (curveValue *
                                                                    0.9))
                                                        : 1.0; // Full opacity when not animating

                                                // Subtle scale effect for iOS
                                                final scaleValue =
                                                    _animationController
                                                                .isAnimating &&
                                                            isIOS
                                                        ? 0.96 +
                                                            (curveValue * 0.04)
                                                        : 1.0; // No scale when not animating

                                                return Transform.scale(
                                                  scale: scaleValue,
                                                  child: Transform.translate(
                                                    offset: Offset(
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          slideValue,
                                                      0,
                                                    ),
                                                    child: Opacity(
                                                      opacity: opacityValue,
                                                      child: ListView.builder(
                                                        shrinkWrap: true,
                                                        physics:
                                                            const NeverScrollableScrollPhysics(),
                                                        padding:
                                                            EdgeInsets.only(
                                                          bottom: bottomPadding,
                                                          left: 16,
                                                          right: 16,
                                                        ),
                                                        itemCount:
                                                            stories.length,
                                                        itemBuilder:
                                                            (context, index) {
                                                          final story =
                                                              stories[index];

                                                          // Staggered animation for individual items (only during animation)
                                                          final itemDelay =
                                                              index * 0.05;
                                                          final itemProgress =
                                                              _animationController
                                                                      .isAnimating
                                                                  ? (curveValue -
                                                                          itemDelay)
                                                                      .clamp(
                                                                          0.0,
                                                                          1.0)
                                                                  : 1.0; // Full progress when not animating
                                                          final itemSlide = _animationController
                                                                  .isAnimating
                                                              ? _animationDirection *
                                                                  (1.0 -
                                                                      itemProgress) *
                                                                  0.1
                                                              : 0.0; // No slide when not animating

                                                          return Transform
                                                              .translate(
                                                            offset: Offset(
                                                              MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  itemSlide,
                                                              0,
                                                            ),
                                                            child: Opacity(
                                                              opacity: _animationController
                                                                      .isAnimating
                                                                  ? 0.3 +
                                                                      (itemProgress *
                                                                          0.7)
                                                                  : 1.0, // Full opacity when not animating
                                                              child: Container(
                                                                margin: const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        6),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              12),
                                                                  boxShadow: [
                                                                    BoxShadow(
                                                                      color: Colors
                                                                          .black
                                                                          .withOpacity(
                                                                              0.04),
                                                                      blurRadius:
                                                                          8,
                                                                      offset:
                                                                          const Offset(
                                                                              0,
                                                                              2),
                                                                      spreadRadius:
                                                                          0,
                                                                    ),
                                                                  ],
                                                                ),
                                                                child:
                                                                    StoryListItem(
                                                                  story: story,
                                                                  onTap: () {
                                                                    context.push(
                                                                        '/story/${story.id}');
                                                                  },
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                            loading: () => Stack(
                              children: [
                                // Layer 3 - Deepest shadow layer
                                Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.7,
                                  margin: const EdgeInsets.only(top: 8),
                                  decoration: BoxDecoration(
                                    color: isDarkMode
                                        ? Colors.black.withOpacity(0.1)
                                        : const Color(0xFFE2E8F0)
                                            .withOpacity(0.5),
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(35),
                                      topRight: Radius.circular(28),
                                    ),
                                  ),
                                ),

                                // Layer 2 - Middle shadow layer
                                Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.7,
                                  margin: const EdgeInsets.only(top: 4),
                                  decoration: BoxDecoration(
                                    color: isDarkMode
                                        ? Colors.black.withOpacity(0.05)
                                        : const Color(0xFFF1F5F9)
                                            .withOpacity(0.7),
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(32),
                                      topRight: Radius.circular(25),
                                    ),
                                  ),
                                ),

                                // Layer 1 - Main loading content
                                Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.7,
                                  decoration: BoxDecoration(
                                    gradient: isDarkMode
                                        ? LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              AppColors.darkCard,
                                              AppColors.darkCard
                                                  .withOpacity(0.98),
                                            ],
                                          )
                                        : LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.white,
                                              const Color(0xFFFDFDFD),
                                            ],
                                          ),
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(30),
                                      topRight: Radius.circular(30),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.12),
                                        blurRadius: 20,
                                        offset: const Offset(0, -6),
                                        spreadRadius: 2,
                                      ),
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.06),
                                        blurRadius: 10,
                                        offset: const Offset(0, -3),
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Skeleton header
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            20, 16, 20, 8),
                                        child: Row(
                                          children: [
                                            Container(
                                              height: 24,
                                              width: 4,
                                              decoration: BoxDecoration(
                                                color: isDarkMode
                                                    ? Colors.grey.shade700
                                                    : Colors.grey.shade300,
                                                borderRadius:
                                                    BorderRadius.circular(2),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              height: 22,
                                              width: 80,
                                              decoration: BoxDecoration(
                                                color: isDarkMode
                                                    ? Colors.grey.shade700
                                                    : Colors.grey.shade300,
                                                borderRadius:
                                                    BorderRadius.circular(4),
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
                                            (index) => _buildStorySkeleton(
                                                index, isDarkMode),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ).animate().shimmer(
                                        delay:
                                            const Duration(milliseconds: 200),
                                        duration:
                                            const Duration(milliseconds: 1000),
                                        curve: Curves.easeInOut,
                                      ),
                                ),
                              ],
                            ),
                            error: (error, stack) => Stack(
                              children: [
                                // Layer 3 - Deepest shadow layer
                                Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.7,
                                  margin: const EdgeInsets.only(top: 8),
                                  decoration: BoxDecoration(
                                    color: isDarkMode
                                        ? Colors.black.withOpacity(0.1)
                                        : const Color(0xFFE2E8F0)
                                            .withOpacity(0.5),
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(35),
                                      topRight: Radius.circular(28),
                                    ),
                                  ),
                                ),

                                // Layer 2 - Middle shadow layer
                                Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.7,
                                  margin: const EdgeInsets.only(top: 4),
                                  decoration: BoxDecoration(
                                    color: isDarkMode
                                        ? Colors.black.withOpacity(0.05)
                                        : const Color(0xFFF1F5F9)
                                            .withOpacity(0.7),
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(32),
                                      topRight: Radius.circular(25),
                                    ),
                                  ),
                                ),

                                // Layer 1 - Main error content
                                Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.7,
                                  decoration: BoxDecoration(
                                    gradient: isDarkMode
                                        ? LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              AppColors.darkCard,
                                              AppColors.darkCard
                                                  .withOpacity(0.98),
                                            ],
                                          )
                                        : LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.white,
                                              const Color(0xFFFDFDFD),
                                            ],
                                          ),
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(30),
                                      topRight: Radius.circular(30),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.12),
                                        blurRadius: 20,
                                        offset: const Offset(0, -6),
                                        spreadRadius: 2,
                                      ),
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.06),
                                        blurRadius: 10,
                                        offset: const Offset(0, -3),
                                        spreadRadius: 1,
                                      ),
                                    ],
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
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
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
                            color: isDarkMode
                                ? Colors.white.withOpacity(0.1)
                                : Colors.white.withOpacity(0.2),
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
                                  color: isDarkMode
                                      ? Colors.white.withOpacity(0.1)
                                      : Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                height: 14,
                                width: 100,
                                decoration: BoxDecoration(
                                  color: isDarkMode
                                      ? Colors.white.withOpacity(0.05)
                                      : Colors.white.withOpacity(0.15),
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
                            color: isDarkMode
                                ? Colors.white.withOpacity(0.1)
                                : Colors.white.withOpacity(0.2),
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
                              color: isDarkMode
                                  ? Colors.white.withOpacity(0.1)
                                  : Colors.white.withOpacity(0.2),
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
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: const BorderRadius.only(
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
                                    color: isDarkMode
                                        ? Colors.grey.shade700
                                        : Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  height: 22,
                                  width: 80,
                                  decoration: BoxDecoration(
                                    color: isDarkMode
                                        ? Colors.grey.shade700
                                        : Colors.grey.shade300,
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
                                (index) =>
                                    _buildStorySkeleton(index, isDarkMode),
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
                  style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build a story skeleton loading item
  Widget _buildStorySkeleton(int index, bool isDarkMode) {
    // Add staggered delay based on index
    final shimmerDelay = Duration(milliseconds: 100 * index);
    final skeletonColor =
        isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200;
    final containerColor = isDarkMode ? AppColors.darkCard : Colors.white;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 100,
      width: double.infinity,
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.05),
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
              color: skeletonColor,
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
                      color: skeletonColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 14,
                    width: 150,
                    decoration: BoxDecoration(
                      color: skeletonColor,
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
                          color: skeletonColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        height: 24,
                        width: 24,
                        decoration: BoxDecoration(
                          color: skeletonColor,
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

  // ignore: unused_element
  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const FilterBottomSheet(),
    );
  }

  void _showMonetizationDialog(BuildContext context) {
    // Instead of showing a dialog, navigate to the subscription screen
    context.push('/subscription');
  }

  // ignore: unused_element
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

// Custom painter for wavy line decoration
class WavyLinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  WavyLinePainter({
    required this.color,
    this.strokeWidth = 2.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final waveHeight = size.height * 0.3;
    final waveLength = size.width / 3;

    // Start point
    path.moveTo(0, size.height / 2);

    // Create smooth wavy curves
    for (int i = 0; i < 3; i++) {
      final x1 = (i * waveLength) + (waveLength * 0.25);
      final y1 = (size.height / 2) + (i.isEven ? -waveHeight : waveHeight);
      final x2 = (i * waveLength) + (waveLength * 0.75);
      final y2 = (size.height / 2) + (i.isEven ? -waveHeight : waveHeight);
      final x3 = (i + 1) * waveLength;
      final y3 = size.height / 2;

      path.cubicTo(x1, y1, x2, y2, x3, y3);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(WavyLinePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
  }
}
