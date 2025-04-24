import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:knowledge/core/themes/app_theme.dart';
import 'package:knowledge/presentation/navigation/router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:knowledge/data/repositories/notification_repository.dart';
import 'package:knowledge/data/providers/auth_provider.dart';
import 'package:knowledge/data/repositories/auth_repository.dart';
import 'package:knowledge/data/providers/feedback_provider.dart';
import 'package:knowledge/presentation/widgets/feedback_dialog.dart';
import 'package:knowledge/data/models/auth_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env file
  await dotenv.load(fileName: ".env");

  // Initialize services
  // Preload notifications and other required app data

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

class _KnowledgeState extends ConsumerState<Knowledge> {
  DateTime? _lastBackPressTime;
  bool _initialSessionCheckComplete = false;

  @override
  void initState() {
    super.initState();

    // Initialize session management
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _checkAndRestoreSession();

      // Start periodic session checks after initial check
      final authNotifier = ref.read(authNotifierProvider.notifier);
      authNotifier.startSessionCheck();

      // Preload OTD notifications when the app starts
      ref.read(onThisDayNotificationsProvider);
    });
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
      }
    } catch (e) {
      // Session invalid or error occurred - remain in unauthenticated state
      print('Session restore error: $e');
    } finally {
      setState(() {
        _initialSessionCheckComplete = true;
      });
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

    // Show loading indicator while checking session status for the first time
    if (!_initialSessionCheckComplete &&
        authState.maybeMap(initial: (_) => true, orElse: () => false)) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App logo
                Image.asset(
                  'assets/images/logo/logo.png',
                  width: 150,
                  height: 150,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.navyBlue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.school,
                      size: 80,
                      color: AppColors.navyBlue,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Animated loading indicator
                Container(
                  width: 48,
                  height: 48,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.navyBlue.withOpacity(0.1),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.limeGreen),
                    strokeWidth: 3,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Loading...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.navyBlue.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return WillPopScope(
      onWillPop: _handleAppExit,
      child: MaterialApp.router(
        title: 'Know[Ledge]',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        routerConfig: router,
        debugShowCheckedModeBanner: false,
        scaffoldMessengerKey: GlobalKey<ScaffoldMessengerState>(),
      ),
    );
  }
}
