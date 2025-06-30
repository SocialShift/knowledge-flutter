import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:knowledge/data/models/pro_onboarding_state.dart';
import 'package:knowledge/data/repositories/profile_repository.dart';
import 'package:knowledge/data/providers/onboarding_provider.dart';

part 'pro_onboarding_provider.g.dart';

@riverpod
class ProOnboardingNotifier extends _$ProOnboardingNotifier {
  @override
  ProOnboardingState build() {
    return const ProOnboardingState();
  }

  Future<void> initializeFromProfile() async {
    try {
      final profileRepository = ref.read(profileRepositoryProvider);
      final profile = await profileRepository.getUserProfile();

      // Extract interests from personalization_questions
      final personalizationQuestions = profile.personalizationQuestions ?? {};
      final interests =
          personalizationQuestions['interests'] as List<dynamic>? ?? [];
      final previousInterests = interests.map((e) => e.toString()).toList();

      state = state.copyWith(
        previousInterests: previousInterests,
        selectedInterests: previousInterests,
      );
    } catch (e) {
      print('Error loading profile data: $e');
    }
  }

  void nextStep() {
    if (state.currentStep < 3) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  void toggleUpdateMode() {
    state = state.copyWith(isUpdateMode: !state.isUpdateMode);
  }

  void toggleInterest(String interest) {
    final currentInterests = List<String>.from(state.selectedInterests);
    if (currentInterests.contains(interest)) {
      currentInterests.remove(interest);
    } else {
      currentInterests.add(interest);
    }
    state = state.copyWith(selectedInterests: currentInterests);
  }

  void confirmInterests() {
    state = state.copyWith(isUpdateMode: false);
  }

  Future<void> answerQuizQuestion(String questionId, String answer) async {
    // Set loading state
    state = state.copyWith(
      isSubmittingAnswer: true,
      currentQuestionId: questionId,
    );

    // Quiz questions with correct answers
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

    // Find the question and check if answer is correct
    final question = quizQuestions.firstWhere(
      (q) => q['id'] == questionId,
      orElse: () => {},
    );

    final isCorrect =
        question.isNotEmpty && question['correctAnswer'] == answer;

    // Update answers and results
    final updatedAnswers = Map<String, String>.from(state.quizAnswers);
    final updatedResults = Map<String, bool>.from(state.quizResults);

    updatedAnswers[questionId] = answer;
    updatedResults[questionId] = isCorrect;

    // Simulate network delay for better UX
    await Future.delayed(const Duration(milliseconds: 500));

    // Update state with answer and show feedback
    state = state.copyWith(
      quizAnswers: updatedAnswers,
      quizResults: updatedResults,
      isSubmittingAnswer: false,
      showQuizFeedback: true,
    );

    // No longer auto-hiding feedback - will be controlled by the Continue button
  }

  void hideFeedback() {
    state = state.copyWith(
      showQuizFeedback: false,
      currentQuestionId: '',
    );
  }

  Future<void> completeOnboarding() async {
    try {
      final profileRepository = ref.read(profileRepositoryProvider);
      final onboardingState = ref.read(onboardingNotifierProvider);

      // Get current profile to merge existing personalization questions
      final profile = await profileRepository.getUserProfile();
      final existingPersonalizationQuestions =
          profile.personalizationQuestions ?? {};

      // Prepare personalization questions in the same format as profile setup
      final Map<String, dynamic> personalizationQuestions = {
        ...existingPersonalizationQuestions,

        // Include all onboarding responses
        'race': onboardingState.race,
        'gender': onboardingState.gender,
        'ethnicity': onboardingState.ethnicity,
        'discovery_source': onboardingState.discoverySource,
        'social_media_platform': onboardingState.socialMediaPlatform,
        'selected_interests': onboardingState.selectedInterests,

        // Add pro onboarding specific data
        'pro_onboarding_interests': state.selectedInterests,
        'pro_onboarding_quiz_answers': state.quizAnswers,
        'pro_onboarding_quiz_results': state.quizResults,
        'pro_onboarding_completed': true,
        'pro_onboarding_completed_at': DateTime.now().toIso8601String(),
      };

      // Use the same update method as profile setup for consistency
      await profileRepository.updateProfile(
        nickname: profile.nickname ?? '',
        pronouns: profile.pronouns ?? '',
        email: profile.email ?? '',
        location: profile.location,
        languagePreference: profile.languagePreference,
        avatarUrl: profile.avatarUrl,
        personalizationQuestions: personalizationQuestions,
      );

      state = state.copyWith(isCompleted: true);

      print('Pro onboarding completed successfully');
      print('Updated interests: ${state.selectedInterests}');
      print('Quiz results: ${state.quizResults}');
    } catch (e) {
      print('Error completing pro onboarding: $e');
      throw 'Failed to complete pro onboarding: $e';
    }
  }
}
