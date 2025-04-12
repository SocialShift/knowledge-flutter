import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:knowledge/core/themes/app_theme.dart';
import 'package:knowledge/data/models/timeline.dart';
import 'package:knowledge/data/repositories/timeline_repository.dart';
import 'package:knowledge/data/providers/timeline_provider.dart';
import 'package:knowledge/presentation/widgets/story_list_item.dart';
import 'package:knowledge/presentation/widgets/circular_timeline.dart';
import 'package:knowledge/presentation/widgets/search_bar_widget.dart';
import 'package:knowledge/presentation/widgets/filter_bottom_sheet.dart';
import 'package:knowledge/data/providers/filter_provider.dart';
import 'package:knowledge/data/repositories/notification_repository.dart';
import 'package:knowledge/presentation/screens/notifications/notifications_screen.dart';

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
    // Get the bottom padding to account for the navigation bar
    final bottomPadding = MediaQuery.of(context).padding.bottom + 80;
    final topPadding = MediaQuery.of(context).padding.top;

    // Watch the timelines provider
    final timelinesAsync = ref.watch(timelinesProvider);

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

            // Watch the filtered stories provider for the selected timeline
            final storiesAsync =
                ref.watch(filteredTimelineStoriesProvider(selectedTimeline.id));

            return RefreshIndicator(
              onRefresh: () async {
                // Refresh all the data
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
                              // Show notifications screen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const NotificationsScreen(),
                                ),
                              );
                            },
                            child: Consumer(builder: (context, ref, child) {
                              // Watch for notifications to display badge
                              final notificationsAsync =
                                  ref.watch(onThisDayNotificationsProvider);
                              final hasNotifications =
                                  notificationsAsync.valueOrNull?.isNotEmpty ??
                                      false;

                              return Container(
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
                                    if (hasNotifications)
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
                              );
                            }),
                          ).animate().fadeIn().scale(
                                delay: const Duration(milliseconds: 400),
                                duration: const Duration(milliseconds: 500),
                              ),
                        ],
                      ),
                    ),
                  ),

                  // Search bar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      child: SearchBarWidget(
                        onSearch: (value) {
                          // Update the search query in the filter state
                          ref
                              .read(filterNotifierProvider.notifier)
                              .updateSearchQuery(value);
                        },
                        onFilterTap: () {
                          _showFilterBottomSheet(context);
                        },
                      ),
                    )
                        .animate()
                        .fadeIn(duration: const Duration(milliseconds: 800)),
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

                  // Stories title section
                  // SliverToBoxAdapter(
                  //   child: Container(
                  //     padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  //     child: Row(
                  //       children: [
                  //         Expanded(
                  //           child: Text(
                  //             'Stories from ${timelines[_selectedTimelineIndex].title}',
                  //             style: TextStyle(
                  //               color: Colors.white.withOpacity(0.9),
                  //               fontSize: 20,
                  //               fontWeight: FontWeight.bold,
                  //             ),
                  //             overflow: TextOverflow.ellipsis,
                  //           ).animate().fadeIn().slideX(
                  //                 begin: -0.1,
                  //                 duration: const Duration(milliseconds: 500),
                  //               ),
                  //         ),
                  //         const SizedBox(width: 8),
                  //         Tooltip(
                  //           message:
                  //               'View all timelines in the ELearning screen',
                  //           child: TextButton.icon(
                  //             onPressed: () {
                  //               context.go('/elearning');
                  //             },
                  //             style: TextButton.styleFrom(
                  //               foregroundColor: AppColors.limeGreen,
                  //               padding: const EdgeInsets.symmetric(
                  //                   horizontal: 12, vertical: 8),
                  //               shape: RoundedRectangleBorder(
                  //                 borderRadius: BorderRadius.circular(20),
                  //               ),
                  //             ),
                  //             icon: const Icon(Icons.arrow_forward, size: 16),
                  //             label: const Text(
                  //               'See All Timelines',
                  //               style: TextStyle(
                  //                 fontWeight: FontWeight.bold,
                  //               ),
                  //             ),
                  //           ),
                  //         ).animate().fadeIn().slideX(
                  //               begin: 0.1,
                  //               duration: const Duration(milliseconds: 500),
                  //             ),
                  //       ],
                  //     ),
                  //   ),
                  // ),

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
                          // Calculate appropriate minimum height to prevent over-scrolling
                          constraints: BoxConstraints(
                            minHeight: MediaQuery.of(context).size.height *
                                0.6, // 60% of screen height
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Timeline info text with enhanced styling
                              // Container(
                              //   padding:
                              //       const EdgeInsets.fromLTRB(20, 24, 20, 16),
                              //   child: Column(
                              //     crossAxisAlignment: CrossAxisAlignment.start,
                              //     children: [
                              //       // Section title
                              //       Row(
                              //         children: [
                              //           Container(
                              //             height: 24,
                              //             width: 4,
                              //             decoration: BoxDecoration(
                              //               color: AppColors.limeGreen,
                              //               borderRadius:
                              //                   BorderRadius.circular(2),
                              //             ),
                              //           ),
                              //           const SizedBox(width: 8),
                              //           Text(
                              //             'Timeline Overview',
                              //             style: TextStyle(
                              //               color: AppColors.navyBlue,
                              //               fontSize: 18,
                              //               fontWeight: FontWeight.bold,
                              //               letterSpacing: 0.5,
                              //             ),
                              //           ),
                              //         ],
                              //       ),
                              //       const SizedBox(height: 12),

                              //       // Description text with styled container
                              //       Container(
                              //         padding: const EdgeInsets.all(16),
                              //         decoration: BoxDecoration(
                              //           color: Colors.grey.shade50,
                              //           borderRadius: BorderRadius.circular(12),
                              //           border: Border.all(
                              //             color: Colors.grey.shade200,
                              //             width: 1,
                              //           ),
                              //           boxShadow: [
                              //             BoxShadow(
                              //               color:
                              //                   Colors.black.withOpacity(0.03),
                              //               blurRadius: 8,
                              //               spreadRadius: 0,
                              //               offset: const Offset(0, 2),
                              //             ),
                              //           ],
                              //         ),
                              //         child: Text(
                              //           _getTimelineInfo(
                              //               timelines, _selectedTimelineIndex),
                              //           style: TextStyle(
                              //             color: Colors.black87,
                              //             fontSize: 15,
                              //             height: 1.5,
                              //             fontWeight: FontWeight.w500,
                              //             letterSpacing: 0.2,
                              //           ),
                              //         ),
                              //       ),
                              //     ],
                              //   ),
                              // ),

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
                        height: 300,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      error: (error, stack) => Container(
                        height: 300,
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
}
