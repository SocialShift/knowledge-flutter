import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:knowledge/data/models/timeline.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:knowledge/presentation/widgets/story_list_item.dart';
import 'package:knowledge/core/themes/app_theme.dart';

class TimelineDetailScreen extends HookConsumerWidget {
  final String timelineId;

  const TimelineDetailScreen({
    super.key,
    required this.timelineId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeline = _demoTimeline;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // Hero Header with Image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            stretch: true,
            backgroundColor: AppColors.navyBlue,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Hero Image
                  Hero(
                    tag: 'timeline_${timeline.id}',
                    child: CachedNetworkImage(
                      imageUrl: timeline.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.navyBlue),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[200],
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: AppColors.navyBlue.withOpacity(0.7),
                              size: 48,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Failed to load image',
                              style: TextStyle(
                                color: AppColors.navyBlue.withOpacity(0.7),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Gradient Overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppColors.navyBlue.withOpacity(0.7),
                          AppColors.navyBlue,
                        ],
                        stops: const [0.2, 0.7, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Year
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          timeline.title,
                          style: const TextStyle(
                            color: AppColors.navyBlue,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.limeGreen.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${timeline.year}',
                            style: const TextStyle(
                              color: AppColors.navyBlue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Overview
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Overview',
                          style: TextStyle(
                            color: AppColors.navyBlue,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          timeline.description,
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Stories Section
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 8, 20, 16),
                    child: Text(
                      'Stories',
                      style: TextStyle(
                        color: AppColors.navyBlue,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Stories List
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final story = timeline.stories[index];
                  return StoryListItem(
                    story: story,
                    onTap: () => context.push('/story/${story.id}'),
                  )
                      .animate(delay: Duration(milliseconds: index * 100))
                      .fadeIn();
                },
                childCount: timeline.stories.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Demo data - Replace with actual data from API
  static final Timeline _demoTimeline = Timeline(
    id: '1',
    title: 'Ancient Greece',
    description:
        'Explore the birthplace of democracy, philosophy, and the Olympic Games. Journey through the rise of city-states, the Golden Age of Athens, and the spread of Hellenistic culture.',
    imageUrl:
        'https://images.pexels.com/photos/164336/pexels-photo-164336.jpeg',
    year: 1967,
    stories: [
      Story(
        id: '1',
        title: 'Birth of Democracy',
        description: 'The rise of democratic ideals in Athens',
        imageUrl:
            'https://images.pexels.com/photos/3290068/pexels-photo-3290068.jpeg',
        year: 1967,
        isCompleted: true,
        mediaType: 'image',
        mediaUrl:
            'https://images.pexels.com/photos/3290068/pexels-photo-3290068.jpeg',
        content: 'The full story content goes here...',
        timestamps: [],
      ),
      Story(
        id: '2',
        title: 'Golden Age',
        description: 'The peak of Greek civilization',
        imageUrl:
            'https://images.pexels.com/photos/1631665/pexels-photo-1631665.jpeg',
        year: 1970,
        isCompleted: false,
        mediaType: 'video',
        mediaUrl: 'https://example.com/video.mp4',
        content: 'The full story content goes here...',
        timestamps: [],
      ),
      // Add more stories...
    ],
  );
}

class _StoryCard extends StatelessWidget {
  final Story story;
  final VoidCallback onTap;

  const _StoryCard({
    required this.story,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image
              CachedNetworkImage(
                imageUrl: story.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.navyBlue),
                )),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),

              // Gradient overlay
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      AppColors.navyBlue.withOpacity(0.7),
                    ],
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (!story.isCompleted)
                      const Icon(
                        Icons.lock,
                        color: Colors.white70,
                        size: 20,
                      ),
                    const Spacer(),
                    Text(
                      story.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
