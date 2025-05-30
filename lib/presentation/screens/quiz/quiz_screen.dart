import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:knowledge/data/providers/quiz_provider.dart';
import 'package:knowledge/data/repositories/quiz_repository.dart';
import 'package:knowledge/data/repositories/timeline_repository.dart';
import 'package:knowledge/data/models/quiz.dart';
// import 'package:flutter_animate/flutter_animate.dart';
import 'package:knowledge/core/themes/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;

class QuizScreen extends HookConsumerWidget {
  final String storyId;

  const QuizScreen({
    super.key,
    required this.storyId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get theme brightness
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDarkMode ? AppColors.darkBackground : Colors.white;
    final cardColor = isDarkMode ? AppColors.darkCard : Colors.white;
    final textColor = isDarkMode ? Colors.white : AppColors.navyBlue;
    final secondaryTextColor = isDarkMode ? Colors.white70 : Colors.black87;
    final borderColor =
        isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300;

    // State variables
    final currentQuestionIndex = useState(0);
    final selectedOptionId = useState<String?>(null);
    final hasSubmitted = useState(false);
    final isCorrect = useState(false);
    final correctOption = useState<Option?>(null);

    // Track user answers for all questions
    final userAnswers = useState<Map<String, String>>({});

    // Track submission state
    final isSubmittingQuiz = useState(false);
    final quizSubmissionError = useState<String?>(null);

    // Animation state for "Milestones Time" intro
    final showMilestonesIntro = useState(true);
    final introAnimationCompleted = useState(false);

    // Add overlay state for feedback popup
    final feedbackOverlay = useState<OverlayEntry?>(null);

    // Fetch quiz data
    final quizAsync = ref.watch(quizNotifierProvider(storyId));

    // Fetch story data to get the title
    final storyAsync = ref.watch(storyDetailProvider(storyId));

    // Function to submit all answers when quiz is completed
    Future<void> submitQuizAnswers(
        String quizId, Map<String, String> answers) async {
      if (answers.isEmpty) return;

      isSubmittingQuiz.value = true;
      quizSubmissionError.value = null;

      try {
        // Convert answers map to list of QuizAnswer objects
        final answersList = answers.entries
            .map((entry) => QuizAnswer(
                  questionId: entry.key,
                  selectedOptionId: entry.value,
                ))
            .toList();

        // Submit answers to the API
        await ref.read(quizRepositoryProvider).submitQuizAnswers(
              quizId,
              answersList,
            );

        // Navigate to the quiz submit screen
        if (context.mounted) {
          // Navigate to the quiz submit screen
          context.push('/quiz-submit/$storyId/$quizId');
        }
      } catch (error) {
        quizSubmissionError.value = error.toString();

        // Show error message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to submit quiz: ${error.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        isSubmittingQuiz.value = false;
      }
    }

    // Auto-hide intro animation after delay
    useEffect(() {
      if (showMilestonesIntro.value) {
        Future.delayed(const Duration(milliseconds: 3500), () {
          if (context.mounted) {
            showMilestonesIntro.value = false;
            Future.delayed(const Duration(milliseconds: 800), () {
              if (context.mounted) {
                introAnimationCompleted.value = true;
              }
            });
          }
        });
      }
      return null;
    }, []);

    // Cleanup overlay on dispose
    useEffect(() {
      return () {
        feedbackOverlay.value?.remove();
        feedbackOverlay.value = null;
      };
    }, []);

    // Function to show animated feedback popup
    void showFeedbackPopup(bool isAnswerCorrect, Option? correctOpt) {
      // Remove any existing overlay
      feedbackOverlay.value?.remove();

      feedbackOverlay.value = OverlayEntry(
        builder: (context) => _QuizFeedbackOverlay(
          isCorrect: isAnswerCorrect,
          correctOption: correctOpt,
          onContinue: () {
            // Hide overlay
            feedbackOverlay.value?.remove();
            feedbackOverlay.value = null;

            // Continue to next question or finish quiz
            final quiz = quizAsync.value;
            if (quiz != null) {
              if (currentQuestionIndex.value < quiz.questions.length - 1) {
                currentQuestionIndex.value++;
                selectedOptionId.value = null;
                hasSubmitted.value = false;
              } else {
                // Quiz completed - submit all answers
                submitQuizAnswers(quiz.id, userAnswers.value);
              }
            }
          },
        ),
      );

      Overlay.of(context).insert(feedbackOverlay.value!);
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // Main quiz content
          if (introAnimationCompleted.value)
            quizAsync.when(
              loading: () => Center(
                  child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    isDarkMode ? AppColors.limeGreen : AppColors.navyBlue),
              )),
              error: (error, stack) => Center(
                child: SelectableText.rich(
                  TextSpan(
                    text: 'Error loading quiz: ',
                    style: TextStyle(color: textColor),
                    children: [
                      TextSpan(
                        text: error.toString(),
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ),
              data: (quiz) {
                final currentQuestion =
                    quiz.questions[currentQuestionIndex.value];
                final totalQuestions = quiz.questions.length;

                return SafeArea(
                  child: Column(
                    children: [
                      // Top navigation bar
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Back button
                            GestureDetector(
                              onTap: () => context.pop(),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isDarkMode
                                      ? Colors.grey.shade800.withOpacity(0.5)
                                      : AppColors.navyBlue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.arrow_back,
                                  color: textColor,
                                  size: 20,
                                ),
                              ),
                            ),

                            // Title - Show story title
                            Expanded(
                              child: Center(
                                child: storyAsync.when(
                                  data: (story) => Text(
                                    story.title,
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                  loading: () => Text(
                                    'Quiz',
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  error: (_, __) => Text(
                                    'Quiz',
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),

                            // Spacer to balance the layout
                            const SizedBox(width: 48),
                          ],
                        ),
                      )
                          .animate()
                          .fadeIn(
                            duration: const Duration(milliseconds: 600),
                            delay: const Duration(milliseconds: 200),
                          )
                          .slideY(
                            begin: -0.3,
                            duration: const Duration(milliseconds: 800),
                            curve: Curves.easeOutCubic,
                          ),

                      // Progress indicator
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            totalQuestions,
                            (index) => Container(
                              width:
                                  index == currentQuestionIndex.value ? 24 : 8,
                              height: 8,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                color: index == currentQuestionIndex.value
                                    ? (isDarkMode
                                        ? AppColors.limeGreen
                                        : AppColors.navyBlue)
                                    : (isDarkMode
                                        ? AppColors.limeGreen.withOpacity(0.3)
                                        : AppColors.navyBlue.withOpacity(0.3)),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ).animate().scale(
                                  delay: Duration(
                                      milliseconds: 400 + (index * 100)),
                                  duration: const Duration(milliseconds: 600),
                                  curve: Curves.elasticOut,
                                ),
                          ),
                        ),
                      ),

                      // Question number
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(vertical: 16),
                      //   child: Text(
                      //     '0${currentQuestionIndex.value + 1} Question /${totalQuestions < 10 ? '0$totalQuestions' : totalQuestions}',
                      //     style: TextStyle(
                      //       color: textColor,
                      //       fontSize: 16,
                      //       fontWeight: FontWeight.w600,
                      //     ),
                      //   ),
                      // ).animate().fadeIn(
                      //       duration: const Duration(milliseconds: 500),
                      //       delay: const Duration(milliseconds: 600),
                      //     ),

                      // Question text

                      SizedBox(height: 5),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                        child: Text(
                          currentQuestion.text,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      )
                          .animate()
                          .fadeIn(
                            duration: const Duration(milliseconds: 600),
                            delay: const Duration(milliseconds: 800),
                          )
                          .slideY(
                            begin: 0.2,
                            duration: const Duration(milliseconds: 800),
                            curve: Curves.easeOutCubic,
                          ),

                      // Options
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: ListView.builder(
                            itemCount: currentQuestion.options.length,
                            itemBuilder: (context, index) {
                              final option = currentQuestion.options[index];
                              final isSelected =
                                  selectedOptionId.value == option.id;

                              // Determine option color based on state
                              Color optionColor = isDarkMode
                                  ? AppColors.darkCard
                                  : Colors.white;
                              if (hasSubmitted.value) {
                                if (option.isCorrect) {
                                  // Always highlight the correct answer after submission
                                  optionColor = isDarkMode
                                      ? Colors.green.shade900
                                      : Colors.green.shade100;
                                } else if (isSelected && !option.isCorrect) {
                                  // Highlight wrong selection in red
                                  optionColor = isDarkMode
                                      ? Colors.red.shade900
                                      : Colors.red.shade100;
                                }
                              } else if (isSelected) {
                                // Selected but not submitted yet
                                optionColor = isDarkMode
                                    ? AppColors.navyBlue.withOpacity(0.3)
                                    : AppColors.navyBlue.withOpacity(0.1);
                              }

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: GestureDetector(
                                  onTap: hasSubmitted.value
                                      ? null
                                      : () {
                                          selectedOptionId.value = option.id;
                                        },
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: optionColor,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSelected
                                            ? (isDarkMode
                                                ? AppColors.limeGreen
                                                : AppColors.navyBlue)
                                            : borderColor,
                                        width: 1.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(
                                              isDarkMode ? 0.2 : 0.05),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        // Option letter (A, B, C, D)
                                        Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? (isDarkMode
                                                    ? AppColors.limeGreen
                                                    : AppColors.navyBlue)
                                                : (isDarkMode
                                                    ? Colors.grey.shade700
                                                    : Colors.grey.shade200),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              String.fromCharCode(65 + index),
                                              style: TextStyle(
                                                color: isSelected
                                                    ? Colors.white
                                                    : (isDarkMode
                                                        ? Colors.white70
                                                        : Colors.black),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        // Option text
                                        Expanded(
                                          child: Text(
                                            option.text,
                                            style: TextStyle(
                                              color: textColor,
                                              fontSize: 16,
                                              fontWeight: isSelected
                                                  ? FontWeight.w600
                                                  : FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                        // Checkmark for selected option
                                        if (isSelected)
                                          Icon(
                                            hasSubmitted.value
                                                ? (option.isCorrect
                                                    ? Icons.check_circle
                                                    : Icons.cancel)
                                                : Icons.check_circle,
                                            color: hasSubmitted.value
                                                ? (option.isCorrect
                                                    ? Colors.green
                                                    : Colors.red)
                                                : (isDarkMode
                                                    ? AppColors.limeGreen
                                                    : AppColors.navyBlue),
                                            size: 24,
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                                  .animate()
                                  .fadeIn(
                                    duration: const Duration(milliseconds: 500),
                                    delay: Duration(
                                        milliseconds: 1000 + (index * 150)),
                                  )
                                  .slideX(
                                    begin: 0.3,
                                    duration: const Duration(milliseconds: 700),
                                    curve: Curves.easeOutCubic,
                                    delay: Duration(
                                        milliseconds: 1000 + (index * 150)),
                                  );
                            },
                          ),
                        ),
                      ),

                      // Bottom button area
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            // Submit/Next button
                            Container(
                              width: double.infinity,
                              height: 56, // Increased height
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black
                                        .withOpacity(isDarkMode ? 0.2 : 0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: selectedOptionId.value == null ||
                                        isSubmittingQuiz.value ||
                                        hasSubmitted.value
                                    ? null
                                    : () {
                                        // Submit answer and show popup
                                        final selectedOption =
                                            currentQuestion.options.firstWhere(
                                          (option) =>
                                              option.id ==
                                              selectedOptionId.value,
                                        );

                                        final correctOpt =
                                            currentQuestion.options.firstWhere(
                                          (option) => option.isCorrect,
                                          orElse: () =>
                                              currentQuestion.options.first,
                                        );

                                        // Update state
                                        isCorrect.value =
                                            selectedOption.isCorrect;
                                        correctOption.value = correctOpt;
                                        hasSubmitted.value = true;

                                        // Store the answer
                                        userAnswers.value = {
                                          ...userAnswers.value,
                                          currentQuestion.id:
                                              selectedOptionId.value!,
                                        };

                                        // Show animated feedback popup
                                        showFeedbackPopup(
                                            selectedOption.isCorrect,
                                            correctOpt);
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.limeGreen,
                                  foregroundColor: Colors.black,
                                  disabledBackgroundColor:
                                      Colors.grey.withOpacity(0.3),
                                  disabledForegroundColor:
                                      Colors.black.withOpacity(0.5),
                                  elevation: 0,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: isSubmittingQuiz.value
                                    ? SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  isDarkMode
                                                      ? Colors.white
                                                      : AppColors.navyBlue),
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        'Submit Answer',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                              ),
                            )
                                .animate()
                                .fadeIn(
                                  duration: const Duration(milliseconds: 600),
                                  delay: const Duration(milliseconds: 1500),
                                )
                                .slideY(
                                  begin: 0.3,
                                  duration: const Duration(milliseconds: 800),
                                  curve: Curves.easeOutBack,
                                  delay: const Duration(milliseconds: 1500),
                                ),

                            // Error message if quiz submission failed
                            if (quizSubmissionError.value != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: Text(
                                  'Error: ${quizSubmissionError.value}',
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

          // "Milestones Time" Intro Animation Overlay
          if (showMilestonesIntro.value)
            _MilestonesTimeIntro(
              isDarkMode: isDarkMode,
              onComplete: () {
                showMilestonesIntro.value = false;
                Future.delayed(const Duration(milliseconds: 800), () {
                  if (context.mounted) {
                    introAnimationCompleted.value = true;
                  }
                });
              },
            ),
        ],
      ),
    );
  }
}

// Spectacular "Milestones Time" intro animation widget
class _MilestonesTimeIntro extends HookWidget {
  final bool isDarkMode;
  final VoidCallback onComplete;

  const _MilestonesTimeIntro({
    required this.isDarkMode,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [
                  AppColors.darkBackground,
                  AppColors.darkSurface,
                  AppColors.navyBlue.withOpacity(0.8),
                ]
              : [
                  AppColors.navyBlue,
                  AppColors.navyBlue.withOpacity(0.9),
                  AppColors.navyBlue.withOpacity(0.7),
                ],
        ),
      ),
      child: Stack(
        children: [
          // Animated background particles
          _AnimatedBackgroundParticles(isDarkMode: isDarkMode),

          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated milestone icon
                _AnimatedMilestoneIcon()
                    .animate()
                    .scale(
                      begin: const Offset(0.3, 0.3),
                      end: const Offset(1.0, 1.0),
                      duration: const Duration(milliseconds: 1200),
                      curve: Curves.elasticOut,
                    )
                    .fadeIn(
                      duration: const Duration(milliseconds: 800),
                    ),

                const SizedBox(height: 40),

                // "MILESTONES" text with spectacular animation
                _AnimatedMilestonesText(isDarkMode: isDarkMode)
                    .animate()
                    .slideY(
                      begin: 0.5,
                      duration: const Duration(milliseconds: 1000),
                      curve: Curves.easeOutCubic,
                      delay: const Duration(milliseconds: 600),
                    )
                    .fadeIn(
                      duration: const Duration(milliseconds: 800),
                      delay: const Duration(milliseconds: 600),
                    ),

                const SizedBox(height: 20),

                // "TIME!" text with explosive animation
                _AnimatedTimeText(isDarkMode: isDarkMode)
                    .animate()
                    .scale(
                      begin: const Offset(0.5, 0.5),
                      end: const Offset(1.0, 1.0),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOutBack,
                      delay: const Duration(milliseconds: 1200),
                    )
                    .fadeIn(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 1200),
                    )
                    .then()
                    .shimmer(
                      duration: const Duration(milliseconds: 1500),
                      color: AppColors.limeGreen.withOpacity(0.8),
                      delay: const Duration(milliseconds: 1800),
                    ),

                const SizedBox(height: 40),

                // Subtitle with fade-in
                Text(
                  'Test your knowledge and\nreach new milestones!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    height: 1.4,
                  ),
                )
                    .animate()
                    .fadeIn(
                      duration: const Duration(milliseconds: 800),
                      delay: const Duration(milliseconds: 2000),
                    )
                    .slideY(
                      begin: 0.3,
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOutCubic,
                      delay: const Duration(milliseconds: 2000),
                    ),
              ],
            ),
          ),

          // Floating sparkles
          _FloatingSparkles(isDarkMode: isDarkMode),
        ],
      ),
    )
        .animate()
        .fadeOut(
          duration: const Duration(milliseconds: 800),
          delay: const Duration(milliseconds: 2800),
        )
        .slideY(
          begin: 0.0,
          end: -0.1,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInCubic,
          delay: const Duration(milliseconds: 2800),
        );
  }
}

// Animated milestone icon widget
class _AnimatedMilestoneIcon extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final glowController = useAnimationController(
      duration: const Duration(milliseconds: 2000),
    );

    final pulseController = useAnimationController(
      duration: const Duration(milliseconds: 1500),
    );

    useEffect(() {
      glowController.repeat(reverse: true);
      pulseController.repeat(reverse: true);
      return null;
    }, []);

    return AnimatedBuilder(
      animation: Listenable.merge([glowController, pulseController]),
      builder: (context, child) {
        final glowValue = glowController.value;
        final pulseValue = pulseController.value;

        return Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.limeGreen.withOpacity(0.4 + (glowValue * 0.4)),
                blurRadius: 30 + (pulseValue * 20),
                spreadRadius: 10 + (glowValue * 15),
              ),
              BoxShadow(
                color: AppColors.limeGreen.withOpacity(0.2 + (glowValue * 0.3)),
                blurRadius: 50 + (pulseValue * 30),
                spreadRadius: 20 + (glowValue * 20),
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.1 + (pulseValue * 0.2)),
                blurRadius: 40,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.limeGreen.withOpacity(0.8 + (glowValue * 0.2)),
                  AppColors.limeGreen.withOpacity(0.6 + (glowValue * 0.3)),
                  AppColors.limeGreen.withOpacity(0.4 + (glowValue * 0.4)),
                ],
              ),
            ),
            child: Icon(
              Icons.lightbulb,
              size: 70,
              color: Colors.white.withOpacity(0.9 + (pulseValue * 0.1)),
            ),
          ),
        );
      },
    ).animate(onPlay: (controller) => controller.repeat()).shimmer(
          duration: const Duration(milliseconds: 2500),
          color: Colors.white.withOpacity(0.4),
        );
  }
}

