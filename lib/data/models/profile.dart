import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile.g.dart';
part 'profile.freezed.dart';

@freezed
class Profile with _$Profile {
  const factory Profile({
    String? nickname,
    required String email,
    required bool isPremium,
    String? pronouns,
    String? avatarUrl,
    String? languagePreference,
    String? location,
    Map<String, dynamic>? personalizationQuestions,
    int? points,
    String? referralCode,
    int? totalReferrals,
    String? joinedDate,
    Map<String, dynamic>? followers,
    Map<String, dynamic>? following,
    // Stats fields
    int? rank,
    int? totalUsers,
    int? percentile,
    int? completedQuizzes,
    int? currentLoginStreak,
    int? maxLoginStreak,
    int? daysToNextMilestone,
    int? nextMilestone,
    int? streakBonus,
  }) = _Profile;

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);

  // Factory constructor to handle the nested API response
  factory Profile.fromApiResponse(Map<String, dynamic> json) {
    final user = json['user'] ?? {};
    final profile = json['profile'] ?? {};
    final stats = json['stats'] ?? {};

    // Create a followers map that includes both count and is_following status
    final Map<String, dynamic> followersMap = {
      ...(profile['followers'] as Map<String, dynamic>? ?? {})
    };

    // Add profile_id to the followers map for simpler access later
    if (!followersMap.containsKey('profile_id')) {
      followersMap['profile_id'] = profile['id'];
    }

    // Make sure is_following is included in the followers map
    if (!followersMap.containsKey('is_following') &&
        profile.containsKey('is_following')) {
      followersMap['is_following'] = profile['is_following'];
    }

    return Profile(
      email: user['email'] ?? '',
      isPremium: profile['is_premium'] ?? false,
      joinedDate: user['joined_at'],
      nickname: profile['nickname'],
      avatarUrl: profile['avatar_url'],
      languagePreference: profile['language_preference'],
      pronouns: profile['pronouns'],
      location: profile['location'],
      personalizationQuestions: profile['personalization_questions'],
      points: profile['points'],
      referralCode: profile['referral_code'],
      totalReferrals: profile['total_referrals'],
      followers: followersMap,
      following: profile['following'],
      // Stats
      rank: stats['rank'],
      totalUsers: stats['total_users'],
      percentile: stats['percentile'],
      completedQuizzes: stats['completed_quizzes'],
      currentLoginStreak: stats['current_login_streak'],
      maxLoginStreak: stats['max_login_streak'],
      daysToNextMilestone: stats['days_to_next_milestone'],
      nextMilestone: stats['next_milestone'],
      streakBonus: stats['streak_bonus'],
    );
  }
}
