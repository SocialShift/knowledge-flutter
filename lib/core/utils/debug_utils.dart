import 'package:flutter/foundation.dart';

class DebugUtils {
  /// Prints debug messages only in debug mode
  /// In release mode, this does nothing for performance
  static void debugLog(String message) {
    if (kDebugMode) {
      debugPrint(message);
    }
  }

  /// Prints error messages only in debug mode
  /// In release mode, this does nothing for performance
  static void debugError(String message) {
    if (kDebugMode) {
      debugPrint('ERROR: $message');
    }
  }

  /// Prints info messages only in debug mode
  /// In release mode, this does nothing for performance
  static void debugInfo(String message) {
    if (kDebugMode) {
      debugPrint('INFO: $message');
    }
  }
}