// Animated "MILESTONES" text
class _AnimatedMilestonesText extends StatelessWidget {
  final bool isDarkMode;

  const _AnimatedMilestonesText({required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: [
          AppColors.limeGreen,
          Colors.white,
          AppColors.limeGreen,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(bounds),
      child: const Text(
        'MILESTONES',
        style: TextStyle(
          fontSize: 42,
          fontWeight: FontWeight.w900,
          letterSpacing: 4.0,
          color: Colors.white,
          shadows: [
            Shadow(
              offset: Offset(0, 4),
              blurRadius: 8,
              color: Colors.black26,
            ),
          ],
        ),
      ),
    );
  }
}

// Animated "TIME!" text
class _AnimatedTimeText extends StatelessWidget {
  final bool isDarkMode;

  const _AnimatedTimeText({required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.limeGreen,
            AppColors.limeGreen.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.limeGreen.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: const Text(
        'TIME!',
        style: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w900,
          letterSpacing: 3.0,
          color: Colors.white,
          shadows: [
            Shadow(
              offset: Offset(0, 2),
              blurRadius: 4,
              color: Colors.black26,
            ),
          ],
        ),
      ),
    );
  }
}

// Animated background particles
class _AnimatedBackgroundParticles extends HookWidget {
  final bool isDarkMode;

