import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:knowledge/data/models/history_item.dart';
import 'package:knowledge/data/models/timeline.dart';
import 'package:knowledge/data/providers/timeline_provider.dart';
import 'package:knowledge/data/providers/filter_provider.dart';
import 'package:knowledge/presentation/widgets/history_card.dart';
import 'package:flutter_animate/flutter_animate.dart';
// import 'package:cached_network_image/cached_network_image.dart';
import 'package:knowledge/presentation/widgets/search_bar_widget.dart';
import 'package:knowledge/presentation/widgets/filter_bottom_sheet.dart';
import 'package:knowledge/core/themes/app_theme.dart';
import 'package:knowledge/data/repositories/notification_repository.dart';
import 'package:knowledge/presentation/screens/notifications/notifications_screen.dart';

class ElearningScreen extends HookConsumerWidget {
  const ElearningScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the bottom padding to account for the navigation bar
    final bottomPadding = MediaQuery.of(context).padding.bottom + 80;

    // Watch the filtered paginated timelines provider
    final paginatedTimelines = ref.watch(filteredPaginatedTimelinesProvider);
    final paginatedTimelinesNotifier =
        ref.watch(paginatedTimelinesProvider.notifier);

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
                // Fixed Header Section with gradient background
                const _HeaderSection(),

                const SizedBox(height: 8),

                // Section Title with Refresh Button
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: Row(
                    children: [
                      Text(
                        'Echoes of the Past',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ).animate().fadeIn().slideX(
                            begin: -0.1,
                            duration: const Duration(milliseconds: 500),
                          ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () {
                          // Refresh the timelines
                          paginatedTimelinesNotifier.refresh();
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.limeGreen,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text(
                          'Refresh',
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
                ),

                // Scrollable Content Area with White Background
                Expanded(
                  child: Container(
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
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                      child: paginatedTimelines.items.isEmpty &&
                              paginatedTimelines.isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.limeGreen),
                              ),
                            )
                          : paginatedTimelines.items.isEmpty &&
                                  paginatedTimelines.error != null
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(32.0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.error_outline,
                                          color: Colors.red,
                                          size: 48,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Error loading timelines: ${paginatedTimelines.error}',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              color: Colors.red),
                                        ),
                                        const SizedBox(height: 16),
                                        ElevatedButton(
                                          onPressed: () =>
                                              paginatedTimelinesNotifier
                                                  .refresh(),
                                          child: const Text('Retry'),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : paginatedTimelines.items.isEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.search_off_outlined,
                                            color: Colors.grey,
                                            size: 48,
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'No matches found',
                                            style: TextStyle(
                                              color: Colors.grey.shade700,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Try a different search term or clear the filters',
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 24),
                                          ElevatedButton.icon(
                                            onPressed: () {
                                              ref
                                                  .read(filterNotifierProvider
                                                      .notifier)
                                                  .clearFilters();
                                            },
                                            icon: const Icon(Icons.clear),
                                            label: const Text('Clear Search'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  AppColors.limeGreen,
                                              foregroundColor:
                                                  AppColors.navyBlue,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : _TimelineGrid(
                                      timelines: paginatedTimelines.items,
                                      onLoadMore: paginatedTimelines.hasMore
                                          ? () => paginatedTimelinesNotifier
                                              .loadNextPage()
                                          : null,
                                      isLoading: paginatedTimelines.isLoading,
                                      bottomPadding: bottomPadding,
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
}

class _TimelineGrid extends StatefulWidget {
  final List<Timeline> timelines;
  final VoidCallback? onLoadMore;
  final bool isLoading;
  final double bottomPadding;

  const _TimelineGrid({
    required this.timelines,
    this.onLoadMore,
    this.isLoading = false,
    required this.bottomPadding,
  });

  @override
  State<_TimelineGrid> createState() => _TimelineGridState();
}

class _TimelineGridState extends State<_TimelineGrid> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (widget.onLoadMore != null &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !widget.isLoading) {
      widget.onLoadMore!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: _scrollController,
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 20,
        bottom: widget
            .bottomPadding, // Add padding at the bottom to account for navigation bar
      ),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.65, // Changed from 0.7 to 0.65 to fix overflow
      ),
      itemCount: widget.timelines.length,
      itemBuilder: (context, index) {
        final timeline = widget.timelines[index];
        // Convert Timeline to HistoryItem for use with HistoryCard
        final historyItem = HistoryItem(
          id: timeline.id,
          title: timeline.title,
          subtitle: timeline.description,
          imageUrl: timeline.imageUrl,
          year: timeline.year,
        );

        return HistoryCard(
          item: historyItem,
          onTap: () {
            context.push('/timeline/${timeline.id}');
          },
        )
            .animate(
              delay: Duration(milliseconds: index * 100 + 400),
            )
            .slideY(
              begin: 0.2,
              end: 0,
              curve: Curves.easeOutCubic,
              duration: const Duration(milliseconds: 600),
            )
            .fadeIn(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
            );
      },
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        children: [
          Row(
            children: [
              // Enhanced logo without rounded corners
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back!',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Discover History Today',
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
                      builder: (context) => const NotificationsScreen(),
                    ),
                  );
                },
                child: Consumer(builder: (context, ref, child) {
                  // Watch for notifications to display badge
                  final notificationsAsync =
                      ref.watch(onThisDayNotificationsProvider);
                  final hasNotifications =
                      notificationsAsync.valueOrNull?.isNotEmpty ?? false;

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
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _SearchBar().animate().fadeIn().slideY(
                  begin: 0.2,
                  delay: const Duration(milliseconds: 500),
                  duration: const Duration(milliseconds: 500),
                ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        return SearchBarWidget(
          onSearch: (value) {
            // Update the search query in the filter state
            ref.read(filterNotifierProvider.notifier).updateSearchQuery(value);
          },
          onFilterTap: () {
            _showFilterBottomSheet(context);
          },
        );
      },
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
