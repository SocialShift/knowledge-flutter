import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:knowledge/data/providers/auth_provider.dart';
import 'package:knowledge/data/models/auth_state.dart';

class EmailVerificationGuard extends ConsumerStatefulWidget {
  final Widget child;

  const EmailVerificationGuard({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<EmailVerificationGuard> createState() =>
      _EmailVerificationGuardState();
}

class _EmailVerificationGuardState
    extends ConsumerState<EmailVerificationGuard> {
  bool _hasCheckedVerification = false;

  @override
  void initState() {
    super.initState();

    // Check verification status after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkEmailVerification();
    });
  }

  void _checkEmailVerification() async {
    if (_hasCheckedVerification) return;

    final authState = ref.read(authNotifierProvider);

    // Only check if user is authenticated AND their User object shows they are not verified
    authState.maybeMap(
      authenticated: (authenticatedState) {
        // Check the User object's isEmailVerified field directly
        if (!authenticatedState.user.isEmailVerified) {
          // Only then make the API call to double-check verification status
          final authNotifier = ref.read(authNotifierProvider.notifier);
          authNotifier.checkAndHandleEmailVerification();
        }
        // If user is verified according to their User object, don't do anything
      },
      orElse: () {},
    );

    setState(() {
      _hasCheckedVerification = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Listen for auth state changes and check verification if needed
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next != null) {
        next.maybeMap(
          authenticated: (authenticatedState) {
            // Only check if user is not verified and we haven't checked yet
            if (!_hasCheckedVerification &&
                !authenticatedState.user.isEmailVerified) {
              _checkEmailVerification();
            }
          },
          orElse: () {},
        );
      }
    });

    return widget.child;
  }
}
