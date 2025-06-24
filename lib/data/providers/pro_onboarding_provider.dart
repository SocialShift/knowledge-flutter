import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:knowledge/data/models/pro_onboarding_state.dart';
import 'package:knowledge/data/repositories/profile_repository.dart';

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

  void answerQuizQuestion(String questionId, String answer) {
    final updatedAnswers = Map<String, String>.from(state.quizAnswers);
    updatedAnswers[questionId] = answer;
    state = state.copyWith(quizAnswers: updatedAnswers);
  }

  Future<void> completeOnboarding() async {
    try {
      final profileRepository = ref.read(profileRepositoryProvider);

      // Update profile with new interests and quiz answers using the repository method
      await profileRepository.updateProOnboardingData(
        interests: state.selectedInterests,
        quizAnswers: state.quizAnswers,
      );

      state = state.copyWith(isCompleted: true);

      print(
          'Pro onboarding completed with interests: ${state.selectedInterests}');
      print('Quiz answers: ${state.quizAnswers}');
    } catch (e) {
      print('Error completing pro onboarding: $e');
      throw 'Failed to complete pro onboarding: $e';
    }
  }
}
