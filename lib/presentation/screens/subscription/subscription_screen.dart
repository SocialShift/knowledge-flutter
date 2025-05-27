import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:knowledge/core/themes/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:knowledge/data/providers/subscription_provider.dart';
import 'dart:math' as math;

class SubscriptionScreen extends HookConsumerWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionNotifier =
        ref.watch(subscriptionNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.navyBlue,
      body: Stack(
        children: [
          // Animated background - covers entire screen
          Positioned.fill(
            child: _AnimatedBackground(),
          ),

          // Close button positioned at top with SafeArea
          Positioned(
            top: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.all(8),
                    child:
                        const Icon(Icons.close, color: Colors.white, size: 28),
                  ),
                ),
              ),
            ),
          ),

          // Main content with SafeArea - scrollable to prevent overflow
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
              child: Column(
                children: [
                  // Enhanced logo with premium styling
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.limeGreen.withOpacity(0.3),
                          AppColors.limeGreen.withOpacity(0.1),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.7, 1.0],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.limeGreen.withOpacity(0.5),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                        BoxShadow(
                          color: AppColors.limeGreen.withOpacity(0.3),
                          blurRadius: 60,
                          spreadRadius: 20,
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(0.1),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      child: Image.asset(
                        'assets/images/logo/logo.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.school,
                            size: 50,
                            color: AppColors.limeGreen,
                          );
                        },
                      ),
                    ),
                  ).animate().fadeIn().scale(
                        delay: const Duration(milliseconds: 100),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.elasticOut,
                      ),

                  const SizedBox(height: 32),

                  // Enhanced main heading with gradient text effect
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [
                        Colors.white,
                        AppColors.limeGreen,
                        Colors.white,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ).createShader(bounds),
                    child: Text(
                      'Unlock Your Full\nLearning Potential',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                        letterSpacing: -0.5,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.4),
                            offset: const Offset(0, 3),
                            blurRadius: 8,
                          ),
                          Shadow(
                            color: AppColors.limeGreen.withOpacity(0.3),
                            offset: const Offset(0, 0),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn().slideY(
                        begin: 0.3,
                        delay: const Duration(milliseconds: 200),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeOutBack,
                      ),

                  const SizedBox(height: 12),

                  // Subtitle (smaller)
                  Text(
                    'learners who are 4.2x more\nlikely to complete their learning journey',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                      height: 1.3,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.2),
                          offset: const Offset(0, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ).animate().fadeIn().slideY(
                        begin: 0.2,
                        delay: const Duration(milliseconds: 300),
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOutCubic,
                      ),

                  const SizedBox(height: 40),

                  // Enhanced feature cards with premium styling
                  _buildEnhancedFeatureCard(
                    icon: Icons.favorite_rounded,
                    title: 'Unlimited Hearts',
                    description: 'Learn without limits',
                    gradient: [Colors.red.shade400, Colors.pink.shade300],
                    delay: 400,
                  ),

                  const SizedBox(height: 16),

                  _buildEnhancedFeatureCard(
                    icon: Icons.block_rounded,
                    title: 'Ad-Free Experience',
                    description: 'Focus on what matters',
                    gradient: [Colors.blue.shade400, Colors.cyan.shade300],
                    delay: 500,
                  ),

                  const SizedBox(height: 16),

                  _buildEnhancedFeatureCard(
                    icon: Icons.library_books_rounded,
                    title: 'Full Story Archive',
                    description: 'Access all historical content',
                    gradient: [
                      Colors.purple.shade400,
                      Colors.deepPurple.shade300
                    ],
                    delay: 600,
                  ),

                  const SizedBox(height: 16),

                  _buildEnhancedFeatureCard(
                    icon: Icons.notifications_active_rounded,
                    title: 'Daily Insights',
                    description: 'Personalized "On This Day" alerts',
                    gradient: [Colors.orange.shade400, Colors.amber.shade300],
                    delay: 700,
                  ),

                  const SizedBox(height: 40),

                  // Enhanced pricing section with premium styling
                  // Container(
                  //   padding: const EdgeInsets.all(24),
                  //   decoration: BoxDecoration(
                  //     gradient: LinearGradient(
                  //       begin: Alignment.topLeft,
                  //       end: Alignment.bottomRight,
                  //       colors: [
                  //         AppColors.limeGreen.withOpacity(0.2),
                  //         AppColors.limeGreen.withOpacity(0.1),
                  //         Colors.white.withOpacity(0.1),
                  //       ],
                  //       stops: const [0.0, 0.5, 1.0],
                  //     ),
                  //     borderRadius: BorderRadius.circular(20),
                  //     border: Border.all(
                  //       color: AppColors.limeGreen.withOpacity(0.4),
                  //       width: 2,
                  //     ),
                  //     boxShadow: [
                  //       BoxShadow(
                  //         color: AppColors.limeGreen.withOpacity(0.3),
                  //         blurRadius: 20,
                  //         spreadRadius: 0,
                  //         offset: const Offset(0, 8),
                  //       ),
                  //       BoxShadow(
                  //         color: Colors.black.withOpacity(0.1),
                  //         blurRadius: 10,
                  //         spreadRadius: 0,
                  //         offset: const Offset(0, 4),
                  //       ),
                  //     ],
                  //   ),
                  //   child: Column(
                  //     children: [
                  //       Container(
                  //         padding: const EdgeInsets.symmetric(
                  //           horizontal: 12,
                  //           vertical: 6,
                  //         ),
                  //         decoration: BoxDecoration(
                  //           color: AppColors.limeGreen,
                  //           borderRadius: BorderRadius.circular(20),
                  //           boxShadow: [
                  //             BoxShadow(
                  //               color: AppColors.limeGreen.withOpacity(0.4),
                  //               blurRadius: 8,
                  //               offset: const Offset(0, 2),
                  //             ),
                  //           ],
                  //         ),
                  //         child: Text(
                  //           '🎉 LIMITED TIME OFFER',
                  //           style: TextStyle(
                  //             color: AppColors.navyBlue,
                  //             fontSize: 12,
                  //             fontWeight: FontWeight.bold,
                  //             letterSpacing: 0.5,
                  //           ),
                  //         ),
                  //       ),
                  //       const SizedBox(height: 16),
                  //       Text(
                  //         'Start Your Free Week',
                  //         style: TextStyle(
                  //           color: Colors.white,
                  //           fontSize: 22,
                  //           fontWeight: FontWeight.bold,
                  //           letterSpacing: -0.5,
                  //         ),
                  //       ),
                  //       const SizedBox(height: 8),
                  //       Row(
                  //         mainAxisAlignment: MainAxisAlignment.center,
                  //         crossAxisAlignment: CrossAxisAlignment.baseline,
                  //         textBaseline: TextBaseline.alphabetic,
                  //         children: [
                  //           Text(
                  //             'Then ',
                  //             style: TextStyle(
                  //               color: Colors.white.withOpacity(0.8),
                  //               fontSize: 16,
                  //             ),
                  //           ),
                  //           Text(
                  //             '\$9.99',
                  //             style: TextStyle(
                  //               color: AppColors.limeGreen,
                  //               fontSize: 24,
                  //               fontWeight: FontWeight.bold,
                  //             ),
                  //           ),
                  //           Text(
                  //             '/month',
                  //             style: TextStyle(
                  //               color: Colors.white.withOpacity(0.8),
                  //               fontSize: 16,
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //       const SizedBox(height: 8),
                  //       Text(
                  //         'Cancel anytime • No commitment',
                  //         style: TextStyle(
                  //           color: Colors.white.withOpacity(0.7),
                  //           fontSize: 13,
                  //           fontStyle: FontStyle.italic,
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ).animate().fadeIn().scale(
                  //       delay: const Duration(milliseconds: 800),
                  //       duration: const Duration(milliseconds: 800),
                  //       curve: Curves.elasticOut,
                  //     ),

                  // const SizedBox(height: 10),

                  // Enhanced Subscribe Button
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.limeGreen,
                          AppColors.limeGreen.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.limeGreen.withOpacity(0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: AppColors.navyBlue,
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      onPressed: () async {
                        await subscriptionNotifier
                            .subscribe(SubscriptionPlan.monthly);

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                'Starting your free trial!',
                                style: TextStyle(color: Colors.white),
                              ),
                              backgroundColor: AppColors.navyBlue,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              margin: const EdgeInsets.all(12),
                            ),
                          );
                          context.pop();
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.rocket_launch_rounded,
                            color: AppColors.navyBlue,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'START MY FREE WEEK',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn().slideY(
                        begin: 0.3,
                        delay: const Duration(milliseconds: 900),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.elasticOut,
                      ),

                  const SizedBox(height: 16),

                  // No Thanks Button
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Maybe Later',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ).animate().fadeIn(
                        delay: const Duration(milliseconds: 1000),
                        duration: const Duration(milliseconds: 400),
                      ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required List<Color> gradient,
    required int delay,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradient,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: gradient.first.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.check_circle_rounded,
            color: AppColors.limeGreen,
            size: 20,
          ),
        ],
      ),
    ).animate().fadeIn().slideX(
          begin: 0.3,
          delay: Duration(milliseconds: delay),
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOutBack,
        );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required int delay,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.limeGreen.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: AppColors.limeGreen,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideX(
          begin: 0.3,
          delay: Duration(milliseconds: delay),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
        );
  }
}

