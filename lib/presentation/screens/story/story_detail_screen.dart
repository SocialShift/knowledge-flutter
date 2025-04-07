import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:knowledge/data/models/timeline.dart';
import 'package:knowledge/data/repositories/timeline_repository.dart';
import 'package:knowledge/data/repositories/quiz_repository.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:knowledge/core/themes/app_theme.dart';
import 'package:video_player/video_player.dart';
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

          // Determine total number of pages based on whether video exists
          final hasVideo = story.mediaUrl.isNotEmpty;
          final totalPages = hasVideo ? 6 : 5; // Add an extra page for video

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
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Pagination dots with enhanced design
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              totalPages, // Updated number of dots based on video presence
                              (index) => AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: index == currentPage.value ? 24 : 8,
                                height: 8,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  color: index == currentPage.value
                                      ? AppColors.limeGreen
                                      : Colors.white.withOpacity(0.3),
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
                              // Video player page (only if video URL exists)
                              if (hasVideo) _VideoPlayerPage(story: story),

                              // Original pages
                              _StoryPage(story: story),
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
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: () {
                            // Bookmark functionality
                          },
                          icon: const Icon(
                            Icons.bookmark_border,
                            color: AppColors.navyBlue,
                          ),
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
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
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.arrow_back_ios_new,
                                    color: AppColors.navyBlue,
                                    size: 16,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'Back',
                                    style: TextStyle(
                                      color: AppColors.navyBlue,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
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
                            final lastPage = hasVideo ? 5 : 4;
                            if (currentPage.value < lastPage) {
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
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.limeGreen.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    currentPage.value < (hasVideo ? 5 : 4)
                                        ? 'Next'
                                        : 'Milestones',
                                    style: const TextStyle(
                                      color: AppColors.navyBlue,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Icon(
                                    currentPage.value < (hasVideo ? 5 : 4)
                                        ? Icons.arrow_forward_ios
                                        : Icons.quiz_outlined,
                                    color: AppColors.navyBlue,
                                    size: 16,
                                  ),
                                ],
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

// Video player page
class _VideoPlayerPage extends HookConsumerWidget {
  final Story story;

  const _VideoPlayerPage({required this.story});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Create video controller using Flutter Hooks
    final videoControllerRef = useState<VideoPlayerController?>(null);
    final isPlaying = useState(false);
    final isInitialized = useState(false);
    final currentPosition = useState(Duration.zero);

    // Initialize the video player
    useEffect(() {
      if (story.mediaUrl.isEmpty) return null;

      final controller = VideoPlayerController.network(story.mediaUrl);
      videoControllerRef.value = controller;

      controller.initialize().then((_) {
        isInitialized.value = true;

        // Add listener to update current position
        controller.addListener(() {
          currentPosition.value = controller.value.position;
        });
      });

      return () {
        controller.dispose();
      };
    }, [story.mediaUrl]);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video player page indicator
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Video',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Video section with controls
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.black,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Video player
                      if (videoControllerRef.value != null &&
                          isInitialized.value)
                        VideoPlayer(videoControllerRef.value!),

                      // Loading indicator
                      if (videoControllerRef.value != null &&
                          !isInitialized.value)
                        const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.limeGreen),
                          ),
                        ),

                      // Play/Pause button overlay
                      if (videoControllerRef.value != null)
                        AnimatedOpacity(
                          opacity: isPlaying.value ? 0.0 : 1.0,
                          duration: const Duration(milliseconds: 300),
                          child: GestureDetector(
                            onTap: () {
                              if (videoControllerRef.value!.value.isPlaying) {
                                videoControllerRef.value!.pause();
                                isPlaying.value = false;
                              } else {
                                videoControllerRef.value!.play();
                                isPlaying.value = true;
                              }
                            },
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: AppColors.limeGreen.withOpacity(0.7),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isPlaying.value
                                    ? Icons.pause
                                    : Icons.play_arrow,
                                color: Colors.white,
                                size: 36,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // Video progress bar
            if (videoControllerRef.value != null && isInitialized.value)
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                child: Column(
                  children: [
                    Slider(
                      activeColor: AppColors.limeGreen,
                      inactiveColor: Colors.white24,
                      value: currentPosition.value.inMilliseconds.toDouble(),
                      min: 0,
                      max: videoControllerRef
                          .value!.value.duration.inMilliseconds
                          .toDouble(),
                      onChanged: (value) {
                        videoControllerRef.value!
                            .seekTo(Duration(milliseconds: value.toInt()));
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(currentPosition.value),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            _formatDuration(
                                videoControllerRef.value!.value.duration),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // Title with improved typography
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: Text(
                story.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.2,
                  height: 1.3,
                ),
              ),
            ),

            // Timestamps section (if video has timestamps)
            if (story.timestamps.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0, bottom: 12.0),
                    child: Text(
                      'Timestamps',
                      style: TextStyle(
                        color: AppColors.limeGreen,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: story.timestamps.map((timestamp) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: GestureDetector(
                            onTap: () {
                              if (videoControllerRef.value != null &&
                                  isInitialized.value) {
                                videoControllerRef.value!.seekTo(
                                    Duration(seconds: timestamp.timeSec));
                                if (!isPlaying.value) {
                                  videoControllerRef.value!.play();
                                  isPlaying.value = true;
                                }
                              }
                            },
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.limeGreen.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    _formatDuration(
                                        Duration(seconds: timestamp.timeSec)),
                                    style: const TextStyle(
                                      color: AppColors.limeGreen,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    timestamp.label,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.play_circle_outline,
                                  color: AppColors.limeGreen,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              )
            else
              // If no timestamps, show a message encouraging swiping to content
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.swipe,
                        color: Colors.white70,
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Swipe to view the story',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Brief description
            // if (story.description.isNotEmpty)
            //   Padding(
            //     padding: const EdgeInsets.symmetric(vertical: 16.0),
            //     child: Text(
            //       story.description,
            //       style: const TextStyle(
            //         color: Colors.white,
            //         fontSize: 14,
            //         height: 1.5,
            //         letterSpacing: 0.2,
            //       ),
            //     ),
            //   ),
          ],
        ),
      ),
    );
  }

  // Helper method to format duration
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours > 0 ? duration.inHours : 0)}:$twoDigitMinutes:$twoDigitSeconds";
  }
}

