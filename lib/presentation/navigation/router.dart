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
import 'package:knowledge/presentation/screens/timeline/timeline_detail_screen.dart';
import 'package:knowledge/presentation/screens/story/story_detail_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);
  final onboardingState = ref.watch(onboardingNotifierProvider);

  return GoRouter(
    initialLocation: '/login',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isAuthenticated = authState.maybeMap(
        authenticated: (_) => true,
        guest: (_) => true,
        orElse: () => false,
      );

      // Don't redirect if accessing detail pages
      if (state.uri.path.startsWith('/timeline/') ||
          state.uri.path.startsWith('/story/')) {
        return null;
      }

      final isAuthRoute = state.uri.path == '/login' ||
          state.uri.path == '/signup' ||
          state.uri.path == '/forgot-password';

      final isOnboardingComplete = onboardingState.isCompleted;
      final isOnboardingRoute = state.uri.path == '/onboarding';

      if (isAuthenticated) {
        if (!isOnboardingComplete && isOnboardingRoute) return null;
        if (isOnboardingComplete && state.uri.path == '/home') return null;

        return !isOnboardingComplete ? '/onboarding' : '/home';
      }

      if (!isAuthRoute && !isAuthenticated) {
        return '/login';
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

      // Move detail routes outside of ShellRoute
      GoRoute(
        path: '/timeline/:id',
        builder: (context, state) {
          final timelineId = state.pathParameters['id'];
          if (timelineId == null) return const SizedBox.shrink();
          return TimelineDetailScreen(timelineId: timelineId);
        },
      ),
      GoRoute(
        path: '/story/:id',
        builder: (context, state) {
          final storyId = state.pathParameters['id'];
          if (storyId == null) return const SizedBox.shrink();
          return StoryDetailScreen(storyId: storyId);
        },
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
