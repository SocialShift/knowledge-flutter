import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:knowledge/data/models/timeline.dart';
import 'package:knowledge/data/repositories/timeline_repository.dart';
import 'package:knowledge/data/repositories/quiz_repository.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:knowledge/core/themes/app_theme.dart';
// import 'package:video_player/video_player.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class StoryDetailScreen extends HookConsumerWidget {
  final String storyId;

  const StoryDetailScreen({
    super.key,
    required this.storyId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fetch story details using the provider
    final storyAsync = ref.watch(storyDetailProvider(storyId));

    // Fetch quiz for this story - use the actual storyId passed to this screen
    final quizAsync = ref.watch(storyQuizProvider(storyId));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: storyAsync.when(
        data: (story) => AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: Text(
            story.title,
            style: const TextStyle(
              color: AppColors.navyBlue,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.navyBlue),
            onPressed: () => context.pop(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.headphones, color: AppColors.navyBlue),
              onPressed: () {
                // Audio functionality
              },
            ),
          ],
        ),
        loading: () => AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'Loading...',
            style: TextStyle(
              color: AppColors.navyBlue,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.navyBlue),
            onPressed: () => context.pop(),
          ),
        ),
        error: (_, __) => AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'Story Details',
            style: TextStyle(
              color: AppColors.navyBlue,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.navyBlue),
            onPressed: () => context.pop(),
          ),
        ),
      ),
      body: storyAsync.when(
        data: (story) {
          final pageController = PageController();
          final currentPage = useState(0);

          return Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Main content
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.navyBlue,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        // Pagination dots
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              5, // The number of dots
                              (index) => Container(
                                width: index == currentPage.value ? 24 : 8,
                                height: 8,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  color: index == currentPage.value
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Content
                        Expanded(
                          child: PageView(
                            controller: pageController,
                            onPageChanged: (index) {
                              currentPage.value = index;
                            },
                            children: [
                              // First page
                              _StoryPage(story: story),
                              // Additional pages would be here
                              _StorySecondPage(story: story),
                              _StoryThirdPage(story: story),
                              _StoryFourthPage(story: story),
                              _StoryFifthPage(story: story),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom navigation buttons
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Row(
                    children: [
                      // Bookmark button
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: AppColors.navyBlue),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.bookmark_border,
                          color: AppColors.navyBlue,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Back button
                      Expanded(
                        child: GestureDetector(
                          onTap: () => context.pop(),
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: AppColors.navyBlue),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Text(
                                'Back',
                                style: TextStyle(
                                  color: AppColors.navyBlue,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Next/Quiz button
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (currentPage.value < 4) {
                              pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            } else {
                              // If on the last page, go to quiz
                              context.push('/quiz/$storyId');
                            }
                          },
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.limeGreen,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                currentPage.value < 4 ? 'Next' : 'Take Quiz',
                                style: const TextStyle(
                                  color: AppColors.navyBlue,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
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
        },
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.limeGreen),
          ),
        ),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Error loading story: $error',
              style: const TextStyle(color: AppColors.navyBlue),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

// First page content
class _StoryPage extends StatelessWidget {
  final Story story;

  const _StoryPage({required this.story});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CachedNetworkImage(
                imageUrl: story.imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[800],
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[800],
                  height: 200,
                  child: const Icon(Icons.error, color: Colors.white),
                ),
              ),
            ),

            // Title and date
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      story.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Author avatars
                  // Row(
                  //   children: [
                  //     CircleAvatar(
                  //       radius: 12,
                  //       backgroundColor: Colors.white,
                  //       backgroundImage: story.imageUrl.isNotEmpty
                  //           ? NetworkImage(story.imageUrl)
                  //           : null,
                  //       child: story.imageUrl.isEmpty
                  //           ? const Icon(Icons.person, size: 12)
                  //           : null,
                  //     ),
                  //     const SizedBox(width: 4),
                  //     CircleAvatar(
                  //       radius: 12,
                  //       backgroundColor: Colors.white,
                  //       backgroundImage: story.imageUrl.isNotEmpty
                  //           ? NetworkImage(story.imageUrl)
                  //           : null,
                  //       child: story.imageUrl.isEmpty
                  //           ? const Icon(Icons.person, size: 12)
                  //           : null,
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),

            // Story content
            const SizedBox(height: 8),
            Text(
              _splitIntoParts(story.content.isNotEmpty
                  ? story.content
                  : story.description)[0],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Additional content pages
class _StorySecondPage extends StatelessWidget {
  final Story story;

  const _StorySecondPage({required this.story});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _splitIntoParts(story.content.isNotEmpty
                  ? story.content
                  : story.description)[1],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoryThirdPage extends StatelessWidget {
  final Story story;

  const _StoryThirdPage({required this.story});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _splitIntoParts(story.content.isNotEmpty
                  ? story.content
                  : story.description)[2],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoryFourthPage extends StatelessWidget {
  final Story story;

  const _StoryFourthPage({required this.story});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _splitIntoParts(story.content.isNotEmpty
                  ? story.content
                  : story.description)[3],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoryFifthPage extends StatelessWidget {
  final Story story;

  const _StoryFifthPage({required this.story});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _splitIntoParts(story.content.isNotEmpty
                  ? story.content
                  : story.description)[4],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                height: 1.5,
              ),
            ),

            // Engagement metrics
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Likes
                Column(
                  children: [
                    const Icon(Icons.favorite, color: Colors.white, size: 24),
                    const SizedBox(height: 4),
                    Text(
                      '${story.likes}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Likes',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),

                // Views
                Column(
                  children: [
                    const Icon(Icons.visibility, color: Colors.white, size: 24),
                    const SizedBox(height: 4),
                    Text(
                      '${story.views}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Views',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),

                // Share
                const Column(
                  children: [
                    Icon(Icons.share, color: Colors.white, size: 24),
                    SizedBox(height: 4),
                    Text(
                      'Share',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Story',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Helper function to split the content into parts
List<String> _splitIntoParts(String text, {int parts = 5}) {
  if (text.isEmpty) {
    return List.generate(parts, (index) => 'No content available');
  }

  // Calculate approximate length for each part
  final partLength = (text.length / parts).ceil();
  List<String> result = [];

  // Try to split at paragraph boundaries first
  List<String> paragraphs = text.split('\n\n');

  // If we have fewer paragraphs than parts, try single line breaks
  if (paragraphs.length < parts) {
    paragraphs = text.split('\n');
  }

  // If still not enough, split by sentences
  if (paragraphs.length < parts) {
    paragraphs = text.split('. ').map((s) => s + '.').toList();
  }

  // If we have enough paragraphs, distribute them into parts
  if (paragraphs.length >= parts) {
    List<List<String>> groups = List.generate(parts, (_) => []);

    for (int i = 0; i < paragraphs.length; i++) {
      groups[i % parts].add(paragraphs[i]);
    }

    result = groups.map((g) => g.join('\n\n')).toList();
  } else {
    // If all else fails, just split the text into equal parts
    for (int i = 0; i < parts; i++) {
      int start = i * partLength;
      int end = (i + 1) * partLength;
      if (end > text.length) end = text.length;

      if (start < text.length) {
        result.add(text.substring(start, end));
      } else {
        result.add('');
      }
    }
  }

  // Ensure we have exactly the requested number of parts
  while (result.length < parts) {
    result.add('');
  }

  return result.take(parts).toList();
}

/* Commented out the entire VideoPlayer functionality 
class _VideoPlayer extends HookWidget {
  final String videoUrl;
  final Function(VideoPlayerController)? onControllerCreated;

  const _VideoPlayer({
    required this.videoUrl,
    this.onControllerCreated,
  });

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
*/
