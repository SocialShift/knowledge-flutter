import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:knowledge/core/themes/app_theme.dart';
import 'package:knowledge/presentation/navigation/router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:knowledge/data/repositories/notification_repository.dart';
import 'package:knowledge/data/providers/auth_provider.dart';
import 'package:knowledge/data/repositories/auth_repository.dart';

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
  @override
  void initState() {
    super.initState();

    // Initialize session management
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Check if the user has a valid session and update auth state
      final authNotifier = ref.read(authNotifierProvider.notifier);

      // First check stored session and restore if valid
      await _checkAndRestoreSession();

      // Start periodic session checks
      authNotifier.startSessionCheck();

      // Preload OTD notifications when the app starts
      ref.read(onThisDayNotificationsProvider);
    });
  }

  // Check for valid session and restore authentication state if exists
  Future<void> _checkAndRestoreSession() async {
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Know[Ledge]',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: GlobalKey<ScaffoldMessengerState>(),
    );
  }
}
