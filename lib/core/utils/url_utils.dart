import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;
import 'package:knowledge/core/utils/debug_utils.dart';
import 'package:knowledge/core/themes/app_theme.dart';

class UrlUtils {
  // App's legal URLs
  static const String termsOfServiceUrl =
      'https://www.knowhistory.xyz/terms-of-service';
  static const String privacyPolicyUrl =
      'https://knowhistory.xyz/privacy-policy';

  /// Launch a URL in the default browser
  static Future<void> openUrl(String urlString, {BuildContext? context}) async {
    try {
      DebugUtils.debugLog('Attempting to launch URL: $urlString');
      final Uri url = Uri.parse(urlString);

      // Handle iOS differently - directly open in Safari
      if (!kIsWeb && Platform.isIOS) {
        try {
          final bool launched =
              await launchUrl(url, mode: LaunchMode.platformDefault);
          if (launched) {
            DebugUtils.debugLog(
                'Successfully launched URL in iOS Safari: $urlString');
            return;
          }
        } catch (e) {
          DebugUtils.debugError('iOS Safari launch failed: $e');
        }
      }

      // For Android and other platforms, try different launch modes
      final List<LaunchMode> modes = [
        LaunchMode.externalApplication,
        LaunchMode.platformDefault,
        LaunchMode.externalNonBrowserApplication,
      ];

      bool launched = false;
      String lastError = '';

      for (final mode in modes) {
        try {
          DebugUtils.debugLog('Trying launch mode: $mode');

          launched = await launchUrl(url, mode: mode);

          if (launched) {
            DebugUtils.debugLog(
                'Successfully launched URL with mode $mode: $urlString');
            return; // Success! Exit the function
          } else {
            DebugUtils.debugLog('Launch mode $mode failed for: $urlString');
          }
        } catch (e) {
          lastError = e.toString();
          DebugUtils.debugLog('Launch mode $mode threw error: $e');
          continue; // Try next mode
        }
      }

      // If all modes failed, show browser selection dialog
      DebugUtils.debugError(
          'All launch modes failed for URL: $urlString. Last error: $lastError');
      if (context != null && context.mounted) {
        _showBrowserSelectionDialog(context, url);
      }
    } catch (e) {
      DebugUtils.debugError('Error launching URL: $e');
      if (context != null && context.mounted) {
        _showErrorSnackBar(context, 'Failed to open link: ${e.toString()}');
      }
    }
  }

  /// Launch Terms of Service URL
  static Future<void> launchTermsOfService({BuildContext? context}) async {
    await openUrl(termsOfServiceUrl, context: context);
  }

  /// Launch Privacy Policy URL
  static Future<void> launchPrivacyPolicy({BuildContext? context}) async {
    await openUrl(privacyPolicyUrl, context: context);
  }

  static void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Show browser selection dialog for Android or fallback for other platforms
  static void _showBrowserSelectionDialog(BuildContext context, Uri url) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Open Link',
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : AppColors.navyBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose how to open this link:',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white70
                      : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                url.toString(),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  // Try with platformDefault mode
                  await launchUrl(url, mode: LaunchMode.platformDefault);
                } catch (e) {
                  DebugUtils.debugError('Platform default launch failed: $e');
                  if (context.mounted) {
                    _showErrorSnackBar(context, 'Unable to open link');
                  }
                }
              },
              child: Text(
                'Open in Browser',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.limeGreen
                      : AppColors.navyBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
