import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:knowledge/data/models/timeline.dart';
import 'package:knowledge/data/repositories/timeline_repository.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:knowledge/core/themes/app_theme.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:io' show Platform;

class StoryDetailScreen extends HookConsumerWidget {
  final String storyId;

  const StoryDetailScreen({
    super.key,
    required this.storyId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get theme colors
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDarkMode ? AppColors.darkBackground : Colors.white;
    final textColor = isDarkMode ? Colors.white : AppColors.navyBlue;

    // Fetch story details using the provider
    final storyAsync = ref.watch(storyDetailProvider(storyId));

    // State for navigation between video and story parts
    final currentPart = useState(0); // 0 = video part, 1 = story part

    return Scaffold(
      backgroundColor: backgroundColor,
      body: storyAsync.when(
        data: (story) {
          final hasVideo =
              story.mediaUrl.isNotEmpty && !_isImageUrl(story.mediaUrl);

          // If no video, skip directly to story part
          if (!hasVideo && currentPart.value == 0) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              currentPart.value = 1;
            });
          }

          return Stack(
            children: [
              // Main content based on current part
              if (currentPart.value == 0 && hasVideo)
                _VideoPartScreen(
                  story: story,
                  hasVideo: hasVideo,
                  onContinue: () => currentPart.value = 1,
                  onBack: () => context.pop(),
                )
              else
                _StoryPartScreen(
                  story: story,
                  onBack: hasVideo
                      ? () =>
                          currentPart.value = 0 // Go back to video if it exists
                      : () => context
                          .pop(), // Go back to previous screen if no video
                  onMilestones: () => context.push('/quiz/$storyId'),
                  hasVideo: hasVideo, // Pass hasVideo information
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
              style: TextStyle(color: textColor),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to check if the URL points to an image file
  bool _isImageUrl(String url) {
    final imageExtensions = ['.png', '.jpg', '.jpeg', '.gif', '.webp', '.bmp'];
    final lowercaseUrl = url.toLowerCase();
    return imageExtensions.any((ext) => lowercaseUrl.endsWith(ext));
  }

  // Helper method to format duration
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return duration.inHours > 0
        ? "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds"
        : "$twoDigitMinutes:$twoDigitSeconds";
  }

  // Helper method to calculate reading time
  int _calculateReadingTime(String text) {
    // Average reading speed: 200 words per minute
    final wordCount = text.split(' ').length;
    final minutes = (wordCount / 200).ceil();
    return minutes > 0 ? minutes : 1; // Minimum 1 minute
  }
}

// Video Part Screen - Shows video with bottom card containing timestamps, title, views
class _VideoPartScreen extends HookConsumerWidget {
  final Story story;
  final bool hasVideo;
  final VoidCallback onContinue;
  final VoidCallback onBack;

  const _VideoPartScreen({
    required this.story,
    required this.hasVideo,
    required this.onContinue,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final videoControllerRef = useState<VideoPlayerController?>(null);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Video Player (40% of screen with 1:1 aspect ratio)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.4,
            child: Center(
              child: AspectRatio(
                aspectRatio: 1.0, // 1:1 aspect ratio
                child: Transform.scale(
                  scale: 1.2, // Zoom the video
                  child: hasVideo
                      ? _AutoPlayVideoWidget(
                          story: story,
                          onControllerReady: (controller) {
                            videoControllerRef.value = controller;
                          },
                        )
                      : Container(
                          color: Colors.black,
                          child: const Center(
                            child: Icon(
                              Icons.play_circle_outline,
                              color: Colors.white54,
                              size: 80,
                            ),
                          ),
                        ),
                ),
              ),
            ),
          ).animate().fadeIn(duration: 800.ms, delay: 200.ms).slideY(
              begin: -0.3,
              end: 0,
              duration: 1000.ms,
              curve: Curves.easeOutCubic),

          // Back button overlay
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            child: GestureDetector(
              onTap: onBack,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ).animate().fadeIn(duration: 600.ms, delay: 400.ms).scale(
              begin: const Offset(0.8, 0.8),
              duration: 600.ms,
              curve: Curves.elasticOut),

          // Static Bottom Card (60% of screen)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.6,
            child: Container(
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.darkSurface : Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Handle bar
                  // Container(
                  //   width: 40,
                  //   height: 4,
                  //   margin: const EdgeInsets.only(top: 12),
                  //   decoration: BoxDecoration(
                  //     color: Colors.grey.withOpacity(0.3),
                  //     borderRadius: BorderRadius.circular(2),
                  //   ),
                  // ),

                  // Fixed Header Section (Title, Views, Year)
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Story Title
                        Text(
                          story.title,
                          style: TextStyle(
                            color:
                                isDarkMode ? Colors.white : AppColors.navyBlue,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Views and Year
                        Row(
                          children: [
                            Icon(
                              Icons.visibility,
                              color: Colors.grey,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${story.views} views',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(
                              Icons.calendar_today,
                              color: Colors.grey,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${story.year}',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Timestamps Label
                        Text(
                          'Timestamps',
                          style: TextStyle(
                            color:
                                isDarkMode ? Colors.white : AppColors.navyBlue,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Scrollable Timestamps Section
                  Expanded(
                    child: story.timestamps.isNotEmpty
                        ? ListView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 90),
                            itemCount: story.timestamps.length,
                            itemBuilder: (context, index) {
                              final timestamp = story.timestamps[index];
                              return GestureDetector(
                                onTap: () {
                                  // Seek to timestamp in video
                                  if (videoControllerRef.value != null &&
                                      videoControllerRef
                                          .value!.value.isInitialized) {
                                    videoControllerRef.value!.seekTo(
                                        Duration(seconds: timestamp.timeSec));
                                    videoControllerRef.value!.play();
                                  }
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isDarkMode
                                        ? Colors.white.withOpacity(0.05)
                                        : Colors.grey.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color:
                                          AppColors.limeGreen.withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.limeGreen
                                              .withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          _formatDuration(Duration(
                                              seconds: timestamp.timeSec)),
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          timestamp.label,
                                          style: TextStyle(
                                            color: isDarkMode
                                                ? Colors.white
                                                : AppColors.navyBlue,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        Icons.play_circle_outline,
                                        color: AppColors.limeGreen,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              )
                                  .animate()
                                  .fadeIn(
                                      duration: 500.ms,
                                      delay: (800 + index * 100).ms)
                                  .slideX(
                                      begin: 0.3,
                                      duration: 600.ms,
                                      curve: Curves.easeOutCubic);
                            },
                          )
                        : Container(
                            padding: const EdgeInsets.all(20),
                            child: Center(
                              child: Text(
                                'No timestamps available',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          )
              .animate()
              .slideY(
                  begin: 1.0,
                  duration: 1000.ms,
                  curve: Curves.easeOutCubic,
                  delay: 600.ms)
              .fadeIn(duration: 800.ms, delay: 600.ms),

          // Fixed Continue Button with opaque background
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? AppColors.darkSurface.withOpacity(0.95)
                    : Colors.white.withOpacity(0.95),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Container(
                height: 50,
                child: ElevatedButton(
                  onPressed: onContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.limeGreen,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'CONTINUE',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
            ),
          )
              .animate()
              .slideY(
                  begin: 1.0,
                  duration: 800.ms,
                  curve: Curves.easeOutBack,
                  delay: 1200.ms)
              .fadeIn(duration: 600.ms, delay: 1200.ms),
        ],
      ),
    );
  }

  // Helper method to format duration
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return duration.inHours > 0
        ? "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds"
        : "$twoDigitMinutes:$twoDigitSeconds";
  }
}

// Story Part Screen - Shows thumbnail and story description
class _StoryPartScreen extends HookConsumerWidget {
  final Story story;
  final VoidCallback onBack;
  final VoidCallback onMilestones;
  final bool hasVideo;

  const _StoryPartScreen({
    required this.story,
    required this.onBack,
    required this.onMilestones,
    required this.hasVideo,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Split story content into paragraphs
    final storyContent =
        story.content.isNotEmpty ? story.content : story.description;
    final paragraphs =
        storyContent.split('\n').where((p) => p.trim().isNotEmpty).toList();

    // Current paragraph index
    final currentParagraphIndex = useState(0);

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : AppColors.offWhite,
      body: Stack(
        children: [
          // Thumbnail Image (40% of screen with 1:1 aspect ratio)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.4,
            child: Center(
              child: AspectRatio(
                aspectRatio: 1.0, // 1:1 aspect ratio
                child: Transform.scale(
                  scale: 1.2, // Zoom the image
                  child: CachedNetworkImage(
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
                      child: const Icon(Icons.error,
                          color: Colors.white, size: 48),
                    ),
                  ),
                ),
              ),
            ),
          )
              .animate()
              .fadeIn(duration: 800.ms, delay: 1800.ms)
              .scale(
                begin: const Offset(0.6, 0.6),
                end: const Offset(1.0, 1.0),
                duration: 1500.ms,
                curve: Curves.elasticOut,
                delay: 1800.ms,
              )
              .then()
              .shimmer(
                duration: 2000.ms,
                color: Colors.white.withOpacity(0.2),
                delay: 800.ms,
              ),

          // Back button overlay with white background
          // Positioned(
          //   top: MediaQuery.of(context).padding.top + 10,
          //   left: 16,
          //   child: GestureDetector(
          //     onTap: onBack,
          //     child: Container(
          //       padding: const EdgeInsets.all(8),
          //       decoration: BoxDecoration(
          //         color: Colors.white, // White background
          //         shape: BoxShape.circle,
          //         boxShadow: [
          //           BoxShadow(
          //             color: Colors.black.withOpacity(0.2),
          //             blurRadius: 4,
          //             offset: const Offset(0, 2),
          //           ),
          //         ],
          //       ),
          //       child: const Icon(
          //         Icons.arrow_back,
          //         color: Colors.black, // Black icon on white background
          //         size: 24,
          //       ),
          //     ),
          //   ),
          // ).animate().fadeIn(duration: 600.ms, delay: 400.ms).scale(
          //     begin: const Offset(0.8, 0.8),
          //     duration: 600.ms,
          //     curve: Curves.elasticOut),

          // Static Bottom Card (60% of screen)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.6,
            child: Container(
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.darkSurface : Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Handle bar
                  // Container(
                  //   width: 40,
                  //   height: 4,
                  //   margin: const EdgeInsets.only(top: 12),
                  //   decoration: BoxDecoration(
                  //     color: Colors.grey.withOpacity(0.3),
                  //     borderRadius: BorderRadius.circular(2),
                  //   ),
                  // ).animate().fadeIn(duration: 600.ms, delay: 2200.ms).scale(
                  //       begin: const Offset(0.3, 1.0),
                  //       duration: 800.ms,
                  //       curve: Curves.elasticOut,
                  //     ),

                  // Fixed Header Section (Title, Year, Read Time, Progress)
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Story Title
                        Text(
                          story.title,
                          style: TextStyle(
                            color:
                                isDarkMode ? Colors.white : AppColors.navyBlue,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 800.ms, delay: 2400.ms)
                            .slideX(
                              begin: -0.4,
                              duration: 1000.ms,
                              curve: Curves.easeOutCubic,
                            )
                            .then()
                            .shimmer(
                              duration: 1500.ms,
                              color: AppColors.limeGreen.withOpacity(0.4),
                              delay: 500.ms,
                            ),

                        const SizedBox(height: 12),

                        // Story metadata
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.limeGreen.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${story.year}',
                                style: const TextStyle(
                                  color: AppColors.navyBlue,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                                .animate()
                                .fadeIn(duration: 600.ms, delay: 2600.ms)
                                .scale(
                                  begin: const Offset(0.8, 0.8),
                                  duration: 600.ms,
                                  curve: Curves.elasticOut,
                                ),
                            const SizedBox(width: 12),
                            Text(
                              '${_calculateReadingTime(storyContent)} min read',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            )
                                .animate()
                                .fadeIn(duration: 600.ms, delay: 2700.ms)
                                .slideX(
                                  begin: -0.3,
                                  duration: 600.ms,
                                  curve: Curves.easeOutCubic,
                                ),
                            const Spacer(),
                            // Paragraph indicator
                            Text(
                              '${currentParagraphIndex.value + 1}/${paragraphs.length}',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            )
                                .animate()
                                .fadeIn(duration: 600.ms, delay: 2800.ms)
                                .slideX(
                                  begin: 0.3,
                                  duration: 600.ms,
                                  curve: Curves.easeOutCubic,
                                ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Scrollable Story Content Section
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 90),
                      child: Column(
                        children: [
                          // Current Paragraph Content
                          if (paragraphs.isNotEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isDarkMode
                                    ? Colors.white.withOpacity(0.05)
                                    : Colors.grey.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.limeGreen.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                paragraphs[currentParagraphIndex.value],
                                style: TextStyle(
                                  color: isDarkMode
                                      ? Colors.white
                                      : AppColors.navyBlue,
                                  fontSize: 16,
                                  height: 1.6,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            )
                                .animate()
                                .fadeIn(duration: 800.ms, delay: 2900.ms)
                                .slideY(
                                  begin: 0.5,
                                  duration: 1000.ms,
                                  curve: Curves.easeOutCubic,
                                )
                                .then()
                                .shimmer(
                                  duration: 2000.ms,
                                  color: AppColors.limeGreen.withOpacity(0.1),
                                  delay: 1000.ms,
                                ),

                          // Story completed message (only on last slide)
                          if (currentParagraphIndex.value ==
                              paragraphs.length - 1) ...[
                            const SizedBox(height: 20),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.limeGreen.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.limeGreen.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: AppColors.limeGreen,
                                    size: 32,
                                  )
                                      .animate()
                                      .fadeIn(duration: 600.ms, delay: 1500.ms)
                                      .scale(
                                        begin: const Offset(0.5, 0.5),
                                        duration: 800.ms,
                                        curve: Curves.elasticOut,
                                      )
                                      .then()
                                      .shake(duration: 500.ms, hz: 3),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Story Complete!',
                                    style: TextStyle(
                                      color: AppColors.limeGreen,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                      .animate()
                                      .fadeIn(duration: 600.ms, delay: 1700.ms)
                                      .slideY(
                                        begin: 0.3,
                                        duration: 600.ms,
                                        curve: Curves.easeOutBack,
                                      ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Ready for the milestones?',
                                    style: TextStyle(
                                      color: isDarkMode
                                          ? Colors.white70
                                          : Colors.black54,
                                      fontSize: 14,
                                    ),
                                  )
                                      .animate()
                                      .fadeIn(duration: 600.ms, delay: 1800.ms)
                                      .slideY(
                                        begin: 0.3,
                                        duration: 600.ms,
                                        curve: Curves.easeOutBack,
                                      ),
                                ],
                              ),
                            )
                                .animate()
                                .fadeIn(duration: 800.ms, delay: 1400.ms)
                                .scale(
                                  begin: const Offset(0.8, 0.8),
                                  duration: 1000.ms,
                                  curve: Curves.elasticOut,
                                )
                                .then()
                                .shimmer(
                                  duration: 2000.ms,
                                  color: AppColors.limeGreen.withOpacity(0.3),
                                ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
              .animate()
              .slideY(
                  begin: 1.0,
                  duration: 1200.ms,
                  curve: Curves.easeOutCubic,
                  delay: 500.ms)
              .fadeIn(duration: 800.ms, delay: 500.ms),

          // Fixed Action Buttons with opaque background
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? AppColors.darkSurface.withOpacity(0.95)
                    : Colors.white.withOpacity(0.95),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        if (currentParagraphIndex.value > 0) {
                          // Go to previous paragraph
                          currentParagraphIndex.value--;
                        } else {
                          // Go back to video screen or previous screen
                          onBack();
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (currentParagraphIndex.value > 0) ...[
                            const Icon(
                              Icons.arrow_back,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            currentParagraphIndex.value > 0
                                ? 'Previous'
                                : 'Back',
                            style: TextStyle(
                              color: isDarkMode
                                  ? Colors.white
                                  : AppColors.navyBlue,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(duration: 600.ms, delay: 3200.ms).slideX(
                        begin: -0.5,
                        duration: 800.ms,
                        curve: Curves.easeOutBack,
                      ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          currentParagraphIndex.value < paragraphs.length - 1
                              ? () {
                                  currentParagraphIndex.value++;
                                }
                              : onMilestones,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.limeGreen,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            currentParagraphIndex.value < paragraphs.length - 1
                                ? 'Continue'
                                : 'Milestones',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (currentParagraphIndex.value <
                              paragraphs.length - 1) ...[
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.arrow_forward,
                              size: 16,
                              color: Colors.black,
                            ),
                          ],
                        ],
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 600.ms, delay: 3300.ms)
                      .slideX(
                        begin: 0.5,
                        duration: 800.ms,
                        curve: Curves.easeOutBack,
                      )
                      .then()
                      .shimmer(
                        duration: 2000.ms,
                        color: Colors.white.withOpacity(0.4),
                        delay: 1000.ms,
                      ),
                ],
              ),
            ),
          )
              .animate()
              .slideY(
                  begin: 1.0,
                  duration: 1000.ms,
                  curve: Curves.easeOutBack,
                  delay: 3000.ms)
              .fadeIn(duration: 800.ms, delay: 3000.ms),
        ],
      ),
    );
  }

  // Helper method to calculate reading time
  int _calculateReadingTime(String text) {
    final wordCount = text.split(' ').length;
    final minutes = (wordCount / 200).ceil();
    return minutes > 0 ? minutes : 1;
  }
}

// Auto-playing Video Widget
class _AutoPlayVideoWidget extends HookConsumerWidget {
  final Story story;
  final Function(VideoPlayerController?) onControllerReady;

  const _AutoPlayVideoWidget(
      {required this.story, required this.onControllerReady});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final videoControllerRef = useState<VideoPlayerController?>(null);
    final chewieControllerRef = useState<ChewieController?>(null);
    final isBuffering = useState(true);
    final errorMessage = useState<String?>(null);

    useEffect(() {
      if (story.mediaUrl.isEmpty) {
        errorMessage.value = "No video available";
        isBuffering.value = false;
        return null;
      }

      final controller = VideoPlayerController.networkUrl(
        Uri.parse(story.mediaUrl),
        httpHeaders: {
          'User-Agent': Platform.isIOS
              ? 'Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1'
              : 'Mozilla/5.0 (Linux; Android 11; SM-G975F)',
        },
      );

      videoControllerRef.value = controller;

      controller.initialize().then((_) {
        if (controller.value.hasError) {
          errorMessage.value = "Failed to load video";
          isBuffering.value = false;
          return;
        }

        chewieControllerRef.value = ChewieController(
          videoPlayerController: controller,
          aspectRatio: controller.value.aspectRatio,
          autoPlay: true, // Auto-play as requested
          looping: true,
          materialProgressColors: ChewieProgressColors(
            playedColor: AppColors.limeGreen,
            handleColor: AppColors.limeGreen,
            backgroundColor: Colors.white24,
            bufferedColor: Colors.white38,
          ),
          allowFullScreen: true,
          showControls: true,
          allowPlaybackSpeedChanging: false,
        );
        isBuffering.value = false;
        onControllerReady(controller);
      }).catchError((error) {
        errorMessage.value = "Unable to load video";
        isBuffering.value = false;
      });

      return () {
        chewieControllerRef.value?.dispose();
        videoControllerRef.value?.dispose();
      };
    }, [story.mediaUrl]);

    if (errorMessage.value != null) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.white70,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                errorMessage.value!,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (isBuffering.value) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.limeGreen),
          ),
        ),
      );
    }

    return chewieControllerRef.value != null
        ? Chewie(controller: chewieControllerRef.value!)
        : Container(color: Colors.black);
  }
}
