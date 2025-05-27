import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:knowledge/core/themes/app_theme.dart';
import 'package:knowledge/data/models/timeline.dart';
import 'package:knowledge/data/repositories/timeline_repository.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;

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
        body: Stack(
          children: [
            // Animated background - covers entire screen
            Positioned.fill(
              child: _AnimatedBackground(),
            ),

            SafeArea(
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
                          return _buildCongratulationsContent(
                              context, null, story);
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
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
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
          ],
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

            // Enhanced Trophy icon with multiple animations and confetti
            Stack(
              alignment: Alignment.center,
              children: [
                // Multiple glow rings for depth
                ...List.generate(3, (ringIndex) {
                  return Container(
                    width: 180 + (ringIndex * 20),
                    height: 180 + (ringIndex * 20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.amber.withOpacity(0.15 - (ringIndex * 0.05)),
                          Colors.orange.withOpacity(0.1 - (ringIndex * 0.03)),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.6, 1.0],
                      ),
                    ),
                  ).animate(onPlay: (controller) => controller.repeat()).scale(
                        begin: const Offset(0.9, 0.9),
                        end: const Offset(1.1, 1.1),
                        duration:
                            Duration(milliseconds: 2500 + (ringIndex * 500)),
                        curve: Curves.easeInOut,
                      );
                }),

                // Main trophy container with enhanced design
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        Colors.amber.shade50,
                        Colors.amber.shade200,
                        Colors.orange.shade300,
                        Colors.orange.shade400,
                      ],
                      stops: const [0.0, 0.4, 0.7, 1.0],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.6),
                        blurRadius: 30,
                        spreadRadius: 8,
                      ),
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.4),
                        blurRadius: 50,
                        spreadRadius: 15,
                      ),
                      BoxShadow(
                        color: Colors.white.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                        offset: const Offset(-5, -5),
                      ),
                    ],
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.amber.shade100,
                        width: 3,
                      ),
                    ),
                    child: Icon(
                      Icons.emoji_events,
                      size: 80,
                      color: Colors.amber.shade800,
                    ),
                  ),
                )
                    .animate()
                    .scale(
                      duration: const Duration(milliseconds: 1000),
                      curve: Curves.elasticOut,
                    )
                    .then()
                    .shake(
                      duration: const Duration(milliseconds: 600),
                      hz: 2,
                    )
                    .then()
                    .shimmer(
                      duration: const Duration(milliseconds: 1500),
                      color: Colors.white.withOpacity(0.8),
                    ),

                // Enhanced sparkle particles with different sizes and colors
                // ...List.generate(12, (index) {
                //   final angle = (index * 30) * (math.pi / 180);
                //   final radius = 90.0 + (index % 3) * 15;
                //   final x = math.cos(angle) * radius;
                //   final y = math.sin(angle) * radius;
                //   final sparkleColors = [
                //     Colors.amber.shade300,
                //     Colors.yellow.shade200,
                //     Colors.orange.shade300,
                //     Colors.white,
                //   ];

                //   return Positioned(
                //     left: 90 + x,
                //     top: 90 + y,
                //     child: Icon(
                //       index % 4 == 0
                //           ? Icons.star
                //           : index % 4 == 1
                //               ? Icons.auto_awesome
                //               : index % 4 == 2
                //                   ? Icons.diamond
                //                   : Icons.circle,
                //       size: 12 + (index % 3) * 4,
                //       color: sparkleColors[index % sparkleColors.length],
                //     )
                //         .animate(
                //             onPlay: (controller) =>
                //                 controller.repeat(reverse: true))
                //         .fadeIn(
                //           duration: const Duration(milliseconds: 1000),
                //           delay: Duration(milliseconds: index * 150),
                //         )
                //         .then()
                //         .fadeOut(
                //           duration: const Duration(milliseconds: 1000),
                //         )
                //         .animate(onPlay: (controller) => controller.repeat())
                //         .rotate(
                //           duration:
                //               Duration(milliseconds: 3000 + (index * 200)),
                //         ),
                //   );
                // }),

                // Confetti particles falling from top
                // ...List.generate(8, (index) {
                //   return Positioned(
                //     left: 50 + (index * 25),
                //     top: -20,
                //     child: Container(
                //       width: 8,
                //       height: 8,
                //       decoration: BoxDecoration(
                //         color: [
                //           Colors.amber,
                //           Colors.orange,
                //           Colors.yellow,
                //           Colors.red.shade300,
                //         ][index % 4],
                //         borderRadius: BorderRadius.circular(2),
                //       ),
                //     )
                //         .animate(onPlay: (controller) => controller.repeat())
                //         .moveY(
                //           begin: -50,
                //           end: 300,
                //           duration:
                //               Duration(milliseconds: 2000 + (index * 300)),
                //           curve: Curves.easeInQuad,
                //         )
                //         .fadeIn(
                //           duration: const Duration(milliseconds: 500),
                //           delay: Duration(milliseconds: index * 200),
                //         ),
                //   );
                // }),
              ],
            ),

            // const SizedBox(height: 10),

            // Enhanced Congratulations text with multiple effects
            Column(
              children: [
                // Main congratulations text
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      Colors.amber.shade200,
                      Colors.white,
                      Colors.amber.shade200,
                      Colors.orange.shade200,
                      Colors.white,
                    ],
                    stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                  ).createShader(bounds),
                  child: const Text(
                    '🎉 Congratulations!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.5,
                      height: 1.2,
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(
                      duration: const Duration(milliseconds: 800),
                    )
                    .then()
                    .shimmer(
                      duration: const Duration(milliseconds: 2000),
                      color: Colors.white.withOpacity(0.8),
                    )
                    .animate()
                    .scale(
                      delay: const Duration(milliseconds: 200),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.elasticOut,
                    ),

                const SizedBox(height: 12),

                // Achievement badge
                // Container(
                //   padding:
                //       const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                //   decoration: BoxDecoration(
                //     gradient: LinearGradient(
                //       colors: [
                //         Colors.amber.withOpacity(0.2),
                //         Colors.orange.withOpacity(0.1),
                //       ],
                //     ),
                //     borderRadius: BorderRadius.circular(20),
                //     border: Border.all(
                //       color: Colors.amber.withOpacity(0.4),
                //       width: 1,
                //     ),
                //   ),
                //   child: Row(
                //     mainAxisSize: MainAxisSize.min,
                //     children: [
                //       Icon(
                //         Icons.verified,
                //         color: Colors.amber.shade300,
                //         size: 20,
                //       ),
                //       const SizedBox(width: 8),
                //       Text(
                //         'Story Master',
                //         style: TextStyle(
                //           color: Colors.amber.shade200,
                //           fontSize: 14,
                //           fontWeight: FontWeight.bold,
                //           letterSpacing: 0.5,
                //         ),
                //       ),
                //     ],
                //   ),
                // )
                //     .animate()
                //     .fadeIn(
                //       delay: const Duration(milliseconds: 600),
                //       duration: const Duration(milliseconds: 500),
                //     )
                //     .then()
                //     .slideX(
                //       begin: 0.3,
                //       duration: const Duration(milliseconds: 400),
                //       curve: Curves.easeOutBack,
                //     ),
              ],
            ),

            const SizedBox(height: 24),

            // Enhanced Description text with better styling
            // // Container(
            // //   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            // //   decoration: BoxDecoration(
            // //     gradient: LinearGradient(
            // //       begin: Alignment.topLeft,
            // //       end: Alignment.bottomRight,
            // //       colors: [
            // //         Colors.white.withOpacity(0.1),
            // //         Colors.white.withOpacity(0.05),
            // //       ],
            // //     ),
            // //     borderRadius: BorderRadius.circular(16),
            // //     border: Border.all(
            // //       color: Colors.white.withOpacity(0.2),
            // //       width: 1,
            // //     ),
            // //   ),
            // //   child: Column(
            // //     children: [
            // //       Icon(
            // //         Icons.auto_stories,
            // //         color: Colors.white.withOpacity(0.8),
            // //         size: 24,
            // //       ),
            // //       const SizedBox(height: 8),
            // //       Text(
            // //         'You have successfully completed all milestones for this story.',
            // //         textAlign: TextAlign.center,
            // //         style: TextStyle(
            // //           fontSize: 16,
            // //           color: Colors.white.withOpacity(0.9),
            // //           height: 1.5,
            // //           fontWeight: FontWeight.w500,
            // //         ),
            // //       ),
            // //       const SizedBox(height: 8),
            // //       Text(
            // //         'Your knowledge journey continues!',
            // //         textAlign: TextAlign.center,
            // //         style: TextStyle(
            // //           fontSize: 14,
            // //           color: Colors.amber.shade200,
            // //           fontWeight: FontWeight.w600,
            // //           fontStyle: FontStyle.italic,
            // //         ),
            // //       ),
            // //     ],
            // //   ),
            // // )
            //     .animate()
            //     .fadeIn(
            //       delay: const Duration(milliseconds: 800),
            //       duration: const Duration(milliseconds: 600),
            //     )
            //     .then()
            //     .slideY(
            //       begin: 0.2,
            //       duration: const Duration(milliseconds: 500),
            //       curve: Curves.easeOutBack,
            //     ),

            // const SizedBox(height: 40),

            // Story completion status - floating on background
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.15),
                    Colors.amber.withOpacity(0.1),
                    Colors.white.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Enhanced completion icon with multiple layers
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: [
                              Colors.green.shade100,
                              Colors.green.shade200,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.check_circle,
                          color: Colors.green.shade700,
                          size: 28,
                        ),
                      ),
                      // Pulse ring effect
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.green.withOpacity(0.3),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      )
                          .animate(onPlay: (controller) => controller.repeat())
                          .scale(
                            begin: const Offset(0.8, 0.8),
                            end: const Offset(1.2, 1.2),
                            duration: const Duration(milliseconds: 2000),
                          )
                          .fadeOut(
                            duration: const Duration(milliseconds: 2000),
                          ),
                    ],
                  ).animate().scale(
                        delay: const Duration(milliseconds: 1000),
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.elasticOut,
                      ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Story Completed! 🎊',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.9),
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          story.title,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),
                      ],
                    )
                        .animate()
                        .fadeIn(
                          delay: const Duration(milliseconds: 1100),
                          duration: const Duration(milliseconds: 500),
                        )
                        .then()
                        .slideX(
                          begin: 0.3,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOutBack,
                        ),
                  ),

                  // Celebration sparkles
                  Column(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        color: Colors.amber.shade400,
                        size: 20,
                      )
                          .animate(onPlay: (controller) => controller.repeat())
                          .rotate(
                            duration: const Duration(milliseconds: 3000),
                          ),
                      const SizedBox(height: 8),
                      Icon(
                        Icons.star,
                        color: Colors.orange.shade400,
                        size: 16,
                      )
                          .animate(
                              onPlay: (controller) =>
                                  controller.repeat(reverse: true))
                          .fadeIn(
                            duration: const Duration(milliseconds: 1500),
                          ),
                    ],
                  ).animate().fadeIn(
                        delay: const Duration(milliseconds: 1200),
                        duration: const Duration(milliseconds: 400),
                      ),
                ],
              ),
            ).animate().fadeIn(
                  delay: const Duration(milliseconds: 1000),
                  duration: const Duration(milliseconds: 600),
                ),

            const SizedBox(height: 30),

            // Next story section - seamless floating design
            if (nextStory != null)
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.orange.withOpacity(0.15),
                      Colors.amber.withOpacity(0.1),
                      Colors.white.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.orange.withOpacity(0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: () => context.push('/story/${nextStory.id}'),
                  borderRadius: BorderRadius.circular(16),
                  child: Row(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer glow ring
                          Container(
                            width: 65,
                            height: 65,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: Colors.orange.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                          )
                              .animate(
                                  onPlay: (controller) => controller.repeat())
                              .scale(
                                begin: const Offset(0.9, 0.9),
                                end: const Offset(1.1, 1.1),
                                duration: const Duration(milliseconds: 2000),
                              )
                              .fadeOut(
                                duration: const Duration(milliseconds: 2000),
                              ),

                          // Main play button
                          Container(
                            width: 55,
                            height: 55,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.orange.shade300,
                                  Colors.orange.shade500,
                                  Colors.orange.shade700,
                                ],
                                stops: const [0.0, 0.5, 1.0],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.orange.withOpacity(0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.8),
                                  blurRadius: 8,
                                  offset: const Offset(-2, -2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ],
                      )
                          .animate()
                          .scale(
                            delay: const Duration(milliseconds: 1300),
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.elasticOut,
                          )
                          .then()
                          .shimmer(
                            duration: const Duration(milliseconds: 1500),
                            color: Colors.white.withOpacity(0.6),
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
                                color: Colors.white.withOpacity(0.7),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              nextStory.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(
                            delay: const Duration(milliseconds: 1400),
                            duration: const Duration(milliseconds: 400),
                          ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.orange.shade300,
                      ).animate().slideX(
                            begin: -0.3,
                            delay: const Duration(milliseconds: 1500),
                            duration: const Duration(milliseconds: 400),
                          ),
                    ],
                  ),
                ),
              ).animate().fadeIn(
                    delay: const Duration(milliseconds: 1200),
                    duration: const Duration(milliseconds: 600),
                  )
            else
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.blue.withOpacity(0.15),
                      Colors.indigo.withOpacity(0.1),
                      Colors.white.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: () => context.go('/elearning'),
                  borderRadius: BorderRadius.circular(16),
                  child: Row(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer glow ring
                          Container(
                            width: 65,
                            height: 65,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: Colors.blue.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                          )
                              .animate(
                                  onPlay: (controller) => controller.repeat())
                              .scale(
                                begin: const Offset(0.9, 0.9),
                                end: const Offset(1.1, 1.1),
                                duration: const Duration(milliseconds: 2500),
                              )
                              .fadeOut(
                                duration: const Duration(milliseconds: 2500),
                              ),

                          // Main explore button
                          Container(
                            width: 55,
                            height: 55,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.blue.shade300,
                                  Colors.blue.shade500,
                                  Colors.indigo.shade600,
                                ],
                                stops: const [0.0, 0.5, 1.0],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.8),
                                  blurRadius: 8,
                                  offset: const Offset(-2, -2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.explore,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ],
                      )
                          .animate()
                          .scale(
                            delay: const Duration(milliseconds: 1300),
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.elasticOut,
                          )
                          .then()
                          .shimmer(
                            duration: const Duration(milliseconds: 1500),
                            color: Colors.white.withOpacity(0.6),
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
                                color: Colors.white.withOpacity(0.7),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Explore more timelines',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(
                            delay: const Duration(milliseconds: 1400),
                            duration: const Duration(milliseconds: 400),
                          ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.blue.shade300,
                      ).animate().slideX(
                            begin: -0.3,
                            delay: const Duration(milliseconds: 1500),
                            duration: const Duration(milliseconds: 400),
                          ),
                    ],
                  ),
                ),
              ).animate().fadeIn(
                    delay: const Duration(milliseconds: 1200),
                    duration: const Duration(milliseconds: 600),
                  ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// Custom painter for animated wavy lines
class AnimatedWavyLinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double animationValue;

  AnimatedWavyLinePainter({
    required this.color,
    this.strokeWidth = 2.0,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Safety checks
    if (size.width <= 0 ||
        size.height <= 0 ||
        animationValue.isNaN ||
        animationValue.isInfinite) {
      return;
    }

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth.clamp(0.1, 10.0)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final waveHeight = (size.height * 0.3).clamp(1.0, size.height * 0.5);
    final waveLength = (size.width / 4).clamp(10.0, size.width);
    final animationOffset =
        (animationValue * waveLength).clamp(-size.width * 2, size.width * 2);

    // Start point
    path.moveTo(-animationOffset, size.height / 2);

    // Create smooth wavy curves with animation
    for (int i = -1; i < 5; i++) {
      final x1 = (i * waveLength) + (waveLength * 0.25) - animationOffset;
      final y1 = (size.height / 2) + (i.isEven ? -waveHeight : waveHeight);
      final x2 = (i * waveLength) + (waveLength * 0.75) - animationOffset;
      final y2 = (size.height / 2) + (i.isEven ? -waveHeight : waveHeight);
      final x3 = (i + 1) * waveLength - animationOffset;
      final y3 = size.height / 2;

      // Ensure all values are finite
      if ([x1, y1, x2, y2, x3, y3].every((val) => val.isFinite)) {
        path.cubicTo(x1, y1, x2, y2, x3, y3);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(AnimatedWavyLinePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.animationValue != animationValue;
  }
}

class _AnimatedBackground extends StatefulWidget {
  @override
  State<_AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<_AnimatedBackground>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _particlesController;
  late Animation<double> _backgroundFloat1;
  late Animation<double> _backgroundFloat2;
  late Animation<double> _particlesAnimation;

  @override
  void initState() {
    super.initState();

    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 6000),
      vsync: this,
    );

    _particlesController = AnimationController(
      duration: const Duration(milliseconds: 8000),
      vsync: this,
    );

    _backgroundFloat1 = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.linear,
    ));

    _backgroundFloat2 = Tween<double>(
      begin: 0.0,
      end: 4 * math.pi,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.linear,
    ));

    _particlesAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _particlesController,
      curve: Curves.linear,
    ));

    _backgroundController.repeat();
    _particlesController.repeat();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _particlesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: Listenable.merge([
        _backgroundController,
        _particlesController,
      ]),
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      const Color(0xFF1A1A2E),
                      AppColors.darkBackground,
                      const Color(0xFF16213E),
                    ]
                  : [
                      const Color(0xFF1E3A8A),
                      AppColors.navyBlue,
                      const Color(0xFF312E81),
                    ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: Stack(
            children: [
              // Floating abstract shapes
              _buildFloatingShape(
                top: MediaQuery.of(context).size.height * 0.1 +
                    math.sin(_backgroundFloat1.value) * 30,
                left: -100 + math.cos(_backgroundFloat1.value * 0.7) * 50,
                width: 250,
                height: 180,
                colors: [
                  AppColors.limeGreen.withOpacity(0.15),
                  AppColors.limeGreen.withOpacity(0.05),
                ],
                borderRadius: const BorderRadius.only(
                  topRight: Radius.elliptical(180, 100),
                  bottomRight: Radius.elliptical(120, 80),
                ),
              ),

              _buildFloatingShape(
                top: MediaQuery.of(context).size.height * 0.3 +
                    math.cos(_backgroundFloat2.value * 0.8) * 40,
                right: -120 + math.sin(_backgroundFloat2.value * 0.6) * 60,
                width: 200,
                height: 150,
                colors: [
                  Colors.white.withOpacity(0.12),
                  Colors.white.withOpacity(0.03),
                ],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.elliptical(150, 90),
                  bottomLeft: Radius.elliptical(100, 70),
                ),
              ),

              _buildFloatingShape(
                bottom: MediaQuery.of(context).size.height * 0.2 +
                    math.sin(_backgroundFloat1.value * 1.2) * 25,
                left: -80 + math.cos(_backgroundFloat1.value * 0.9) * 40,
                width: 180,
                height: 120,
                colors: [
                  const Color(0xFF00FF88).withOpacity(0.08),
                  Colors.transparent,
                ],
                borderRadius: const BorderRadius.only(
                  topRight: Radius.elliptical(120, 70),
                  bottomRight: Radius.elliptical(90, 50),
                ),
              ),

              // Floating particles
              ...List.generate(12, (index) {
                final offset = index * 0.5;
                final x = 50 +
                    (index * 35) +
                    math.sin(_particlesAnimation.value * 2 * math.pi + offset) *
                        30;
                final y = 100 +
                    (index * 60) +
                    math.cos(_particlesAnimation.value * 2 * math.pi +
                            offset * 1.5) *
                        50;

                // Ensure positions are valid
                if (x.isNaN || y.isNaN || x.isInfinite || y.isInfinite) {
                  return const SizedBox.shrink();
                }

                final opacity = 0.3 +
                    math.sin(_particlesAnimation.value * 4 * math.pi + offset) *
                        0.3;

                // Clamp opacity to valid range
                final clampedOpacity = opacity.clamp(0.0, 1.0);

                return Positioned(
                  left: x.clamp(0.0, MediaQuery.of(context).size.width),
                  top: y.clamp(0.0, MediaQuery.of(context).size.height),
                  child: _buildFloatingParticle(
                    size: 6 + (index % 4) * 3,
                    opacity: clampedOpacity,
                    color: index % 4 == 0
                        ? AppColors.limeGreen
                        : index % 4 == 1
                            ? Colors.white
                            : index % 4 == 2
                                ? Colors.yellow.shade300
                                : const Color(0xFF00FF88),
                  ),
                );
              }),

              // Dynamic wavy patterns
              Positioned(
                top: MediaQuery.of(context).size.height * 0.25,
                left: 0,
                right: 0,
                child: Transform.translate(
                  offset: Offset(math.sin(_backgroundFloat1.value) * 20, 0),
                  child: CustomPaint(
                    size: Size(double.infinity, 60),
                    painter: AnimatedWavyLinePainter(
                      color: Colors.white.withOpacity(0.1),
                      strokeWidth: 2,
                      animationValue: _backgroundFloat1.value,
                    ),
                  ),
                ),
              ),

              Positioned(
                bottom: MediaQuery.of(context).size.height * 0.3,
                left: 0,
                right: 0,
                child: Transform.translate(
                  offset: Offset(math.cos(_backgroundFloat2.value) * 15, 0),
                  child: CustomPaint(
                    size: Size(double.infinity, 40),
                    painter: AnimatedWavyLinePainter(
                      color: AppColors.limeGreen.withOpacity(0.08),
                      strokeWidth: 1.5,
                      animationValue: _backgroundFloat2.value * 0.7,
                    ),
                  ),
                ),
              ),

              // Glass morphism overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.05),
                      Colors.transparent,
                      Colors.white.withOpacity(0.02),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFloatingShape({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double width,
    required double height,
    required List<Color> colors,
    required BorderRadius borderRadius,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
          borderRadius: borderRadius,
        ),
      ),
    );
  }

  Widget _buildFloatingParticle({
    required double size,
    required double opacity,
    required Color color,
  }) {
    // Ensure valid values
    final clampedSize = size.clamp(1.0, 50.0);
    final clampedOpacity = opacity.clamp(0.0, 1.0);

    return Container(
      width: clampedSize,
      height: clampedSize,
      decoration: BoxDecoration(
        color: color.withOpacity(clampedOpacity),
        shape: BoxShape.circle,
        boxShadow: clampedOpacity > 0.1
            ? [
                BoxShadow(
                  color: color.withOpacity(clampedOpacity * 0.5),
                  blurRadius: (clampedSize * 0.8).clamp(1.0, 20.0),
                  spreadRadius: (clampedSize * 0.2).clamp(0.0, 5.0),
                ),
              ]
            : null,
      ),
    );
  }
}
