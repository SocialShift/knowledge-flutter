import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:knowledge/core/themes/app_theme.dart';
import 'package:knowledge/data/models/timeline.dart';
import 'package:knowledge/data/repositories/timeline_repository.dart';
import 'package:flutter_animate/flutter_animate.dart';

class QuizSubmitScreen extends HookConsumerWidget {
  final String storyId;
  final String quizId;

  const QuizSubmitScreen({
    super.key,
    required this.storyId,
    required this.quizId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fetch the completed story to get its timelineId
    final storyAsync = ref.watch(storyDetailProvider(storyId));

    // Override back button to go to home
    return WillPopScope(
      onWillPop: () async {
        context.go('/home');
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.navyBlue,
        body: SafeArea(
          child: Column(
            children: [
              // Close button in top-left
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GestureDetector(
                    onTap: () => context.go('/home'),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(8.0),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),

              // Main content
              Expanded(
                child: storyAsync.when(
                  data: (story) {
                    // If we have the story's timelineId, fetch the timeline's stories
                    final timelineId = story.timelineId;

                    if (timelineId == null) {
                      // If no timelineId is available, just show the congratulations without next story options
                      return _buildCongratulationsContent(context, null, story);
                    }

                    // Fetch all stories for this timeline to find the next one
                    final timelineStoriesAsync =
                        ref.watch(timelineStoriesProvider(timelineId));

                    return timelineStoriesAsync.when(
                      data: (stories) {
                        // Find the index of the current story
                        final currentIndex =
                            stories.indexWhere((s) => s.id == storyId);

                        // Find the next story if one exists
                        Story? nextStory;
                        if (currentIndex != -1 &&
                            currentIndex < stories.length - 1) {
                          nextStory = stories[currentIndex + 1];
                        }

                        return _buildCongratulationsContent(
                            context, nextStory, story);
                      },
                      loading: () => const Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      error: (error, stack) => Center(
                        child: Text(
                          'Error loading next story: $error',
                          style: const TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  error: (error, stack) => Center(
                    child: Text(
                      'Error loading story: $error',
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCongratulationsContent(
      BuildContext context, Story? nextStory, Story story) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            // Trophy icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.yellow.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.emoji_events,
                size: 70,
                color: Colors.yellow.shade700,
              ),
            ).animate().scale(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.elasticOut,
                ),

            const SizedBox(height: 24),

            // Congratulations text
            const Text(
              'Congratulations!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ).animate().fadeIn(
                  duration: const Duration(milliseconds: 400),
                ),

            const SizedBox(height: 12),

            // Description text
            Text(
              'You have successfully completed all milestones for this story.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.9),
                height: 1.4,
              ),
            ).animate().fadeIn(
                  delay: const Duration(milliseconds: 200),
                  duration: const Duration(milliseconds: 400),
                ),

            const SizedBox(height: 50),

            // White card section at the bottom
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header showing remaining plays
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      '${story.title} completed',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ),

                  const Divider(height: 1),

                  // Next story to play (if available)
                  if (nextStory != null)
                    InkWell(
                      onTap: () => context.push('/story/${nextStory.id}'),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.orange.shade200,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.play_arrow,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Next story',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    nextStory.title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    InkWell(
                      onTap: () {
                        // Navigate to elearning screen instead of timeline detail
                        context.go('/elearning');
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.auto_stories,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Continue learning',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Explore more timelines',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            )
                .animate()
                .slideY(
                  begin: 0.2,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutQuad,
                )
                .fadeIn(),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
