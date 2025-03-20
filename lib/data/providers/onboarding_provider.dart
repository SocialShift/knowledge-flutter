import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:knowledge/data/models/onboarding_state.dart';

part 'onboarding_provider.g.dart';

@riverpod
class OnboardingNotifier extends _$OnboardingNotifier {
  @override
  OnboardingState build() => const OnboardingState();

  void updateRace(String race) {
    state = state.copyWith(
      race: race,
      responses: {...state.responses, 'race': race},
    );
  }

  void updateGender(String gender) {
    state = state.copyWith(
      gender: gender,
      responses: {...state.responses, 'gender': gender},
    );
  }

  void updateEthnicity(String ethnicity) {
    state = state.copyWith(
      ethnicity: ethnicity,
      responses: {...state.responses, 'ethnicity': ethnicity},
    );
  }

  void toggleTopic(String topic) {
    final topics = List<String>.from(state.selectedTopics);
    if (topics.contains(topic)) {
      topics.remove(topic);
    } else {
      topics.add(topic);
    }
    state = state.copyWith(
      selectedTopics: topics,
      responses: {...state.responses, 'topics': topics},
    );
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
    state = state.copyWith(
      selectedInterests: interests,
      responses: {...state.responses, 'interests': interests},
    );
  }

  void setResponse(String key, dynamic value) {
    state = state.copyWith(
      responses: {...state.responses, key: value},
    );
  }

  void completeOnboarding() {
    state = state.copyWith(isCompleted: true);
  }

  void resetOnboarding() {
    state = const OnboardingState();
  }

  void updateDiscoverySource(String source) {
    state = state.copyWith(
      discoverySource: source,
      responses: {...state.responses, 'discovery_source': source},
    );
  }

  void updateSocialMediaPlatform(String platform) {
    state = state.copyWith(
      socialMediaPlatform: platform,
      responses: {...state.responses, 'social_media_platform': platform},
    );
  }

  void updatePrimaryInterest(String interest) {
    state = state.copyWith(
      primaryInterest: interest,
      responses: {...state.responses, 'primary_interest': interest},
    );
  }
}
