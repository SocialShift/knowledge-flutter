import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:knowledge/presentation/navigation/app_layout.dart';
import 'package:knowledge/presentation/screens/auth/login_screen.dart';
import 'package:knowledge/presentation/screens/auth/signup_screen.dart';
import 'package:knowledge/presentation/screens/home/home_screen.dart';
import 'package:knowledge/presentation/screens/profile/profile_screen.dart';
import 'package:knowledge/presentation/screens/settings/settings_screen.dart';
import 'package:knowledge/presentation/screens/auth/forgot_password_screen.dart';
import 'package:knowledge/data/providers/auth_provider.dart';
import 'package:knowledge/data/providers/onboarding_provider.dart';
import 'package:knowledge/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:knowledge/presentation/screens/timeline/timeline_detail_screen.dart';
import 'package:knowledge/presentation/screens/story/story_detail_screen.dart';
import 'package:knowledge/presentation/screens/profile/edit_profile_screen.dart';
import 'package:knowledge/presentation/screens/quiz/quiz_screen.dart';
import 'package:knowledge/presentation/screens/leaderboard/leaderboard_screen.dart';
import 'package:knowledge/presentation/screens/auth/profile_setup_screen.dart';
import 'package:knowledge/presentation/screens/elearning/elearning_screen.dart';
import 'package:knowledge/presentation/screens/subscription/subscription_screen.dart';
import 'package:knowledge/presentation/screens/games/games_screen.dart';
import 'package:knowledge/presentation/navigation/page_transitions.dart';
import 'package:knowledge/presentation/screens/notifications/notifications_screen.dart';
import 'package:knowledge/presentation/screens/quiz/quiz_submit_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);
  final onboardingState = ref.watch(onboardingNotifierProvider);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isAuthenticated = authState.maybeMap(
        authenticated: (_) => true,
        guest: (_) => true,
        orElse: () => false,
      );

      final hasCompletedProfile = authState.maybeMap(
        authenticated: (auth) => auth.hasCompletedProfile,
        orElse: () => false,
      );

      // For initial route '/', redirect based on auth state
      if (state.uri.path == '/') {
        if (isAuthenticated) {
          if (!hasCompletedProfile) {
            // Check if onboarding is completed
            final isOnboardingComplete = onboardingState.isCompleted;
            if (!isOnboardingComplete) {
              return '/onboarding';
            }
            return '/profile-setup';
          }
          return '/home';
        } else {
          return '/login';
        }
      }

      // Don't redirect if accessing detail pages or main navigation routes
      if (state.uri.path.startsWith('/timeline/') ||
          state.uri.path.startsWith('/story/') ||
          state.uri.path.startsWith('/quiz/') ||
          state.uri.path.startsWith('/games/') ||
          state.uri.path == '/home' ||
          state.uri.path == '/profile' ||
          state.uri.path == '/profile/edit' ||
          state.uri.path == '/leaderboard' ||
          state.uri.path == '/elearning' ||
          state.uri.path == '/games') {
        return null;
      }

      final isAuthRoute = state.uri.path == '/login' ||
          state.uri.path == '/signup' ||
          state.uri.path == '/forgot-password';

      // For guest users, skip onboarding and redirect directly to home
      if (authState.maybeMap(
        guest: (_) => true,
        orElse: () => false,
      )) {
        return '/home';
      }

      final isOnboardingComplete = onboardingState.isCompleted;
      final isOnboardingRoute = state.uri.path == '/onboarding';
      final isProfileSetupRoute = state.uri.path == '/profile-setup';

      if (isAuthenticated) {
        // If user has completed profile, go to home
        if (hasCompletedProfile) {
          return isAuthRoute ? '/home' : null;
        }

        // If onboarding is not complete and on onboarding route, allow it
        if (!isOnboardingComplete && isOnboardingRoute) return null;

        // If onboarding is complete but profile setup not done, go to profile setup
        if (isOnboardingComplete && !isProfileSetupRoute)
          return '/profile-setup';

        // If on profile setup route, allow it
        if (isProfileSetupRoute) return null;

        // If onboarding is not complete, go to onboarding
        if (!isOnboardingComplete) return '/onboarding';

        // Otherwise go to home
        return '/home';
      }

      // Redirect to login if not authenticated and not on an auth route
      if (!isAuthRoute && !isAuthenticated) {
        return '/login';
      }

      return null;
    },
    routes: [
      // Root route (will be redirected based on auth state)
      GoRoute(
        path: '/',
        pageBuilder: (context, state) => buildCupertinoPageTransition(
          context: context,
          state: state,
          child: Container(), // Placeholder, will be redirected
        ),
      ),
      // Auth routes without bottom navigation
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => buildCupertinoPageTransition(
          context: context,
          state: state,
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: '/signup',
        pageBuilder: (context, state) => buildCupertinoPageTransition(
          context: context,
          state: state,
          child: const SignupScreen(),
        ),
      ),
      GoRoute(
        path: '/forgot-password',
        pageBuilder: (context, state) => buildCupertinoPageTransition(
          context: context,
          state: state,
          child: const ForgotPasswordScreen(),
        ),
      ),
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) => buildFadeThroughTransition(
          context: context,
          state: state,
          child: const OnboardingScreen(),
        ),
      ),

      // Detail routes with slide-up transition for modal-style pages
      GoRoute(
        path: '/timeline/:id',
        pageBuilder: (context, state) {
          final timelineId = state.pathParameters['id'];
          if (timelineId == null)
            return buildCupertinoPageTransition(
              context: context,
              state: state,
              child: const SizedBox.shrink(),
            );
          return buildSlideUpTransition(
            context: context,
            state: state,
            child: TimelineDetailScreen(timelineId: timelineId),
          );
        },
      ),
      GoRoute(
        path: '/story/:id',
        pageBuilder: (context, state) {
          final storyId = state.pathParameters['id'];
          if (storyId == null)
            return buildCupertinoPageTransition(
              context: context,
              state: state,
              child: const SizedBox.shrink(),
            );
          return buildSlideUpTransition(
            context: context,
            state: state,
            child: StoryDetailScreen(storyId: storyId),
          );
        },
      ),

      // Quiz route with shared axis transition for visual continuity
      GoRoute(
        path: '/quiz/:storyId',
        pageBuilder: (context, state) {
          final storyId = state.pathParameters['storyId'];
          if (storyId == null)
            return buildCupertinoPageTransition(
              context: context,
              state: state,
              child: const SizedBox.shrink(),
            );
          return buildSharedAxisHorizontalTransition(
            context: context,
            state: state,
            child: QuizScreen(storyId: storyId),
          );
        },
      ),

      // Quiz Submit Screen
      GoRoute(
        path: '/quiz-submit/:storyId/:quizId',
        pageBuilder: (context, state) {
          final storyId = state.pathParameters['storyId'];
          final quizId = state.pathParameters['quizId'];
          if (storyId == null || quizId == null)
            return buildCupertinoPageTransition(
              context: context,
              state: state,
              child: const SizedBox.shrink(),
            );
          return buildSlideUpTransition(
            context: context,
            state: state,
            child: QuizSubmitScreen(storyId: storyId, quizId: quizId),
          );
        },
      ),

      // Subscription screen with slide-up transition
      GoRoute(
        path: '/subscription',
        pageBuilder: (context, state) => buildSlideUpTransition(
          context: context,
          state: state,
          child: const SubscriptionScreen(),
        ),
      ),

      // Notifications screen with slide-up transition
      GoRoute(
        path: '/notifications',
        pageBuilder: (context, state) => buildSlideUpTransition(
          context: context,
          state: state,
          child: const NotificationsScreen(),
        ),
      ),

      // Shell route for bottom navigation
      ShellRoute(
        pageBuilder: (context, state, child) => buildFadeThroughTransition(
          context: context,
          state: state,
          child: AppLayout(child: child),
        ),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => buildCupertinoPageTransition(
              context: context,
              state: state,
              child: const HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) => buildCupertinoPageTransition(
              context: context,
              state: state,
              child: const ProfileScreen(),
            ),
          ),
          GoRoute(
            path: '/profile/edit',
            pageBuilder: (context, state) => buildCupertinoPageTransition(
              context: context,
              state: state,
              child: const EditProfileScreen(),
            ),
          ),
          // Enable e-learning route
          GoRoute(
            path: '/elearning',
            pageBuilder: (context, state) => buildCupertinoPageTransition(
              context: context,
              state: state,
              child: const ElearningScreen(),
            ),
          ),
          // Add games center route
          GoRoute(
            path: '/games',
            pageBuilder: (context, state) => buildCupertinoPageTransition(
              context: context,
              state: state,
              child: const GamesScreen(),
            ),
          ),
          // Game detail routes
          GoRoute(
            path: '/games/:gameId',
            pageBuilder: (context, state) {
              final gameId = state.pathParameters['gameId'];
              if (gameId == null)
                return buildCupertinoPageTransition(
                  context: context,
                  state: state,
                  child: const SizedBox.shrink(),
                );
              return buildSharedAxisHorizontalTransition(
                context: context,
                state: state,
                child: Center(
                  child: Text('Game: $gameId'),
                ),
              );
            },
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) => buildCupertinoPageTransition(
              context: context,
              state: state,
              child: const SettingsScreen(),
            ),
          ),
          GoRoute(
            path: '/bookmarks',
            pageBuilder: (context, state) => buildCupertinoPageTransition(
              context: context,
              state: state,
              child: const Center(
                child: Text('Bookmarks Screen'),
              ),
            ),
          ),
          GoRoute(
            path: '/leaderboard',
            pageBuilder: (context, state) => buildCupertinoPageTransition(
              context: context,
              state: state,
              child: const LeaderboardScreen(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/profile-setup',
        pageBuilder: (context, state) => buildCupertinoPageTransition(
          context: context,
          state: state,
          child: const ProfileSetupScreen(),
        ),
      ),
    ],
  );
});