// First page content
class _StoryPage extends StatelessWidget {
  final Story story;

  const _StoryPage({required this.story});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stylish page number indicator
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Part 1/5',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Enhanced Thumbnail with shadow and rounded corners
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
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
            ),

            // Title with improved typography
            Padding(
              padding: const EdgeInsets.only(top: 24, bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      story.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.2,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Story metadata with period and timeframe info
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.limeGreen.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.limeGreen.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.history,
                    color: AppColors.limeGreen,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${story.year ?? "Historical"} Period',
                    style: const TextStyle(
                      color: AppColors.limeGreen,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Story content with improved readability
            Text(
              _splitIntoParts(story.content.isNotEmpty
                  ? story.content
                  : story.description)[0],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                height: 1.6,
                letterSpacing: 0.3,
                fontWeight: FontWeight.w400,
              ),
            ),

            // Visual separator
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),

            // Reading time estimate
            Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.timer_outlined,
                      color: Colors.white70,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${_calculateReadingTime(story.content)} min read',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to calculate reading time
  int _calculateReadingTime(String text) {
    // Average reading speed: 200 words per minute
    final wordCount = text.split(' ').length;
    final minutes = (wordCount / 200).ceil();
    return minutes > 0 ? minutes : 1; // Minimum 1 minute
  }
}

// Additional content pages
class _StorySecondPage extends StatelessWidget {
  final Story story;

  const _StorySecondPage({required this.story});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page indicator
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Part 2/5',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ).animate().fadeIn(duration: const Duration(milliseconds: 500)),

            const SizedBox(height: 20),

