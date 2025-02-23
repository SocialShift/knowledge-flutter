import 'package:freezed_annotation/freezed_annotation.dart';

part 'onboarding_state.g.dart';
part 'onboarding_state.freezed.dart';

@freezed
class OnboardingState with _$OnboardingState {
  const factory OnboardingState({
    @Default(false) bool isCompleted,
    @Default(0) int currentStep,
    @Default('') String race,
    @Default('') String gender,
    @Default('') String ethnicity,
    @Default('') String discoverySource,
    @Default('') String primaryInterest,
    @Default([]) List<String> selectedTopics,
    @Default([]) List<String> selectedInterests,
    @Default({}) Map<String, dynamic> responses,
  }) = _OnboardingState;

  factory OnboardingState.fromJson(Map<String, dynamic> json) =>
      _$OnboardingStateFromJson(json);
}
