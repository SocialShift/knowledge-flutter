// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProfileImpl _$$ProfileImplFromJson(Map<String, dynamic> json) =>
    _$ProfileImpl(
      nickname: json['nickname'] as String?,
      email: json['email'] as String,
      pronouns: json['pronouns'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      languagePreference: json['languagePreference'] as String?,
      location: json['location'] as String?,
      personalizationQuestions:
          json['personalizationQuestions'] as Map<String, dynamic>?,
      points: (json['points'] as num?)?.toInt(),
      referralCode: json['referralCode'] as String?,
      totalReferrals: (json['totalReferrals'] as num?)?.toInt(),
      rank: (json['rank'] as num?)?.toInt(),
      totalUsers: (json['totalUsers'] as num?)?.toInt(),
      percentile: (json['percentile'] as num?)?.toInt(),
      completedQuizzes: (json['completedQuizzes'] as num?)?.toInt(),
      currentLoginStreak: (json['currentLoginStreak'] as num?)?.toInt(),
      maxLoginStreak: (json['maxLoginStreak'] as num?)?.toInt(),
      daysToNextMilestone: (json['daysToNextMilestone'] as num?)?.toInt(),
      nextMilestone: (json['nextMilestone'] as num?)?.toInt(),
      streakBonus: (json['streakBonus'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$ProfileImplToJson(_$ProfileImpl instance) =>
    <String, dynamic>{
      'nickname': instance.nickname,
      'email': instance.email,
      'pronouns': instance.pronouns,
      'avatarUrl': instance.avatarUrl,
      'languagePreference': instance.languagePreference,
      'location': instance.location,
      'personalizationQuestions': instance.personalizationQuestions,
      'points': instance.points,
      'referralCode': instance.referralCode,
      'totalReferrals': instance.totalReferrals,
      'rank': instance.rank,
      'totalUsers': instance.totalUsers,
      'percentile': instance.percentile,
      'completedQuizzes': instance.completedQuizzes,
      'currentLoginStreak': instance.currentLoginStreak,
      'maxLoginStreak': instance.maxLoginStreak,
      'daysToNextMilestone': instance.daysToNextMilestone,
      'nextMilestone': instance.nextMilestone,
      'streakBonus': instance.streakBonus,
    };
