import 'package:freezed_annotation/freezed_annotation.dart';

part 'pro_onboarding_state.freezed.dart';
part 'pro_onboarding_state.g.dart';

@freezed
class ProOnboardingState with _$ProOnboardingState {
  const factory ProOnboardingState({
    @Default(0) int currentStep,
    @Default([]) List<String> previousInterests,
    @Default([]) List<String> selectedInterests,
    @Default(false) bool isUpdateMode,
    @Default({}) Map<String, String> quizAnswers,
    @Default(false) bool isCompleted,
  }) = _ProOnboardingState;

  factory ProOnboardingState.fromJson(Map<String, dynamic> json) =>
      _$ProOnboardingStateFromJson(json);
}
