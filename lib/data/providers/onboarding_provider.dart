import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:knowledge/data/models/onboarding_state.dart';

part 'onboarding_provider.g.dart';

@riverpod
class OnboardingNotifier extends _$OnboardingNotifier {
  @override
  OnboardingState build() => const OnboardingState();

  void updateRace(String race) {
    state = state.copyWith(race: race);
  }

  void updateGender(String gender) {
    state = state.copyWith(gender: gender);
  }

  void updateEthnicity(String ethnicity) {
    state = state.copyWith(ethnicity: ethnicity);
  }

  void toggleTopic(String topic) {
    final topics = List<String>.from(state.selectedTopics);
    if (topics.contains(topic)) {
      topics.remove(topic);
    } else {
      topics.add(topic);
    }
    state = state.copyWith(selectedTopics: topics);
  }

  void nextStep() {
    state = state.copyWith(currentStep: state.currentStep + 1);
  }

  void toggleInterest(String interest) {
    final interests = List<String>.from(state.selectedInterests);
    if (interests.contains(interest)) {
      interests.remove(interest);
    } else {
      interests.add(interest);
    }
    state = state.copyWith(selectedInterests: interests);
  }

  void completeOnboarding() {
    state = state.copyWith(
      isCompleted: true,
      currentStep: state.currentStep + 1,
    );
  }

  void updateDiscoverySource(String source) {
    state = state.copyWith(discoverySource: source);
  }

  void updatePrimaryInterest(String interest) {
    state = state.copyWith(primaryInterest: interest);
  }
}
