import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:knowledge/presentation/navigation/app_layout.dart';
import 'package:knowledge/presentation/screens/auth/login_screen.dart';
import 'package:knowledge/presentation/screens/auth/signup_screen.dart';
import 'package:knowledge/presentation/screens/home/home_screen.dart';
import 'package:knowledge/presentation/screens/profile/profile_screen.dart';
import 'package:knowledge/presentation/screens/elearning/elearning_screen.dart';
import 'package:knowledge/presentation/screens/settings/settings_screen.dart';
import 'package:knowledge/presentation/screens/auth/forgot_password_screen.dart';
import 'package:knowledge/data/providers/auth_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isAuthenticated = authState.maybeMap(
        authenticated: (_) => true,
        guest: (_) => true,
        orElse: () => false,
      );

      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup' ||
          state.matchedLocation == '/forgot-password';

      if (!isAuthenticated && !isAuthRoute) {
        return '/login';
      }

      if (isAuthenticated && isAuthRoute) {
        return '/home';
      }

      return null;
    },
    routes: [
      // Auth routes without bottom navigation
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),

      // Main content routes with bottom navigation
      GoRoute(
        path: '/home',
        builder: (context, state) => const AppLayout(child: HomeScreen()),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const AppLayout(child: ProfileScreen()),
      ),
      GoRoute(
        path: '/elearning',
        builder: (context, state) => const AppLayout(child: ElearningScreen()),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const AppLayout(child: SettingsScreen()),
      ),
      GoRoute(
        path: '/bookmarks',
        builder: (context, state) => const AppLayout(
          child: Center(child: Text('Bookmarks Screen')),
        ),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
    ],
  );
});
