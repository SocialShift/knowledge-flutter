// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OnboardingStateImpl _$$OnboardingStateImplFromJson(
        Map<String, dynamic> json) =>
    _$OnboardingStateImpl(
      isCompleted: json['isCompleted'] as bool? ?? false,
      currentStep: (json['currentStep'] as num?)?.toInt() ?? 0,
      race: json['race'] as String? ?? '',
      gender: json['gender'] as String? ?? '',
      ethnicity: json['ethnicity'] as String? ?? '',
      discoverySource: json['discoverySource'] as String? ?? '',
      socialMediaPlatform: json['socialMediaPlatform'] as String? ?? '',
      primaryInterest: json['primaryInterest'] as String? ?? '',
      selectedTopics: (json['selectedTopics'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      selectedInterests: (json['selectedInterests'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      responses: json['responses'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$$OnboardingStateImplToJson(
        _$OnboardingStateImpl instance) =>
    <String, dynamic>{
      'isCompleted': instance.isCompleted,
      'currentStep': instance.currentStep,
      'race': instance.race,
      'gender': instance.gender,
      'ethnicity': instance.ethnicity,
      'discoverySource': instance.discoverySource,
      'socialMediaPlatform': instance.socialMediaPlatform,
      'primaryInterest': instance.primaryInterest,
      'selectedTopics': instance.selectedTopics,
      'selectedInterests': instance.selectedInterests,
      'responses': instance.responses,
    };
