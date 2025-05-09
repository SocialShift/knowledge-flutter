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

// Create a cached version of filtered paginated timelines provider
// This provider will keep its state even when we navigate away from the screen
final cachedFilteredTimelinesProvider =
    Provider<PaginatedData<Timeline>>((ref) {
  // Watch the filtered provider but keep its state in our cached provider
  return ref.watch(filteredPaginatedTimelinesProvider);
}, name: 'cachedFilteredTimelinesProvider');

class ElearningScreen extends HookConsumerWidget {
  const ElearningScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the bottom padding to account for the navigation bar
    final bottomPadding = MediaQuery.of(context).padding.bottom + 80;

    // Watch the cached filtered paginated timelines provider
    final paginatedTimelines = ref.watch(cachedFilteredTimelinesProvider);
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

                // Section Title
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
                          ? Center(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 40),
                                child: _buildLoadingGrid(),
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
                                      onRefresh: () async {
                                        await Future.delayed(Duration.zero);
                                        paginatedTimelinesNotifier.refresh();
                                        return;
                                      },
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

  // Build a grid of skeleton loading items
  Widget _buildLoadingGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.65,
      ),
      itemCount: 6, // Show 6 skeleton items
      itemBuilder: (context, index) {
        return _buildSkeletonCard(index);
      },
    );
  }

  // Build a skeleton card with shimmer effect
  Widget _buildSkeletonCard(int index) {
    // Add staggered animation based on index
    final delay = Duration(milliseconds: 50 * index);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          Container(
            height: 140,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
          ),

          // Content placeholders
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Year pill
                Container(
                  height: 20,
                  width: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 12),

                // Title
                Container(
                  height: 16,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),

                // Subtitle
                Container(
                  height: 14,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),

                // Description lines
                Container(
                  height: 12,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  height: 12,
                  width: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate(delay: delay)
        .fadeIn(duration: const Duration(milliseconds: 500))
        .shimmer(
          duration: const Duration(milliseconds: 1200),
          delay: delay + const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
  }
}

class _TimelineGrid extends StatefulWidget {
  final List<Timeline> timelines;
  final VoidCallback? onLoadMore;
  final Future<void> Function() onRefresh;
  final bool isLoading;
  final double bottomPadding;

  const _TimelineGrid({
    required this.timelines,
    this.onLoadMore,
    required this.onRefresh,
    this.isLoading = false,
    required this.bottomPadding,
  });

  @override
  State<_TimelineGrid> createState() => _TimelineGridState();
}

class _TimelineGridState extends State<_TimelineGrid>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();

  // Keep the widget alive when navigating away
  @override
  bool get wantKeepAlive => true;

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
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      color: AppColors.limeGreen,
      backgroundColor: Colors.white,
      strokeWidth: 2.5,
      displacement: 40,
      child: GridView.builder(
        controller: _scrollController,
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 20,
          bottom: widget
              .bottomPadding, // Add padding at the bottom to account for navigation bar
        ),
        physics: const AlwaysScrollableScrollPhysics(),
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
                delay: Duration(milliseconds: index * 50),
              )
              .fadeIn(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
              );
        },
      ),
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
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Discover History',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
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
              ),
            ],
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _SearchBar(),
          ),
        ],
      ),
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
