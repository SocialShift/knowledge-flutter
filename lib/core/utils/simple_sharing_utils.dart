import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io' show Platform;
import 'package:knowledge/data/models/profile.dart';
import 'package:knowledge/data/models/timeline.dart';

class SimpleSharingUtils {
  // App configuration
  static const String _appName = 'Know[ledge]';
  static const String _baseDeepLinkUrl = 'https://knowhistory.xyz';
  static const String _playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.knowhistory_knowledge.app';
  static const String _appStoreUrl =
      'https://apps.apple.com/know-ledge/id6744873533';

  /// Share user profile using system sharing
  static Future<void> shareProfile({
    required BuildContext context,
    required Profile profile,
  }) async {
    try {
      // Generate profile share link
      final profileId = profile.followers?['profile_id']?.toString() ?? '';
      final shareUrl = '$_baseDeepLinkUrl/shared/profile/$profileId';

      // Create share text with user details
      final shareText = _buildProfileShareText(profile, shareUrl);

      // Show sharing options
      await _showSharingOptions(
          context, shareText, 'Profile: ${profile.nickname ?? "User"}');
    } catch (e) {
      _showErrorSnackBar(context, 'Failed to share profile: $e');
    }
  }

  /// Share story using system sharing
  static Future<void> shareStory({
    required BuildContext context,
    required Story story,
  }) async {
    try {
      // Generate story share link
      final shareUrl = '$_baseDeepLinkUrl/shared/story/${story.id}';

      // Create share text with story details
      final shareText = _buildStoryShareText(story, shareUrl);

      // Show sharing options
      await _showSharingOptions(context, shareText, 'Story: ${story.title}');
    } catch (e) {
      _showErrorSnackBar(context, 'Failed to share story: $e');
    }
  }

  /// Show native sharing options
  static Future<void> _showSharingOptions(
      BuildContext context, String text, String title) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Share $title',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Copy to clipboard option
                  ListTile(
                    leading: const Icon(Icons.copy),
                    title: const Text('Copy to Clipboard'),
                    onTap: () async {
                      await Clipboard.setData(ClipboardData(text: text));
                      Navigator.pop(context);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Copied to clipboard!'),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                  ),

                  // Share via WhatsApp
                  ListTile(
                    leading: const Icon(Icons.message),
                    title: const Text('Share via WhatsApp'),
                    onTap: () async {
                      Navigator.pop(context);
                      await _shareViaWhatsApp(text);
                    },
                  ),

                  // Share via SMS
                  ListTile(
                    leading: const Icon(Icons.sms),
                    title: const Text('Share via SMS'),
                    onTap: () async {
                      Navigator.pop(context);
                      final success = await _shareViaSMS(text);
                      if (!success && context.mounted) {
                        _showErrorSnackBar(
                            context, 'No SMS app available on this device');
                      }
                    },
                  ),

                  // Share via Email
                  ListTile(
                    leading: const Icon(Icons.email),
                    title: const Text('Share via Email'),
                    onTap: () async {
                      Navigator.pop(context);
                      final success = await _shareViaEmail(text, title);
                      if (!success && context.mounted) {
                        _showErrorSnackBar(
                            context, 'No email app available on this device');
                      }
                    },
                  ),

                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Share via WhatsApp
  static Future<void> _shareViaWhatsApp(String text) async {
    try {
      final encodedText = Uri.encodeComponent(text);
      final whatsappUrl = 'whatsapp://send?text=$encodedText';
      final uri = Uri.parse(whatsappUrl);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        // Fallback to web WhatsApp
        final webWhatsappUrl = 'https://wa.me/?text=$encodedText';
        final webUri = Uri.parse(webWhatsappUrl);
        if (await canLaunchUrl(webUri)) {
          await launchUrl(webUri, mode: LaunchMode.externalApplication);
        }
      }
    } catch (e) {
      print('Error sharing via WhatsApp: $e');
    }
  }

  /// Share via SMS
  static Future<bool> _shareViaSMS(String text) async {
    try {
      final encodedText = Uri.encodeComponent(text);

      // Use the most reliable SMS URL scheme for each platform
      final smsUrl =
          Platform.isIOS ? 'sms:&body=$encodedText' : 'sms:?body=$encodedText';

      final uri = Uri.parse(smsUrl);

      // Don't check canLaunchUrl for SMS - just try to launch directly
      // SMS is a system capability that should always be available
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return true;
    } catch (e) {
      print('Error sharing via SMS: $e');

      // Try alternative SMS scheme as fallback
      try {
        final encodedText = Uri.encodeComponent(text);
        final fallbackUrl = 'smsto:?body=$encodedText';
        final fallbackUri = Uri.parse(fallbackUrl);
        await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
        return true;
      } catch (fallbackError) {
        print('SMS fallback also failed: $fallbackError');
        return false;
      }
    }
  }

  /// Share via Email
  static Future<bool> _shareViaEmail(String text, String subject) async {
    try {
      final encodedSubject = Uri.encodeComponent(subject);
      final encodedBody = Uri.encodeComponent(text);
      final emailUrl = 'mailto:?subject=$encodedSubject&body=$encodedBody';
      final uri = Uri.parse(emailUrl);

      // Don't check canLaunchUrl for email - just try to launch directly
      // Email is a system capability that should always be available
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return true;
    } catch (e) {
      print('Error sharing via Email: $e');

      // Try opening basic email app as fallback
      try {
        final fallbackUri = Uri.parse('mailto:');
        await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
        return true;
      } catch (fallbackError) {
        print('Email fallback also failed: $fallbackError');
        return false;
      }
    }
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
    buffer.writeln();
    buffer.writeln('Android: $_playStoreUrl');
    buffer.writeln();
    buffer.writeln('iOS: $_appStoreUrl');

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
    buffer.writeln();
    buffer.writeln('Android: $_playStoreUrl');
    buffer.writeln();
    buffer.writeln('iOS: $_appStoreUrl');

    return buffer.toString();
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
}
