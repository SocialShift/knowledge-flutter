import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:knowledge/presentation/navigation/app_layout.dart';
import 'package:knowledge/presentation/screens/auth/login_screen.dart';
import 'package:knowledge/presentation/screens/auth/signup_screen.dart';
import 'package:knowledge/presentation/screens/auth/email_verification_screen.dart';
import 'package:knowledge/presentation/screens/auth/password_reset_screen.dart';
import 'package:knowledge/presentation/screens/home/home_screen.dart';
import 'package:knowledge/presentation/screens/profile/profile_screen.dart';
import 'package:knowledge/presentation/screens/settings/settings_screen.dart';
import 'package:knowledge/presentation/screens/auth/forgot_password_screen.dart';
import 'package:knowledge/data/providers/auth_provider.dart';
import 'package:knowledge/data/providers/onboarding_provider.dart';
import 'package:knowledge/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:knowledge/presentation/screens/onboarding/pro_onboarding_screen.dart';
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
import 'package:knowledge/presentation/screens/socials/add_friends.dart';
import 'package:knowledge/presentation/screens/socials/user_profile_screen.dart';
import 'package:knowledge/presentation/screens/socials/followers_screen.dart';
import 'package:knowledge/presentation/screens/socials/following_screen.dart';
import 'package:knowledge/presentation/screens/community/community_screen.dart';
import 'package:knowledge/presentation/screens/community/create_community_screen.dart';
import 'package:knowledge/presentation/screens/community/community_detail_screen.dart';
import 'package:knowledge/presentation/screens/community/create_post_screen.dart';
import 'package:knowledge/core/utils/debug_utils.dart';
import 'package:knowledge/core/utils/sharing_utils.dart';

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
        emailVerified: (_) => true,
        orElse: () => false,
      );

      // Check for password reset flow states
      final isInPasswordResetFlow = authState.maybeMap(
        passwordResetPending: (_) => true,
        passwordResetVerified: (_) => true,
        orElse: () => false,
      );

      final hasCompletedProfile = authState.maybeMap(
        authenticated: (auth) => auth.hasCompletedProfile,
        orElse: () => false,
      );

      // Debug logging for profile completion status
      if (state.uri.path == '/' || state.uri.path == '/profile-setup') {
        DebugUtils.debugLog('Router redirect check:');
        DebugUtils.debugLog('  - isAuthenticated: $isAuthenticated');
        DebugUtils.debugLog('  - hasCompletedProfile: $hasCompletedProfile');
        DebugUtils.debugLog('  - current path: ${state.uri.path}');
      }

      // Check if user is explicitly unauthenticated (logged out)
      final isExplicitlyUnauthenticated = authState.maybeMap(
        unauthenticated: (_) => true,
        orElse: () => false,
      );

      final isAuthRoute = state.uri.path == '/login' ||
          state.uri.path == '/signup' ||
          state.uri.path == '/forgot-password' ||
          state.uri.path == '/email-verification' ||
          state.uri.path == '/password-reset';

      // If user is explicitly unauthenticated (just logged out), allow access to auth routes
      if (isExplicitlyUnauthenticated && isAuthRoute) {
        return null; // Allow access to auth routes
      }

      // Handle password reset flow navigation
      if (isInPasswordResetFlow) {
        // Allow access to password reset related routes
        if (state.uri.path == '/email-verification' ||
            state.uri.path == '/password-reset' ||
            state.uri.path == '/forgot-password') {
          return null;
        }

        // Handle password reset pending state - redirect to email verification
        final isPasswordResetPending = authState.maybeMap(
          passwordResetPending: (_) => true,
          orElse: () => false,
        );

        if (isPasswordResetPending && state.uri.path != '/email-verification') {
          final email = authState.maybeMap(
            passwordResetPending: (state) => state.email,
            orElse: () => '',
          );
          return '/email-verification?email=${Uri.encodeComponent(email)}&type=password_reset';
        }

        // Handle password reset verified state - redirect to password reset screen
        final isPasswordResetVerified = authState.maybeMap(
          passwordResetVerified: (_) => true,
          orElse: () => false,
        );

        if (isPasswordResetVerified && state.uri.path != '/password-reset') {
          final email = authState.maybeMap(
            passwordResetVerified: (state) => state.email,
            orElse: () => '',
          );
          final otp = authState.maybeMap(
            passwordResetVerified: (state) => state.otp,
            orElse: () => '',
          );
          return '/password-reset?email=${Uri.encodeComponent(email)}&otp=${Uri.encodeComponent(otp)}';
        }
      }

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
          // Check if user just verified email
          final isEmailVerified = authState.maybeMap(
            emailVerified: (_) => true,
            orElse: () => false,
          );

          if (isEmailVerified) {
            return '/onboarding';
          }

          return '/login';
        }
      }

      // Don't redirect if accessing detail pages or main navigation routes
      if (state.uri.path.startsWith('/timeline/') ||
          state.uri.path.startsWith('/story/') ||
          state.uri.path.startsWith('/quiz/') ||
          state.uri.path.startsWith('/games/') ||
          state.uri.path.startsWith('/community/') ||
          state.uri.path == '/home' ||
          state.uri.path == '/profile' ||
          state.uri.path == '/profile/edit' ||
          state.uri.path == '/settings' ||
          state.uri.path == '/subscription' ||
          state.uri.path == '/notifications' ||
          state.uri.path == '/leaderboard' ||
          state.uri.path == '/elearning' ||
          state.uri.path == '/games') {
        return null;
      }

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
        // If user has completed profile, redirect auth routes to home
        if (hasCompletedProfile) {
          if (isAuthRoute) {
            return '/home';
          }
          return null;
        }

        // If onboarding is not complete and on onboarding route, allow it
        if (!isOnboardingComplete && isOnboardingRoute) {
          return null;
        }

        // If onboarding is complete but profile setup not done, go to profile setup
        if (isOnboardingComplete && !isProfileSetupRoute) {
          return '/profile-setup';
        }

        // If on profile setup route, allow it
        if (isProfileSetupRoute) {
          return null;
        }

        // If onboarding is not complete, go to onboarding
        if (!isOnboardingComplete) {
          return '/onboarding';
        }

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
        path: '/email-verification',
        pageBuilder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          final type = state.uri.queryParameters['type'];
          return buildCupertinoPageTransition(
            context: context,
            state: state,
            child: EmailVerificationScreen(email: email, type: type),
          );
        },
      ),
      GoRoute(
        path: '/password-reset',
        pageBuilder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          final otp = state.uri.queryParameters['otp'] ?? '';
          return buildCupertinoPageTransition(
            context: context,
            state: state,
            child: PasswordResetScreen(email: email, otp: otp),
          );
        },
      ),
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) => buildFadeThroughTransition(
          context: context,
          state: state,
          child: const OnboardingScreen(),
        ),
      ),
      GoRoute(
        path: '/pro-onboarding',
        pageBuilder: (context, state) => buildFadeThroughTransition(
          context: context,
          state: state,
          child: const ProOnboardingScreen(),
        ),
      ),

      // Deep link routes for shared content (without bottom navigation)
      GoRoute(
        path: '/shared/profile/:profileId',
        pageBuilder: (context, state) {
          final profileIdStr = state.pathParameters['profileId']!;
          final profileId = int.tryParse(profileIdStr) ?? 0;
          return buildCupertinoPageTransition(
            context: context,
            state: state,
            child: UserProfileScreen(userId: profileId),
          );
        },
      ),
      GoRoute(
        path: '/shared/story/:storyId',
        pageBuilder: (context, state) {
          final storyId = state.pathParameters['storyId']!;
          return buildCupertinoPageTransition(
            context: context,
            state: state,
            child: StoryDetailScreen(storyId: storyId),
          );
        },
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
        name: 'subscription',
        builder: (context, state) => const SubscriptionScreen(),
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
          // Community route
          GoRoute(
            path: '/community',
            pageBuilder: (context, state) => buildCupertinoPageTransition(
              context: context,
              state: state,
              child: const CommunityScreen(),
            ),
          ),
          // Community detail route
          GoRoute(
            path: '/community/:communityId',
            pageBuilder: (context, state) {
              final communityIdStr = state.pathParameters['communityId'];
              if (communityIdStr == null) {
                return buildCupertinoPageTransition(
                  context: context,
                  state: state,
                  child: const SizedBox.shrink(),
                );
              }

              final communityId = int.tryParse(communityIdStr);
              if (communityId == null) {
                return buildCupertinoPageTransition(
                  context: context,
                  state: state,
                  child: const SizedBox.shrink(),
                );
              }

              return buildCupertinoPageTransition(
                context: context,
                state: state,
                child: CommunityDetailScreen(communityId: communityId),
              );
            },
          ),
          // Create post route
          GoRoute(
            path: '/community/:communityId/create-post',
            pageBuilder: (context, state) {
              final communityIdStr = state.pathParameters['communityId'];
              if (communityIdStr == null) {
                return buildCupertinoPageTransition(
                  context: context,
                  state: state,
                  child: const SizedBox.shrink(),
                );
              }

              final communityId = int.tryParse(communityIdStr);
              if (communityId == null) {
                return buildCupertinoPageTransition(
                  context: context,
                  state: state,
                  child: const SizedBox.shrink(),
                );
              }

              final extra = state.extra as Map<String, dynamic>?;
              final communityName =
                  extra?['communityName'] as String? ?? 'Community';

              return buildSlideUpTransition(
                context: context,
                state: state,
                child: CreatePostScreen(
                  communityId: communityId,
                  communityName: communityName,
                ),
              );
            },
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
          // Social routes
          GoRoute(
            path: '/add-friends',
            pageBuilder: (context, state) => buildSlideUpTransition(
              context: context,
              state: state,
              child: const AddFriendsScreen(),
            ),
          ),
          GoRoute(
            path: '/profile/:userId',
            pageBuilder: (context, state) {
              final userIdStr = state.pathParameters['userId'];
              if (userIdStr == null) {
                return buildCupertinoPageTransition(
                  context: context,
                  state: state,
                  child: const SizedBox.shrink(),
                );
              }

              final userId = int.tryParse(userIdStr);
              if (userId == null) {
                return buildCupertinoPageTransition(
                  context: context,
                  state: state,
                  child: const SizedBox.shrink(),
                );
              }

              return buildCupertinoPageTransition(
                context: context,
                state: state,
                child: UserProfileScreen(userId: userId),
              );
            },
          ),
          GoRoute(
            path: '/profile/:userId/followers',
            pageBuilder: (context, state) {
              final userIdStr = state.pathParameters['userId'];
              if (userIdStr == null) {
                return buildCupertinoPageTransition(
                  context: context,
                  state: state,
                  child: const SizedBox.shrink(),
                );
              }

              final userId = int.tryParse(userIdStr);
              if (userId == null) {
                return buildCupertinoPageTransition(
                  context: context,
                  state: state,
                  child: const SizedBox.shrink(),
                );
              }

              return buildCupertinoPageTransition(
                context: context,
                state: state,
                child: FollowersScreen(profileId: userId),
              );
            },
          ),
          GoRoute(
            path: '/profile/:userId/following',
            pageBuilder: (context, state) {
              final userIdStr = state.pathParameters['userId'];
              if (userIdStr == null) {
                return buildCupertinoPageTransition(
                  context: context,
                  state: state,
                  child: const SizedBox.shrink(),
                );
              }

              final userId = int.tryParse(userIdStr);
              if (userId == null) {
                return buildCupertinoPageTransition(
                  context: context,
                  state: state,
                  child: const SizedBox.shrink(),
                );
              }

              return buildCupertinoPageTransition(
                context: context,
                state: state,
                child: FollowingScreen(profileId: userId),
              );
            },
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
      // Create community route (outside main navigation - no bottom nav)
      GoRoute(
        path: '/create-community',
        pageBuilder: (context, state) => buildSlideUpTransition(
          context: context,
          state: state,
          child: const CreateCommunityScreen(),
        ),
      ),
    ],
  );
});
