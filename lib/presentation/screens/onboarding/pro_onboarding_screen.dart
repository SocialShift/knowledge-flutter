import 'package:flutter/material.dart';
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
                      if (proOnboardingState.currentStep == 0)
                        _buildIntroSection(
                            context, proOnboardingState, notifier)
                      else if (proOnboardingState.currentStep == 1)
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

  Widget _buildIntroSection(
    BuildContext context,
    ProOnboardingState state,
    ProOnboardingNotifier notifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Now, you\'ve taken a bold step forward in expanding your historical know{ledge} with us.',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.navyBlue,
                height: 1.3,
              ),
        ).animate().fadeIn(duration: const Duration(milliseconds: 600)),
        const SizedBox(height: 24),
        Text(
          'Let\'s take a brief quiz to get a sense of what you know today—so we can craft a personalized, engaging journey just for you.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
            height: 1.4,
          ),
        ).animate().fadeIn(delay: const Duration(milliseconds: 300)),
        const SizedBox(height: 32),
        // Add some visual elements to make it more engaging
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.limeGreen.withOpacity(0.1),
                AppColors.lightPurple.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.limeGreen.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.limeGreen.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(
                  Icons.psychology_rounded,
                  color: AppColors.navyBlue,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Personalized Learning',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.navyBlue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tailored content based on your interests and knowledge level',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: const Duration(milliseconds: 600)).slideY(
              begin: 0.2,
              duration: const Duration(milliseconds: 800),
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
        if (state.previousInterests.isNotEmpty && !state.isUpdateMode)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Based on your first quiz, you said you were most interested in:',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: state.previousInterests.map((interest) {
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
        if (state.isUpdateMode || state.previousInterests.isEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (state.previousInterests.isEmpty)
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
    // Get current question index based on answered questions
    final answeredQuestions = state.quizAnswers.length;
    final currentQuestionIndex = answeredQuestions;

    // Quiz questions data
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
    ];

    if (currentQuestionIndex >= quizQuestions.length) {
      // All questions answered, show completion message
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Let\'s Test Your Know(ledge)',
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
                  Icons.quiz_rounded,
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
              ],
            ),
          ),
        ],
      );
    }

    final currentQuestion = quizQuestions[currentQuestionIndex];
    final selectedAnswer = state.quizAnswers[currentQuestion['id']];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Let\'s Test Your Know(ledge)',
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
          'A few quick, playful questions to see what you already know (and spark curiosity).',
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
              ...(currentQuestion['options'] as List<String>).map((option) {
                final isSelected = selectedAnswer == option;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AnimatedScale(
                    scale: isSelected ? 1.02 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: GestureDetector(
                      onTap: () => notifier.answerQuizQuestion(
                        currentQuestion['id'] as String,
                        option,
                      ),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.limeGreen
                              : AppColors.lightPurple.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: isSelected
                              ? Border.all(
                                  color: AppColors.navyBlue,
                                  width: 2,
                                )
                              : null,
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
                          option,
                          style: TextStyle(
                            color: isSelected
                                ? AppColors.navyBlue
                                : Colors.black87,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ).animate().fadeIn().slideY(
              begin: 0.2,
              duration: const Duration(milliseconds: 600),
            ),
      ],
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
          'You\'re in. Your journey is now tailored to your interests, knowledge, and curiosity.',
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
              Row(
                children: [
                  Icon(
                    Icons.auto_stories_rounded,
                    color: AppColors.navyBlue,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Personalized story recommendations',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.navyBlue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.insights_rounded,
                    color: AppColors.navyBlue,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Daily insights based on your knowledge level',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.navyBlue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.timeline_rounded,
                    color: AppColors.navyBlue,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Curated historical timelines for your interests',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.navyBlue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
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

  Widget _buildNavigationButtons(
    BuildContext context,
    ProOnboardingState state,
    ProOnboardingNotifier notifier,
  ) {
    final isLastStep = state.currentStep == 3;
    bool canProceed = false;

    switch (state.currentStep) {
      case 0:
        canProceed = true; // Intro can always proceed
        break;
      case 1:
        canProceed = state.selectedInterests.isNotEmpty && !state.isUpdateMode;
        break;
      case 2:
        canProceed = state.quizAnswers.length >= 3; // All 3 questions answered
        break;
      case 3:
        canProceed = true; // Final step
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Row(
        children: [
          const Spacer(),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.limeGreen,
              foregroundColor: AppColors.navyBlue,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
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
                              content: Text('Error completing onboarding: $e'),
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
                Text(isLastStep
                    ? 'Start My Personalized Path'
                    : state.currentStep == 0
                        ? 'Let\'s Begin'
                        : 'Next'),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward, size: 16),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: const Duration(milliseconds: 400));
  }
}
