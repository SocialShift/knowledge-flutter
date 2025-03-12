import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:knowledge/data/models/history_item.dart';
import 'package:knowledge/data/models/timeline.dart';
import 'package:knowledge/data/providers/timeline_provider.dart';
import 'package:knowledge/presentation/widgets/history_card.dart';
import 'package:flutter_animate/flutter_animate.dart';
// import 'package:cached_network_image/cached_network_image.dart';
import 'package:knowledge/presentation/widgets/search_bar_widget.dart';
import 'package:knowledge/core/themes/app_theme.dart';

class ElearningScreen extends HookConsumerWidget {
  const ElearningScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the bottom padding to account for the navigation bar
    final bottomPadding = MediaQuery.of(context).padding.bottom + 80;

    // Watch the paginated timelines provider
    final paginatedTimelines = ref.watch(paginatedTimelinesProvider);
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
                // Top section with gradient background
                Expanded(
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      const SliverToBoxAdapter(
                        child: _HeaderSection(),
                      ),
                      const SliverToBoxAdapter(
                        child: SizedBox(height: 8),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                          child: Row(
                            children: [
                              Text(
                                'Popular in History',
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
                      ),
                      // White background container for the grid
                      SliverToBoxAdapter(
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 24),
                              // Timeline grid with pagination
                              paginatedTimelines.items.isEmpty &&
                                      paginatedTimelines.isLoading
                                  ? const Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(32.0),
                                        child: CircularProgressIndicator(),
                                      ),
                                    )
                                  : paginatedTimelines.items.isEmpty &&
                                          paginatedTimelines.error != null
                                      ? Center(
                                          child: Padding(
                                            padding: const EdgeInsets.all(32.0),
                                            child: Column(
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
                                      : _TimelineGrid(
                                          timelines: paginatedTimelines.items,
                                          onLoadMore: paginatedTimelines.hasMore
                                              ? () => paginatedTimelinesNotifier
                                                  .loadNextPage()
                                              : null,
                                          isLoading:
                                              paginatedTimelines.isLoading,
                                        ),

                              // Add bottom padding to account for navigation bar
                              SizedBox(height: bottomPadding),
                            ],
                          ),
                        ),
                      ),
                    ],
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

  const _TimelineGrid({
    required this.timelines,
    this.onLoadMore,
    this.isLoading = false,
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
    return Column(
      children: [
        SizedBox(
          height: 500, // Fixed height for the grid container
          child: GridView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.85,
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
                    delay: Duration(milliseconds: index * 100 + 600),
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
          ),
        ),
        if (widget.isLoading)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
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
                      'Discover history today',
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
    return SearchBarWidget(
      onSearch: (value) {
        // TODO: Implement search functionality
      },
      onFilterTap: () {
        _showFilterBottomSheet(context);
      },
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.navyBlue,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const _FilterBottomSheet(),
    );
  }
}

class _FilterBottomSheet extends StatefulWidget {
  const _FilterBottomSheet();

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  String _selectedEra = 'All';
  String _selectedRegion = 'All';
  String _selectedType = 'All';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.lightPurple,
                  AppColors.navyBlue,
                ],
                stops: [0.0, 1.0],
              ),
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filter Stories',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),
          // Filter Content
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFilterSection(
                    title: 'Historical Era',
                    options: [
                      'All',
                      'Ancient',
                      'Medieval',
                      'Modern',
                      'Contemporary'
                    ],
                    selectedValue: _selectedEra,
                    onChanged: (value) => setState(() => _selectedEra = value),
                  ),
                  const SizedBox(height: 24),
                  _buildFilterSection(
                    title: 'Region',
                    options: [
                      'All',
                      'Europe',
                      'Asia',
                      'Americas',
                      'Africa',
                      'Oceania'
                    ],
                    selectedValue: _selectedRegion,
                    onChanged: (value) =>
                        setState(() => _selectedRegion = value),
                  ),
                  const SizedBox(height: 24),
                  _buildFilterSection(
                    title: 'Content Type',
                    options: ['All', 'Stories', 'Videos', 'Quizzes'],
                    selectedValue: _selectedType,
                    onChanged: (value) => setState(() => _selectedType = value),
                  ),
                ],
              ),
            ),
          ),
          // Apply Button
          Container(
            padding: EdgeInsets.fromLTRB(
                24, 16, 24, MediaQuery.of(context).padding.bottom + 16),
            decoration: BoxDecoration(
              color: AppColors.navyBlue,
              border: Border(
                top: BorderSide(
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Apply filters
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.limeGreen,
                  foregroundColor: AppColors.navyBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'Apply Filters',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection({
    required String title,
    required List<String> options,
    required String selectedValue,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 12,
          children: options.map((option) {
            final isSelected = option == selectedValue;
            return AnimatedScale(
              scale: isSelected ? 1.05 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: FilterChip(
                selected: isSelected,
                label: Text(
                  option,
                  style: TextStyle(
                    color: isSelected ? AppColors.navyBlue : Colors.black87,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                backgroundColor: Colors.white.withOpacity(0.9),
                selectedColor: AppColors.limeGreen,
                checkmarkColor: AppColors.navyBlue,
                onSelected: (_) => onChanged(option),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
