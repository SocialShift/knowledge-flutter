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
    if (_showFeedback) return; // Prevent multiple selections during feedback

    // Play haptic feedback
    HapticFeedback.mediumImpact();

    setState(() {
      _selectedOptionId = optionId;
    });

    final isCorrect = await ref
        .read(gameStateNotifierProvider.notifier)
        .submitAnswer(optionId);

    // Check if the game is over after submitting the answer
    final gameState = ref.read(gameStateNotifierProvider);

    setState(() {
      _isCorrect = isCorrect;
      _showFeedback = true;
    });

    // Show feedback for 2 seconds, then move to next question or show game over dialog
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showFeedback = false;
          _selectedOptionId = null;
        });

        // Check if this was the last question
        if (gameState.isGameOver) {
          _showGameOverDialog();
        }
      }
    });
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
                        // Trigger refresh on the games screen
                        ref.read(gamesRefreshProvider.notifier).state++;

                        // Navigate directly to the games screen
                        Navigator.of(context).popUntil((route) {
                          return route.settings.name == '/games' ||
                              route.isFirst;
                        });
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

    return Scaffold(
      backgroundColor: AppColors.navyBlue,
      body: Column(
        children: [
          // App Bar with back button and game title
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.gameTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
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
          ),

          // Progress bar
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 16, 32, 8),
            child: LinearProgressIndicator(
              value: gameState.questions.isEmpty
                  ? 0
                  : gameState.currentQuestionIndex / gameState.questions.length,
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.limeGreen),
              borderRadius: BorderRadius.circular(4),
            ),
          ),

          // Question counter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Question ${gameState.currentQuestionIndex + 1}/${gameState.questions.length}",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
                if (currentQuestion != null)
                  const Icon(
                    Icons.timer_outlined,
                    color: Colors.white,
                    size: 16,
                  ),
              ],
            ),
          ),

          // Content section
          Expanded(
            child: currentQuestion == null
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.limeGreen),
                    ),
                  )
                : buildQuestionContent(currentQuestion),
          ),
        ],
      ),
    );
  }

  // This method should be overridden by subclasses to provide specific UI
  Widget buildQuestionContent(GameQuestion question) {
    return const Center(
      child: Text(
        "Override this method in subclasses",
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  // Helper method to build option buttons
  Widget buildOptionButton(GameOption option, {bool highlighted = false}) {
    final isSelected = _selectedOptionId == option.id;
    final showCorrectState = _showFeedback && option.isCorrect;
    final showIncorrectState = _showFeedback && isSelected && !option.isCorrect;

    return GestureDetector(
      onTap: () => _handleOptionSelected(option.id),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: showCorrectState
              ? Colors.green.withOpacity(0.2)
              : showIncorrectState
                  ? Colors.red.withOpacity(0.2)
                  : isSelected
                      ? AppColors.limeGreen.withOpacity(0.2)
                      : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: showCorrectState
                ? Colors.green
                : showIncorrectState
                    ? Colors.red
                    : isSelected
                        ? AppColors.limeGreen
                        : Colors.white.withOpacity(0.2),
            width: isSelected || _showFeedback ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                option.text,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: isSelected || _showFeedback
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),
            if (showCorrectState)
              const Icon(
                Icons.check_circle,
                color: Colors.green,
              ).animate().scale(
                    duration: const Duration(milliseconds: 300),
                  )
            else if (showIncorrectState)
              const Icon(
                Icons.cancel,
                color: Colors.red,
              ).animate().shake(
                    duration: const Duration(milliseconds: 300),
                  ),
          ],
        ),
      ),
    )
        .animate(
          target: highlighted ? 1 : 0,
        )
        .shimmer(
          duration: const Duration(seconds: 2),
          color: AppColors.limeGreen.withOpacity(0.2),
        );
  }

  // Feedback overlay widget
  Widget buildFeedbackOverlay() {
    if (!_showFeedback || _isCorrect == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: _isCorrect! ? Colors.green : Colors.red,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _isCorrect! ? Icons.check_circle : Icons.cancel,
            color: Colors.white,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            _isCorrect! ? "Correct!" : "Incorrect!",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    )
        .animate()
        .slideY(
          begin: 0.5,
          end: 0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        )
        .fadeIn();
  }
}
