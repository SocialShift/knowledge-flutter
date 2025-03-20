import 'package:flutter_dotenv/flutter_dotenv.dart';

class OtdNotification {
  final int id;
  final String title;
  final String shortDesc;
  final String date;
  final String? imageUrl;
  final int storyId;
  final String createdAt;

  OtdNotification({
    required this.id,
    required this.title,
    required this.shortDesc,
    required this.date,
    this.imageUrl,
    required this.storyId,
    required this.createdAt,
  });

  factory OtdNotification.fromJson(Map<String, dynamic> json) {
    final mediaBaseUrl = dotenv.env['MEDIA_BASE_URL'] ?? '';

    // Get the image URL and prepend the base URL if it's a relative path
    String? thumbnailUrl = json['image_url'];
    if (thumbnailUrl != null &&
        thumbnailUrl.isNotEmpty &&
        !thumbnailUrl.startsWith('http')) {
      thumbnailUrl = '$mediaBaseUrl/$thumbnailUrl';
    }

    return OtdNotification(
      id: json['id'],
      title: json['title'] ?? '',
      shortDesc: json['short_desc'] ?? '',
      date: json['date'] ?? '',
      imageUrl: thumbnailUrl,
      storyId: json['story_id'],
      createdAt: json['created_at'] ?? '',
    );
  }

  // Format the date for display (e.g., "December 10")
  String get formattedDate {
    try {
      if (date.isEmpty) return '';

      final parsedDate = DateTime.parse(date);
      final monthNames = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December'
      ];

      return '${monthNames[parsedDate.month - 1]} ${parsedDate.day}';
    } catch (e) {
      return date;
    }
  }
}
