import 'package:flutter/material.dart';
// import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:knowledge/data/providers/auth_provider.dart';
// import 'dart:ui';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:knowledge/core/themes/app_theme.dart';
// import 'package:knowledge/presentation/widgets/success_dialog.dart';

class LoginScreen extends HookConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
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
            height: 280,
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
                        const SizedBox(height: 40),
                        Image.asset(
                          'assets/images/logo/logo.png',
                          width: 100,
                          height: 100,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 28),
                        Text(
                          'Know [ Ledge ]',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 32,
                              ),
                          textAlign: TextAlign.center,
                        ).animate().fadeIn().slideY(
                              begin: 0.3,
                              duration: const Duration(milliseconds: 500),
                            ),
                        const SizedBox(height: 16),
                        Text(
                          'Your journey through History begins here',
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Colors.white70,
                                    fontSize: 16,
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
          // Login Form - Expanded to fill remaining space
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
                  padding: const EdgeInsets.fromLTRB(20.0, 40.0, 20.0, 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
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
                      const SizedBox(height: 20),
                      _buildInfoField(
                        context,
                        'Password',
                        passwordController,
                        Icons.lock_outline,
                        isPassword: true,
                      ).animate().fadeIn().slideX(
                            begin: -0.2,
                            delay: const Duration(milliseconds: 400),
                            duration: const Duration(milliseconds: 500),
                          ),
                      const SizedBox(height: 12),
                      // Forgot Password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => context.push('/forgot-password'),
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: AppColors.navyBlue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ).animate().fadeIn().slideX(
                            begin: 0.2,
                            delay: const Duration(milliseconds: 500),
                            duration: const Duration(milliseconds: 500),
                          ),
                      const SizedBox(height: 40),
                      // Login Button
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
                                  if (emailController.text.isEmpty ||
                                      passwordController.text.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Please fill in all fields')),
                                    );
                                    return;
                                  }
                                  await authNotifier.login(
                                    emailController.text.trim(),
                                    passwordController.text,
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
                                      'Login',
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
                      // Sign Up Link
                      Center(
                        child: TextButton(
                          onPressed: () => context.go('/signup'),
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 15,
                              ),
                              children: [
                                const TextSpan(
                                    text: 'Don\'t have an account? '),
                                TextSpan(
                                  text: 'Sign up',
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
                      const SizedBox(height: 16),
                      // Skip Button
                      // Center(
                      //   child: TextButton(
                      //     onPressed: () => ref
                      //         .read(authNotifierProvider.notifier)
                      //         .loginAsGuest(),
                      //     child: Text(
                      //       'Skip for now',
                      //       style: TextStyle(
                      //         color: Colors.grey.shade500,
                      //         fontSize: 14,
                      //       ),
                      //     ),
                      //   ),
                      // ).animate().fadeIn().slideY(
                      //       begin: 0.2,
                      //       delay: const Duration(milliseconds: 800),
                      //       duration: const Duration(milliseconds: 500),
                      //     ),
                      // const SizedBox(height: 20),
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
