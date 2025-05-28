import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:knowledge/core/themes/app_theme.dart';
import 'package:knowledge/presentation/navigation/router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:knowledge/data/repositories/notification_repository.dart';
import 'package:knowledge/data/providers/auth_provider.dart';
import 'package:knowledge/data/repositories/auth_repository.dart';
import 'package:knowledge/data/providers/feedback_provider.dart';
import 'package:knowledge/presentation/widgets/feedback_dialog.dart';
import 'package:knowledge/presentation/widgets/animated_loading_screen.dart';
import 'package:knowledge/core/utils/platform_optimizations.dart';
import 'package:knowledge/data/repositories/timeline_repository.dart';
import 'package:knowledge/data/providers/profile_provider.dart';
import 'dart:io' show Platform;
import 'dart:math' as math;
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure iOS audio session
  if (Platform.isIOS) {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playback,
        avAudioSessionCategoryOptions:
            AVAudioSessionCategoryOptions.defaultToSpeaker,
        avAudioSessionMode: AVAudioSessionMode.defaultMode,
        avAudioSessionRouteSharingPolicy:
            AVAudioSessionRouteSharingPolicy.defaultPolicy,
        avAudioSessionSetActiveOptions:
            AVAudioSessionSetActiveOptions.notifyOthersOnDeactivation,
      ));
      developer.log('Global iOS audio session configured successfully');
    } catch (e) {
      developer.log('Error configuring global iOS audio session: $e');
    }
  }

  // Apply platform-specific optimizations
  PlatformOptimizations.applyIOSOptimizations();

  // Set app-wide image caching parameters for better performance
  PaintingBinding.instance.imageCache.maximumSize = 1000;

  // Optimize system overlays based on platform
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
    overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
  );

  // Load .env file
  await dotenv.load(fileName: ".env");

  // Disable print statements in release mode for performance
  if (kReleaseMode) {
    debugPrint = (String? message, {int? wrapWidth}) {};
  }

  runApp(
    ProviderScope(
      child: Knowledge(),
    ),
  );
}

class Knowledge extends ConsumerStatefulWidget {
  @override
  ConsumerState<Knowledge> createState() => _KnowledgeState();
}

