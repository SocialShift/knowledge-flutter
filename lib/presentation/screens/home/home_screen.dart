import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:knowledge/core/themes/app_theme.dart';
import 'package:knowledge/data/models/timeline.dart';
import 'package:knowledge/data/repositories/timeline_repository.dart';
import 'package:knowledge/presentation/widgets/story_list_item.dart';
import 'package:knowledge/presentation/widgets/circular_timeline.dart';
import 'package:knowledge/presentation/widgets/search_bar_widget.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedTimelineIndex = 0; // Default to first timeline

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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get the bottom padding to account for the navigation bar
    final bottomPadding = MediaQuery.of(context).padding.bottom + 80;

    // Watch the timelines provider
    final timelinesAsync = ref.watch(timelinesProvider);

    return Scaffold(
      backgroundColor: AppColors.navyBlue,
      body: Stack(
        children: [
          // Background gradient
          Container(
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
          ),
          SafeArea(
            bottom: false, // Don't apply safe area at the bottom
            child: Column(
              children: [
                // Header with welcome message and notification icon
                Padding(
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
                              'Welcome👋',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'The History Erased Now in Your Hands',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ).animate().fadeIn().slideX(
                              begin: -0.2,
                              delay: const Duration(milliseconds: 300),
                              duration: const Duration(milliseconds: 500),
                            ),
                      ),
                      // Notification icon
                      GestureDetector(
                        onTap: () {
                          // TODO: Show notifications
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
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              const Icon(
                                Icons.notifications_outlined,
                                color: Colors.white,
                                size: 24,
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  height: 8,
                                  width: 8,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.limeGreen,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn().scale(
                            delay: const Duration(milliseconds: 400),
                            duration: const Duration(milliseconds: 500),
                          ),
                    ],
                  ),
                ),

                // Search bar
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: SearchBarWidget(
                    onSearch: (value) {
                      // TODO: Implement search functionality
                    },
                    onFilterTap: () {
                      _showFilterBottomSheet(context);
                    },
                  ),
                ).animate().fadeIn(duration: const Duration(milliseconds: 800)),

                // Timeline section with matching gradient background
                Container(
                  child: timelinesAsync.when(
                    data: (timelines) {
                      // Ensure we don't go out of bounds
                      if (_selectedTimelineIndex >= timelines.length &&
                          timelines.isNotEmpty) {
                        _selectedTimelineIndex = 0;
                      }

                      final timelinePeriods =
                          _convertToTimelinePeriods(timelines);

                      return Column(
                        children: [
                          // Timeline circles
                          CircularTimeline(
                            periods: timelinePeriods,
                            selectedIndex: _selectedTimelineIndex,
                            onPeriodSelected: (index) {
                              setState(() {
                                _selectedTimelineIndex = index;
                              });
                            },
                          ).animate().fadeIn(
                              duration: const Duration(milliseconds: 900)),

                          // Spacer to ensure no error text is visible
                          const SizedBox(height: 16),
                        ],
                      );
                    },
                    loading: () => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    error: (error, stack) => Center(
                      child: Text(
                        'Error loading timelines: $error',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),

                // Stories section title with proper background
                timelinesAsync.when(
                  data: (timelines) {
                    if (timelines.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return Container(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Stories from ${timelines[_selectedTimelineIndex].year}s Era',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ).animate().fadeIn().slideX(
                                  begin: -0.1,
                                  duration: const Duration(milliseconds: 500),
                                ),
                          ),
                          const SizedBox(width: 8),
                          TextButton.icon(
                            onPressed: () {
                              // TODO: Navigate to all stories
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.limeGreen,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            icon: const Icon(Icons.arrow_forward, size: 16),
                            label: const Text(
                              'See All',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ).animate().fadeIn().slideX(
                                begin: 0.1,
                                duration: const Duration(milliseconds: 500),
                              ),
                        ],
                      ),
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),

                // Stories section with white background - Fixed layout
                Expanded(
                  child: timelinesAsync.when(
                    data: (timelines) {
                      if (timelines.isEmpty) {
                        return const Center(
                          child: Text(
                            'No timelines available',
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      }

                      final selectedTimeline =
                          timelines[_selectedTimelineIndex];

                      // Watch the stories provider for the selected timeline
                      final storiesAsync = ref
                          .watch(timelineStoriesProvider(selectedTimeline.id));

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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Timeline info text with enhanced styling
                            Container(
                              padding:
                                  const EdgeInsets.fromLTRB(20, 24, 20, 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Section title
                                  Row(
                                    children: [
                                      Container(
                                        height: 24,
                                        width: 4,
                                        decoration: BoxDecoration(
                                          color: AppColors.limeGreen,
                                          borderRadius:
                                              BorderRadius.circular(2),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Timeline Overview',
                                        style: TextStyle(
                                          color: AppColors.navyBlue,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),

                                  // Description text with styled container
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.grey.shade200,
                                        width: 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.03),
                                          blurRadius: 8,
                                          spreadRadius: 0,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      _getTimelineInfo(
                                          timelines, _selectedTimelineIndex),
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 15,
                                        height: 1.5,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Stories list
                            Expanded(
                              child: storiesAsync.when(
                                data: (stories) {
                                  if (stories.isEmpty) {
                                    return const Center(
                                      child: Text(
                                        'No stories available for this timeline',
                                      ),
                                    );
                                  }

                                  return ListView.builder(
                                    padding: EdgeInsets.only(
                                      bottom: bottomPadding,
                                      left: 16,
                                      right: 16,
                                    ),
                                    itemCount: stories.length,
                                    itemBuilder: (context, index) {
                                      final story = stories[index];
                                      return StoryListItem(
                                        story: story,
                                        onTap: () {
                                          context.push('/story/${story.id}');
                                        },
                                      );
                                    },
                                  );
                                },
                                loading: () => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                                error: (error, stack) => Center(
                                  child: Text(
                                    'Error loading stories: $error',
                                    style: const TextStyle(
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    loading: () => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    error: (error, stack) => Center(
                      child: Text(
                        'Error loading stories: $error',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              // Filter options would go here
              const Text('Filter options coming soon...'),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.navyBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
