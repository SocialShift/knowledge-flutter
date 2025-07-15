import 'package:freezed_annotation/freezed_annotation.dart';

part 'badge.freezed.dart';
part 'badge.g.dart';

@freezed
class Badge with _$Badge {
  const factory Badge({
    required String id,
    required String name,
    required String path,
    required String tier,
    required String description,
    @JsonKey(name: 'icon_url') required String iconUrl,
    @JsonKey(name: 'earned_at') String? earnedAt,
  }) = _Badge;

  factory Badge.fromJson(Map<String, dynamic> json) => _$BadgeFromJson(json);
}

// Helper class for badge paths/categories
class BadgePath {
  static const String illumination = 'illumination';
  static const String game = 'game';
  static const String streak = 'streak';
  static const String starter = 'starter';

  static String getDisplayName(String path) {
    switch (path) {
      case illumination:
        return 'Illumination';
      case game:
        return 'Games';
      case streak:
        return 'Streaks';
      case starter:
        return 'Starter';
      default:
        return path.toUpperCase();
    }
  }

  static List<String> getAllPaths() {
    return [illumination, game, streak, starter];
  }
}

// All available badges in the system
class AllBadges {
  static const List<Map<String, dynamic>> badges = [
    // Illumination Path
    {
      'id': 'spark',
      'name': 'Spark',
      'path': 'illumination',
      'tier': '1',
      'description': 'You\'ve taken the first step into untold truths',
      'icon_url': 'media/badges/spark.png',
    },
    {
      'id': 'candlebearer',
      'name': 'Candlebearer',
      'path': 'illumination',
      'tier': '2',
      'description': 'You\'re starting to light the darkness with knowledge',
      'icon_url': 'media/badges/candlebearer.png',
    },
    {
      'id': 'torchbearer',
      'name': 'Torchbearer',
      'path': 'illumination',
      'tier': '3',
      'description': 'You carry the truth forward, one story at a time',
      'icon_url': 'media/badges/torchbearer.png',
    },
    {
      'id': 'flamekeeper',
      'name': 'Flamekeeper',
      'path': 'illumination',
      'tier': '4',
      'description': 'You protect what others tried to extinguish',
      'icon_url': 'media/badges/flamekeeper.png',
    },
    {
      'id': 'beacon',
      'name': 'Beacon',
      'path': 'illumination',
      'tier': '5',
      'description':
          'You shine so others can see. Your knowledge guides generations',
      'icon_url': 'media/badges/beacon.png',
    },
    {
      'id': 'constellation',
      'name': 'Constellation',
      'path': 'illumination',
      'tier': '6',
      'description': 'You\'ve connected erased histories across communities',
      'icon_url': 'media/badges/constellation.png',
    },

    // Game Path
    {
      'id': 'uncover',
      'name': 'Uncover',
      'path': 'game',
      'tier': '1',
      'description': 'Play 1 game of any type',
      'icon_url': 'media/badges/uncover.png',
    },
    {
      'id': 'seeker',
      'name': 'Seeker',
      'path': 'game',
      'tier': '2',
      'description': 'Play 3 different game types',
      'icon_url': 'media/badges/seeker.png',
    },
    {
      'id': 'revealer',
      'name': 'Revealer',
      'path': 'game',
      'tier': '3',
      'description': 'Score 80%+ on 3 games',
      'icon_url': 'media/badges/revealer.png',
    },
    {
      'id': 'historian',
      'name': 'Historian',
      'path': 'game',
      'tier': '4',
      'description': 'Play 10 total games',
      'icon_url': 'media/badges/historian.png',
    },
    {
      'id': 'archivist',
      'name': 'Archivist',
      'path': 'game',
      'tier': '5',
      'description': 'Complete all games in a challenge set',
      'icon_url': 'media/badges/archivist.png',
    },

    // Streak Path
    {
      'id': 'ember',
      'name': 'Ember',
      'path': 'streak',
      'tier': '1',
      'description': '3-day streak',
      'icon_url': 'media/badges/ember.png',
    },
    {
      'id': 'flame',
      'name': 'Flame',
      'path': 'streak',
      'tier': '2',
      'description': '7-day streak',
      'icon_url': 'media/badges/flame.png',
    },
    {
      'id': 'inferno',
      'name': 'Inferno',
      'path': 'streak',
      'tier': '3',
      'description': '30-day streak',
      'icon_url': 'media/badges/inferno.png',
    },
    {
      'id': 'eternal_flame',
      'name': 'Eternal Flame',
      'path': 'streak',
      'tier': '4',
      'description': '90-day streak',
      'icon_url': 'media/badges/eternal_flame.png',
    },

    // Starter Path
    {
      'id': 'truth_seeker',
      'name': 'Truth Seeker',
      'path': 'starter',
      'tier': '0',
      'description':
          'Welcome to Knowledge. Your journey to uncover hidden truths begins now.',
      'icon_url': 'media/badges/truth_seeker.png',
    },
    {
      'id': 'first_step',
      'name': 'First Step',
      'path': 'starter',
      'tier': '0',
      'description':
          'Every journey begins with a single step. You\'ve taken yours.',
      'icon_url': 'media/badges/first_step.png',
    },
  ];

  static List<Badge> getAllBadges() {
    return badges.map((badge) => Badge.fromJson(badge)).toList();
  }

  static Badge? getBadgeById(String id) {
    try {
      final badgeData = badges.firstWhere((badge) => badge['id'] == id);
      return Badge.fromJson(badgeData);
    } catch (e) {
      return null;
    }
  }
}
