import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:knowledge/data/models/timeline.dart';
import 'package:knowledge/data/providers/timeline_provider.dart';
import 'package:knowledge/data/providers/filter_provider.dart';
import 'package:knowledge/presentation/widgets/timeline_discovery_card.dart';
import 'package:flutter_animate/flutter_animate.dart';
// import 'package:cached_network_image/cached_network_image.dart';
import 'package:knowledge/presentation/widgets/search_bar_widget.dart';
import 'package:knowledge/presentation/widgets/filter_bottom_sheet.dart';
import 'package:knowledge/presentation/widgets/butterfly_loading_widget.dart';
import 'package:knowledge/core/themes/app_theme.dart';
import 'package:knowledge/data/repositories/notification_repository.dart';

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

    // Get theme colors
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDarkMode ? AppColors.darkBackground : AppColors.navyBlue;
    final cardColor = isDarkMode ? AppColors.darkCard : Colors.white;
    final textColor = isDarkMode ? Colors.white : AppColors.navyBlue;
    final secondaryTextColor = isDarkMode ? Colors.white70 : Colors.black87;
    final shimmerColor =
        isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200;

    // Watch the cached filtered paginated timelines provider
    final paginatedTimelines = ref.watch(cachedFilteredTimelinesProvider);
    final paginatedTimelinesNotifier =
        ref.watch(paginatedTimelinesProvider.notifier);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // Background gradient
          Container(
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
          ),
          SafeArea(
            bottom: false, // Don't apply safe area at the bottom
            child: Column(
              children: [
                // Fixed Header Section with gradient background
                _HeaderSection(),

                const SizedBox(height: 8),

                // Section Title
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: Row(
                    children: [
                      Text(
                        'Echoes of the Past',
                        style: TextStyle(
                          color: isDarkMode
                              ? Colors.white.withOpacity(0.9)
                              : Colors.white.withOpacity(0.9),
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
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: const Offset(0, -2),
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
                          ? _buildButterflyLoading(context, isDarkMode)
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
                                              color: isDarkMode
                                                  ? Colors.grey.shade400
                                                  : Colors.grey.shade700,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Try a different search term or clear the filters',
                                            style: TextStyle(
                                              color: isDarkMode
                                                  ? Colors.grey.shade500
                                                  : Colors.grey.shade600,
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
                                              foregroundColor: isDarkMode
                                                  ? Colors.black
                                                  : AppColors.navyBlue,
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

  // Build butterfly loading with cool animations
  Widget _buildButterflyLoading(BuildContext context, bool isDarkMode) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          // Animated background gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.5,
                  colors: [
                    AppColors.limeGreen.withOpacity(0.03),
                    Colors.transparent,
                    AppColors.limeGreen.withOpacity(0.01),
                  ],
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
            )
                .animate(
                    onPlay: (controller) => controller.repeat(reverse: true))
                .scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1.2, 1.2),
                  duration: const Duration(milliseconds: 4000),
                  curve: Curves.easeInOut,
                ),
          ),

          // Enhanced floating particles
          Positioned.fill(
            child: _buildEnhancedFloatingParticles(isDarkMode),
          ),

          // Orbiting elements around butterfly
          Positioned.fill(
            child: _buildOrbitingElements(isDarkMode),
          ),

          // Main loading content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Clean butterfly without background shadow
                const ButterflyLoadingWidget(
                  size: 140,
                  showBackground: false,
                  showDots: false,
                )
                    .animate(onPlay: (controller) => controller.repeat())
                    .scale(
                      begin: const Offset(0.9, 0.9),
                      end: const Offset(1.1, 1.1),
                      duration: const Duration(milliseconds: 2500),
                      curve: Curves.easeInOut,
                    )
                    .then()
                    .scale(
                      begin: const Offset(1.1, 1.1),
                      end: const Offset(0.9, 0.9),
                      duration: const Duration(milliseconds: 2500),
                      curve: Curves.easeInOut,
                    )
                    .rotate(
                      begin: -0.05,
                      end: 0.05,
                      duration: const Duration(milliseconds: 3000),
                      curve: Curves.easeInOut,
                    )
                    .then()
                    .rotate(
                      begin: 0.05,
                      end: -0.05,
                      duration: const Duration(milliseconds: 3000),
                      curve: Curves.easeInOut,
                    ),

                const SizedBox(height: 50),

                // Enhanced loading text with shimmer effect
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? Colors.white.withOpacity(0.05)
                        : Colors.grey.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.limeGreen.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'Discovering Timelines...',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.0,
                    ),
                  ),
                )
                    .animate(onPlay: (controller) => controller.repeat())
                    .shimmer(
                      duration: const Duration(milliseconds: 2000),
                      color: AppColors.limeGreen.withOpacity(0.3),
                    )
                    .fadeIn(duration: const Duration(milliseconds: 1000))
                    .then(delay: const Duration(milliseconds: 500))
                    .fadeOut(duration: const Duration(milliseconds: 1000))
                    .then(delay: const Duration(milliseconds: 500)),

                const SizedBox(height: 20),

                // Enhanced subtitle with wave effect
                Text(
                  'Unveiling the stories of yesterday',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white54 : Colors.black38,
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    letterSpacing: 0.5,
                  ),
                )
                    .animate()
                    .fadeIn(delay: const Duration(milliseconds: 1500))
                    .slideY(
                      begin: 0.5,
                      duration: const Duration(milliseconds: 1000),
                      curve: Curves.elasticOut,
                    ),

                const SizedBox(height: 40),

                // Enhanced loading dots with pulse effect
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return Container(
                      width: 10,
                      height: 10,
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            AppColors.limeGreen.withOpacity(0.8),
                            AppColors.limeGreen.withOpacity(0.4),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.limeGreen.withOpacity(0.5),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    )
                        .animate(onPlay: (controller) => controller.repeat())
                        .scale(
                          begin: const Offset(0.3, 0.3),
                          end: const Offset(1.5, 1.5),
                          delay: Duration(milliseconds: index * 150),
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.elasticOut,
                        )
                        .then()
                        .scale(
                          begin: const Offset(1.5, 1.5),
                          end: const Offset(0.3, 0.3),
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeInCubic,
                        )
                        .fadeIn(
                          delay: Duration(milliseconds: index * 150),
                          duration: const Duration(milliseconds: 400),
                        )
                        .then()
                        .fadeOut(duration: const Duration(milliseconds: 400));
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build enhanced floating particles with various sizes and speeds
  Widget _buildEnhancedFloatingParticles(bool isDarkMode) {
    return Stack(
      children: List.generate(12, (index) {
        final double left = (index * 60.0) % 350;
        final double top = (index * 90.0) % 500;
        final double size = 3.0 + (index % 3) * 2.0; // Varying sizes
        final bool isLarge = index % 4 == 0;

        return Positioned(
          left: left,
          top: top,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.limeGreen.withOpacity(isLarge ? 0.6 : 0.4),
                  AppColors.limeGreen.withOpacity(isLarge ? 0.2 : 0.1),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.limeGreen.withOpacity(0.3),
                  blurRadius: isLarge ? 6 : 3,
                ),
              ],
            ),
          )
              .animate(onPlay: (controller) => controller.repeat())
              .moveY(
                begin: 0,
                end: isLarge ? -150 : -80,
                delay: Duration(milliseconds: index * 400),
                duration: Duration(milliseconds: isLarge ? 4000 : 2500),
                curve: Curves.easeInOut,
              )
              .fadeIn(
                delay: Duration(milliseconds: index * 400),
                duration: const Duration(milliseconds: 1500),
              )
              .then()
              .fadeOut(duration: const Duration(milliseconds: 1500))
              .scale(
                begin: const Offset(0.0, 0.0),
                end: const Offset(1.0, 1.0),
                delay: Duration(milliseconds: index * 400),
                duration: const Duration(milliseconds: 1000),
                curve: Curves.elasticOut,
              ),
        );
      }),
    );
  }

  // Build orbiting elements around the butterfly
  Widget _buildOrbitingElements(bool isDarkMode) {
    return Stack(
      children: List.generate(6, (index) {
        final double angle =
            (index * 60.0) * (3.14159 / 180); // Convert to radians
        final double radius = 100.0 + (index % 2) * 20.0;

        return Positioned.fill(
          child: Transform.rotate(
            angle: angle,
            child: Align(
              alignment: Alignment.center,
              child: Transform.translate(
                offset: Offset(0, -radius),
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.limeGreen.withOpacity(0.5),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.limeGreen.withOpacity(0.3),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
              .animate(onPlay: (controller) => controller.repeat())
              .rotate(
                begin: 0,
                end: 1,
                delay: Duration(milliseconds: index * 300),
                duration: const Duration(milliseconds: 8000),
              )
              .fadeIn(
                delay: Duration(milliseconds: 2000 + index * 300),
                duration: const Duration(milliseconds: 1000),
              ),
        );
      }),
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
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkSurface
          : Colors.white,
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
          mainAxisSpacing: 20,
          crossAxisSpacing: 16,
          childAspectRatio: 0.68, // Adjusted for the simplified card design
        ),
        itemCount: widget.timelines.length,
        itemBuilder: (context, index) {
          final timeline = widget.timelines[index];

          return TimelineDiscoveryCard(
            timeline: timeline,
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final iconBgColor = isDarkMode
        ? Colors.white.withOpacity(0.1)
        : Colors.white.withOpacity(0.2);

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
                        color: isDarkMode
                            ? Colors.white.withOpacity(0.9)
                            : Colors.white.withOpacity(0.9),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              // Notification icon with badge
              Consumer(
                builder: (context, ref, child) {
                  final notificationsAsync =
                      ref.watch(onThisDayNotificationsProvider);

                  // Check if there are notifications
                  final hasNotifications = notificationsAsync.hasValue &&
                      notificationsAsync.value!.isNotEmpty;

                  return Stack(
                    children: [
                      GestureDetector(
                        onTap: () {
                          // Navigate to notifications screen
                          context.push('/notifications');
                        },
                        child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: iconBgColor,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.notifications_outlined,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),

                      // Notification badge
                      if (hasNotifications)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
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
