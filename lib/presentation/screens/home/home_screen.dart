import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:knowledge/core/themes/app_theme.dart';
import 'package:knowledge/data/models/timeline.dart';
import 'package:knowledge/presentation/widgets/story_list_item.dart';
import 'package:knowledge/presentation/widgets/circular_timeline.dart';
import 'package:knowledge/presentation/widgets/user_avatar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:knowledge/presentation/widgets/search_bar_widget.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedTimelineIndex = 0; // Default to 1700s

  // Mock data for timelines using TimelinePeriod from circular_timeline.dart
  late final List<TimelinePeriod> _timelines = [
    TimelinePeriod(
        year: 1700, imageUrl: 'https://picsum.photos/200/300?random=1'),
    TimelinePeriod(
        year: 1800, imageUrl: 'https://picsum.photos/200/300?random=2'),
    TimelinePeriod(
        year: 1900, imageUrl: 'https://picsum.photos/200/300?random=3'),
    TimelinePeriod(
        year: 2000, imageUrl: 'https://picsum.photos/200/300?random=4'),
    TimelinePeriod(
        year: 2100, imageUrl: 'https://picsum.photos/200/300?random=5'),
  ];

  // Timeline info text based on selected timeline
  String _getTimelineInfo(int index) {
    switch (_timelines[index].year) {
      case 1700:
        return '1700 (MDCC) was a century leap year starting on Friday of the Gregorian calendar.';
      case 1800:
        return '1800 (MDCCC) was an exceptional common year starting on Wednesday of the Gregorian calendar.';
      case 1900:
        return '1900 (MCM) was an exceptional common year starting on Monday of the Gregorian calendar.';
      default:
        return '';
    }
  }

  // Mock data for stories
  final List<Story> _mockStories = [
    Story(
      id: '1',
      title: 'Lorem ipsum dolor',
      description:
          'Lorem ipsum dolor sit amet consectetur. Nibh sagittis adipiscing...',
      imageUrl: 'https://picsum.photos/200/300?random=4',
      year: 1758,
      isCompleted: true,
      mediaType: 'image',
      mediaUrl: 'https://picsum.photos/200/300?random=5',
      content: 'Lorem ipsum dolor sit amet',
      timestamps: [],
    ),
    Story(
      id: '2',
      title: 'Lorem ipsum dolor',
      description:
          'Lorem ipsum dolor sit amet consectetur. Nibh sagittis adipiscing...',
      imageUrl: 'https://picsum.photos/200/300?random=6',
      year: 1789,
      isCompleted: true,
      mediaType: 'image',
      mediaUrl: 'https://picsum.photos/200/300?random=7',
      content: 'Lorem ipsum dolor sit amet',
      timestamps: [],
    ),
    Story(
      id: '3',
      title: 'Lorem ipsum dolor',
      description:
          'Lorem ipsum dolor sit amet consectetur. Nibh sagittis adipiscing...',
      imageUrl: 'https://picsum.photos/200/300?random=8',
      year: 1795,
      isCompleted: true,
      mediaType: 'image',
      mediaUrl: 'https://picsum.photos/200/300?random=9',
      content: 'Lorem ipsum dolor sit amet',
      timestamps: [],
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get the bottom padding to account for the navigation bar
    final bottomPadding = MediaQuery.of(context).padding.bottom + 70;

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
              crossAxisAlignment: CrossAxisAlignment.start,
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
                              'Welcome, Ann 👋',
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
                  child: Column(
                    children: [
                      // Timeline circles
                      CircularTimeline(
                        periods: _timelines,
                        selectedIndex: _selectedTimelineIndex,
                        onPeriodSelected: (index) {
                          setState(() {
                            _selectedTimelineIndex = index;
                          });
                        },
                      )
                          .animate()
                          .fadeIn(duration: const Duration(milliseconds: 900)),

                      // Spacer to ensure no error text is visible
                      const SizedBox(height: 16),
                    ],
                  ),
                ),

                // Stories section title with proper background
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Row(
                    children: [
                      Text(
                        'Stories from ${_timelines[_selectedTimelineIndex].year}s',
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
                ),

                // Stories section with white background - Fixed layout
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
                          color: Color(0x1A000000),
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
                      child: ListView.builder(
                        padding: EdgeInsets.only(
                          left: 16,
                          right: 16,
                          top: 24,
                          bottom: bottomPadding,
                        ),
                        physics: const BouncingScrollPhysics(),
                        itemCount: _mockStories.length,
                        itemBuilder: (context, index) {
                          return _buildStoryCard(
                            context,
                            _mockStories[index],
                            index,
                          );
                        },
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

  Widget _buildStoryCard(BuildContext context, Story story, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.navyBlue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/story/${story.id}'),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left side - Image
                Hero(
                  tag: 'story_image_${story.id}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 100,
                      height: 100,
                      child: CachedNetworkImage(
                        imageUrl: story.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.navyBlue),
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[200],
                          child: Icon(Icons.error, color: Colors.grey[400]),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Right side - Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        story.title,
                        style: const TextStyle(
                          color: AppColors.navyBlue,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${story.year}',
                        style: TextStyle(
                          color: AppColors.limeGreen,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        story.description,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(
          duration: const Duration(milliseconds: 600),
          delay: Duration(milliseconds: 100 * index),
        );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
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
      height: MediaQuery.of(context).size.height * 0.85,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: Color(0xFFEEEEEE),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back button
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, size: 18),
                  onPressed: () => Navigator.pop(context),
                  color: Colors.black54,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                // Title
                const Text(
                  'Filters',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                // Reset button
                IconButton(
                  icon: const Icon(Icons.refresh, size: 20),
                  onPressed: () {
                    setState(() {
                      _selectedEra = 'All';
                      _selectedRegion = 'All';
                      _selectedType = 'All';
                    });
                  },
                  color: Colors.black54,
                ),
              ],
            ),
          ),
          // Filter Content
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
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
          // Confirm Button
          Container(
            padding: EdgeInsets.fromLTRB(
                20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(
                  color: Color(0xFFEEEEEE),
                  width: 1,
                ),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Apply filters
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFFDEE14B), // Yellow-green color
                  foregroundColor: Colors.black87,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Confirm',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
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
            color: Colors.black87,
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
            return GestureDetector(
              onTap: () => onChanged(option),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFE9DAFF) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFFE9DAFF)
                        : const Color(0xFFE0E0E0),
                    width: 1,
                  ),
                ),
                child: Text(
                  option,
                  style: TextStyle(
                    color:
                        isSelected ? const Color(0xFF8B5CF6) : Colors.black54,
                    fontWeight:
                        isSelected ? FontWeight.w500 : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
