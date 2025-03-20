import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:knowledge/core/themes/app_theme.dart';
import 'package:knowledge/presentation/navigation/router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:knowledge/data/repositories/notification_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env file
  await dotenv.load(fileName: ".env");

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

    // Preload OTD notifications when the app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(onThisDayNotificationsProvider);
    });
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
