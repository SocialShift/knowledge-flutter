import 'dart:io' show Platform;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Utility class for platform-specific optimizations
/// Contains methods to improve performance on iOS
class PlatformOptimizations {
  /// Apply platform-specific optimizations
  static void applyIOSOptimizations() {
    // For iOS-specific optimizations
    if (Platform.isIOS) {
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

    // The following applies to all platforms for smoother animations

    // Enable any image codegeneration backend
    if (Platform.isAndroid) {
      // Android-specific settings
      PaintingBinding.instance.imageCache.maximumSizeBytes = 150 *
          1024 *
          1024; // 150 MB for Android (more RAM typically available)

      // Set system-wide UI properties for Android
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.white,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      );
    }

    // Apply additional hardware optimizations if needed in the future
  }

  /// Apply iOS-style navigation settings to PageRoute
  static PageRoute<T> buildIOSPageRoute<T>({
    required WidgetBuilder builder,
    RouteSettings? settings,
    bool maintainState = true,
    bool fullscreenDialog = false,
  }) {
    if (Platform.isIOS) {
      return CupertinoPageRoute<T>(
        builder: builder,
        settings: settings,
        maintainState: maintainState,
        fullscreenDialog: fullscreenDialog,
      );
    } else {
      // For Android, we create a custom page route with optimized transitions
      return MaterialPageRoute<T>(
        builder: builder,
        settings: settings,
        maintainState: maintainState,
        fullscreenDialog: fullscreenDialog,
      );
    }
  }

  /// Get optimized PageTransitionsBuilder based on platform
  static PageTransitionsBuilder getOptimizedPageTransitionsBuilder() {
    // Return platform-specific transitions builder
    if (Platform.isIOS) {
      return const CupertinoPageTransitionsBuilder();
    } else {
      // Custom Android transitions (similar to iOS but optimized for Android)
      return const OpenUpwardsPageTransitionsBuilder();
    }
  }

  /// Configure theme data with optimized page transitions
  static ThemeData configureOptimizedTransitions(ThemeData theme) {
    return theme.copyWith(
      pageTransitionsTheme: PageTransitionsTheme(
        builders: {
          TargetPlatform.iOS: const CupertinoPageTransitionsBuilder(),
          TargetPlatform.android: const OpenUpwardsPageTransitionsBuilder(),
          TargetPlatform.windows: const ZoomPageTransitionsBuilder(),
          TargetPlatform.macOS: const CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: const ZoomPageTransitionsBuilder(),
        },
      ),
      // Add other performance optimizations
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  /// Clear image cache to free up memory
  static void clearImageCache() {
    PaintingBinding.instance.imageCache.clear();
    imageCache.clear();
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
    final reductionFactor = Platform.isIOS ? 0.8 : 0.9;

    return (screenWidth * devicePixelRatio * reductionFactor).round();
  }

  /// Create optimized CachedNetworkImage options for the platform
  static Map<String, dynamic> getOptimalCacheOptions({
    required int width,
    required int height,
  }) {
    if (Platform.isIOS) {
      return {
        'memCacheWidth': width,
        'memCacheHeight': height,
        'maxWidthDiskCache': width * 2,
        'maxHeightDiskCache': height * 2,
        'filterQuality': FilterQuality.medium,
        'fadeInDuration': const Duration(milliseconds: 200),
      };
    } else if (Platform.isAndroid) {
      return {
        'memCacheWidth': width,
        'memCacheHeight': height,
        'maxWidthDiskCache': width * 2,
        'maxHeightDiskCache': height * 2,
        'filterQuality': FilterQuality.medium,
        'fadeInDuration': const Duration(milliseconds: 150),
      };
    } else {
      return {
        'memCacheWidth': width,
        'memCacheHeight': height,
        'filterQuality': FilterQuality.high,
      };
    }
  }

  /// Check if animations should be reduced based on platform settings
  static bool shouldReduceAnimations(BuildContext context) {
    return MediaQuery.of(context).disableAnimations;
  }

  /// Get optimal ListView cacheExtent based on platform
  static double getOptimalCacheExtent(BuildContext context) {
    // Adjust based on device screen size for better performance
    final screenHeight = MediaQuery.of(context).size.height;

    if (Platform.isIOS) {
      return screenHeight * 0.5; // Half the screen height for iOS
    } else if (Platform.isAndroid) {
      return screenHeight * 0.7; // More caching for Android
    } else {
      return 500.0; // Default for other platforms
    }
  }

  /// Get the optimal animation curve for smoother animations
  static Curve getOptimalAnimationCurve() {
    if (Platform.isIOS) {
      return Curves.easeOutCubic;
    } else {
      return Curves.fastOutSlowIn;
    }
  }

  /// Get optimal animation duration based on platform
  static Duration getOptimalAnimationDuration() {
    if (Platform.isIOS) {
      return const Duration(milliseconds: 250);
    } else {
      return const Duration(milliseconds: 220);
    }
  }
}
