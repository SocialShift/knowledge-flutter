import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Utility class for platform-specific optimizations
/// Contains methods to improve performance on iOS
class PlatformOptimizations {
  /// Apply iOS specific optimizations
  static void applyIOSOptimizations() {
    if (!Platform.isIOS) return;

    // Optimize image caching
    PaintingBinding.instance.imageCache.maximumSizeBytes =
        100 * 1024 * 1024; // 100 MB

    // Configure default CachedNetworkImage settings
    CachedNetworkImage.logLevel = CacheManagerLogLevel.none;

    // Set preferred orientations
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Optimize UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  /// Clear image cache to free up memory
  static void clearImageCache() {
    if (Platform.isIOS) {
      PaintingBinding.instance.imageCache.clear();
      imageCache.clear();
    }
  }

  /// Get optimal FilterQuality based on platform
  static FilterQuality get optimalFilterQuality {
    return Platform.isIOS ? FilterQuality.medium : FilterQuality.high;
  }

  /// Optimize image resolution based on device screen size
  static int getOptimalImageResolution(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;

    // For iOS, reduce the resolution slightly to improve performance
    final reductionFactor = Platform.isIOS ? 0.8 : 1.0;

    return (screenWidth * devicePixelRatio * reductionFactor).round();
  }

  /// Create optimized CachedNetworkImage options for iOS
  static Map<String, dynamic> getOptimalCacheOptions({
    required int width,
    required int height,
  }) {
    if (!Platform.isIOS) {
      return {
        'memCacheWidth': width,
        'memCacheHeight': height,
        'filterQuality': FilterQuality.high,
      };
    }

    return {
      'memCacheWidth': width,
      'memCacheHeight': height,
      'maxWidthDiskCache': width * 2,
      'maxHeightDiskCache': height * 2,
      'filterQuality': FilterQuality.medium,
      'fadeInDuration': const Duration(milliseconds: 200),
    };
  }

  /// Check if animations should be reduced based on platform settings
  static bool shouldReduceAnimations(BuildContext context) {
    return Platform.isIOS && MediaQuery.of(context).disableAnimations;
  }

  /// Get optimal ListView cacheExtent based on platform
  static double get optimalCacheExtent {
    return Platform.isIOS ? 250.0 : 500.0;
  }
}