            // Visual element to break up text
            Center(
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_stories,
                  color: AppColors.limeGreen,
                  size: 30,
                ),
              ),
            ).animate().fadeIn(duration: const Duration(milliseconds: 700)),

            const SizedBox(height: 24),

            // Story content
            Text(
              _splitIntoParts(story.content.isNotEmpty
                  ? story.content
                  : story.description)[1],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                height: 1.6,
                letterSpacing: 0.3,
                fontWeight: FontWeight.w400,
              ),
            ).animate().fadeIn(
                delay: const Duration(milliseconds: 300),
                duration: const Duration(milliseconds: 800)),

            // Visual separator
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),

            // Page progress indicator
            Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.swipe_left_alt,
                      color: Colors.white70,
                      size: 16,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Swipe for next part',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(
                delay: const Duration(milliseconds: 700),
                duration: const Duration(milliseconds: 600)),
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
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page indicator
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Part 3/5',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ).animate().fadeIn(duration: const Duration(milliseconds: 500)),

            const SizedBox(height: 20),

            // Decorative quote element
            Container(
              margin: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.limeGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.limeGreen.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.format_quote,
                    color: AppColors.limeGreen,
                    size: 30,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '"${story.title}" - Part 3',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: const Duration(milliseconds: 800))
                .scaleXY(
                    begin: 0.9,
                    end: 1.0,
                    duration: const Duration(milliseconds: 500)),

            // Story content
            Text(
              _splitIntoParts(story.content.isNotEmpty
                  ? story.content
                  : story.description)[2],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                height: 1.6,
                letterSpacing: 0.3,
                fontWeight: FontWeight.w400,
              ),
            ).animate().fadeIn(
                delay: const Duration(milliseconds: 300),
                duration: const Duration(milliseconds: 800)),

            // Visual separator
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),

            // Progress indicator
            LinearProgressIndicator(
              value: 0.6, // 3 out of 5 pages
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.limeGreen),
              borderRadius: BorderRadius.circular(10),
              minHeight: 6,
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
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page indicator
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Part 4/5',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ).animate().fadeIn(duration: const Duration(milliseconds: 500)),

            const SizedBox(height: 20),

            // Timeline element to show progression
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.limeGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      '4',
                      style: TextStyle(
                        color: AppColors.navyBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 3,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.limeGreen,
                          AppColors.limeGreen.withOpacity(0.3),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      '5',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ).animate().fadeIn(
                delay: const Duration(milliseconds: 300),
                duration: const Duration(milliseconds: 800)),

            const SizedBox(height: 24),

            // Story content
            Text(
              _splitIntoParts(story.content.isNotEmpty
                  ? story.content
                  : story.description)[3],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                height: 1.6,
                letterSpacing: 0.3,
                fontWeight: FontWeight.w400,
              ),
            ).animate().fadeIn(
                delay: const Duration(milliseconds: 300),
                duration: const Duration(milliseconds: 800)),

            // Visual separator
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),

            // Almost done indicator
            Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.limeGreen.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: AppColors.limeGreen,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Almost there!',
                      style: TextStyle(
                        color: AppColors.limeGreen,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(
                delay: const Duration(milliseconds: 700),
                duration: const Duration(milliseconds: 600)),
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
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page indicator
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.limeGreen.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Final Part',
                  style: TextStyle(
                    color: AppColors.limeGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ).animate().fadeIn(duration: const Duration(milliseconds: 500)),

            const SizedBox(height: 20),

            // Conclusion badge
            Center(
              child: Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.limeGreen,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  'Conclusion',
                  style: TextStyle(
                    color: AppColors.navyBlue,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
                .animate()
                .fadeIn(duration: const Duration(milliseconds: 600))
                .scaleXY(
                    begin: 0.9,
                    end: 1.0,
                    duration: const Duration(milliseconds: 500)),

            // Story content (final part)
            Text(
              _splitIntoParts(story.content.isNotEmpty
                  ? story.content
                  : story.description)[4],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                height: 1.6,
                letterSpacing: 0.3,
                fontWeight: FontWeight.w400,
              ),
            ).animate().fadeIn(
                delay: const Duration(milliseconds: 300),
                duration: const Duration(milliseconds: 800)),

            // Engagement metrics with enhanced UI
            Padding(
              padding: const EdgeInsets.only(top: 30, bottom: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Likes with animation
                    Column(
                      children: [
                        Icon(
                          Icons.favorite,
                          color: Colors.redAccent.shade200,
                          size: 28,
                        )
                            .animate(
                              onPlay: (controller) =>
                                  controller.repeat(reverse: true),
                            )
                            .scaleXY(
                              begin: 1.0,
                              end: 1.1,
                              duration: const Duration(seconds: 1),
                            ),
                        const SizedBox(height: 8),
                        Text(
                          '${story.likes}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
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

                    // Views with enhanced look
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.visibility,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${story.views}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
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

                    // Share button with animation
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.limeGreen.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.share,
                            color: AppColors.limeGreen,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Share',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const Text(
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
              ),
            ).animate().fadeIn(
                delay: const Duration(milliseconds: 500),
                duration: const Duration(milliseconds: 800)),

            // Ready for quiz indicator
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 8, bottom: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.limeGreen.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.limeGreen.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.quiz,
                      color: AppColors.limeGreen,
                      size: 20,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Ready for the milestones?',
                      style: TextStyle(
                        color: AppColors.limeGreen,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(
                delay: const Duration(milliseconds: 700),
                duration: const Duration(milliseconds: 600)),
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
