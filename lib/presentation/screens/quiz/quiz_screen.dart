import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:knowledge/data/providers/quiz_provider.dart';
import 'package:knowledge/data/repositories/quiz_repository.dart';
import 'package:knowledge/data/repositories/timeline_repository.dart';
// import 'package:flutter_animate/flutter_animate.dart';
import 'package:knowledge/core/themes/app_theme.dart';

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

    // Track user answers for all questions
    final userAnswers = useState<Map<String, String>>({});

    // Track submission state
    final isSubmittingQuiz = useState(false);
    final quizSubmissionError = useState<String?>(null);

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

    return Scaffold(
      backgroundColor: backgroundColor,
      body: quizAsync.when(
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
          final currentQuestion = quiz.questions[currentQuestionIndex.value];
          final totalQuestions = quiz.questions.length;

          // Find the correct option
          final correctOption = currentQuestion.options.firstWhere(
              (option) => option.isCorrect,
              orElse: () => currentQuestion.options.first);

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
                      storyAsync.when(
                        data: (story) => Text(
                          story.title,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        loading: () => Text(
                          'Quiz',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        error: (_, __) => Text(
                          'Quiz',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
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
                              ? (isDarkMode
                                  ? AppColors.limeGreen
                                  : AppColors.navyBlue)
                              : (isDarkMode
                                  ? AppColors.limeGreen.withOpacity(0.3)
                                  : AppColors.navyBlue.withOpacity(0.3)),
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
                    style: TextStyle(
                      color: textColor,
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
                    style: TextStyle(
                      color: textColor,
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
                        final isSelected = selectedOptionId.value == option.id;

                        // Determine option color based on state
                        Color optionColor =
                            isDarkMode ? AppColors.darkCard : Colors.white;
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
                                    color: Colors.black
                                        .withOpacity(isDarkMode ? 0.2 : 0.05),
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
                        );
                      },
                    ),
                  ),
                ),

                // Explanation text (shown after submission)
                if (hasSubmitted.value)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      isCorrect.value
                          ? 'Correct! Well done.'
                          : 'Incorrect. The correct answer is: ${correctOption.text}',
                      style: TextStyle(
                        color: isCorrect.value ? Colors.green : Colors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
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
                                  isSubmittingQuiz.value
                              ? null
                              : () {
                                  if (!hasSubmitted.value) {
                                    // Submit answer
                                    final selectedOption =
                                        currentQuestion.options.firstWhere(
                                      (option) =>
                                          option.id == selectedOptionId.value,
                                    );
                                    isCorrect.value = selectedOption.isCorrect;
                                    hasSubmitted.value = true;

                                    // Store the answer
                                    userAnswers.value = {
                                      ...userAnswers.value,
                                      currentQuestion.id:
                                          selectedOptionId.value!,
                                    };
                                  } else {
                                    // Move to next question
                                    if (currentQuestionIndex.value <
                                        totalQuestions - 1) {
                                      currentQuestionIndex.value++;
                                      selectedOptionId.value = null;
                                      hasSubmitted.value = false;
                                    } else {
                                      // Quiz completed - submit all answers
                                      submitQuizAnswers(
                                          quiz.id, userAnswers.value);
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.limeGreen,
                            foregroundColor: Colors.black,
                            disabledBackgroundColor:
                                Colors.grey.withOpacity(0.3),
                            disabledForegroundColor:
                                Colors.black.withOpacity(0.5),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: isSubmittingQuiz.value
                              ? SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        isDarkMode
                                            ? Colors.white
                                            : AppColors.navyBlue),
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  !hasSubmitted.value
                                      ? 'Submit'
                                      : (currentQuestionIndex.value <
                                              totalQuestions - 1
                                          ? 'Next'
                                          : 'Finish'),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                        ),
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
    );
  }
}
