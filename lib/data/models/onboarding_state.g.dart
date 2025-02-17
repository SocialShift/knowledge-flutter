// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OnboardingStateImpl _$$OnboardingStateImplFromJson(
        Map<String, dynamic> json) =>
    _$OnboardingStateImpl(
      race: json['race'] as String? ?? '',
      gender: json['gender'] as String? ?? '',
      ethnicity: json['ethnicity'] as String? ?? '',
      selectedTopics: (json['selectedTopics'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      selectedInterests: (json['selectedInterests'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      discoverySource: json['discoverySource'] as String? ?? '',
      primaryInterest: json['primaryInterest'] as String? ?? '',
      currentStep: (json['currentStep'] as num?)?.toInt() ?? 0,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );

Map<String, dynamic> _$$OnboardingStateImplToJson(
        _$OnboardingStateImpl instance) =>
    <String, dynamic>{
      'race': instance.race,
      'gender': instance.gender,
      'ethnicity': instance.ethnicity,
      'selectedTopics': instance.selectedTopics,
      'selectedInterests': instance.selectedInterests,
      'discoverySource': instance.discoverySource,
      'primaryInterest': instance.primaryInterest,
      'currentStep': instance.currentStep,
      'isCompleted': instance.isCompleted,
    };
