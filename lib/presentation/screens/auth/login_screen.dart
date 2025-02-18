import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:knowledge/data/providers/auth_provider.dart';
import 'dart:ui';
import 'package:flutter_animate/flutter_animate.dart';

class LoginScreen extends HookConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final authNotifier = ref.watch(authNotifierProvider.notifier);
    final authState = ref.watch(authNotifierProvider);

    // Add animation controller using hooks
    final isAnimating = useState(true);

    // Use effect to control initial animation
    useEffect(() {
      Future.delayed(const Duration(milliseconds: 1000), () {
        isAnimating.value = false;
      });
      return null;
    }, []);

    // Handle auth state changes
    ref.listen(authNotifierProvider, (previous, next) {
      // Clear any existing snackbars first
      ScaffoldMessenger.of(context).clearSnackBars();

      next.when(
        initial: () => null,
        loading: () {
          _showSnackBar(
            context,
            'Logging in...',
            backgroundColor: Colors.blue,
            showProgress: true,
          );
        },
        authenticated: (user, message) {
          _showSnackBar(
            context,
            message ?? 'Login successful!',
            backgroundColor: Colors.green,
          ).then((_) {
            if (context.mounted) {
              context.go('/onboarding'); // Changed from /home to /onboarding
            }
          });
        },
        unauthenticated: (message) {
          if (message != null) {
            _showSnackBar(
              context,
              message,
              backgroundColor: Colors.orange,
            );
          }
        },
        error: (message) {
          _showSnackBar(
            context,
            message,
            backgroundColor: Colors.red,
          );
        },
        guest: () {
          context.go('/home');
        },
      );
    });

    return Scaffold(
      backgroundColor: const Color(0xFF3498DB),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Initial spacer with smooth animation
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 1000),
                      height: isAnimating.value
                          ? MediaQuery.of(context).size.height * 0.3
                          : 60,
                      curve: Curves.easeOutCubic,
                    ),
                    // Logo with professional animation
                    Center(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 1000),
                        width: isAnimating.value ? 200 : 120,
                        height: isAnimating.value ? 200 : 120,
                        curve: Curves.easeOutCubic,
                        child: Image.asset(
                          'assets/images/logo/logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ).animate(
                      effects: [
                        FadeEffect(
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeOut,
                        ),
                        ScaleEffect(
                          begin: const Offset(0.8, 0.8),
                          end: const Offset(1, 1),
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeOut,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    // Welcome text with fade animation
                    Text(
                      'Know [ Ledge ]',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                      textAlign: TextAlign.center,
                    ).animate(
                      delay: const Duration(milliseconds: 400),
                      effects: const [
                        FadeEffect(
                          duration: Duration(milliseconds: 800),
                          curve: Curves.easeOut,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your journey through History begins here',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white70,
                          ),
                      textAlign: TextAlign.center,
                    ).animate(
                      delay: const Duration(milliseconds: 600),
                      effects: const [
                        FadeEffect(
                          duration: Duration(milliseconds: 800),
                          curve: Curves.easeOut,
                        ),
                      ],
                    ),
                    const SizedBox(height: 48),
                    // Form fields with fade animation
                    Column(
                      children: [
                        // Email field
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: TextField(
                              controller: emailController,
                              style: const TextStyle(color: Colors.white),
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                hintText: 'Email',
                                hintStyle: TextStyle(
                                    color: Colors.white.withOpacity(0.7)),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.1),
                                prefixIcon: Icon(CupertinoIcons.mail,
                                    color: Colors.white.withOpacity(0.7)),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
                            ),
                          ),
                        ).animate(
                          delay: const Duration(milliseconds: 800),
                          effects: const [
                            FadeEffect(
                              duration: Duration(milliseconds: 800),
                              curve: Curves.easeOut,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Password field
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: TextField(
                              controller: passwordController,
                              obscureText: true,
                              style: const TextStyle(color: Colors.white),
                              textInputAction: TextInputAction.done,
                              decoration: InputDecoration(
                                hintText: 'Password',
                                hintStyle: TextStyle(
                                    color: Colors.white.withOpacity(0.7)),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.1),
                                prefixIcon: Icon(CupertinoIcons.lock,
                                    color: Colors.white.withOpacity(0.7)),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
                            ),
                          ),
                        ).animate(
                          delay: const Duration(milliseconds: 800),
                          effects: const [
                            FadeEffect(
                              duration: Duration(milliseconds: 800),
                              curve: Curves.easeOut,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Forgot Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => context.push('/forgot-password'),
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ),
                    ).animate(
                      delay: const Duration(milliseconds: 800),
                      effects: const [
                        FadeEffect(
                          duration: Duration(milliseconds: 800),
                          curve: Curves.easeOut,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Login Button
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFB5FF3A), Color(0xFF8CD612)],
                        ),
                      ),
                      child: ElevatedButton(
                        onPressed: authState.maybeMap(
                          loading: (_) => null,
                          orElse: () => () async {
                            // Clear any existing snackbars
                            ScaffoldMessenger.of(context).clearSnackBars();

                            // Validate inputs
                            if (emailController.text.isEmpty ||
                                passwordController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please fill in all fields'),
                                  backgroundColor: Colors.orange,
                                  behavior: SnackBarBehavior.floating,
                                  margin: EdgeInsets.all(16),
                                  duration: Duration(seconds: 3),
                                ),
                              );
                              return;
                            }

                            if (!emailController.text.contains('@')) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please enter a valid email'),
                                  backgroundColor: Colors.orange,
                                  behavior: SnackBarBehavior.floating,
                                  margin: EdgeInsets.all(16),
                                  duration: Duration(seconds: 3),
                                ),
                              );
                              return;
                            }

                            await authNotifier.login(
                              emailController.text.trim(),
                              passwordController.text,
                            );
                          },
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.black,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: authState.maybeMap(
                          loading: (_) => const CircularProgressIndicator(),
                          orElse: () => const Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ).animate(
                      delay: const Duration(milliseconds: 800),
                      effects: const [
                        FadeEffect(
                          duration: Duration(milliseconds: 800),
                          curve: Curves.easeOut,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Sign Up Link
                    TextButton(
                      onPressed: () => context.go('/signup'),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: const TextStyle(color: Colors.white70),
                          children: [
                            const TextSpan(text: 'Don\'t have an account? '),
                            TextSpan(
                              text: 'Sign up',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.white.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate(
                      delay: const Duration(milliseconds: 800),
                      effects: const [
                        FadeEffect(
                          duration: Duration(milliseconds: 800),
                          curve: Curves.easeOut,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Skip Button
                    TextButton(
                      onPressed: () => ref
                          .read(authNotifierProvider.notifier)
                          .loginAsGuest(),
                      child: Text(
                        'Skip for now',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ).animate(
                      delay: const Duration(milliseconds: 800),
                      effects: const [
                        FadeEffect(
                          duration: Duration(milliseconds: 800),
                          curve: Curves.easeOut,
                        ),
                      ],
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showSnackBar(
    BuildContext context,
    String message, {
    Color backgroundColor = Colors.black,
    bool showProgress = false,
  }) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          if (showProgress) ...[
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    );

    return ScaffoldMessenger.of(context).showSnackBar(snackBar).closed;
  }
}
