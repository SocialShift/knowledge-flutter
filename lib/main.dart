import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:knowledge/core/themes/app_theme.dart';
import 'package:knowledge/presentation/navigation/router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeNotifierProvider);

    return MaterialApp.router(
      title: 'Know[Ledge]',
      themeMode: themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: GlobalKey<ScaffoldMessengerState>(),
    );
  }
}
