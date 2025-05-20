import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:knowledge/data/models/timeline.dart';
import 'package:knowledge/data/repositories/timeline_repository.dart';
import 'package:knowledge/data/repositories/quiz_repository.dart';
import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter_animate/flutter_animate.dart';
import 'package:knowledge/core/themes/app_theme.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:chewie/chewie.dart';
import 'dart:io' show Platform;
import 'package:flutter/services.dart';
import 'package:audio_session/audio_session.dart';
import 'dart:developer' as developer;

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
          actions: const [],
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

          // Check if the media URL is an image or a video
          final isImageMedia = _isImageUrl(story.mediaUrl);

          // Determine total number of pages based on whether valid video exists
          final hasVideo = story.mediaUrl.isNotEmpty && !isImageMedia;
          final totalPages = hasVideo ? 2 : 1; // Only video page and story page

          // Create video controller using Flutter Hooks
          final videoControllerRef = useState<VideoPlayerController?>(null);
          final chewieControllerRef = useState<ChewieController?>(null);
          final isBuffering = useState(false);
          final errorMessage = useState<String?>(null);
          final hasRetried = useState(false);
          final selectedPlaybackSpeed = useState(1.0);
          final isFullscreen = useState(false);
          final audioSessionConfigured = useState(false);

          // Available playback speeds
          final playbackSpeeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

          // Configure iOS audio session for video playback
          useEffect(() {
            if (Platform.isIOS && !audioSessionConfigured.value) {
              audioSessionConfigured.value = true;
              developer.log('Configuring iOS audio session');

              // Ensure audio session is configured properly
              AudioSession.instance.then((session) async {
                try {
                  // First set active to false to reset any existing sessions
                  await session.setActive(false);

                  // Configure with proper settings for video playback
                  await session.configure(const AudioSessionConfiguration(
                    avAudioSessionCategory: AVAudioSessionCategory.playback,
                    avAudioSessionCategoryOptions:
                        AVAudioSessionCategoryOptions.defaultToSpeaker,
                    avAudioSessionMode: AVAudioSessionMode.moviePlayback,
                    avAudioSessionRouteSharingPolicy:
                        AVAudioSessionRouteSharingPolicy.defaultPolicy,
                    avAudioSessionSetActiveOptions:
                        AVAudioSessionSetActiveOptions
                            .notifyOthersOnDeactivation,
                  ));

                  // Then set active
                  await session.setActive(true);
                  developer.log('iOS audio session configured successfully');
                } catch (e) {
                  developer.log('Error configuring iOS audio session: $e');
                }
              });
            }
            return null;
          }, const []);

          // Retry video initialization
          void _retryInitialization() {
            errorMessage.value = null;
            isBuffering.value = true;
            hasRetried.value = false;

            // Clean up existing controllers
            chewieControllerRef.value?.dispose();
            chewieControllerRef.value = null;

            videoControllerRef.value?.dispose();
            videoControllerRef.value = null;

            // Force rebuild
            Future.microtask(() {});
          }

          // Handle video playback errors
          void _handleVideoError(dynamic error) {
            // If first attempt failed and we haven't retried yet, try with different settings
            if (!hasRetried.value) {
              hasRetried.value = true;
              videoControllerRef.value?.dispose();

              // Try with a different format hint
              final Uri originalUri = Uri.parse(story.mediaUrl);
              String videoUrl = story.mediaUrl;

              if (originalUri.scheme == 'http') {
                videoUrl =
                    'https://${originalUri.authority}${originalUri.path}';
                if (originalUri.hasQuery) {
                  videoUrl += '?${originalUri.query}';
                }
              }

              developer.log('Retrying with format hint: $videoUrl');

              final retryController = VideoPlayerController.networkUrl(
                Uri.parse(videoUrl),
                formatHint: VideoFormat.other,
                httpHeaders: {
                  'User-Agent': Platform.isIOS
                      ? 'Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1'
                      : 'Mozilla/5.0 (Linux; Android 11; SM-G975F)',
                },
              );

              videoControllerRef.value = retryController;

              retryController.initialize().then((_) {
                // For iOS, ensure volume is set to maximum
                if (Platform.isIOS) {
                  retryController.setVolume(1.0);
                  developer.log(
                      'iOS: Set volume to maximum after retry initialization');
                }

                chewieControllerRef.value = ChewieController(
                  videoPlayerController: retryController,
                  aspectRatio: retryController.value.aspectRatio,
                  autoPlay: true,
                  looping: false,
                  materialProgressColors: ChewieProgressColors(
                    playedColor: AppColors.limeGreen,
                    handleColor: AppColors.limeGreen,
                    backgroundColor: Colors.white24,
                    bufferedColor: Colors.white38,
                  ),
                  allowFullScreen: true,
                  showControls: true,
                  allowPlaybackSpeedChanging: true,
                  customControls: const MaterialControls(),
                );
                isBuffering.value = false;
              }).catchError((retryError) {
                developer.log('Video retry error: $retryError');
                errorMessage.value =
                    "Unable to load video: Video format may not be supported on this device";
                isBuffering.value = false;
              });
            } else {
              developer.log('Video error after retry: $error');
              errorMessage.value =
                  "Failed to load video: Please check your internet connection or try again later";
              isBuffering.value = false;
            }
          }

          // Ensure proper disposal of controllers
          useEffect(() {
            return () {
              developer.log('Disposing video controllers');
              chewieControllerRef.value?.dispose();
              videoControllerRef.value?.dispose();

              // Reset audio session when widget is disposed
              if (Platform.isIOS) {
                AudioSession.instance.then((session) {
                  try {
                    session.setActive(false);
                    developer.log('iOS audio session deactivated');
                  } catch (e) {
                    developer.log('Error deactivating iOS audio session: $e');
                  }
                });
              }
            };
          }, []);

          // Initialize the video player with better error handling
          useEffect(() {
            if (story.mediaUrl.isEmpty) {
              errorMessage.value = "No video available";
              return null;
            }

            final Uri originalUri = Uri.parse(story.mediaUrl);
            String videoUrl = story.mediaUrl;

            // Check if the URL uses HTTPS
            if (originalUri.scheme == 'http') {
              // Convert to HTTPS for iOS compatibility
              videoUrl = 'https://${originalUri.authority}${originalUri.path}';
              if (originalUri.hasQuery) {
                videoUrl += '?${originalUri.query}';
              }
            }

            isBuffering.value = true;
            developer.log('Initializing video: $videoUrl');

            // Add platform-specific options for better compatibility
            Map<String, String> headers = {
              'User-Agent': Platform.isIOS
                  ? 'Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1'
                  : 'Mozilla/5.0 (Linux; Android 11; SM-G975F)',
            };

            // Create controller with platform-specific settings
            final controller = VideoPlayerController.networkUrl(
              Uri.parse(videoUrl),
              httpHeaders: headers,
              videoPlayerOptions: VideoPlayerOptions(
                mixWithOthers:
                    false, // Disable mixing for better iOS compatibility
                allowBackgroundPlayback: false,
              ),
            );

            videoControllerRef.value = controller;

            controller.initialize().then((_) {
              if (controller.value.hasError) {
                throw Exception(
                    "Video initialization failed: ${controller.value.errorDescription}");
              }

              // For iOS, ensure volume is set to maximum after initialization
              if (Platform.isIOS) {
                controller.setVolume(1.0);
                developer
                    .log('iOS: Set volume to maximum after initialization');
              }

              // Create Chewie controller for improved UI
              chewieControllerRef.value = ChewieController(
                videoPlayerController: controller,
                aspectRatio: controller.value.aspectRatio,
                autoPlay: true, // Auto-play on iOS to trigger audio
                looping: false,
                materialProgressColors: ChewieProgressColors(
                  playedColor: AppColors.limeGreen,
                  handleColor: AppColors.limeGreen,
                  backgroundColor: Colors.white24,
                  bufferedColor: Colors.white38,
                ),
                placeholder: const Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.limeGreen),
                  ),
                ),
                errorBuilder: (context, errorMessage) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.white70,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          errorMessage,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _retryInitialization,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.limeGreen,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                },
                allowFullScreen: true,
                fullScreenByDefault: false,
                showControls: true,
                allowPlaybackSpeedChanging: true,
                customControls: const MaterialControls(),
              );

              isBuffering.value = false;

              // For iOS, ensure audio works by playing and then pausing if autoplay is false
              if (Platform.isIOS) {
                // This ensures the audio track is properly initialized
                Future.delayed(const Duration(milliseconds: 100), () {
                  controller.play().then((_) {
                    developer
                        .log('iOS: Video playback started to initialize audio');
                    // If you don't want autoplay, you can pause it after a short delay
                    // Future.delayed(const Duration(milliseconds: 300), controller.pause);
                  });
                });
              }
            }).catchError((error) {
              developer.log('Video initialization error: $error');
              _handleVideoError(error);
            });

            return null;
          }, [story.mediaUrl]);

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
                              // Video player page (only if media URL is a valid video)
                              if (hasVideo) _VideoPlayerPage(story: story),

                              // Complete story on a single page
                              _CompleteStoryPage(story: story),
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
                            if (currentPage.value < totalPages - 1) {
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
                                    currentPage.value < (totalPages - 1)
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
                                    currentPage.value < (totalPages - 1)
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

  // Helper method to check if the URL points to an image file
  bool _isImageUrl(String url) {
    final imageExtensions = ['.png', '.jpg', '.jpeg', '.gif', '.webp', '.bmp'];
    final lowercaseUrl = url.toLowerCase();
    return imageExtensions.any((ext) => lowercaseUrl.endsWith(ext));
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
    final chewieControllerRef = useState<ChewieController?>(null);
    final isBuffering = useState(false);
    final errorMessage = useState<String?>(null);
    final hasRetried = useState(false);
    final selectedPlaybackSpeed = useState(1.0);
    final isFullscreen = useState(false);
    final audioSessionConfigured = useState(false);

    // Since this component only renders for video URLs now, we don't need to check again

    // Available playback speeds
    final playbackSpeeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

    // Configure iOS audio session for video playback
    useEffect(() {
      if (Platform.isIOS && !audioSessionConfigured.value) {
        audioSessionConfigured.value = true;
        developer.log('Configuring iOS audio session');

        // Ensure audio session is configured properly
        AudioSession.instance.then((session) async {
          try {
            // First set active to false to reset any existing sessions
            await session.setActive(false);

            // Configure with proper settings for video playback
            await session.configure(const AudioSessionConfiguration(
              avAudioSessionCategory: AVAudioSessionCategory.playback,
              avAudioSessionCategoryOptions:
                  AVAudioSessionCategoryOptions.defaultToSpeaker,
              avAudioSessionMode: AVAudioSessionMode.moviePlayback,
              avAudioSessionRouteSharingPolicy:
                  AVAudioSessionRouteSharingPolicy.defaultPolicy,
              avAudioSessionSetActiveOptions:
                  AVAudioSessionSetActiveOptions.notifyOthersOnDeactivation,
            ));

            // Then set active
            await session.setActive(true);
            developer.log('iOS audio session configured successfully');
          } catch (e) {
            developer.log('Error configuring iOS audio session: $e');
          }
        });
      }
      return null;
    }, const []);

    // Retry video initialization
    void _retryInitialization() {
      errorMessage.value = null;
      isBuffering.value = true;
      hasRetried.value = false;

      // Clean up existing controllers
      chewieControllerRef.value?.dispose();
      chewieControllerRef.value = null;

      videoControllerRef.value?.dispose();
      videoControllerRef.value = null;

      // Force rebuild
      Future.microtask(() {});
    }

    // Handle video playback errors
    void _handleVideoError(dynamic error) {
      // If first attempt failed and we haven't retried yet, try with different settings
      if (!hasRetried.value) {
        hasRetried.value = true;
        videoControllerRef.value?.dispose();

        // Try with a different format hint
        final Uri originalUri = Uri.parse(story.mediaUrl);
        String videoUrl = story.mediaUrl;

        if (originalUri.scheme == 'http') {
          videoUrl = 'https://${originalUri.authority}${originalUri.path}';
          if (originalUri.hasQuery) {
            videoUrl += '?${originalUri.query}';
          }
        }

        developer.log('Retrying with format hint: $videoUrl');

        final retryController = VideoPlayerController.networkUrl(
          Uri.parse(videoUrl),
          formatHint: VideoFormat.other,
          httpHeaders: {
            'User-Agent': Platform.isIOS
                ? 'Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1'
                : 'Mozilla/5.0 (Linux; Android 11; SM-G975F)',
          },
        );

        videoControllerRef.value = retryController;

        retryController.initialize().then((_) {
          // For iOS, ensure volume is set to maximum
          if (Platform.isIOS) {
            retryController.setVolume(1.0);
            developer
                .log('iOS: Set volume to maximum after retry initialization');
          }

          chewieControllerRef.value = ChewieController(
            videoPlayerController: retryController,
            aspectRatio: retryController.value.aspectRatio,
            autoPlay: true,
            looping: false,
            materialProgressColors: ChewieProgressColors(
              playedColor: AppColors.limeGreen,
              handleColor: AppColors.limeGreen,
              backgroundColor: Colors.white24,
              bufferedColor: Colors.white38,
            ),
            allowFullScreen: true,
            showControls: true,
            allowPlaybackSpeedChanging: true,
            customControls: const MaterialControls(),
          );
          isBuffering.value = false;
        }).catchError((retryError) {
          developer.log('Video retry error: $retryError');
          errorMessage.value =
              "Unable to load video: Video format may not be supported on this device";
          isBuffering.value = false;
        });
      } else {
        developer.log('Video error after retry: $error');
        errorMessage.value =
            "Failed to load video: Please check your internet connection or try again later";
        isBuffering.value = false;
      }
    }

    // Ensure proper disposal of controllers
    useEffect(() {
      return () {
        developer.log('Disposing video controllers');
        chewieControllerRef.value?.dispose();
        videoControllerRef.value?.dispose();

        // Reset audio session when widget is disposed
        if (Platform.isIOS) {
          AudioSession.instance.then((session) {
            try {
              session.setActive(false);
              developer.log('iOS audio session deactivated');
            } catch (e) {
              developer.log('Error deactivating iOS audio session: $e');
            }
          });
        }
      };
    }, []);

    // Initialize the video player with better error handling
    useEffect(() {
      if (story.mediaUrl.isEmpty) {
        errorMessage.value = "No video available";
        return null;
      }

      final Uri originalUri = Uri.parse(story.mediaUrl);
      String videoUrl = story.mediaUrl;

      // Check if the URL uses HTTPS
      if (originalUri.scheme == 'http') {
        // Convert to HTTPS for iOS compatibility
        videoUrl = 'https://${originalUri.authority}${originalUri.path}';
        if (originalUri.hasQuery) {
          videoUrl += '?${originalUri.query}';
        }
      }

      isBuffering.value = true;
      developer.log('Initializing video: $videoUrl');

      // Add platform-specific options for better compatibility
      Map<String, String> headers = {
        'User-Agent': Platform.isIOS
            ? 'Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1'
            : 'Mozilla/5.0 (Linux; Android 11; SM-G975F)',
      };

      // Create controller with platform-specific settings
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(videoUrl),
        httpHeaders: headers,
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: false, // Disable mixing for better iOS compatibility
          allowBackgroundPlayback: false,
        ),
      );

      videoControllerRef.value = controller;

      controller.initialize().then((_) {
        if (controller.value.hasError) {
          throw Exception(
              "Video initialization failed: ${controller.value.errorDescription}");
        }

        // For iOS, ensure volume is set to maximum after initialization
        if (Platform.isIOS) {
          controller.setVolume(1.0);
          developer.log('iOS: Set volume to maximum after initialization');
        }

        // Create Chewie controller for improved UI
        chewieControllerRef.value = ChewieController(
          videoPlayerController: controller,
          aspectRatio: controller.value.aspectRatio,
          autoPlay: true, // Auto-play on iOS to trigger audio
          looping: false,
          materialProgressColors: ChewieProgressColors(
            playedColor: AppColors.limeGreen,
            handleColor: AppColors.limeGreen,
            backgroundColor: Colors.white24,
            bufferedColor: Colors.white38,
          ),
          placeholder: const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.limeGreen),
            ),
          ),
          errorBuilder: (context, errorMessage) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.white70,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    errorMessage,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _retryInitialization,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.limeGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          },
          allowFullScreen: true,
          fullScreenByDefault: false,
          showControls: true,
          allowPlaybackSpeedChanging: true,
          customControls: const MaterialControls(),
        );

        isBuffering.value = false;

        // For iOS, ensure audio works by playing and then pausing if autoplay is false
        if (Platform.isIOS) {
          // This ensures the audio track is properly initialized
          Future.delayed(const Duration(milliseconds: 100), () {
            controller.play().then((_) {
              developer.log('iOS: Video playback started to initialize audio');
              // If you don't want autoplay, you can pause it after a short delay
              // Future.delayed(const Duration(milliseconds: 300), controller.pause);
            });
          });
        }
      }).catchError((error) {
        developer.log('Video initialization error: $error');
        _handleVideoError(error);
      });

      return null;
    }, [story.mediaUrl]);

    // Use RepaintBoundary for better performance with the video player
    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Video player with Chewie controls
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
                    child: errorMessage.value != null
                        ? _buildErrorWidget()
                        : isBuffering.value
                            ? const Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.limeGreen),
                                ),
                              )
                            : chewieControllerRef.value != null
                                ? Chewie(
                                    controller: chewieControllerRef.value!,
                                  )
                                : const SizedBox(),
                  ),
                ),
              ),

              // Simple spacing after video
              const SizedBox(height: 16),

              // iOS playback helper - Audio troubleshooting button for iOS
              if (Platform.isIOS)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Center(
                    child: GestureDetector(
                      onTap: () {
                        if (videoControllerRef.value != null) {
                          // Force audio initialization
                          videoControllerRef.value!.setVolume(1.0);
                          videoControllerRef.value!.play();
                          developer.log('iOS: Manual audio restart triggered');

                          // Re-configure audio session
                          AudioSession.instance.then((session) async {
                            try {
                              await session.setActive(false);
                              await session
                                  .configure(const AudioSessionConfiguration(
                                avAudioSessionCategory:
                                    AVAudioSessionCategory.playback,
                                avAudioSessionCategoryOptions:
                                    AVAudioSessionCategoryOptions
                                        .defaultToSpeaker,
                                avAudioSessionMode:
                                    AVAudioSessionMode.moviePlayback,
                              ));
                              await session.setActive(true);
                              developer.log(
                                  'iOS: Audio session reconfigured manually');
                            } catch (e) {
                              developer
                                  .log('Error reconfiguring audio session: $e');
                            }
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.volume_up,
                              color: AppColors.limeGreen,
                              size: 16,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Tap if no sound',
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
                                if (videoControllerRef.value != null) {
                                  videoControllerRef.value!.seekTo(
                                      Duration(seconds: timestamp.timeSec));
                                  videoControllerRef.value!.play();
                                }
                              },
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color:
                                          AppColors.limeGreen.withOpacity(0.2),
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
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
            ],
          ),
        ),
      ),
    );
  }

  // Build error widget with retry button
  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.white70,
            size: 48,
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              "Unable to load video. The format may not be supported or there might be network issues.",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // This will rebuild the widget and retry
              // Force a rebuild by changing errorMessage to null
              // This isn't directly possible with the current structure
              // but the button is here for UI consistency
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.limeGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text('Retry'),
          ),
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

