import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io' show Platform;
import 'package:knowledge/data/models/profile.dart';
import 'package:knowledge/data/models/timeline.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class SharingUtils {
  // App configuration
  static const String _appName = 'Knowledge';
  static const String _appDescription =
      'History of Western Civilization Learning App';
  static const String _baseDeepLinkUrl = 'https://knowledge.app';
  static const String _playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.knowhistory_knowledge.app';
  static const String _appStoreUrl =
      'https://apps.apple.com/app/id123456789'; // Replace with actual App Store ID

  /// Share user profile with rich content and deep linking
  static Future<void> shareProfile({
    required BuildContext context,
    required Profile profile,
    Rect? sharePositionOrigin,
  }) async {
    try {
      // Generate profile share link
      final profileId = profile.followers?['profile_id']?.toString() ?? '';
      final shareUrl = '$_baseDeepLinkUrl/shared/profile/$profileId';

      // Create share text with user details
      final shareText = _buildProfileShareText(profile, shareUrl);

      // Download and share profile image if available
      if (profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty) {
        await _shareWithImage(
          context: context,
          text: shareText,
          imageUrl: profile.avatarUrl!,
          subject: '${profile.nickname ?? "User"} on $_appName',
          sharePositionOrigin: sharePositionOrigin,
        );
      } else {
        // Share without image
        await _shareText(
          context: context,
          text: shareText,
          subject: '${profile.nickname ?? "User"} on $_appName',
          sharePositionOrigin: sharePositionOrigin,
        );
      }
    } catch (e) {
      _showErrorSnackBar(context, 'Failed to share profile: $e');
    }
  }

  /// Share story with rich content and deep linking
  static Future<void> shareStory({
    required BuildContext context,
    required Story story,
    Rect? sharePositionOrigin,
  }) async {
    try {
      // Generate story share link
      final shareUrl = '$_baseDeepLinkUrl/shared/story/${story.id}';

      // Create share text with story details
      final shareText = _buildStoryShareText(story, shareUrl);

      // Download and share story image
      if (story.imageUrl.isNotEmpty) {
        await _shareWithImage(
          context: context,
          text: shareText,
          imageUrl: story.imageUrl,
          subject: '${story.title} - $_appName',
          sharePositionOrigin: sharePositionOrigin,
        );
      } else {
        // Share without image
        await _shareText(
          context: context,
          text: shareText,
          subject: '${story.title} - $_appName',
          sharePositionOrigin: sharePositionOrigin,
        );
      }
    } catch (e) {
      _showErrorSnackBar(context, 'Failed to share story: $e');
    }
  }

  /// Share text only
  static Future<void> _shareText({
    required BuildContext context,
    required String text,
    required String subject,
    Rect? sharePositionOrigin,
  }) async {
    try {
      await Share.share(
        text,
        subject: subject,
        sharePositionOrigin: sharePositionOrigin,
      );
    } catch (e) {
      _showErrorSnackBar(context, 'Failed to share: $e');
    }
  }

  /// Share with image attachment
  static Future<void> _shareWithImage({
    required BuildContext context,
    required String text,
    required String imageUrl,
    required String subject,
    Rect? sharePositionOrigin,
  }) async {
    try {
      // For now, just share text to avoid plugin issues
      // We can add image sharing later once plugin is properly configured
      await _shareText(
        context: context,
        text: text,
        subject: subject,
        sharePositionOrigin: sharePositionOrigin,
      );
    } catch (e) {
      // Fallback to text only sharing
      await _shareText(
        context: context,
        text: text,
        subject: subject,
        sharePositionOrigin: sharePositionOrigin,
      );
    }
  }

  /// Download image to temporary file for sharing
  static Future<File?> _downloadImageToTemp(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final tempDir = await getTemporaryDirectory();
        final fileName =
            'share_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final file = File('${tempDir.path}/$fileName');
        await file.writeAsBytes(bytes);
        return file;
      }
    } catch (e) {
      print('Error downloading image for sharing: $e');
    }
    return null;
  }

  /// Build profile share text with rich formatting
  static String _buildProfileShareText(Profile profile, String shareUrl) {
    final nickname = profile.nickname ?? 'A Knowledge User';
    final points = profile.points ?? 0;
    final rank = profile.rank;
    final completedQuizzes = profile.completedQuizzes ?? 0;

    final buffer = StringBuffer();
    buffer.writeln('📚 Check out $nickname on $_appName!');
    buffer.writeln();
    buffer.writeln('🌟 Points: $points');
    if (rank != null) {
      buffer.writeln('🏆 Rank: #$rank');
    }
    buffer.writeln('📖 Completed Quizzes: $completedQuizzes');
    buffer.writeln();
    buffer.writeln('Join them on their historical learning journey!');
    buffer.writeln();
    buffer.writeln('📱 View Profile: $shareUrl');
    buffer.writeln();
    buffer.writeln(
        'Download $_appName and start your own journey through history!');

    return buffer.toString();
  }

  /// Build story share text with rich formatting
  static String _buildStoryShareText(Story story, String shareUrl) {
    final buffer = StringBuffer();
    buffer.writeln('📜 "${story.title}" on $_appName');
    buffer.writeln();
    buffer.writeln('📅 Year: ${story.year}');
    buffer.writeln('👀 Views: ${story.views}');
    buffer.writeln();
    if (story.description.isNotEmpty) {
      // Truncate description if too long
      final description = story.description.length > 100
          ? '${story.description.substring(0, 100)}...'
          : story.description;
      buffer.writeln(description);
      buffer.writeln();
    }
    buffer.writeln('🎓 Dive into history with this fascinating story!');
    buffer.writeln();
    buffer.writeln('📱 Read Story: $shareUrl');
    buffer.writeln();
    buffer.writeln('Download $_appName to explore more historical stories!');

    return buffer.toString();
  }

  /// Handle incoming deep links
  static Future<void> handleDeepLink(String url) async {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;

      if (pathSegments.length >= 2) {
        final type = pathSegments[0]; // 'profile' or 'story'
        final id = pathSegments[1];

        // Check if app is installed and can handle the link
        final canLaunch = await canLaunchUrl(uri);

        if (canLaunch) {
          // App is installed, launch deep link
          await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );
        } else {
          // App not installed, redirect to store
          await _redirectToAppStore();
        }
      }
    } catch (e) {
      print('Error handling deep link: $e');
      await _redirectToAppStore();
    }
  }

  /// Redirect to appropriate app store
  static Future<void> _redirectToAppStore() async {
    try {
      final storeUrl = Platform.isIOS ? _appStoreUrl : _playStoreUrl;
      final uri = Uri.parse(storeUrl);

      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (e) {
      print('Error redirecting to app store: $e');
    }
  }

  /// Get share position for iPad compatibility
  static Rect? getSharePositionOrigin(BuildContext context) {
    if (Platform.isIOS) {
      final RenderBox? box = context.findRenderObject() as RenderBox?;
      if (box != null) {
        return box.localToGlobal(Offset.zero) & box.size;
      }
    }
    return null;
  }

  /// Show error snackbar
  static void _showErrorSnackBar(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(12),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// Generate app download links for sharing
  static String getAppDownloadText() {
    return '''
📱 Download $_appName:
🤖 Android: $_playStoreUrl
🍎 iOS: $_appStoreUrl

Start your journey through the history of Western Civilization!
''';
  }
}
