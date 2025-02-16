import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NavigationService {
  static final navigatorKey = GlobalKey<NavigatorState>();

  static NavigatorState get navigator => navigatorKey.currentState!;

  static void navigateToHome(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        context.go('/home');
      }
    });
  }

  static void navigateToLogin(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        context.go('/login');
      }
    });
  }
}
