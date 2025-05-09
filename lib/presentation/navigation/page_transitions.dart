import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

/// Creates an optimized iOS-style page transition with better performance.
CustomTransitionPage<T> buildCupertinoPageTransition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // Optimize the animation curve for smoother motion
      final primaryAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutQuart,
        reverseCurve: Curves.easeInQuart,
      );

      final secondAnimation = CurvedAnimation(
        parent: secondaryAnimation,
        curve: Curves.easeInOut,
      );

      return CupertinoPageTransition(
        primaryRouteAnimation: primaryAnimation,
        secondaryRouteAnimation: secondAnimation,
        linearTransition: false,
        child: child,
      );
    },
    // Reduce the transition duration slightly for a snappier feel
    transitionDuration: const Duration(milliseconds: 250),
    reverseTransitionDuration: const Duration(milliseconds: 200),
    maintainState: true,
    opaque: true,
  );
}

/// Creates an optimized fade-through transition.
CustomTransitionPage<T> buildFadeThroughTransition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // Use a more performant curve for fade transitions
      return FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        ),
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 220),
    reverseTransitionDuration: const Duration(milliseconds: 200),
    maintainState: true,
    opaque: true,
  );
}

/// Creates an optimized slide-up transition.
CustomTransitionPage<T> buildSlideUpTransition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // Optimize both slide and fade
      const begin = Offset(0.0, 0.15); // Reduced distance for smoother feel
      const end = Offset.zero;

      final slideAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );

      final tween = Tween(begin: begin, end: end);
      final fadeAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );

      return FadeTransition(
        opacity: fadeAnimation,
        child: SlideTransition(
          position: tween.animate(slideAnimation),
          child: child,
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 220),
    reverseTransitionDuration: const Duration(milliseconds: 200),
    maintainState: true,
    opaque: true,
  );
}

/// Creates a shared axis horizontal transition with optimized performance.
CustomTransitionPage<T> buildSharedAxisHorizontalTransition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // Reduced slide distance for smoother animations
      const begin = Offset(0.15, 0.0);
      const end = Offset.zero;

      // Use better curves for smoother animation
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );

      final fadeAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOut,
      );

      final tween = Tween(begin: begin, end: end);

      return FadeTransition(
        opacity: fadeAnimation,
        child: SlideTransition(
          position: tween.animate(curvedAnimation),
          child: child,
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 220),
    reverseTransitionDuration: const Duration(milliseconds: 200),
    maintainState: true,
    opaque: true,
  );
}

/// A zero-animation immediate transition for situations where animations
/// might be too heavy on performance.
CustomTransitionPage<T> buildImmediateTransition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return child;
    },
    transitionDuration: Duration.zero,
    reverseTransitionDuration: Duration.zero,
    maintainState: true,
    opaque: true,
  );
}
