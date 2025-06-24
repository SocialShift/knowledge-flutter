// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pro_onboarding_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProOnboardingStateImpl _$$ProOnboardingStateImplFromJson(
        Map<String, dynamic> json) =>
    _$ProOnboardingStateImpl(
      currentStep: (json['currentStep'] as num?)?.toInt() ?? 0,
      previousInterests: (json['previousInterests'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      selectedInterests: (json['selectedInterests'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      isUpdateMode: json['isUpdateMode'] as bool? ?? false,
      quizAnswers: (json['quizAnswers'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
      isCompleted: json['isCompleted'] as bool? ?? false,
    );

Map<String, dynamic> _$$ProOnboardingStateImplToJson(
        _$ProOnboardingStateImpl instance) =>
    <String, dynamic>{
      'currentStep': instance.currentStep,
      'previousInterests': instance.previousInterests,
      'selectedInterests': instance.selectedInterests,
      'isUpdateMode': instance.isUpdateMode,
      'quizAnswers': instance.quizAnswers,
      'isCompleted': instance.isCompleted,
    };
