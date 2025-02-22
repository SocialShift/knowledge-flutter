import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:knowledge/data/providers/quiz_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
      backgroundColor: const Color(0xFF1A1A1A),
      body: quizAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: SelectableText.rich(
            TextSpan(
              text: 'Error loading quiz: ',
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

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress and close button
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => context.pop(),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Question ${currentQuestionIndex.value + 1}/${quiz.questions.length}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: (currentQuestionIndex.value + 1) /
                                  quiz.questions.length,
                              backgroundColor: Colors.white10,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ).animate().fadeIn(),

                  const SizedBox(height: 40),

                  // Question
                  Text(
                    currentQuestion.text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ).animate().fadeIn().slideX(
                      begin: 0.2,
                      end: 0,
                      duration: const Duration(milliseconds: 400)),

                  const SizedBox(height: 40),

                  // Options
                  ...currentQuestion.options.asMap().entries.map((entry) {
                    final index = entry.key;
                    final option = entry.value;
                    final isSelected = selectedOptionIndex.value == index;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _QuizOption(
                        text: option.text,
                        isSelected: isSelected,
                        onTap: () {
                          selectedOptionIndex.value = index;
                          // Wait a bit before moving to next question
                          Future.delayed(const Duration(milliseconds: 500), () {
                            if (currentQuestionIndex.value <
                                quiz.questions.length - 1) {
                              currentQuestionIndex.value++;
                              selectedOptionIndex.value = null;
                            } else {
                              // Quiz completed
                              context.pop();
                            }
                          });
                        },
                      ),
                    )
                        .animate()
                        .fadeIn(
                          delay: Duration(milliseconds: 100 * index),
                        )
                        .slideX(begin: 0.2, end: 0);
                  }),
                ],
              ),
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.white24,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? Colors.white : Colors.transparent,
                border: Border.all(
                  color: isSelected ? Colors.blue : Colors.white24,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.blue,
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
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
