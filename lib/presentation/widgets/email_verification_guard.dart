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

    // Only check if user is authenticated
    if (authState.maybeMap(
      authenticated: (_) => true,
      orElse: () => false,
    )) {
      final authNotifier = ref.read(authNotifierProvider.notifier);
      await authNotifier.checkAndHandleEmailVerification();

      setState(() {
        _hasCheckedVerification = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen for auth state changes and check verification if needed
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next != null) {
        next.maybeMap(
          authenticated: (_) {
            if (!_hasCheckedVerification) {
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