  const _AnimatedBackgroundParticles({required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 8000),
    );

    useEffect(() {
      animationController.repeat();
      return null;
    }, []);

    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        return Stack(
          children: List.generate(20, (index) {
            final progress = (animationController.value + (index * 0.1)) % 1.0;
            final size = 4.0 + (index % 3) * 2.0;
            final opacity = math.sin(progress * math.pi);

            return Positioned(
              left: (index * 50.0) % MediaQuery.of(context).size.width,
              top: progress * MediaQuery.of(context).size.height,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: AppColors.limeGreen.withOpacity(opacity * 0.6),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.limeGreen.withOpacity(opacity * 0.3),
                      blurRadius: size * 2,
                      spreadRadius: size * 0.5,
                    ),
                  ],
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

// Floating sparkles animation
class _FloatingSparkles extends HookWidget {
  final bool isDarkMode;

  const _FloatingSparkles({required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final sparkleController = useAnimationController(
      duration: const Duration(milliseconds: 3000),
    );

    useEffect(() {
      sparkleController.repeat();
      return null;
    }, []);

    return AnimatedBuilder(
      animation: sparkleController,
      builder: (context, child) {
        return Stack(
          children: [
            // Top left sparkle
            Positioned(
              top: 100 + math.sin(sparkleController.value * 2 * math.pi) * 20,
              left: 50 + math.cos(sparkleController.value * 2 * math.pi) * 15,
              child: Icon(
                Icons.auto_awesome,
                color: AppColors.limeGreen.withOpacity(0.8),
                size: 24,
              )
                  .animate(onPlay: (controller) => controller.repeat())
                  .rotate(duration: const Duration(milliseconds: 2000)),
            ),

            // Top right sparkle
            Positioned(
              top: 120 + math.cos(sparkleController.value * 1.5 * math.pi) * 25,
              right:
                  60 + math.sin(sparkleController.value * 1.5 * math.pi) * 20,
              child: Icon(
                Icons.star,
                color: Colors.white.withOpacity(0.9),
                size: 20,
              )
                  .animate(
                      onPlay: (controller) => controller.repeat(reverse: true))
                  .scale(
                    duration: const Duration(milliseconds: 1500),
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1.2, 1.2),
                  ),
            ),

            // Bottom left sparkle
            Positioned(
              bottom:
                  150 + math.sin(sparkleController.value * 1.8 * math.pi) * 30,
              left: 80 + math.cos(sparkleController.value * 1.8 * math.pi) * 25,
              child: Icon(
                Icons.diamond,
                color: AppColors.limeGreen.withOpacity(0.7),
                size: 18,
              )
                  .animate(onPlay: (controller) => controller.repeat())
                  .fadeIn(duration: const Duration(milliseconds: 1000))
                  .then()
                  .fadeOut(duration: const Duration(milliseconds: 1000)),
            ),

            // Bottom right sparkle
            Positioned(
              bottom:
                  180 + math.cos(sparkleController.value * 2.2 * math.pi) * 20,
              right:
                  70 + math.sin(sparkleController.value * 2.2 * math.pi) * 15,
              child: Icon(
                Icons.auto_awesome,
                color: Colors.white.withOpacity(0.8),
                size: 16,
              )
                  .animate(onPlay: (controller) => controller.repeat())
                  .rotate(duration: const Duration(milliseconds: 1800)),
            ),
          ],
        );
      },
    );
  }
}

// Quiz Feedback Overlay Widget - Animated popup for quiz answer feedback
class _QuizFeedbackOverlay extends HookWidget {
  final bool isCorrect;
  final Option? correctOption;
  final VoidCallback onContinue;

  const _QuizFeedbackOverlay({
    required this.isCorrect,
    required this.correctOption,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final overlayController = useAnimationController(
      duration: const Duration(milliseconds: 300),
    );
    final popupController = useAnimationController(
      duration: const Duration(milliseconds: 500),
    );

    useEffect(() {
      overlayController.forward();
      popupController.forward();
      return null;
    }, []);

    return AnimatedBuilder(
      animation: Listenable.merge([overlayController, popupController]),
      builder: (context, child) {
        return Material(
          color: Colors.transparent,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black.withOpacity(0.6 * overlayController.value),
            child: Center(
              child: Transform.scale(
                scale: 0.8 + (0.2 * popupController.value),
                child: Opacity(
                  opacity: popupController.value,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 32),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isCorrect
                            ? [
                                Colors.green.withOpacity(0.95),
                                Colors.green.shade600.withOpacity(0.95),
                              ]
                            : [
                                Colors.red.withOpacity(0.95),
                                Colors.red.shade600.withOpacity(0.95),
                              ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Icon with animation
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isCorrect ? Icons.check_circle : Icons.cancel,
                            color: Colors.white,
                            size: 50,
                          ),
                        )
                            .animate(delay: Duration(milliseconds: 200))
                            .scale(duration: const Duration(milliseconds: 300))
                            .then()
                            .shake(duration: const Duration(milliseconds: 200)),

                        const SizedBox(height: 20),

                        // Main feedback text
                        Text(
                          isCorrect ? 'Correct! 🎉' : 'Oops! 😅',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        )
                            .animate(delay: Duration(milliseconds: 300))
                            .fadeIn(duration: const Duration(milliseconds: 300))
                            .slideY(begin: 0.3, end: 0),

                        const SizedBox(height: 12),

                        // Subtitle
                        Text(
                          isCorrect
                              ? 'Well done! You got it right!'
                              : 'Don\'t worry, keep trying!',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        )
                            .animate(delay: Duration(milliseconds: 400))
                            .fadeIn(duration: const Duration(milliseconds: 300))
                            .slideY(begin: 0.3, end: 0),

                        // Show correct answer if wrong
                        if (!isCorrect && correctOption != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.lightbulb_outline,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Correct answer: ${correctOption!.text}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                              .animate(delay: Duration(milliseconds: 500))
                              .fadeIn(
                                  duration: const Duration(milliseconds: 300))
                              .slideY(begin: 0.3, end: 0),
                        ],

                        const SizedBox(height: 24),

                        // Continue button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: onContinue,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor:
                                  isCorrect ? Colors.green : Colors.red,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.arrow_forward_rounded, size: 20),
                                const SizedBox(width: 8),
                                const Text(
                                  'Continue',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                            .animate(delay: Duration(milliseconds: 600))
                            .fadeIn(duration: const Duration(milliseconds: 300))
                            .slideY(begin: 0.3, end: 0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