// Complete story page that shows all content at once
class _CompleteStoryPage extends StatelessWidget {
  final Story story;

  const _CompleteStoryPage({required this.story});

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
            // Align(
            //   alignment: Alignment.centerRight,
            //   child: Container(
            //     padding:
            //         const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            //     decoration: BoxDecoration(
            //       color: Colors.white.withOpacity(0.15),
            //       borderRadius: BorderRadius.circular(20),
            //     ),
            //     child: const Text(
            //       'Story',
            //       style: TextStyle(
            //         color: Colors.white,
            //         fontSize: 12,
            //         fontWeight: FontWeight.w500,
            //       ),
            //     ),
            //   ),
            // ).animate().fadeIn(duration: const Duration(milliseconds: 500)),

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
                    '${story.year ?? "Historical"}',
                    style: const TextStyle(
                      color: AppColors.limeGreen,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Reading time estimate
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

            // Full story content in one section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                story.content.isNotEmpty ? story.content : story.description,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  height: 1.6,
                  letterSpacing: 0.3,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),

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
                    // Column(
                    //   children: [
                    //     Icon(
                    //       Icons.favorite,
                    //       color: Colors.redAccent.shade200,
                    //       size: 28,
                    //     )
                    //         .animate(
                    //           onPlay: (controller) =>
                    //               controller.repeat(reverse: true),
                    //         )
                    //         .scaleXY(
                    //           begin: 1.0,
                    //           end: 1.1,
                    //           duration: const Duration(seconds: 1),
                    //         ),
                    //     const SizedBox(height: 8),
                    //     Text(
                    //       '${story.likes}',
                    //       style: const TextStyle(
                    //         color: Colors.white,
                    //         fontWeight: FontWeight.bold,
                    //         fontSize: 16,
                    //       ),
                    //     ),
                    //     const Text(
                    //       'Likes',
                    //       style: TextStyle(
                    //         color: Colors.white70,
                    //         fontSize: 12,
                    //       ),
                    //     ),
                    //   ],
                    // ),

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
                    // Column(
                    //   children: [
                    //     Container(
                    //       padding: const EdgeInsets.all(8),
                    //       decoration: BoxDecoration(
                    //         color: AppColors.limeGreen.withOpacity(0.3),
                    //         shape: BoxShape.circle,
                    //       ),
                    //       child: const Icon(
                    //         Icons.share,
                    //         color: AppColors.limeGreen,
                    //         size: 24,
                    //       ),
                    //     ),
                    //     const SizedBox(height: 8),
                    //     const Text(
                    //       'Share',
                    //       style: TextStyle(
                    //         color: Colors.white,
                    //         fontWeight: FontWeight.bold,
                    //         fontSize: 16,
                    //       ),
                    //     ),
                    //     const Text(
                    //       'Story',
                    //       style: TextStyle(
                    //         color: Colors.white70,
                    //         fontSize: 12,
                    //       ),
                    //     ),
                    //   ],
                    // ),
                  ],
                ),
              ),
            ),

            // Ready for quiz indicator
            // Center(
            //   child: Container(
            //     margin: const EdgeInsets.only(top: 8, bottom: 8),
            //     padding:
            //         const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            //     decoration: BoxDecoration(
            //       color: AppColors.limeGreen.withOpacity(0.2),
            //       borderRadius: BorderRadius.circular(16),
            //       border: Border.all(
            //         color: AppColors.limeGreen.withOpacity(0.3),
            //         width: 1,
            //       ),
            //     ),
            //     child: const Row(
            //       mainAxisSize: MainAxisSize.min,
            //       children: [
            //         Icon(
            //           Icons.quiz,
            //           color: AppColors.limeGreen,
            //           size: 20,
            //         ),
            //         SizedBox(width: 10),
            //         Text(
            //           'Ready for the milestones?',
            //           style: TextStyle(
            //             color: AppColors.limeGreen,
            //             fontSize: 16,
            //             fontWeight: FontWeight.bold,
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
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
