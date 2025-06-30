import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:knowledge/data/providers/pro_onboarding_provider.dart';
import 'package:knowledge/data/models/pro_onboarding_state.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:knowledge/core/themes/app_theme.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class ProOnboardingScreen extends HookConsumerWidget {
  const ProOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final proOnboardingState = ref.watch(proOnboardingNotifierProvider);
    final notifier = ref.read(proOnboardingNotifierProvider.notifier);

    // Initialize profile data on first load
    useEffect(() {
      notifier.initializeFromProfile();
      return null;
    }, []);

    // If it's the first step (welcome screen), show full screen
    if (proOnboardingState.currentStep == 0) {
      return _buildFullScreenWelcome(context, proOnboardingState, notifier);
    }

    // For other steps, show normal layout
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              LinearProgressIndicator(
                value: (proOnboardingState.currentStep + 1) / 4,
                backgroundColor: AppColors.lightGray,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.limeGreen),
              ).animate().fadeIn().slideX(),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (proOnboardingState.currentStep == 1)
                        _buildInterestsSection(
                            context, proOnboardingState, notifier)
                      else if (proOnboardingState.currentStep == 2)
                        _buildQuizSection(context, proOnboardingState, notifier)
                      else
                        _buildFinalSection(
                            context, proOnboardingState, notifier),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              _buildNavigationButtons(context, proOnboardingState, notifier),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFullScreenWelcome(
    BuildContext context,
    ProOnboardingState state,
    ProOnboardingNotifier notifier,
  ) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.navyBlue,
              Color(0xFF3949AB),
              AppColors.navyBlue.withOpacity(0.9),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),

                // Welcome icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.limeGreen.withOpacity(0.2),
                    border: Border.all(
                      color: AppColors.limeGreen,
                      width: 3,
                    ),
                  ),
                  child: Icon(
                    Icons.psychology_rounded,
                    size: 50,
                    color: AppColors.limeGreen,
                  ),
                ).animate().fadeIn().scale(
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.elasticOut,
                    ),

                const SizedBox(height: 32),

                // Welcome text
                Text(
                  'Welcome to Your',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w300,
                      ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: const Duration(milliseconds: 300)),

                const SizedBox(height: 8),

                Text(
                  'Know[ledge] Journey',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.limeGreen,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: const Duration(milliseconds: 500)),

                const SizedBox(height: 16),

                Text(
                  'You\'ve taken a bold step forward in expanding your historical knowledge with us.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: const Duration(milliseconds: 700)),

                const SizedBox(height: 20),

                Text(
                  'Let\'s take a brief quiz to get a sense of what you know today—so we can craft a personalized, engaging journey just for you.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: const Duration(milliseconds: 900)),

                const SizedBox(height: 28),

                // Features preview
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.limeGreen.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildFeatureItem(
                        icon: Icons.auto_stories_rounded,
                        title: 'Personalized Learning',
                        subtitle: 'Tailored content based on your interests',
                      ),
                      const SizedBox(height: 14),
                      _buildFeatureItem(
                        icon: Icons.quiz_outlined,
                        title: 'Interactive Quizzes',
                        subtitle: 'Test and expand your knowledge',
                      ),
                      const SizedBox(height: 14),
                      _buildFeatureItem(
                        icon: Icons.timeline_rounded,
                        title: 'Historical Timelines',
                        subtitle: 'Explore diverse narratives and perspectives',
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(delay: const Duration(milliseconds: 1100))
                    .slideY(
                      begin: 0.3,
                      duration: const Duration(milliseconds: 800),
                    ),

                const SizedBox(height: 32),

                // Start button
                Container(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.limeGreen,
                      foregroundColor: AppColors.navyBlue,
                      elevation: 8,
                      shadowColor: AppColors.limeGreen.withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      print('Let\'s Begin button pressed!');
                      notifier.nextStep();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Let\'s Begin',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.arrow_forward, size: 20),
                      ],
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(delay: const Duration(milliseconds: 1300))
                    .slideY(
                      begin: 0.3,
                      duration: const Duration(milliseconds: 800),
                    ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.limeGreen.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: AppColors.limeGreen,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInterestsSection(
    BuildContext context,
    ProOnboardingState state,
    ProOnboardingNotifier notifier,
  ) {
    final interests = [
      'Indigenous Histories and Cultures',
      'African Diaspora and Black History',
      'LGBTQ+ Movements and Milestones',
      'Women\'s Histories and Contributions',
      'Immigrant and Refugee Stories',
      'Colonialism and Post-Colonial Histories',
      'Civil Rights and Social Justice Movements',
      'Lesser-Known Historical Figures',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Discovering Your Starting Point',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.navyBlue,
              ),
        ).animate().fadeIn(duration: const Duration(milliseconds: 600)),
        const SizedBox(height: 16),
        if (state.selectedInterests.isNotEmpty && !state.isUpdateMode)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                state.previousInterests.isNotEmpty
                    ? 'Based on your previous selections, you were interested in:'
                    : 'You have selected these interests:',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: state.selectedInterests.map((interest) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.limeGreen,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.limeGreen.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: Text(
                      interest,
                      style: TextStyle(
                        color: AppColors.navyBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => notifier.confirmInterests(),
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Confirm'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.navyBlue,
                        side: BorderSide(color: AppColors.navyBlue),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => notifier.toggleUpdateMode(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Update'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.limeGreen,
                        foregroundColor: AppColors.navyBlue,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        if (state.isUpdateMode || state.selectedInterests.isEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (state.selectedInterests.isEmpty)
                Text(
                  'Select the historical topics that interest you most:',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              const SizedBox(height: 16),
              Text(
                'Select all that apply',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: interests.map((interest) {
                  final isSelected = state.selectedInterests.contains(interest);
                  return AnimatedScale(
                    scale: isSelected ? 1.05 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: GestureDetector(
                      onTap: () => notifier.toggleInterest(interest),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.limeGreen
                              : AppColors.lightPurple.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.limeGreen.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : null,
                        ),
                        child: Text(
                          interest,
                          style: TextStyle(
                            color: isSelected
                                ? AppColors.navyBlue
                                : Colors.black87,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              if (state.isUpdateMode)
                Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: state.selectedInterests.isNotEmpty
                          ? () => notifier.confirmInterests()
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.limeGreen,
                        foregroundColor: AppColors.navyBlue,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Confirm Selection'),
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }

  Widget _buildQuizSection(
    BuildContext context,
    ProOnboardingState state,
    ProOnboardingNotifier notifier,
  ) {
    // Quiz questions data with corrected answers
    final quizQuestions = [
      {
        'id': 'q1',
        'question': 'In what year was the Stonewall Uprising?',
        'options': ['1959', '1963', '1969', '1973'],
        'correctAnswer': '1969',
      },
      {
        'id': 'q2',
        'question': 'Who was Mabel Ping-Hua Lee?',
        'options': [
          'A fashion designer during the Harlem Renaissance',
          'The first Chinese American mayor',
          'A founding member of the Black Panther Party',
          'A suffragist who marched for the right to vote but was barred from voting herself',
        ],
        'correctAnswer':
            'A suffragist who marched for the right to vote but was barred from voting herself',
      },
      {
        'id': 'q3',
        'question': 'What is "Black Wall Street" a reference to?',
        'options': [
          'The birthplace of the NAACP',
          'Tulsa\'s thriving Black business district destroyed in 1921',
          'A Harlem jazz club in the 1920s',
          'The nickname for the civil rights court in Alabama',
        ],
        'correctAnswer':
            'Tulsa\'s thriving Black business district destroyed in 1921',
      },
      {
        'id': 'q4',
        'question':
            'Which historical figure was known as the "Moses of her people"?',
        'options': [
          'Sojourner Truth',
          'Harriet Tubman',
          'Ida B. Wells',
          'Mary McLeod Bethune',
        ],
        'correctAnswer': 'Harriet Tubman',
      },
    ];

    // Get current question index based on answered questions
    final answeredQuestions = state.quizAnswers.length;
    final currentQuestionIndex = answeredQuestions;

    if (currentQuestionIndex >= quizQuestions.length) {
      // All questions answered, show completion message
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quiz Complete! 🎉',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.navyBlue,
                ),
          ).animate().fadeIn(duration: const Duration(milliseconds: 600)),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.limeGreen.withOpacity(0.1),
                  AppColors.lightPurple.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.celebration_rounded,
                  size: 48,
                  color: AppColors.navyBlue,
                ),
                const SizedBox(height: 16),
                Text(
                  'Great job! You\'ve completed the quiz.',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.navyBlue,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Your responses will help us personalize your learning experience.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                _buildQuizResults(state, quizQuestions),
              ],
            ),
          ),
        ],
      );
    }

    final currentQuestion = quizQuestions[currentQuestionIndex];
    final questionId = currentQuestion['id'] as String;
    final selectedAnswer = state.quizAnswers[questionId];
    final isCorrect = state.quizResults[questionId];
    final showFeedback =
        state.showQuizFeedback && state.currentQuestionId == questionId;

    // Create a state hook for tracking the temporary selection before submission
    final selectedOption = useState<String?>(selectedAnswer);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Let\'s Test Your Know[ledge]',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.navyBlue,
                    ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.limeGreen.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${currentQuestionIndex + 1}/${quizQuestions.length}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.navyBlue,
                ),
              ),
            ),
          ],
        ).animate().fadeIn(duration: const Duration(milliseconds: 600)),
        const SizedBox(height: 16),
        Text(
          'Test your knowledge with these history questions.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 32),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                currentQuestion['question'] as String,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.navyBlue,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 20),
              ...(currentQuestion['options'] as List<String>)
                  .asMap()
                  .entries
                  .map((entry) {
                final index = entry.key;
                final option = entry.value;
                final isSelected = selectedOption.value == option;
                final isCorrectOption =
                    option == currentQuestion['correctAnswer'];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildQuizOption(
                    option: option,
                    index: index,
                    isSelected: isSelected,
                    isCorrectOption: isCorrectOption,
                    showFeedback: showFeedback,
                    onTap: state.isSubmittingAnswer || showFeedback
                        ? null
                        : () {
                            HapticFeedback.selectionClick();
                            selectedOption.value = option;
                          },
                  ),
                );
              }).toList(),
            ],
          ),
        ).animate().fadeIn().slideY(
              begin: 0.2,
              duration: const Duration(milliseconds: 600),
            ),

        // Submit button (similar to base_game_screen)
        if (!showFeedback)
          Padding(
            padding: const EdgeInsets.only(top: 24.0),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed:
                    selectedOption.value != null && !state.isSubmittingAnswer
                        ? () {
                            HapticFeedback.mediumImpact();
                            notifier.answerQuizQuestion(
                                questionId, selectedOption.value!);
                          }
                        : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.limeGreen,
                  foregroundColor: Colors.black,
                  disabledBackgroundColor: Colors.grey.withOpacity(0.3),
                  disabledForegroundColor: Colors.black.withOpacity(0.5),
                  elevation: selectedOption.value != null ? 4 : 0,
                  shadowColor: AppColors.limeGreen.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.send_rounded,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Submit Answer',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Feedback popup and Next button
        if (showFeedback)
          Column(
            children: [
              _buildQuizFeedback(
                  isCorrect!, currentQuestion['correctAnswer'] as String),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    notifier.hideFeedback();
                    // Move to next question if there are more questions
                    if (currentQuestionIndex < quizQuestions.length - 1) {
                      // Reset selected option for next question
                      selectedOption.value = null;
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isCorrect! ? Colors.green : Colors.red.shade400,
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: (isCorrect ? Colors.green : Colors.red)
                        .withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Continue',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildQuizOption({
    required String option,
    required int index,
    required bool isSelected,
    required bool isCorrectOption,
    required bool showFeedback,
    required VoidCallback? onTap,
  }) {
    Color backgroundColor = AppColors.lightPurple.withOpacity(0.3);
    Color borderColor = Colors.transparent;
    Color textColor = Colors.black87;
    Color letterBgColor = Colors.grey.shade300;
    Color letterTextColor = Colors.black54;

    if (showFeedback) {
      if (isCorrectOption) {
        backgroundColor = Colors.green.shade50;
        borderColor = Colors.green;
        textColor = Colors.green.shade800;
        letterBgColor = Colors.green;
        letterTextColor = Colors.white;
      } else if (isSelected && !isCorrectOption) {
        backgroundColor = Colors.red.shade50;
        borderColor = Colors.red;
        textColor = Colors.red.shade800;
        letterBgColor = Colors.red;
        letterTextColor = Colors.white;
      } else if (!isSelected && isCorrectOption) {
        backgroundColor = Colors.green.shade50;
        borderColor = Colors.green;
        textColor = Colors.green.shade800;
        letterBgColor = Colors.green;
        letterTextColor = Colors.white;
      }
    } else if (isSelected) {
      backgroundColor = AppColors.limeGreen;
      borderColor = AppColors.navyBlue;
      textColor = AppColors.navyBlue;
      letterBgColor = AppColors.navyBlue;
      letterTextColor = Colors.white;
    }

    return AnimatedScale(
      scale: isSelected ? 1.02 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: borderColor,
              width: borderColor != Colors.transparent ? 2 : 0,
            ),
            boxShadow: isSelected && !showFeedback
                ? [
                    BoxShadow(
                      color: AppColors.limeGreen.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          child: Row(
            children: [
              // Option letter
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: letterBgColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    String.fromCharCode(65 + index),
                    style: TextStyle(
                      color: letterTextColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Option text
              Expanded(
                child: Text(
                  option,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 15,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
              // Feedback icon
              if (showFeedback && (isSelected || isCorrectOption))
                Icon(
                  isCorrectOption ? Icons.check_circle : Icons.cancel,
                  color: isCorrectOption ? Colors.green : Colors.red,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuizFeedback(bool isCorrect, String correctAnswer) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isCorrect
              ? [Colors.green.withOpacity(0.1), Colors.green.withOpacity(0.05)]
              : [Colors.red.withOpacity(0.1), Colors.red.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCorrect ? Colors.green : Colors.red,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isCorrect ? Icons.check_circle : Icons.cancel,
            color: isCorrect ? Colors.green : Colors.red,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCorrect ? 'Correct! 🎉' : 'Not quite! 🤔',
                  style: TextStyle(
                    color:
                        isCorrect ? Colors.green.shade800 : Colors.red.shade800,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!isCorrect) ...[
                  const SizedBox(height: 4),
                  Text(
                    'The correct answer is: $correctAnswer',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().scale(
          duration: const Duration(milliseconds: 300),
        );
  }

  Widget _buildQuizResults(
      ProOnboardingState state, List<Map<String, dynamic>> questions) {
    final correctCount =
        state.quizResults.values.where((result) => result).length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.limeGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.limeGreen.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Text(
            'Your Score: $correctCount/${questions.length}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.navyBlue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            correctCount >= 3
                ? 'Excellent knowledge!'
                : correctCount >= 2
                    ? 'Good effort!'
                    : 'Keep learning!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinalSection(
    BuildContext context,
    ProOnboardingState state,
    ProOnboardingNotifier notifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                AppColors.limeGreen.withOpacity(0.3),
                AppColors.limeGreen.withOpacity(0.1),
                Colors.transparent,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.limeGreen.withOpacity(0.4),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.all(30),
            child: Icon(
              Icons.celebration_rounded,
              size: 60,
              color: AppColors.navyBlue,
            ),
          ),
        ).animate().fadeIn().scale(
              delay: const Duration(milliseconds: 100),
              duration: const Duration(milliseconds: 800),
              curve: Curves.elasticOut,
            ),
        const SizedBox(height: 32),
        Text(
          'You\'re in! Your journey is now tailored to your interests, knowledge, and curiosity.',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.navyBlue,
                height: 1.3,
              ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: const Duration(milliseconds: 300)),
        const SizedBox(height: 16),
        Text(
          'Expect story paths that resonate. Insights that challenge. And narratives that reflect who you are—and who we\'ve always been.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: const Duration(milliseconds: 500)),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.limeGreen.withOpacity(0.1),
                AppColors.lightPurple.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _buildFeatureRow(
                icon: Icons.auto_stories_rounded,
                text: 'Personalized story recommendations',
              ),
              const SizedBox(height: 12),
              _buildFeatureRow(
                icon: Icons.insights_rounded,
                text: 'Daily insights based on your knowledge level',
              ),
              const SizedBox(height: 12),
              _buildFeatureRow(
                icon: Icons.timeline_rounded,
                text: 'Curated historical timelines for your interests',
              ),
            ],
          ),
        ).animate().fadeIn(delay: const Duration(milliseconds: 700)).slideY(
              begin: 0.2,
              duration: const Duration(milliseconds: 800),
            ),
      ],
    );
  }

  Widget _buildFeatureRow({
    required IconData icon,
    required String text,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.navyBlue,
          size: 24,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.navyBlue,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons(
    BuildContext context,
    ProOnboardingState state,
    ProOnboardingNotifier notifier,
  ) {
    final isLastStep = state.currentStep == 3;
    bool canProceed = false;

    switch (state.currentStep) {
      case 1:
        canProceed = state.selectedInterests.isNotEmpty && !state.isUpdateMode;
        break;
      case 2:
        canProceed = state.quizAnswers.length >= 4; // All 4 questions answered
        break;
      case 3:
        canProceed = true; // Final step
        break;
      default:
        canProceed = false;
    }

    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            const Spacer(),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor:
                    canProceed ? AppColors.limeGreen : Colors.grey.shade300,
                foregroundColor:
                    canProceed ? AppColors.navyBlue : Colors.grey.shade600,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              onPressed: canProceed
                  ? () async {
                      if (!isLastStep) {
                        notifier.nextStep();
                      } else {
                        try {
                          await notifier.completeOnboarding();
                          if (context.mounted) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              context.go('/home');
                            });
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('Error completing onboarding: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      }
                    }
                  : null,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(isLastStep ? 'Start My Personalized Path' : 'Next'),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward, size: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: const Duration(milliseconds: 400));
  }
}