class _KnowledgeState extends ConsumerState<Knowledge>
    with WidgetsBindingObserver {
  DateTime? _lastBackPressTime;
  bool _initialSessionCheckComplete = false;

  @override
  void initState() {
    super.initState();

    // Add observer for app lifecycle events
    WidgetsBinding.instance.addObserver(this);

    // Initialize session management and start data preloading immediately
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Start preloading data immediately in parallel with session check
      // This ensures faster app experience regardless of auth state
      final preloadFuture = _preloadEssentialData();

      // Check session in parallel
      final sessionFuture = _checkAndRestoreSession();

      // Wait for both to complete
      await Future.wait([preloadFuture, sessionFuture]);

      // Start periodic session checks after initial check
      final authNotifier = ref.read(authNotifierProvider.notifier);
      authNotifier.startSessionCheck();

      // Preload OTD notifications when the app starts
      ref.read(onThisDayNotificationsProvider);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Apply system UI color based on current theme mode
    final brightness = Theme.of(context).brightness;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            brightness == Brightness.dark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: brightness == Brightness.dark
            ? AppColors.darkBackground
            : Colors.white,
        systemNavigationBarIconBrightness:
            brightness == Brightness.dark ? Brightness.light : Brightness.dark,
      ),
    );
  }

  @override
  void dispose() {
    // Remove observer when widget is disposed
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Handle app lifecycle changes - important for iOS memory management
    if (state == AppLifecycleState.paused) {
      // App is in background - release resources if needed
      // This is particularly important for iOS
      PlatformOptimizations.clearImageCache();
    } else if (state == AppLifecycleState.resumed) {
      // App is in foreground again
      // Check session validity when app is resumed
      final authNotifier = ref.read(authNotifierProvider.notifier);
      authNotifier.checkSessionValidity();

      // Also check email verification status when app is resumed
      authNotifier.checkAndHandleEmailVerification();
    }
  }

  // Check for valid session and restore authentication state if exists
  Future<void> _checkAndRestoreSession() async {
    if (_initialSessionCheckComplete) return;

    final authNotifier = ref.read(authNotifierProvider.notifier);

    try {
      final authRepository = ref.read(authRepositoryProvider);
      final isValid = await authRepository.checkSession();

      if (isValid) {
        // Session exists and is valid, get user profile
        final user = await authRepository.getUserFromSession();
        final hasProfile = await authRepository.hasCompletedProfileSetup();

        // Set authenticated state with user info
        authNotifier.restoreSession(user, hasProfile);

        // Check email verification status after restoring session
        await authNotifier.checkAndHandleEmailVerification();

        // Preload user-specific data after authentication
        await _preloadUserData();
      }
    } catch (e) {
      // Session invalid or error occurred - remain in unauthenticated state
      debugPrint('Session restore error: $e');
    } finally {
      setState(() {
        _initialSessionCheckComplete = true;
      });
    }
  }

  // Preload essential app data immediately for faster UI performance
  Future<void> _preloadEssentialData() async {
    try {
      debugPrint('Starting essential data preloading...');

      // Start preloading timelines immediately (don't wait for auth)
      final timelinesAsync = ref.read(timelinesProvider.future);
      final timelines = await timelinesAsync;
      debugPrint('Timelines preloaded: ${timelines.length} timelines');

      // Preload stories for the first few timelines (most commonly accessed)
      if (timelines.isNotEmpty) {
        // Load stories for first 5 timelines for better initial experience
        final preloadCount = math.min(5, timelines.length);
        final preloadFutures = <Future>[];

        for (int i = 0; i < preloadCount; i++) {
          final timelineId = timelines[i].id;
          preloadFutures.add(
            ref.read(timelineStoriesProvider(timelineId).future).catchError(
              (error) {
                debugPrint(
                    'Error preloading stories for timeline $timelineId: $error');
                // Don't let one timeline failure stop others from loading
                return [];
              },
            ),
          );
        }

        // Wait for all preloading to complete
        await Future.wait(preloadFutures);
        debugPrint(
            'Successfully preloaded stories for $preloadCount timelines');
      }
    } catch (e) {
      // Don't let preloading errors affect app startup
      debugPrint('Error during essential data preloading: $e');
    }
  }

  // Preload additional user-specific data after authentication
  Future<void> _preloadUserData() async {
    try {
      // Preload user profile (if not already loaded)
      ref.read(userProfileProvider);

      // Preload any user-specific data here
      debugPrint('User-specific data preloading completed');
    } catch (e) {
      debugPrint('Error during user data preloading: $e');
    }
  }

  // Show feedback dialog on first exit attempt
  Future<bool> _handleAppExit() async {
    // Get current time
    final currentTime = DateTime.now();

    // If pressed back button twice within 2 seconds, exit the app
    if (_lastBackPressTime != null &&
        currentTime.difference(_lastBackPressTime!) <=
            const Duration(seconds: 2)) {
      return true;
    }

    _lastBackPressTime = currentTime;

    // Check if feedback dialog should be shown using the provider
    final feedbackShown = await ref.read(feedbackNotifierProvider.future);

    if (!feedbackShown) {
      // Mark feedback as shown using the provider
      ref.read(feedbackNotifierProvider.notifier).markFeedbackAsShown();

      if (context.mounted) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const FeedbackDialog(),
        );
      }
    } else {
      // If feedback has been shown before, just show toast for back press again
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Press back again to exit'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }

    return false; // Don't exit the app yet
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final authState = ref.watch(authNotifierProvider);

    // Show animated loading screen while checking session status for the first time
    if (!_initialSessionCheckComplete &&
        authState.maybeMap(initial: (_) => true, orElse: () => false)) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const AnimatedLoadingScreen(),
        theme: _configureOptimizedTheme(AppTheme.lightTheme),
        darkTheme: _configureOptimizedTheme(AppTheme.darkTheme),
        themeMode: ref.watch(themeModeNotifierProvider),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final shouldPop = await _handleAppExit();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: MaterialApp.router(
        title: 'Know[Ledge]',
        theme: _configureOptimizedTheme(AppTheme.lightTheme),
        darkTheme: _configureOptimizedTheme(AppTheme.darkTheme),
        themeMode: ref.watch(themeModeNotifierProvider),
        routerConfig: router,
        debugShowCheckedModeBanner: false,
        scaffoldMessengerKey: GlobalKey<ScaffoldMessengerState>(),
        // Apply platform-specific optimizations
        builder: (context, child) {
          // Apply fixed text scaling for consistent UI
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(1.0),
            ),
            child: child!,
          );
        },
      ),
    );
  }

  // Configure theme data with platform-optimized transitions
  ThemeData _configureOptimizedTheme(ThemeData theme) {
    return PlatformOptimizations.configureOptimizedTransitions(theme);
  }
}
