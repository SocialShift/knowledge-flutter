import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:knowledge/data/providers/auth_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:knowledge/core/themes/app_theme.dart';

class EmailVerificationScreen extends HookConsumerWidget {
  final String email;

  const EmailVerificationScreen({
    super.key,
    required this.email,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final otpController = useTextEditingController();
    final authNotifier = ref.watch(authNotifierProvider.notifier);
    final authState = ref.watch(authNotifierProvider);

    // Show error message if there is one
    useEffect(() {
      authState.maybeMap(
        error: (state) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          });
        },
        emailVerificationPending: (state) {
          if (state.message != null && state.message!.contains('sent')) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message!),
                  backgroundColor: Colors.green,
                ),
              );
            });
          }
        },
        orElse: () {},
      );
      return null;
    }, [authState]);

    // Show success message and navigate to login for verification scenarios (not logout)
    useEffect(() {
      authState.maybeMap(
        unauthenticated: (state) {
          // Clear account deletion messages to prevent redirect loops
          if (state.message != null &&
              state.message!.toLowerCase().contains('account deleted')) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              // Show the message briefly, then clear it
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message!),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                ),
              );
              // Clear the message to prevent redirect loops
              Future.delayed(const Duration(milliseconds: 500), () {
                final authNotifier = ref.read(authNotifierProvider.notifier);
                authNotifier.clearMessage();
              });
            });
            return;
          }

          // Only redirect to login if this is a verification-related success message
          // NOT from logout
          if (state.message != null &&
              !state.message!.toLowerCase().contains('logged out') &&
              !state.message!.toLowerCase().contains('logout')) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message!),
                  backgroundColor: Colors.green,
                ),
              );
              Future.delayed(const Duration(seconds: 2), () {
                if (context.mounted) {
                  context.go('/login');
                }
              });
            });
          }
        },
        emailVerified: (state) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message ?? 'Email verified successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            Future.delayed(const Duration(seconds: 2), () {
              if (context.mounted) {
                context.go('/onboarding');
              }
            });
          });
        },
        orElse: () {},
      );
      return null;
    }, [authState]);

    // Show loading indicator
    final isLoading = authState.maybeMap(
      loading: (_) => true,
      orElse: () => false,
    );

    return Scaffold(
      backgroundColor: AppColors.navyBlue,
      body: Column(
        children: [
          // Header with gradient and logo
          SizedBox(
            height: 240,
            child: Stack(
              children: [
                // Gradient background
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.lightPurple,
                        AppColors.navyBlue,
                      ],
                    ),
                  ),
                ),
                // Logo and title
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 30),
                        Icon(
                          Icons.mark_email_read_outlined,
                          size: 80,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Verify Your Email',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                          textAlign: TextAlign.center,
                        ).animate().fadeIn().slideY(
                              begin: 0.3,
                              duration: const Duration(milliseconds: 500),
                            ),
                        const SizedBox(height: 8),
                        Text(
                          'We sent a verification code to\n$email',
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                          textAlign: TextAlign.center,
                        ).animate().fadeIn().slideY(
                              begin: 0.3,
                              delay: const Duration(milliseconds: 200),
                              duration: const Duration(milliseconds: 500),
                            ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Verification Form - Expanded to fill remaining space
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 30.0, 20.0, 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Enter Verification Code',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.grey.shade800,
                              fontWeight: FontWeight.bold,
                            ),
                      ).animate().fadeIn().slideY(
                            begin: 0.2,
                            delay: const Duration(milliseconds: 300),
                            duration: const Duration(milliseconds: 500),
                          ),
                      const SizedBox(height: 8),
                      Text(
                        'Please enter the 6-digit code sent to your email',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn().slideY(
                            begin: 0.2,
                            delay: const Duration(milliseconds: 400),
                            duration: const Duration(milliseconds: 500),
                          ),
                      const SizedBox(height: 40),
                      _buildOTPField(
                        context,
                        otpController,
                      ).animate().fadeIn().slideX(
                            begin: -0.2,
                            delay: const Duration(milliseconds: 500),
                            duration: const Duration(milliseconds: 500),
                          ),
                      const SizedBox(height: 40),
                      // Verify Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.limeGreen,
                            foregroundColor: AppColors.navyBlue,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: isLoading
                              ? null
                              : () async {
                                  if (otpController.text.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Please enter the verification code')),
                                    );
                                    return;
                                  }
                                  if (otpController.text.length != 6) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Please enter a valid 6-digit code')),
                                    );
                                    return;
                                  }
                                  await authNotifier.verifyEmail(
                                    email,
                                    otpController.text.trim(),
                                  );
                                },
                          child: isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.navyBlue,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Verify Email',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      Icons.verified,
                                      color: AppColors.navyBlue,
                                    ),
                                  ],
                                ),
                        ),
                      ).animate().fadeIn().slideY(
                            begin: 0.2,
                            delay: const Duration(milliseconds: 600),
                            duration: const Duration(milliseconds: 500),
                          ),
                      const SizedBox(height: 20),
                      // Resend Code Link
                      Center(
                        child: TextButton(
                          onPressed: isLoading
                              ? null
                              : () async {
                                  await authNotifier
                                      .resendVerificationEmail(email);
                                },
                          child: Text(
                            'Didn\'t receive the code? Resend',
                            style: TextStyle(
                              color: AppColors.navyBlue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ).animate().fadeIn().slideY(
                            begin: 0.2,
                            delay: const Duration(milliseconds: 700),
                            duration: const Duration(milliseconds: 500),
                          ),
                      const SizedBox(height: 20),
                      // Back to Login Link
                      Center(
                        child: TextButton(
                          onPressed: isLoading
                              ? null
                              : () async {
                                  try {
                                    // Show loading feedback
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(Colors.white),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            const Text('Clearing session...'),
                                          ],
                                        ),
                                        backgroundColor: AppColors.navyBlue,
                                        behavior: SnackBarBehavior.floating,
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );

                                    // Clear verification state to allow email change
                                    await authNotifier.clearVerificationState();

                                    if (context.mounted) {
                                      // Clear the loading snackbar
                                      ScaffoldMessenger.of(context)
                                          .clearSnackBars();
                                      context.go('/login');
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .clearSnackBars();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text('Error: $e'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                },
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 15,
                              ),
                              children: [
                                const TextSpan(text: 'Use different email? '),
                                TextSpan(
                                  text: 'Back to Login',
                                  style: TextStyle(
                                    color: AppColors.navyBlue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ).animate().fadeIn().slideY(
                            begin: 0.2,
                            delay: const Duration(milliseconds: 800),
                            duration: const Duration(milliseconds: 500),
                          ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOTPField(
    BuildContext context,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            'Verification Code',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 6,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            style: TextStyle(
              color: Colors.grey.shade800,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 8,
            ),
            decoration: InputDecoration(
              hintText: '000000',
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 8,
              ),
              prefixIcon: Icon(
                Icons.security,
                color: AppColors.navyBlue,
              ),
              border: InputBorder.none,
              counterText: '',
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
