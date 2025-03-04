import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:knowledge/data/providers/quiz_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:knowledge/core/themes/app_theme.dart';

class QuizScreen extends HookConsumerWidget {
  final String storyId;

  const QuizScreen({
    super.key,
    required this.storyId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentQuestionIndex = useState(0);
    final selectedOptionIndex = useState<int?>(null);
    final quizAsync = ref.watch(quizNotifierProvider(storyId));

    return Scaffold(
      backgroundColor: Colors.white,
      body: quizAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.navyBlue),
        )),
        error: (error, stack) => Center(
          child: SelectableText.rich(
            TextSpan(
              text: 'Error loading quiz: ',
              style: const TextStyle(color: AppColors.navyBlue),
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
          final currentQuestion = quiz.questions[currentQuestionIndex.value];
          final totalQuestions = quiz.questions.length;

          return SafeArea(
            child: Column(
              children: [
                // Top navigation bar
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back button
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.navyBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: AppColors.navyBlue,
                            size: 20,
                          ),
                        ),
                      ),

                      // Title
                      const Text(
                        'Title',
                        style: TextStyle(
                          color: AppColors.navyBlue,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      // Hint button
                      GestureDetector(
                        onTap: () {
                          // Show hint dialog
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Hint'),
                              content: Text(
                                  'Hint for question ${currentQuestionIndex.value + 1}'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Close'),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.navyBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.lightbulb_outline,
                            color: AppColors.navyBlue,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Progress indicator
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      totalQuestions,
                      (index) => Container(
                        width: index == currentQuestionIndex.value ? 24 : 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: index == currentQuestionIndex.value
                              ? AppColors.navyBlue
                              : AppColors.navyBlue.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),

                // Question number
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    '0${currentQuestionIndex.value + 1} Question /${totalQuestions < 10 ? '0$totalQuestions' : totalQuestions}',
                    style: const TextStyle(
                      color: AppColors.navyBlue,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                // Question text
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Text(
                    currentQuestion.text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.navyBlue,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                // Options
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ListView.builder(
                      itemCount: currentQuestion.options.length,
                      itemBuilder: (context, index) {
                        final option = currentQuestion.options[index];
                        final isSelected = selectedOptionIndex.value == index;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _QuizOption(
                            text: option.text,
                            isSelected: isSelected,
                            onTap: () {
                              selectedOptionIndex.value = index;
                              // Wait a bit before moving to next question
                              Future.delayed(const Duration(milliseconds: 500),
                                  () {
                                if (currentQuestionIndex.value <
                                    totalQuestions - 1) {
                                  currentQuestionIndex.value++;
                                  selectedOptionIndex.value = null;
                                } else {
                                  // Quiz completed
                                  context.pop();
                                }
                              });
                            },
                          ),
                        ).animate().fadeIn(
                              delay: Duration(milliseconds: 100 * index),
                            );
                      },
                    ),
                  ),
                ),

                // Bottom navigation
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Next button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: selectedOptionIndex.value != null
                              ? () {
                                  if (currentQuestionIndex.value <
                                      totalQuestions - 1) {
                                    currentQuestionIndex.value++;
                                    selectedOptionIndex.value = null;
                                  } else {
                                    // Quiz completed
                                    context.pop();
                                  }
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.limeGreen,
                            foregroundColor: Colors.black,
                            disabledBackgroundColor:
                                Colors.grey.withOpacity(0.3),
                            disabledForegroundColor:
                                Colors.black.withOpacity(0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Next',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Learn more button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: TextButton(
                          onPressed: () {
                            // Show learn more dialog
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Learn More'),
                                content: Text(
                                    'Additional information about question ${currentQuestionIndex.value + 1}'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Close'),
                                  ),
                                ],
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.grey.withOpacity(0.1),
                            foregroundColor: Colors.black87,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Learn More',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
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
      ),
    );
  }
}

class _QuizOption extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _QuizOption({
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.lightPurple.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? AppColors.lightPurple
                : Colors.grey.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.lightPurple : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? AppColors.lightPurple
                      : Colors.grey.withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: isSelected
                  ? const Center(
                      child: Icon(
                        Icons.circle,
                        size: 10,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: isSelected ? AppColors.navyBlue : Colors.black87,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
