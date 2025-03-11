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
      backgroundColor: AppColors.navyBlue,
      appBar: storyAsync.when(
        data: (story) => AppBar(
          backgroundColor: AppColors.navyBlue,
          elevation: 0,
          centerTitle: true,
          title: Text(
            story.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.headphones, color: Colors.white),
              onPressed: () {
                // Audio functionality
              },
            ),
          ],
        ),
        loading: () => AppBar(
          backgroundColor: AppColors.navyBlue,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'Loading...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.pop(),
          ),
        ),
        error: (_, __) => AppBar(
          backgroundColor: AppColors.navyBlue,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'Story Details',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.pop(),
          ),
        ),
      ),
      body: storyAsync.when(
        data: (story) {
          final isVideo = story.mediaType == 'video';
          final pageController = PageController();
          final currentPage = ValueNotifier<int>(0);

          // Calculate number of pages based on content length
          final contentLength = story.content.length;
          final pageCount = (contentLength / 1000).ceil().clamp(1, 10);

          return Column(
            children: [
              // Page indicators
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: ValueListenableBuilder<int>(
                  valueListenable: currentPage,
                  builder: (context, value, child) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        pageCount,
                        (index) => Container(
                          width: index == value ? 24 : 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: index == value
                                ? Colors.white
                                : Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Main content
              Expanded(
                child: PageView(
                  controller: pageController,
                  onPageChanged: (index) {
                    currentPage.value = index;
                  },
                  children: [
                    for (int i = 0; i < pageCount; i++)
                      _ContentPage(
                        story: story,
                        isVideo: isVideo,
                        pageIndex: i,
                      ),
                  ],
                ),
              ),

              // Bottom navigation buttons
              Padding(
                padding: const EdgeInsets.all(16),
                child: ValueListenableBuilder<int>(
                  valueListenable: currentPage,
                  builder: (context, pageValue, child) {
                    final isLastPage = pageValue == pageCount - 1;

                    return Row(
                      children: [
                        // Bookmark button
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
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
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
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

                        // Next button or Take Quiz button on last page
                        Expanded(
                          child: isLastPage
                              ? quizAsync.when(
                                  data: (quiz) {
                                    // Show Take Quiz button if quiz is available
                                    if (quiz != null) {
                                      return GestureDetector(
                                        onTap: () {
                                          // Navigate to quiz with the story ID, not the quiz ID
                                          context.push('/quiz/$storyId');
                                        },
                                        child: Container(
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: AppColors.limeGreen,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Center(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const Icon(
                                                  Icons.quiz_outlined,
                                                  color: AppColors.navyBlue,
                                                  size: 20,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  'Take Quiz',
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
                                      );
                                    } else {
                                      // If no quiz, show a finish button
                                      return GestureDetector(
                                        onTap: () => context.pop(),
                                        child: Container(
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: AppColors.limeGreen,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Center(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const Icon(
                                                  Icons.check,
                                                  color: AppColors.navyBlue,
                                                  size: 20,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  'Finish',
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
                                      );
                                    }
                                  },
                                  loading: () => Container(
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: AppColors.limeGreen,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Center(
                                      child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  AppColors.navyBlue),
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                  error: (_, __) => GestureDetector(
                                    onTap: () => context.pop(),
                                    child: Container(
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: AppColors.limeGreen,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: Text(
                                          'Finish',
                                          style: TextStyle(
                                            color: AppColors.navyBlue,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : GestureDetector(
                                  onTap: () {
                                    pageController.nextPage(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    );
                                  },
                                  child: Container(
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: AppColors.limeGreen,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Next',
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
                      ],
                    );
                  },
                ),
              ),
            ],
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
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class _ContentPage extends StatelessWidget {
  final Story story;
  final bool isVideo;
  final int pageIndex;

  const _ContentPage({
    required this.story,
    required this.isVideo,
    required this.pageIndex,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // Calculate content for this page
    final contentChunkSize = 1000; // Approximate characters per page
    final startIndex = pageIndex * contentChunkSize;
    final endIndex = (pageIndex + 1) * contentChunkSize;
    final pageContent = story.content.length > startIndex
        ? story.content.substring(
            startIndex,
            endIndex < story.content.length ? endIndex : story.content.length,
          )
        : '';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Media (Image or Video)
          if (pageIndex == 0) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                width: size.width - 48,
                height: (size.width - 48) * 0.6,
                child: isVideo
                    ? _VideoPlayer(videoUrl: story.mediaUrl)
                    : CachedNetworkImage(
                        imageUrl: story.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[800],
                          child: const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.limeGreen),
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
            const SizedBox(height: 16),
          ],

          // Content
          Text(
            pageIndex == 0 ? story.description : '',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
              fontWeight: FontWeight.w400,
              height: 1.4,
            ),
          ),

          // Display story date if available
          if (pageIndex == 0 &&
              story.storyDate != null &&
              story.storyDate!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: AppColors.limeGreen,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDate(story.storyDate!),
                  style: TextStyle(
                    color: AppColors.limeGreen,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 16),

          Text(
            pageContent,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.6,
              letterSpacing: 0.3,
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // Helper method to format the date from "YYYY-MM-DD" to a more readable format
  String _formatDate(String dateString) {
    try {
      final parts = dateString.split('-');
      if (parts.length == 3) {
        final year = parts[0];
        final month = _getMonthName(int.parse(parts[1]));
        final day = int.parse(parts[2]);

        return '$month $day, $year';
      }
      return dateString;
    } catch (e) {
      print('Error formatting date: $e');
      return dateString;
    }
  }

  // Helper method to convert month number to name
  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    if (month >= 1 && month <= 12) {
      return months[month - 1];
    }
    return '';
  }
}

class _VideoPlayer extends HookWidget {
  final String videoUrl;

  const _VideoPlayer({required this.videoUrl});

  @override
  Widget build(BuildContext context) {
    final videoPlayerController = useState<VideoPlayerController?>(null);
    final isInitialized = useState(false);
    final isPlaying = useState(false);
    final hasError = useState(false);
    final errorMessage = useState<String>('');

    // Initialize the video controller
    useEffect(() {
      // Check if the URL is valid
      if (videoUrl.isEmpty) {
        hasError.value = true;
        errorMessage.value = 'Video URL is empty';
        return null;
      }

      print('Initializing video with URL: $videoUrl');

      try {
        final controller =
            VideoPlayerController.networkUrl(Uri.parse(videoUrl));
        videoPlayerController.value = controller;

        controller.initialize().then((_) {
          print('Video initialized successfully');
          isInitialized.value = true;
          // Auto-play once initialized (optional)
          // controller.play();
          // isPlaying.value = true;
        }).catchError((error) {
          print('Error initializing video: $error');
          hasError.value = true;
          errorMessage.value = 'Failed to load video: $error';
        });

        return () {
          controller.dispose();
        };
      } catch (e) {
        print('Exception creating video controller: $e');
        hasError.value = true;
        errorMessage.value = 'Invalid video URL: $e';
        return null;
      }
    }, [videoUrl]);

    // If there's an error, show error message
    if (hasError.value) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 40),
              const SizedBox(height: 16),
              Text(
                'Video Error',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  errorMessage.value,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // If not initialized yet, show loading
    if (!isInitialized.value || videoPlayerController.value == null) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              SizedBox(height: 16),
              Text(
                'Loading video...',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    // Get the controller for easier access
    final controller = videoPlayerController.value!;

    // Use a fixed aspect ratio if the video's aspect ratio is invalid
    final aspectRatio = controller.value.aspectRatio <= 0 ||
            controller.value.aspectRatio.isNaN ||
            controller.value.aspectRatio.isInfinite
        ? 16 / 9 // Default 16:9 aspect ratio
        : controller.value.aspectRatio;

    return Container(
      color: Colors.black,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Video player with fixed size container
          SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.contain,
              child: SizedBox(
                width: controller.value.size.width,
                height: controller.value.size.height,
                child: VideoPlayer(controller),
              ),
            ),
          ),

          // Play/pause button overlay
          GestureDetector(
            onTap: () {
              if (controller.value.isPlaying) {
                controller.pause();
                isPlaying.value = false;
              } else {
                controller.play();
                isPlaying.value = true;
              }
            },
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isPlaying.value ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),

          // Video progress indicator
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: VideoProgressIndicator(
              controller,
              allowScrubbing: true,
              colors: const VideoProgressColors(
                playedColor: AppColors.limeGreen,
                bufferedColor: Colors.white30,
                backgroundColor: Colors.grey,
              ),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            ),
          ),
        ],
      ),
    );
  }
}
