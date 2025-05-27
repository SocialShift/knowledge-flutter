import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:knowledge/core/themes/app_theme.dart';
import 'package:knowledge/data/models/game_question.dart';
import 'package:knowledge/data/providers/game_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:knowledge/presentation/screens/games/games_screen.dart';
import 'package:knowledge/presentation/screens/games/game_completion_screen.dart';

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

class _BaseGameScreenState extends ConsumerState<BaseGameScreen>
    with TickerProviderStateMixin {
  bool _showFeedback = false;
  bool? _isCorrect;
  int? _selectedOptionId;
  GameOption? _correctOption;

  // Animation controllers for gamification
  late AnimationController _scoreAnimationController;
  late AnimationController _progressAnimationController;
  late AnimationController _feedbackAnimationController;

  // Encouraging messages
  final List<String> _encouragingMessages = [
    "Great job! Keep it up! 🎉",
    "You're on fire! 🔥",
    "Excellent work! 🌟",
    "Amazing! You're crushing it! 💪",
    "Fantastic! Keep going! 🚀",
    "Brilliant! You're doing great! ✨",
    "Outstanding! 🏆",
    "Superb! You're unstoppable! ⭐",
  ];

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _scoreAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _feedbackAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Load questions when the screen is first shown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadQuestions();
    });
  }

  @override
  void dispose() {
    _scoreAnimationController.dispose();
    _progressAnimationController.dispose();
    _feedbackAnimationController.dispose();
    super.dispose();
  }

  void _loadQuestions() async {
    try {
      final questions =
          await ref.read(gameQuestionsProvider(widget.gameType).future);
      ref.read(gameStateNotifierProvider.notifier).setQuestions(questions);

      // Animate progress bar
      _progressAnimationController.forward();
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

    // Find the selected option and correct option
    final selectedOption = currentQuestion.options.firstWhere(
      (option) => option.id == optionId,
      orElse: () => currentQuestion.options.first,
    );

    final correctOption = currentQuestion.options.firstWhere(
      (option) => option.isCorrect,
      orElse: () => currentQuestion.options.first,
    );

    // Determine if answer is correct immediately from the option data
    final isCorrect = selectedOption.isCorrect;

    setState(() {
      _selectedOptionId = optionId;
      _correctOption = correctOption;
      _isCorrect = isCorrect;
      _showFeedback = true;
    });

    // Trigger feedback animation immediately
    _feedbackAnimationController.forward();

    // Trigger score animation if correct
    if (isCorrect) {
      _scoreAnimationController.forward().then((_) {
        _scoreAnimationController.reset();
      });

      // Trigger haptic feedback for correct answer
      HapticFeedback.lightImpact();
    }

    // Submit the answer to server in background (fire and forget)
    // This updates the score and sends data to server without blocking UI
    ref
        .read(gameStateNotifierProvider.notifier)
        .submitAnswer(optionId)
        .catchError((error) {
      // Handle any network errors silently or show a non-blocking notification
      print('Error submitting answer to server: $error');
    });
  }

  void _goToNextQuestion() {
    final gameState = ref.read(gameStateNotifierProvider);

    // Reset animations
    _feedbackAnimationController.reset();

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

      // Update progress animation
      final totalQuestions = gameState.questions.length;
      final currentIndex = gameState.currentQuestionIndex;
      final progress = (currentIndex + 1) / totalQuestions;

      _progressAnimationController.animateTo(progress);
    }
  }

  String _getEncouragingMessage() {
    final gameState = ref.read(gameStateNotifierProvider);
    final score = gameState.score;

    if (score >= 8) return _encouragingMessages[7]; // Outstanding
    if (score >= 6) return _encouragingMessages[6]; // Excellent
    if (score >= 4) return _encouragingMessages[5]; // Great
    if (score >= 2) return _encouragingMessages[4]; // Good
    return _encouragingMessages[0]; // Keep going
  }

  void _showGameOverDialog() {
    final gameState = ref.read(gameStateNotifierProvider);
    final totalQuestions = gameState.questions.length;

    // Navigate to the new GameCompletionScreen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GameCompletionScreen(
          gameId: widget.gameId,
          gameTitle: widget.gameTitle,
          gameType: widget.gameType,
          score: gameState.score,
          totalQuestions: totalQuestions,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameStateNotifierProvider);
    final currentQuestion = gameState.currentQuestion;
    final totalQuestions = gameState.questions.length;
    final currentIndex = gameState.currentQuestionIndex;

    // Theme-related variables
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDarkMode ? AppColors.darkBackground : Colors.white;
    final textColor = isDarkMode ? Colors.white : AppColors.navyBlue;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Enhanced top navigation with progress
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.darkSurface : backgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
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
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.arrow_back,
                            color: textColor,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Title
                      Expanded(
                        child: Text(
                          widget.gameTitle,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Animated score indicator
                      AnimatedBuilder(
                        animation: _scoreAnimationController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale:
                                1.0 + (_scoreAnimationController.value * 0.2),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.limeGreen,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: _scoreAnimationController.value > 0
                                    ? [
                                        BoxShadow(
                                          color: AppColors.limeGreen
                                              .withOpacity(0.3),
                                          blurRadius: 8,
                                          spreadRadius: 2,
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.star,
                                    size: 16,
                                    color: Colors.black,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "${gameState.score}",
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Progress bar with question counter
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Question ${currentIndex + 1}",
                            style: TextStyle(
                              color: textColor.withOpacity(0.7),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            "$totalQuestions Total",
                            style: TextStyle(
                              color: textColor.withOpacity(0.7),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      AnimatedBuilder(
                        animation: _progressAnimationController,
                        builder: (context, child) {
                          final progress = totalQuestions > 0
                              ? (currentIndex + 1) / totalQuestions
                              : 0.0;
                          final animatedProgress =
                              _progressAnimationController.value * progress;

                          return Container(
                            height: 6,
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: LinearProgressIndicator(
                                value: animatedProgress,
                                backgroundColor: Colors.transparent,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.limeGreen,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Main content area with optimized layout
            Expanded(
              child: currentQuestion == null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.limeGreen),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Loading questions...",
                            style: TextStyle(
                              color: textColor.withOpacity(0.7),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Enhanced question card
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: isDarkMode
                                      ? [
                                          AppColors.darkCard,
                                          AppColors.darkSurface
                                        ]
                                      : [Colors.white, AppColors.offWhite],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isDarkMode
                                      ? Colors.grey.shade700
                                      : Colors.grey.shade200,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black
                                        .withOpacity(isDarkMode ? 0.2 : 0.05),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Question header with icon
                                  Row(
                                      // children: [
                                      //   Container(
                                      //     padding: const EdgeInsets.all(8),
                                      //     decoration: BoxDecoration(
                                      //       color: AppColors.limeGreen
                                      //           .withOpacity(0.1),
                                      //       borderRadius:
                                      //           BorderRadius.circular(8),
                                      //     ),
                                      //     child: Icon(
                                      //       Icons.quiz_outlined,
                                      //       color: AppColors.limeGreen,
                                      //       size: 20,
                                      //     ),
                                      //   ),
                                      //   const SizedBox(width: 12),
                                      //   Expanded(
                                      //     child: Text(
                                      //       "Question",
                                      //       style: TextStyle(
                                      //         color: textColor.withOpacity(0.7),
                                      //         fontSize: 12,
                                      //         fontWeight: FontWeight.w600,
                                      //         letterSpacing: 0.5,
                                      //       ),
                                      //     ),
                                      //   ),
                                      // ],
                                      ),
                                  const SizedBox(height: 5),

                                  // Question text
                                  Text(
                                    currentQuestion.title,
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      height: 1.4,
                                    ),
                                  ),

                                  // Compact image section if exists
                                  if (currentQuestion.imageUrl != null &&
                                      currentQuestion.imageUrl!.isNotEmpty) ...[
                                    const SizedBox(height: 16),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        height: 140,
                                        width: double.infinity,
                                        color: isDarkMode
                                            ? Colors.grey.shade800
                                            : Colors.grey.shade100,
                                        child: Image.network(
                                          currentQuestion.imageUrl!,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (context, child,
                                              loadingProgress) {
                                            if (loadingProgress == null)
                                              return child;
                                            return Center(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  SizedBox(
                                                    width: 24,
                                                    height: 24,
                                                    child:
                                                        CircularProgressIndicator(
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                                  Color>(
                                                              AppColors
                                                                  .limeGreen),
                                                      strokeWidth: 2,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    "Loading image...",
                                                    style: TextStyle(
                                                      color: textColor
                                                          .withOpacity(0.5),
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Center(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons
                                                        .image_not_supported_outlined,
                                                    color: isDarkMode
                                                        ? Colors.grey.shade600
                                                        : Colors.grey.shade400,
                                                    size: 32,
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    "Image unavailable",
                                                    style: TextStyle(
                                                      color: textColor
                                                          .withOpacity(0.5),
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ).animate().fadeIn(
                                duration: const Duration(milliseconds: 500)),

                            const SizedBox(height: 20),

                            // Options section with enhanced design
                            ...currentQuestion.options
                                .asMap()
                                .entries
                                .map((entry) {
                              final index = entry.key;
                              final option = entry.value;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _buildCompactOptionButton(
                                        option, index, isDarkMode, textColor)
                                    .animate(
                                        delay:
                                            Duration(milliseconds: 100 * index))
                                    .slideX(
                                        begin: 0.2,
                                        duration:
                                            const Duration(milliseconds: 300))
                                    .fadeIn(),
                              );
                            }).toList(),

                            const SizedBox(height: 20),

                            // Enhanced feedback section
                            if (_showFeedback)
                              AnimatedBuilder(
                                animation: _feedbackAnimationController,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: 0.9 +
                                        (_feedbackAnimationController.value *
                                            0.1),
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: _isCorrect!
                                              ? [
                                                  Colors.green.withOpacity(0.1),
                                                  Colors.green
                                                      .withOpacity(0.05),
                                                ]
                                              : [
                                                  Colors.red.withOpacity(0.1),
                                                  Colors.red.withOpacity(0.05),
                                                ],
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: _isCorrect!
                                              ? Colors.green
                                              : Colors.red,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(6),
                                                decoration: BoxDecoration(
                                                  color: (_isCorrect!
                                                          ? Colors.green
                                                          : Colors.red)
                                                      .withOpacity(0.1),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(
                                                  _isCorrect!
                                                      ? Icons.check
                                                      : Icons.close,
                                                  color: _isCorrect!
                                                      ? Colors.green
                                                      : Colors.red,
                                                  size: 18,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  _isCorrect!
                                                      ? 'Correct! Well done! 🎉'
                                                      : 'Not quite right 😅',
                                                  style: TextStyle(
                                                    color: _isCorrect!
                                                        ? Colors.green
                                                        : Colors.red,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (!_isCorrect! &&
                                              _correctOption != null) ...[
                                            const SizedBox(height: 12),
                                            Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: Colors.green
                                                    .withOpacity(0.05),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: Colors.green
                                                      .withOpacity(0.2),
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.lightbulb_outline,
                                                    color: Colors.green,
                                                    size: 16,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      'Correct answer: ${_correctOption!.text}',
                                                      style: TextStyle(
                                                        color: Colors.green,
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),

                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
            ),

            // Enhanced fixed bottom button area
            Container(
              padding: const EdgeInsets.fromLTRB(
                  16, 16, 16, 20), // Fixed bottom padding
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.darkSurface : backgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  height: 56, // Increased height to prevent text cutoff
                  child: ElevatedButton(
                    // Disable button when no option selected
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
                      disabledBackgroundColor: isDarkMode
                          ? Colors.grey.shade800.withOpacity(0.5)
                          : Colors.grey.withOpacity(0.3),
                      disabledForegroundColor: isDarkMode
                          ? Colors.grey.shade500
                          : Colors.black.withOpacity(0.5),
                      elevation: _selectedOptionId != null ? 4 : 0,
                      shadowColor: AppColors.limeGreen.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          !_showFeedback
                              ? Icons.send_rounded
                              : Icons.arrow_forward_rounded,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          !_showFeedback ? 'Submit Answer' : 'Next Question',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate(target: _selectedOptionId != null ? 1 : 0)
                      .shimmer(duration: const Duration(milliseconds: 1000)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Enhanced compact option button design
  Widget _buildCompactOptionButton(
      GameOption option, int index, bool isDarkMode, Color textColor) {
    final isSelected = _selectedOptionId == option.id;
    final isIncorrectSelection =
        isSelected && !option.isCorrect && _showFeedback;
    final isCorrectAnswer = option.isCorrect && _showFeedback;

    // Determine option color based on state
    Color optionColor = isDarkMode ? AppColors.darkSurface : Colors.white;
    Color borderColor =
        isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200;

    if (isCorrectAnswer) {
      optionColor = isDarkMode ? Colors.green.shade900 : Colors.green.shade50;
      borderColor = Colors.green;
    } else if (isIncorrectSelection) {
      optionColor = isDarkMode ? Colors.red.shade900 : Colors.red.shade50;
      borderColor = Colors.red;
    } else if (isSelected) {
      optionColor = isDarkMode
          ? AppColors.limeGreen.withOpacity(0.15)
          : AppColors.limeGreen.withOpacity(0.08);
      borderColor = AppColors.limeGreen;
    }

    return GestureDetector(
      onTap: _showFeedback
          ? null
          : () {
              setState(() => _selectedOptionId = option.id);
              HapticFeedback.selectionClick();
            },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: optionColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected && !_showFeedback
              ? [
                  BoxShadow(
                    color: AppColors.limeGreen.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Row(
          children: [
            // Enhanced option letter circle
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: [
                          AppColors.limeGreen,
                          AppColors.limeGreen.withOpacity(0.8)
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: !isSelected
                    ? (isDarkMode ? Colors.grey.shade700 : Colors.grey.shade100)
                    : null,
                shape: BoxShape.circle,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.limeGreen.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  String.fromCharCode(65 + index),
                  style: TextStyle(
                    color: isSelected
                        ? Colors.black
                        : (isDarkMode ? Colors.white : Colors.black87),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
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
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  height: 1.4,
                ),
              ),
            ),
            // Status icon for feedback
            if (_showFeedback && (isSelected || option.isCorrect))
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: (option.isCorrect ? Colors.green : Colors.red)
                      .withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  option.isCorrect ? Icons.check_rounded : Icons.close_rounded,
                  color: option.isCorrect ? Colors.green : Colors.red,
                  size: 18,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // This method should be overridden by subclasses to provide specific UI
  @protected
  Widget buildQuestionContent(
      GameQuestion question, bool isDarkMode, Color textColor) {
    // This method is kept for backward compatibility but the new layout
    // handles content directly in the build method
    return const SizedBox.shrink();
  }

  // Helper method to build option buttons - kept for backward compatibility
  @protected
  Widget buildOptionButton(
      GameOption option, int index, bool isDarkMode, Color textColor) {
    return _buildCompactOptionButton(option, index, isDarkMode, textColor);
  }
}
