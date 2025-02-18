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
import 'package:knowledge/data/providers/onboarding_provider.dart';
import 'package:knowledge/presentation/screens/onboarding/onboarding_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);
  final onboardingState = ref.watch(onboardingNotifierProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isAuthenticated = authState.maybeMap(
        authenticated: (_) => true,
        guest: (_) => true,
        orElse: () => false,
      );

      final isAuthRoute = state.uri.path == '/login' ||
          state.uri.path == '/signup' ||
          state.uri.path == '/forgot-password';

      final isOnboardingComplete = onboardingState.isCompleted;
      final isOnboardingRoute = state.uri.path == '/onboarding';

      // If not authenticated and trying to access protected route, go to login
      if (!isAuthenticated && !isAuthRoute) {
        return '/login';
      }

      // If authenticated but onboarding not complete and not on onboarding route
      if (isAuthenticated && !isOnboardingComplete && !isOnboardingRoute) {
        return '/onboarding';
      }

      // If authenticated and onboarding complete
      if (isAuthenticated && isOnboardingComplete) {
        // If on auth routes or onboarding, redirect to home
        if (isAuthRoute || isOnboardingRoute) {
          return '/home';
        }
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
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Shell route for bottom navigation
      ShellRoute(
        builder: (context, state, child) => AppLayout(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/elearning',
            builder: (context, state) => const ElearningScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: '/bookmarks',
            builder: (context, state) => const Center(
              child: Text('Bookmarks Screen'),
            ),
          ),
        ],
      ),
    ],
  );
});
