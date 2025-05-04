import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:knowledge/core/themes/app_theme.dart';
import 'package:knowledge/data/models/game_question.dart';
import 'package:knowledge/data/providers/game_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:knowledge/presentation/screens/games/games_screen.dart';

class ImageGuessGameScreen extends ConsumerStatefulWidget {
  const ImageGuessGameScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ImageGuessGameScreen> createState() =>
      _ImageGuessGameScreenState();
}

class _ImageGuessGameScreenState extends ConsumerState<ImageGuessGameScreen> {
  bool _isLoading = true;
  bool _showFeedback = false;
  bool? _isCorrect;
  int? _selectedOptionId;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  void _loadQuestions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final questions =
          await ref.read(gameQuestionsProvider(kImageGuessGameType).future);
      ref.read(gameStateNotifierProvider.notifier).setQuestions(questions);
    } catch (e) {
      print('Error loading questions: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleOptionSelected(int optionId) async {
    if (_showFeedback) return;

    final gameState = ref.read(gameStateNotifierProvider);
    final currentQuestion = gameState.currentQuestion;
    if (currentQuestion == null) return;

    setState(() {
      _selectedOptionId = optionId;
    });

    final isCorrect = await ref
        .read(gameStateNotifierProvider.notifier)
        .submitAnswer(optionId);

    setState(() {
      _isCorrect = isCorrect;
      _showFeedback = true;
    });

    // Show feedback for 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        final updatedGameState = ref.read(gameStateNotifierProvider);

        setState(() {
          _showFeedback = false;
          _selectedOptionId = null;
        });

        if (updatedGameState.isGameOver) {
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

                        // Navigate back to games screen
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
                        Navigator.pop(context); // Close dialog
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

  Widget _buildOptionButton(GameOption option) {
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
    );
  }

  Widget _buildFeedbackOverlay() {
    if (!_showFeedback || _isCorrect == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameStateNotifierProvider);
    final currentQuestion = gameState.currentQuestion;

    return Scaffold(
      backgroundColor: AppColors.navyBlue,
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Image Guess",
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

            // Progress bar
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 16, 32, 8),
              child: LinearProgressIndicator(
                value: gameState.questions.isEmpty
                    ? 0
                    : gameState.currentQuestionIndex /
                        gameState.questions.length,
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
                  const Icon(
                    Icons.timer_outlined,
                    color: Colors.white,
                    size: 16,
                  ),
                ],
              ),
            ),

            // Game content
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.limeGreen),
                      ),
                    )
                  : currentQuestion == null
                      ? Center(
                          child: Text(
                            "No questions available",
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      : Column(
                          children: [
                            // Image and question
                            Expanded(
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Image
                                    if (currentQuestion.imageUrl != null)
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: CachedNetworkImage(
                                          imageUrl: currentQuestion.imageUrl!,
                                          height: 200,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              Container(
                                            height: 200,
                                            width: double.infinity,
                                            color: Colors.grey.shade800,
                                            child: const Center(
                                              child: CircularProgressIndicator(
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(
                                                  AppColors.limeGreen,
                                                ),
                                              ),
                                            ),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              Container(
                                            height: 200,
                                            width: double.infinity,
                                            color: Colors.grey.shade800,
                                            child: const Center(
                                              child: Icon(
                                                Icons.error_outline,
                                                color: Colors.white,
                                                size: 48,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ).animate().fadeIn(
                                            duration: const Duration(
                                                milliseconds: 500),
                                          ),
                                    const SizedBox(height: 24),

                                    // Question title
                                    Text(
                                      currentQuestion.title,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ).animate().slideY(
                                          begin: 0.1,
                                          duration:
                                              const Duration(milliseconds: 500),
                                        ),
                                  ],
                                ),
                              ),
                            ),

                            // Options
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(30),
                                  topRight: Radius.circular(30),
                                ),
                              ),
                              padding: const EdgeInsets.only(
                                top: 24,
                                bottom: 24,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Options
                                  ...currentQuestion.options
                                      .map(_buildOptionButton)
                                      .toList(),

                                  // Feedback overlay
                                  _buildFeedbackOverlay(),
                                ],
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
}
