// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leaderboard.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LeaderboardResponse _$LeaderboardResponseFromJson(Map<String, dynamic> json) =>
    LeaderboardResponse(
      leaderboard: (json['leaderboard'] as List<dynamic>)
          .map((e) => LeaderboardUser.fromJson(e as Map<String, dynamic>))
          .toList(),
      userRank: (json['user_rank'] as num).toInt(),
    );

Map<String, dynamic> _$LeaderboardResponseToJson(
        LeaderboardResponse instance) =>
    <String, dynamic>{
      'leaderboard': instance.leaderboard,
      'user_rank': instance.userRank,
    };

LeaderboardUser _$LeaderboardUserFromJson(Map<String, dynamic> json) =>
    LeaderboardUser(
      rank: (json['rank'] as num).toInt(),
      userId: (json['user_id'] as num).toInt(),
      nickname: json['nickname'] as String,
      avatarUrl: json['avatar_url'] as String,
      points: (json['points'] as num).toInt(),
      currentStreak: (json['current_streak'] as num).toInt(),
      maxStreak: (json['max_streak'] as num).toInt(),
      badge: json['badge'] as String? ?? '',
    );

Map<String, dynamic> _$LeaderboardUserToJson(LeaderboardUser instance) =>
    <String, dynamic>{
      'rank': instance.rank,
      'user_id': instance.userId,
      'nickname': instance.nickname,
      'avatar_url': instance.avatarUrl,
      'points': instance.points,
      'current_streak': instance.currentStreak,
      'max_streak': instance.maxStreak,
      'badge': instance.badge,
    };
