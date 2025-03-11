import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:knowledge/data/models/history_item.dart';
import 'package:knowledge/data/models/timeline.dart';
import 'package:knowledge/data/repositories/timeline_repository.dart';
import 'package:knowledge/presentation/widgets/history_card.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:knowledge/presentation/widgets/search_bar_widget.dart';
import 'package:knowledge/core/themes/app_theme.dart';

class ElearningScreen extends HookConsumerWidget {
  const ElearningScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                      const SliverToBoxAdapter(
                        child: _FeaturedSection(),
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
                                  // TODO: Navigate to all history items
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
                              // History items grid
                              SizedBox(
                                height:
                                    500, // Fixed height for the grid container
                                child: _HistoryGrid(items: _demoItems),
                              ),

                              // Timeline section title
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 32, 16, 16),
                                child: Row(
                                  children: [
                                    Text(
                                      'Explore Timelines',
                                      style: TextStyle(
                                        color: Colors.black.withOpacity(0.9),
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Spacer(),
                                    TextButton.icon(
                                      onPressed: () {
                                        // TODO: Navigate to all timelines
                                      },
                                      style: TextButton.styleFrom(
                                        foregroundColor: AppColors.navyBlue,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 8),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                      ),
                                      icon: const Icon(Icons.arrow_forward,
                                          size: 16),
                                      label: const Text(
                                        'See All',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Timeline cards
                              timelinesAsync.when(
                                data: (timelines) {
                                  if (timelines.isEmpty) {
                                    return const Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Center(
                                        child: Text('No timelines available'),
                                      ),
                                    );
                                  }

                                  return SizedBox(
                                    height: 220,
                                    child: ListView.builder(
                                      padding: const EdgeInsets.fromLTRB(
                                          16, 0, 16, 24),
                                      scrollDirection: Axis.horizontal,
                                      itemCount: timelines.length,
                                      itemBuilder: (context, index) {
                                        final timeline = timelines[index];
                                        return _buildTimelineCard(
                                            context, timeline, index);
                                      },
                                    ),
                                  );
                                },
                                loading: () => const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(24),
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                                error: (error, stack) => Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Center(
                                    child: Text(
                                      'Error loading timelines: $error',
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ),
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

  Widget _buildTimelineCard(
      BuildContext context, Timeline timeline, int index) {
    return GestureDetector(
      onTap: () {
        // Navigate to timeline detail
        context.push('/timeline/${timeline.id}');
      },
      child: Container(
        width: 280,
        margin: EdgeInsets.only(
          right: 16,
          top: 8,
          bottom: 8,
          left: index == 0 ? 0 : 0,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Background image
              Positioned.fill(
                child: CachedNetworkImage(
                  imageUrl: timeline.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.navyBlue),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.error, color: Colors.white),
                  ),
                ),
              ),
              // Gradient overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                      stops: const [0.5, 1.0],
                    ),
                  ),
                ),
              ),
              // Content
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Year
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.limeGreen,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${timeline.year}',
                          style: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Title
                      Text(
                        timeline.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Description
                      Text(
                        timeline.description,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ).animate().fadeIn(
            duration: const Duration(milliseconds: 600),
            delay: Duration(milliseconds: 100 * index),
          ),
    );
  }
}

// Demo items for the history grid
final List<HistoryItem> _demoItems = [
  HistoryItem(
    id: '1',
    title: 'World War II',
    subtitle: 'Global conflict that lasted from 1939 to 1945',
    imageUrl: 'https://picsum.photos/200/300?random=1',
    year: 1939,
  ),
  HistoryItem(
    id: '2',
    title: 'Renaissance',
    subtitle: 'Period of cultural rebirth across Europe',
    imageUrl: 'https://picsum.photos/200/300?random=2',
    year: 1400,
  ),
  HistoryItem(
    id: '3',
    title: 'Industrial Revolution',
    subtitle: 'Transition to new manufacturing processes',
    imageUrl: 'https://picsum.photos/200/300?random=3',
    year: 1760,
  ),
  HistoryItem(
    id: '4',
    title: 'French Revolution',
    subtitle: 'Period of radical social and political upheaval',
    imageUrl: 'https://picsum.photos/200/300?random=4',
    year: 1789,
  ),
  HistoryItem(
    id: '5',
    title: 'Ancient Egypt',
    subtitle: 'One of the world\'s oldest civilizations',
    imageUrl: 'https://picsum.photos/200/300?random=5',
    year: -3000,
  ),
  HistoryItem(
    id: '6',
    title: 'Space Race',
    subtitle: 'Competition between Cold War rivals',
    imageUrl: 'https://picsum.photos/200/300?random=6',
    year: 1957,
  ),
];

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

class _FeaturedSection extends StatelessWidget {
  const _FeaturedSection();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/timeline/featured'),
      child: Container(
        height: 200,
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Hero(
                tag: 'timeline_featured',
                child: CachedNetworkImage(
                  imageUrl:
                      'https://images.unsplash.com/photo-1552832230-c0197dd311b5',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[800],
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.limeGreen),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[800],
                    child: const Icon(Icons.error, color: Colors.white),
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.limeGreen,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Featured Story',
                      style: TextStyle(
                        color: AppColors.navyBlue,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'The Rise of Roman Empire',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black54,
                          blurRadius: 2,
                          offset: Offset(1, 1),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '1970',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.access_time,
                              color: Colors.white,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '10 min read',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Play button overlay for video content
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.bookmark_border,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideX(
          begin: -0.1,
          end: 0,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutQuart,
        );
  }
}

class _HistoryGrid extends StatelessWidget {
  final List<HistoryItem> items;

  const _HistoryGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return HistoryCard(
          item: item,
          onTap: () {
            context.push('/timeline/${item.id}');
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
    );
  }
}
