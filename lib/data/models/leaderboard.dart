import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:json_annotation/json_annotation.dart';

part 'leaderboard.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class LeaderboardResponse {
  final List<LeaderboardUser> leaderboard;
  final int userRank;

  LeaderboardResponse({
    required this.leaderboard,
    required this.userRank,
  });

  factory LeaderboardResponse.fromJson(Map<String, dynamic> json) =>
      _$LeaderboardResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LeaderboardResponseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class LeaderboardUser {
  final int rank;
  final int userId;
  final String nickname;
  final String avatarUrl;
  final int points;
  final int currentStreak;
  final int maxStreak;
  final String badge;

  LeaderboardUser({
    required this.rank,
    required this.userId,
    required this.nickname,
    required this.avatarUrl,
    required this.points,
    required this.currentStreak,
    required this.maxStreak,
    this.badge = '',
  });

  factory LeaderboardUser.fromJson(Map<String, dynamic> json) {
    final mediaBaseUrl = dotenv.env['MEDIA_BASE_URL'] ?? '';

    // Process avatar URL
    String avatarUrl = json['avatar_url'] ?? '';
    if (avatarUrl.isNotEmpty && !avatarUrl.startsWith('http')) {
      avatarUrl = '$mediaBaseUrl/$avatarUrl';
    }

    // Determine badge based on points or other criteria
    String badge = '';
    final points = json['points'] as int? ?? 0;

    if (points >= 2500) {
      badge = 'History Master';
    } else if (points >= 2000) {
      badge = 'Quiz Champion';
    } else if (points >= 1500) {
      badge = 'Knowledge Seeker';
    } else if (points >= 1000) {
      badge = 'Rising Star';
    } else {
      badge = 'Dedicated Learner';
    }

    return LeaderboardUser(
      rank: json['rank'] as int? ?? 0,
      userId: json['user_id'] as int? ?? 0,
      nickname: json['nickname'] as String? ?? '',
      avatarUrl: avatarUrl,
      points: points,
      currentStreak: json['current_streak'] as int? ?? 0,
      maxStreak: json['max_streak'] as int? ?? 0,
      badge: badge,
    );
  }

  Map<String, dynamic> toJson() => _$LeaderboardUserToJson(this);
}
