import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:knowledge/core/themes/app_theme.dart';
import 'package:knowledge/data/providers/game_provider.dart';
import 'package:knowledge/presentation/screens/games/games_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;

class GameCompletionScreen extends HookConsumerWidget {
  final String gameId;
  final String gameTitle;
  final int gameType;
  final int score;
  final int totalQuestions;

  const GameCompletionScreen({
    super.key,
    required this.gameId,
    required this.gameTitle,
    required this.gameType,
    required this.score,
    required this.totalQuestions,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final percentage = ((score / totalQuestions) * 100).round();

    // Override back button to go to home
    return WillPopScope(
      onWillPop: () async {
        context.go('/home');
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.navyBlue,
        body: Stack(
          children: [
            // Animated background - covers entire screen
            Positioned.fill(
              child: _AnimatedBackground(),
            ),

            SafeArea(
              child: Column(
                children: [
                  // Close button in top-left
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: GestureDetector(
                        onTap: () => context.go('/home'),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(8.0),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Main content
                  Expanded(
                    child: _buildCompletionContent(context, ref),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionContent(BuildContext context, WidgetRef ref) {
    final percentage = ((score / totalQuestions) * 100).round();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            // Enhanced Trophy icon with multiple animations
            Stack(
              alignment: Alignment.center,
              children: [
                // Outer glow ring
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        _getTrophyColor(percentage).withOpacity(0.3),
                        _getTrophyColor(percentage).withOpacity(0.2),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.7, 1.0],
                    ),
                  ),
                ).animate(onPlay: (controller) => controller.repeat()).scale(
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1.2, 1.2),
                      duration: const Duration(milliseconds: 2000),
                      curve: Curves.easeInOut,
                    ),

                // Main trophy container
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        _getTrophyColor(percentage).shade100,
                        _getTrophyColor(percentage).shade200,
                        _getTrophyColor(percentage).shade300,
                      ],
                      stops: const [0.0, 0.6, 1.0],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _getTrophyColor(percentage).withOpacity(0.5),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                      BoxShadow(
                        color: _getTrophyColor(percentage).withOpacity(0.3),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Icon(
                    _getTrophyIcon(percentage),
                    size: 70,
                    color: _getTrophyColor(percentage).shade700,
                  ),
                )
                    .animate()
                    .scale(
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.elasticOut,
                    )
                    .then()
                    .shake(
                      duration: const Duration(milliseconds: 500),
                      hz: 3,
                    ),

                // Sparkle particles around trophy
                ...List.generate(8, (index) {
                  final angle = (index * 45) * (math.pi / 180);
                  final radius = 80.0;
                  final x = math.cos(angle) * radius;
                  final y = math.sin(angle) * radius;

                  return Positioned(
                    left: 80 + x,
                    top: 80 + y,
                    child: Icon(
                      Icons.star,
                      size: 16,
                      color: _getTrophyColor(percentage).shade300,
                    )
                        .animate(
                            onPlay: (controller) =>
                                controller.repeat(reverse: true))
                        .fadeIn(
                          duration: const Duration(milliseconds: 800),
                          delay: Duration(milliseconds: index * 200),
                        )
                        .then()
                        .fadeOut(
                          duration: const Duration(milliseconds: 800),
                        ),
                  );
                }),
              ],
            ),

            // const SizedBox(height: 32),

            // Enhanced Game Complete text with gradient
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [
                  Colors.white,
                  _getTrophyColor(percentage).shade200,
                  Colors.white,
                ],
                stops: const [0.0, 0.5, 1.0],
              ).createShader(bounds),
              child: const Text(
                'Game Complete!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
            )
                .animate()
                .fadeIn(
                  duration: const Duration(milliseconds: 600),
                )
                .then()
                .shimmer(
                  duration: const Duration(milliseconds: 1200),
                  color: _getTrophyColor(percentage).shade200,
                ),

            // const SizedBox(height: 16),

            // Score display with enhanced styling
            // Container(
            //   padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            //   decoration: BoxDecoration(
            //     gradient: LinearGradient(
            //       begin: Alignment.topLeft,
            //       end: Alignment.bottomRight,
            //       colors: [
            //         Colors.white.withOpacity(0.15),
            //         Colors.white.withOpacity(0.08),
            //       ],
            //     ),
            //     borderRadius: BorderRadius.circular(20),
            //     border: Border.all(
            //       color: _getTrophyColor(percentage).withOpacity(0.4),
            //       width: 2,
            //     ),
            //     boxShadow: [
            //       BoxShadow(
            //         color: _getTrophyColor(percentage).withOpacity(0.3),
            //         blurRadius: 15,
            //         offset: const Offset(0, 5),
            //       ),
            //     ],
            //   ),
            //   child: Column(
            //     children: [
            //       Text(
            //         "$score/$totalQuestions",
            //         style: TextStyle(
            //           fontSize: 36,
            //           fontWeight: FontWeight.bold,
            //           color: _getTrophyColor(percentage),
            //         ),
            //       ),
            //       const SizedBox(height: 4),
            //       Text(
            //         "$percentage% Correct",
            //         style: TextStyle(
            //           fontSize: 16,
            //           fontWeight: FontWeight.w600,
            //           color: Colors.white.withOpacity(0.9),
            //         ),
            //       ),
            //     ],
            //   ),
            // )
            //     .animate()
            //     .fadeIn(
            //       delay: const Duration(milliseconds: 400),
            //       duration: const Duration(milliseconds: 600),
            //     )
            //     .then()
            //     .slideY(
            //       begin: 0.2,
            //       duration: const Duration(milliseconds: 400),
            //       curve: Curves.easeOutBack,
            //     ),

            const SizedBox(height: 24),

            // Encouraging message
            Text(
              _getEncouragingMessage(percentage),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Colors.white.withOpacity(0.9),
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ).animate().fadeIn(
                  delay: const Duration(milliseconds: 600),
                  duration: const Duration(milliseconds: 600),
                ),

            const SizedBox(height: 50),

            // Enhanced action buttons card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.95),
                    Colors.white.withOpacity(0.9),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 0,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: _getTrophyColor(percentage).withOpacity(0.1),
                    blurRadius: 30,
                    spreadRadius: 5,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header showing game completion
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.check_circle,
                            color: Colors.green.shade600,
                            size: 24,
                          ),
                        ).animate().scale(
                              delay: const Duration(milliseconds: 800),
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.elasticOut,
                            ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '$gameTitle completed',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ).animate().fadeIn(
                                delay: const Duration(milliseconds: 900),
                                duration: const Duration(milliseconds: 400),
                              ),
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 1),

                  // Action buttons
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        // Play Again button
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.limeGreen,
                                  AppColors.limeGreen.withOpacity(0.8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.limeGreen.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: AppColors.navyBlue,
                                elevation: 0,
                                shadowColor: Colors.transparent,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                                ref
                                    .read(gameStateNotifierProvider.notifier)
                                    .restartGame();
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.refresh, size: 20),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Play Again',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ).animate().scale(
                                delay: const Duration(milliseconds: 1000),
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.elasticOut,
                              ),
                        ),

