import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:knowledge/data/providers/auth_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:knowledge/core/themes/app_theme.dart';

class ForgotPasswordScreen extends HookConsumerWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController();
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
        orElse: () {},
      );
      return null;
    }, [authState]);

    // Handle password reset pending state and navigate to email verification
    useEffect(() {
      authState.maybeMap(
        passwordResetPending: (state) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message ?? 'Password reset code sent!'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
            // Router will handle navigation automatically
          });
        },
        unauthenticated: (state) {
          // Handle successful password reset completion
          if (state.message != null &&
              state.message!
                  .toLowerCase()
                  .contains('password reset successfully')) {
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
                // Back button
                Positioned(
                  top: 40,
                  left: 16,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => context.go('/login'),
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
                        Image.asset(
                          'assets/images/logo/logo.png',
                          width: 100,
                          height: 100,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Forgot Password',
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
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Form - Expanded to fill remaining space
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
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text(
                          'Enter your email address and we\'ll send you instructions to reset your password.',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ).animate().fadeIn().slideY(
                            begin: 0.3,
                            delay: const Duration(milliseconds: 200),
                            duration: const Duration(milliseconds: 500),
                          ),
                      const SizedBox(height: 30),
                      _buildInfoField(
                        context,
                        'Email',
                        emailController,
                        Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ).animate().fadeIn().slideX(
                            begin: -0.2,
                            delay: const Duration(milliseconds: 300),
                            duration: const Duration(milliseconds: 500),
                          ),
                      const SizedBox(height: 40),
                      // Submit Button
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
                                  if (emailController.text.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text('Please enter your email')),
                                    );
                                    return;
                                  }
                                  await authNotifier.requestPasswordReset(
                                      emailController.text.trim());
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
                                      'Reset Password',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      Icons.arrow_forward,
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
                      // Back to Login
                      Center(
                        child: TextButton(
                          onPressed: () => context.go('/login'),
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 15,
                              ),
                              children: [
                                const TextSpan(
                                    text: 'Remember your password? '),
                                TextSpan(
                                  text: 'Login',
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
                            delay: const Duration(milliseconds: 700),
                            duration: const Duration(milliseconds: 500),
                          ),
                      const SizedBox(height: 20),
                      // Additional space filler
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.1,
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

  Widget _buildInfoField(
    BuildContext context,
    String label,
    TextEditingController controller,
    IconData icon, {
    bool isPassword = false,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            label,
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
            obscureText: isPassword,
            keyboardType: keyboardType,
            style: TextStyle(
              color: Colors.grey.shade800,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: 'Enter your $label',
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 14,
              ),
              prefixIcon: Icon(
                icon,
                color: AppColors.navyBlue,
              ),
              border: InputBorder.none,
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
