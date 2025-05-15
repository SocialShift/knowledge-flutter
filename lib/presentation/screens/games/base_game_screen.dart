import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:knowledge/core/themes/app_theme.dart';
import 'package:knowledge/data/models/game_question.dart';
import 'package:knowledge/data/providers/game_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:knowledge/presentation/screens/games/games_screen.dart';

class BaseGameScreen extends ConsumerStatefulWidget {
  final String gameId;
  final String gameTitle;
  final int gameType;

  const BaseGameScreen({
    Key? key,
    required this.gameId,
    required this.gameTitle,
    required this.gameType,
  }) : super(key: key);

  @override
  ConsumerState<BaseGameScreen> createState() => _BaseGameScreenState();
}

class _BaseGameScreenState extends ConsumerState<BaseGameScreen> {
  bool _showFeedback = false;
  bool? _isCorrect;
  int? _selectedOptionId;
  GameOption? _correctOption;

  @override
  void initState() {
    super.initState();
    // Load questions when the screen is first shown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadQuestions();
    });
  }

  void _loadQuestions() async {
    try {
      final questions =
          await ref.read(gameQuestionsProvider(widget.gameType).future);
      ref.read(gameStateNotifierProvider.notifier).setQuestions(questions);
    } catch (e) {
      print('Error loading questions: $e');
    }
  }

  void _handleOptionSelected(int optionId) async {
    // Don't allow selection if feedback is already showing
    if (_showFeedback) return;

    // Play haptic feedback for better UX
    HapticFeedback.mediumImpact();

    final gameState = ref.read(gameStateNotifierProvider);
    final currentQuestion = gameState.currentQuestion;

    if (currentQuestion == null) return;

    // Find the correct option for showing feedback
    final correctOption = currentQuestion.options.firstWhere(
      (option) => option.isCorrect,
      orElse: () => currentQuestion.options.first,
    );

    setState(() {
      _selectedOptionId = optionId;
      _correctOption = correctOption;
    });

    // Submit the answer to update score
    final isCorrect = await ref
        .read(gameStateNotifierProvider.notifier)
        .submitAnswer(optionId);

    // Show feedback but don't automatically advance to next question
    setState(() {
      _isCorrect = isCorrect;
      _showFeedback = true;
    });
  }

  void _goToNextQuestion() {
    final gameState = ref.read(gameStateNotifierProvider);

    setState(() {
      _showFeedback = false;
      _selectedOptionId = null;
      _correctOption = null;
    });

    // Check if this was the last question
    if (gameState.isGameOver) {
      _showGameOverDialog();
    } else {
      // Move to the next question
      ref.read(gameStateNotifierProvider.notifier).nextQuestion();
    }
  }

  void _showGameOverDialog() {
    final gameState = ref.read(gameStateNotifierProvider);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.emoji_events_outlined,
                  size: 56,
                  color: AppColors.limeGreen,
                ).animate().scale(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.elasticOut,
                    ),
                const SizedBox(height: 20),
                Text(
                  "Game Complete!",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.navyBlue,
                  ),
                ).animate().fadeIn(
                      duration: const Duration(milliseconds: 500),
                    ),
                const SizedBox(height: 16),
                Text(
                  "Your Score: ${gameState.score}",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: AppColors.navyBlue.withOpacity(0.8),
                  ),
                ).animate().fadeIn(
                      delay: const Duration(milliseconds: 200),
                      duration: const Duration(milliseconds: 500),
                    ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        // First close dialog
                        Navigator.of(context).pop();

                        // Trigger refresh on the games screen
                        ref.read(gamesRefreshProvider.notifier).state++;

                        // Navigate to home screen using GoRouter
                        context.go('/home');
                      },
                      child: Text(
                        "Exit",
                        style: TextStyle(color: AppColors.navyBlue),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        backgroundColor: AppColors.limeGreen,
                        foregroundColor: AppColors.navyBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        context.pop(); // Close dialog
                        ref
                            .read(gameStateNotifierProvider.notifier)
                            .restartGame();
                      },
                      child: const Text(
                        "Play Again",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ).animate().scale(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameStateNotifierProvider);
    final currentQuestion = gameState.currentQuestion;
    final totalQuestions = gameState.questions.length;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top navigation bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                  Text(
                    widget.gameTitle,
                    style: const TextStyle(
                      color: AppColors.navyBlue,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Score indicator
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.limeGreen,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      "Score: ${gameState.score}",
                      style: const TextStyle(
                        color: AppColors.navyBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Progress indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  totalQuestions,
                  (index) => Container(
                    width: index == gameState.currentQuestionIndex ? 24 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: index == gameState.currentQuestionIndex
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
                '0${gameState.currentQuestionIndex + 1} Question /${totalQuestions < 10 ? '0$totalQuestions' : totalQuestions}',
                style: const TextStyle(
                  color: AppColors.navyBlue,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // Question text
            if (currentQuestion != null)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Text(
                  currentQuestion.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.navyBlue,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

            // Content section
            Expanded(
              child: currentQuestion == null
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.navyBlue),
                      ),
                    )
                  : buildQuestionContent(currentQuestion),
            ),

            // Bottom area: Feedback and Next button
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Feedback when answer is submitted
                  if (_showFeedback)
                    Column(
                      children: [
                        Text(
                          _isCorrect!
                              ? 'Correct! Well done.'
                              : 'Incorrect. The correct answer is:',
                          style: TextStyle(
                            color: _isCorrect! ? Colors.green : Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        // Show correct answer when wrong
                        if (!_isCorrect! && _correctOption != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              _correctOption!.text,
                              style: const TextStyle(
                                color: Colors.green,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                      ],
                    ),

                  // Submit/Next button (similar to quiz screen)
                  Container(
                    width: double.infinity,
                    height: 56,
                    margin: _showFeedback
                        ? const EdgeInsets.only(top: 16)
                        : EdgeInsets.zero,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      // Disable button when no option selected or when loading
                      onPressed: _selectedOptionId == null
                          ? null
                          : () {
                              if (!_showFeedback) {
                                // Submit the answer
                                _handleOptionSelected(_selectedOptionId!);
                              } else {
                                // Move to next question
                                _goToNextQuestion();
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.limeGreen,
                        foregroundColor: Colors.black,
                        disabledBackgroundColor: Colors.grey.withOpacity(0.3),
                        disabledForegroundColor: Colors.black.withOpacity(0.5),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        !_showFeedback ? 'Submit' : 'Next',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
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

  // This method should be overridden by subclasses to provide specific UI
  @protected
  Widget buildQuestionContent(GameQuestion question) {
    // Check if the question has an image (for image-based games)
    final hasImage = question.imageUrl != null && question.imageUrl!.isNotEmpty;

    return Column(
      children: [
        // Display the image if it exists
        if (hasImage)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.grey.shade200,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                question.imageUrl!,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.navyBlue),
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.grey.shade400,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Failed to load image",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ).animate().fadeIn(duration: const Duration(milliseconds: 500)),

        // Options list
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ListView.builder(
              itemCount: question.options.length,
              itemBuilder: (context, index) {
                final option = question.options[index];
                return buildOptionButton(option, index);
              },
            ),
          ),
        ),
      ],
    );
  }

  // Helper method to build option buttons with new design
  @protected
  Widget buildOptionButton(GameOption option, int index) {
    final isSelected = _selectedOptionId == option.id;

    // Get feedback state - correct or incorrect selection
    final isCorrectOption = option.isCorrect;
    final isIncorrectSelection =
        isSelected && !option.isCorrect && _showFeedback;
    final isCorrectSelection = isSelected && option.isCorrect && _showFeedback;
    final isCorrectAnswer = option.isCorrect && _showFeedback;

    // Determine option color based on state
    Color optionColor = Colors.white;
    if (isCorrectAnswer) {
      // Always highlight the correct answer after submission
      optionColor = Colors.green.shade100;
    } else if (isIncorrectSelection) {
      // Highlight wrong selection in red
      optionColor = Colors.red.shade100;
    } else if (isSelected) {
      // Selected but not submitted yet
      optionColor = AppColors.navyBlue.withOpacity(0.1);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: _showFeedback
            ? null
            : () => setState(() => _selectedOptionId = option.id),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: optionColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.navyBlue : Colors.grey.shade300,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
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
                  color: isSelected ? AppColors.navyBlue : Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    String.fromCharCode(65 + index),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
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
                    color: AppColors.navyBlue,
                    fontSize: 16,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
              // Checkmark for selected option
              if (isSelected)
                Icon(
                  _showFeedback
                      ? (option.isCorrect ? Icons.check_circle : Icons.cancel)
                      : Icons.check_circle,
                  color: _showFeedback
                      ? (option.isCorrect ? Colors.green : Colors.red)
                      : AppColors.navyBlue,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