                        const SizedBox(width: 16),

                        // Exit button
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.grey.shade300,
                                  Colors.grey.shade400,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.grey.shade700,
                                elevation: 0,
                                shadowColor: Colors.transparent,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: () {
                                ref.read(gamesRefreshProvider.notifier).state++;
                                context.go('/home');
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.home, size: 20),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Exit',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ).animate().scale(
                                delay: const Duration(milliseconds: 1100),
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.elasticOut,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .slideY(
                  begin: 0.3,
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutBack,
                )
                .fadeIn(),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // Helper methods
  MaterialColor _getTrophyColor(int percentage) {
    if (percentage >= 90) return Colors.amber; // Gold
    if (percentage >= 70) return Colors.grey; // Silver
    if (percentage >= 50) return Colors.orange; // Bronze
    return Colors.blue; // Participation
  }

  IconData _getTrophyIcon(int percentage) {
    if (percentage >= 90) return Icons.emoji_events; // Gold trophy
    if (percentage >= 70) return Icons.military_tech; // Silver medal
    if (percentage >= 50) return Icons.workspace_premium; // Bronze medal
    return Icons.star; // Participation star
  }

  String _getEncouragingMessage(int percentage) {
    if (percentage >= 90) return "You're a true champion! 🏆";
    if (percentage >= 80) return "You're crushing it! 🌟";
    if (percentage >= 70) return "Keep up the momentum! 🚀";
    if (percentage >= 60) return "You're improving! 💪";
    if (percentage >= 50) return "Practice makes perfect! 📚";
    return "Every attempt makes you stronger! 💫";
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
    // Safety checks
    if (size.width <= 0 ||
        size.height <= 0 ||
        animationValue.isNaN ||
        animationValue.isInfinite) {
      return;
    }

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth.clamp(0.1, 10.0)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final waveHeight = (size.height * 0.3).clamp(1.0, size.height * 0.5);
    final waveLength = (size.width / 4).clamp(10.0, size.width);
    final animationOffset =
        (animationValue * waveLength).clamp(-size.width * 2, size.width * 2);

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

      // Ensure all values are finite
      if ([x1, y1, x2, y2, x3, y3].every((val) => val.isFinite)) {
        path.cubicTo(x1, y1, x2, y2, x3, y3);
      }
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
              ...List.generate(12, (index) {
                final offset = index * 0.5;
                final x = 50 +
                    (index * 35) +
                    math.sin(_particlesAnimation.value * 2 * math.pi + offset) *
                        30;
                final y = 100 +
                    (index * 60) +
                    math.cos(_particlesAnimation.value * 2 * math.pi +
                            offset * 1.5) *
                        50;

                // Ensure positions are valid
                if (x.isNaN || y.isNaN || x.isInfinite || y.isInfinite) {
                  return const SizedBox.shrink();
                }

                final opacity = 0.3 +
                    math.sin(_particlesAnimation.value * 4 * math.pi + offset) *
                        0.3;

                // Clamp opacity to valid range
                final clampedOpacity = opacity.clamp(0.0, 1.0);

                return Positioned(
                  left: x.clamp(0.0, MediaQuery.of(context).size.width),
                  top: y.clamp(0.0, MediaQuery.of(context).size.height),
                  child: _buildFloatingParticle(
                    size: 6 + (index % 4) * 3,
                    opacity: clampedOpacity,
                    color: index % 4 == 0
                        ? AppColors.limeGreen
                        : index % 4 == 1
                            ? Colors.white
                            : index % 4 == 2
                                ? Colors.yellow.shade300
                                : const Color(0xFF00FF88),
                  ),
                );
              }),

              // Dynamic wavy patterns
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
    // Ensure valid values
    final clampedSize = size.clamp(1.0, 50.0);
    final clampedOpacity = opacity.clamp(0.0, 1.0);

    return Container(
      width: clampedSize,
      height: clampedSize,
      decoration: BoxDecoration(
        color: color.withOpacity(clampedOpacity),
        shape: BoxShape.circle,
        boxShadow: clampedOpacity > 0.1
            ? [
                BoxShadow(
                  color: color.withOpacity(clampedOpacity * 0.5),
                  blurRadius: (clampedSize * 0.8).clamp(1.0, 20.0),
                  spreadRadius: (clampedSize * 0.2).clamp(0.0, 5.0),
                ),
              ]
            : null,
      ),
    );
  }
}