// Custom painter for animated wavy lines
class AnimatedWavyLinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double animationValue;

  AnimatedWavyLinePainter({
    required this.color,
    this.strokeWidth = 2.0,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final waveHeight = size.height * 0.3;
    final waveLength = size.width / 4;
    final animationOffset = animationValue * waveLength;

    // Start point
    path.moveTo(-animationOffset, size.height / 2);

    // Create smooth wavy curves with animation
    for (int i = -1; i < 5; i++) {
      final x1 = (i * waveLength) + (waveLength * 0.25) - animationOffset;
      final y1 = (size.height / 2) + (i.isEven ? -waveHeight : waveHeight);
      final x2 = (i * waveLength) + (waveLength * 0.75) - animationOffset;
      final y2 = (size.height / 2) + (i.isEven ? -waveHeight : waveHeight);
      final x3 = (i + 1) * waveLength - animationOffset;
      final y3 = size.height / 2;

      path.cubicTo(x1, y1, x2, y2, x3, y3);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(AnimatedWavyLinePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.animationValue != animationValue;
  }
}

class _AnimatedBackground extends StatefulWidget {
  @override
  State<_AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<_AnimatedBackground>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _particlesController;
  late Animation<double> _backgroundFloat1;
  late Animation<double> _backgroundFloat2;
  late Animation<double> _particlesAnimation;

  @override
  void initState() {
    super.initState();

    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 6000),
      vsync: this,
    );

    _particlesController = AnimationController(
      duration: const Duration(milliseconds: 8000),
      vsync: this,
    );

    _backgroundFloat1 = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.linear,
    ));

    _backgroundFloat2 = Tween<double>(
      begin: 0.0,
      end: 4 * math.pi,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.linear,
    ));

    _particlesAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _particlesController,
      curve: Curves.linear,
    ));

    _backgroundController.repeat();
    _particlesController.repeat();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _particlesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: Listenable.merge([
        _backgroundController,
        _particlesController,
      ]),
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      const Color(0xFF1A1A2E),
                      AppColors.darkBackground,
                      const Color(0xFF16213E),
                    ]
                  : [
                      const Color(0xFF1E3A8A),
                      AppColors.navyBlue,
                      const Color(0xFF312E81),
                    ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: Stack(
            children: [
              // Floating abstract shapes
              _buildFloatingShape(
                top: MediaQuery.of(context).size.height * 0.1 +
                    math.sin(_backgroundFloat1.value) * 30,
                left: -100 + math.cos(_backgroundFloat1.value * 0.7) * 50,
                width: 250,
                height: 180,
                colors: [
                  AppColors.limeGreen.withOpacity(0.15),
                  AppColors.limeGreen.withOpacity(0.05),
                ],
                borderRadius: const BorderRadius.only(
                  topRight: Radius.elliptical(180, 100),
                  bottomRight: Radius.elliptical(120, 80),
                ),
              ),

              _buildFloatingShape(
                top: MediaQuery.of(context).size.height * 0.3 +
                    math.cos(_backgroundFloat2.value * 0.8) * 40,
                right: -120 + math.sin(_backgroundFloat2.value * 0.6) * 60,
                width: 200,
                height: 150,
                colors: [
                  Colors.white.withOpacity(0.12),
                  Colors.white.withOpacity(0.03),
                ],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.elliptical(150, 90),
                  bottomLeft: Radius.elliptical(100, 70),
                ),
              ),

              _buildFloatingShape(
                bottom: MediaQuery.of(context).size.height * 0.2 +
                    math.sin(_backgroundFloat1.value * 1.2) * 25,
                left: -80 + math.cos(_backgroundFloat1.value * 0.9) * 40,
                width: 180,
                height: 120,
                colors: [
                  const Color(0xFF00FF88).withOpacity(0.08),
                  Colors.transparent,
                ],
                borderRadius: const BorderRadius.only(
                  topRight: Radius.elliptical(120, 70),
                  bottomRight: Radius.elliptical(90, 50),
                ),
              ),

              // Floating particles
              ...List.generate(8, (index) {
                final offset = index * 0.5;
                final x = 50 +
                    (index * 45) +
                    math.sin(_particlesAnimation.value * 2 * math.pi + offset) *
                        30;
                final y = 100 +
                    (index * 80) +
                    math.cos(_particlesAnimation.value * 2 * math.pi +
                            offset * 1.5) *
                        50;

                return Positioned(
                  left: x,
                  top: y,
                  child: _buildFloatingParticle(
                    size: 8 + (index % 3) * 4,
                    opacity: 0.4 +
                        math.sin(_particlesAnimation.value * 4 * math.pi +
                                offset) *
                            0.3,
                    color: index % 3 == 0
                        ? AppColors.limeGreen
                        : index % 3 == 1
                            ? Colors.white
                            : const Color(0xFF00FF88),
                  ),
                );
              }),

              // Dynamic wavy patterns (same as loading screen)
              Positioned(
                top: MediaQuery.of(context).size.height * 0.25,
                left: 0,
                right: 0,
                child: Transform.translate(
                  offset: Offset(math.sin(_backgroundFloat1.value) * 20, 0),
                  child: CustomPaint(
                    size: Size(double.infinity, 60),
                    painter: AnimatedWavyLinePainter(
                      color: Colors.white.withOpacity(0.1),
                      strokeWidth: 2,
                      animationValue: _backgroundFloat1.value,
                    ),
                  ),
                ),
              ),

              Positioned(
                bottom: MediaQuery.of(context).size.height * 0.3,
                left: 0,
                right: 0,
                child: Transform.translate(
                  offset: Offset(math.cos(_backgroundFloat2.value) * 15, 0),
                  child: CustomPaint(
                    size: Size(double.infinity, 40),
                    painter: AnimatedWavyLinePainter(
                      color: AppColors.limeGreen.withOpacity(0.08),
                      strokeWidth: 1.5,
                      animationValue: _backgroundFloat2.value * 0.7,
                    ),
                  ),
                ),
              ),

              // Glass morphism overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.05),
                      Colors.transparent,
                      Colors.white.withOpacity(0.02),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFloatingShape({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double width,
    required double height,
    required List<Color> colors,
    required BorderRadius borderRadius,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
          borderRadius: borderRadius,
        ),
      ),
    );
  }

  Widget _buildFloatingParticle({
    required double size,
    required double opacity,
    required Color color,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(opacity),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(opacity * 0.5),
            blurRadius: size * 0.8,
            spreadRadius: size * 0.2,
          ),
        ],
      ),
    );
  }
}
