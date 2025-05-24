import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:knowledge/core/themes/app_theme.dart';
import 'dart:math' as math;

class AnimatedLoadingScreen extends StatefulWidget {
  const AnimatedLoadingScreen({super.key});

  @override
  State<AnimatedLoadingScreen> createState() => _AnimatedLoadingScreenState();
}

class _AnimatedLoadingScreenState extends State<AnimatedLoadingScreen>
    with TickerProviderStateMixin {
  late AnimationController _butterflyController;
  late AnimationController _logoController;
  late AnimationController _quoteController;
  late AnimationController _backgroundController;

  late Animation<double> _butterflyFly;
  late Animation<double> _butterflyScale;
  late Animation<double> _butterflyOpacity;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _quoteOpacity;
  late Animation<double> _backgroundPulse;

  final List<String> _inspirationalQuotes = [
    "Knowledge is the wing wherewith we fly to heaven.",
    "The beautiful thing about learning is nobody can take it away from you.",
    "Education is the most powerful weapon to change the world.",
    "Live as if you were to die tomorrow. Learn as if you were to live forever.",
    "The mind is not a vessel to be filled, but a fire to be kindled.",
    "Knowledge grows when shared.",
    "In learning you will teach, and in teaching you will learn.",
    "The more that you read, the more things you will know.",
    "Learning never exhausts the mind.",
    "Knowledge is power, but enthusiasm pulls the switch.",
  ];

  late String _currentQuote;

  @override
  void initState() {
    super.initState();

    // Select a random quote
    _currentQuote = _inspirationalQuotes[
        math.Random().nextInt(_inspirationalQuotes.length)];

    // Initialize animation controllers
    _butterflyController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _quoteController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    // Butterfly animations
    _butterflyFly = Tween<double>(
      begin: -200.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _butterflyController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeInOutCubic),
    ));

    _butterflyScale = Tween<double>(
      begin: 0.5,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _butterflyController,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    ));

    _butterflyOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _butterflyController,
      curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
    ));

    // Logo animations
    _logoScale = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _logoOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
    ));

    // Quote animation
    _quoteOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _quoteController,
      curve: Curves.easeInOut,
    ));

    // Background pulse animation
    _backgroundPulse = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeInOut,
    ));

    // Start animation sequence
    _startAnimationSequence();
  }

  void _startAnimationSequence() async {
    // Start background pulse (infinite)
    _backgroundController.repeat(reverse: true);

    // Start butterfly flying in
    await _butterflyController.forward();

    // Small delay before butterfly transforms
    await Future.delayed(const Duration(milliseconds: 300));

    // Trigger haptic feedback for transformation
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      HapticFeedback.lightImpact();
    }

    // Start logo transformation and quote appearance
    _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    _quoteController.forward();
  }

  @override
  void dispose() {
    _butterflyController.dispose();
    _logoController.dispose();
    _quoteController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      AppColors.darkBackground,
                      AppColors.darkSurface,
                      AppColors.darkBackground,
                    ]
                  : [
                      Colors.white,
                      AppColors.offWhite,
                      Colors.white,
                    ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _butterflyController,
              _logoController,
              _quoteController,
              _backgroundController,
            ]),
            builder: (context, child) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Main animation area
                  SizedBox(
                    height: 200,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Background glow effect
                        AnimatedBuilder(
                          animation: _backgroundPulse,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _backgroundPulse.value,
                              child: Container(
                                width: 180,
                                height: 180,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      AppColors.limeGreen.withOpacity(0.1),
                                      AppColors.navyBlue.withOpacity(0.05),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        // Butterfly animation
                        if (_butterflyController.value < 0.8)
                          Transform.translate(
                            offset: Offset(
                              _butterflyFly.value,
                              math.sin(_butterflyController.value *
                                      4 *
                                      math.pi) *
                                  20,
                            ),
                            child: Transform.scale(
                              scale: _butterflyScale.value,
                              child: Opacity(
                                opacity: _butterflyOpacity.value,
                                child: Transform.rotate(
                                  angle: math.sin(_butterflyController.value *
                                          8 *
                                          math.pi) *
                                      0.2,
                                  child: _ButterflyWidget(
                                    size: 120,
                                    animationValue: _butterflyController.value,
                                  ),
                                ),
                              ),
                            ),
                          ),

                        // Logo transformation
                        if (_logoController.value > 0.0)
                          Transform.scale(
                            scale: _logoScale.value,
                            child: Opacity(
                              opacity: _logoOpacity.value,
                              child: Container(
                                width: 150,
                                height: 150,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          AppColors.limeGreen.withOpacity(0.3),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.asset(
                                    'assets/images/logo/logo.png',
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          color: AppColors.navyBlue
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: const Icon(
                                          Icons.school,
                                          size: 80,
                                          color: AppColors.navyBlue,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 60),

                  // Animated quote
                  Opacity(
                    opacity: _quoteOpacity.value,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Column(
                        children: [
                          Text(
                            '"$_currentQuote"',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: isDark
                                      ? Colors.white.withOpacity(0.9)
                                      : AppColors.navyBlue.withOpacity(0.8),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  fontStyle: FontStyle.italic,
                                  height: 1.4,
                                ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: 60,
                            height: 2,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.limeGreen,
                                  AppColors.navyBlue,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Animated dots loading indicator
                  if (_quoteController.value > 0.5)
                    _AnimatedDots(
                      color: isDark ? AppColors.limeGreen : AppColors.navyBlue,
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ButterflyWidget extends StatelessWidget {
  final double size;
  final double animationValue;

  const _ButterflyWidget({
    required this.size,
    required this.animationValue,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ButterflyPainter(
          animationValue: animationValue,
        ),
      ),
    );
  }
}

class _ButterflyPainter extends CustomPainter {
  final double animationValue;

  _ButterflyPainter({
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Enhanced wing flapping with more natural movement
    final primaryWingFlap = math.sin(animationValue * 30 * math.pi) * 0.2 + 0.8;
    final secondaryWingFlap =
        math.sin(animationValue * 25 * math.pi + math.pi / 3) * 0.15 + 0.85;

    canvas.save();
    canvas.translate(center.dx, center.dy);

    // Draw wing shadows first for depth
    _drawWingShadows(canvas, size, primaryWingFlap, secondaryWingFlap);

    // Draw wings
    _drawCompleteWing(
        canvas, size, true, primaryWingFlap, secondaryWingFlap); // Left wing
    _drawCompleteWing(
        canvas, size, false, primaryWingFlap, secondaryWingFlap); // Right wing

    // Draw enhanced butterfly body
    _drawEnhancedBody(canvas, size);

    // Draw enhanced antennae
    _drawEnhancedAntennae(canvas, size);

    canvas.restore();
  }

  void _drawWingShadows(
      Canvas canvas, Size size, double primaryFlap, double secondaryFlap) {
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.save();
    canvas.translate(4, 4); // Shadow offset

    // Primary wing shadows
    canvas.save();
    canvas.scale(-1, primaryFlap);
    final leftPrimaryPath = _createPrimaryWingPath(size);
    canvas.drawPath(leftPrimaryPath, shadowPaint);
    canvas.restore();

    canvas.save();
    canvas.scale(1, primaryFlap);
    final rightPrimaryPath = _createPrimaryWingPath(size);
    canvas.drawPath(rightPrimaryPath, shadowPaint);
    canvas.restore();

    canvas.restore();
  }

  void _drawCompleteWing(Canvas canvas, Size size, bool isLeft,
      double primaryFlap, double secondaryFlap) {
    canvas.save();
    if (isLeft) canvas.scale(-1, 1);

    // Primary wing (upper)
    _drawPrimaryWing(canvas, size, primaryFlap);

    // Secondary wing (lower)
    _drawSecondaryWing(canvas, size, secondaryFlap);

    // Wing details and patterns
    _drawWingDetails(canvas, size, primaryFlap, secondaryFlap);

    canvas.restore();
  }

  void _drawPrimaryWing(Canvas canvas, Size size, double flap) {
    canvas.save();
    canvas.scale(1, flap);

    // Create stunning gradient for primary wing with theme colors
    final primaryGradient = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.2),
        radius: 1.5,
        colors: [
          const Color(0xFF00FF88).withOpacity(0.95), // Bright lime green
          AppColors.limeGreen.withOpacity(0.85),
          const Color(0xFF1E3A8A).withOpacity(0.75), // Deep blue
          AppColors.navyBlue.withOpacity(0.9),
          const Color(0xFF312E81).withOpacity(0.85), // Purple-blue
        ],
        stops: const [0.0, 0.3, 0.6, 0.8, 1.0],
      ).createShader(Rect.fromLTWH(-size.width * 0.5, -size.height * 0.5,
          size.width, size.height * 0.6));

    final primaryPath = _createPrimaryWingPath(size);
    canvas.drawPath(primaryPath, primaryGradient);

    // Wing border with shimmer effect
    final borderPaint = Paint()
      ..color = const Color(0xFF00FF88).withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(primaryPath, borderPaint);

    canvas.restore();
  }

  void _drawSecondaryWing(Canvas canvas, Size size, double flap) {
    canvas.save();
    canvas.scale(1, flap);

    // Create gradient for secondary wing with theme colors
    final secondaryGradient = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.2, 0.3),
        radius: 1.0,
        colors: [
          AppColors.limeGreen.withOpacity(0.85),
          const Color(0xFF22C55E).withOpacity(0.75), // Green
          AppColors.navyBlue.withOpacity(0.65),
          const Color(0xFF1E40AF).withOpacity(0.8), // Blue
        ],
        stops: const [0.0, 0.4, 0.7, 1.0],
      ).createShader(Rect.fromLTWH(
          -size.width * 0.4, 0, size.width * 0.8, size.height * 0.5));

    final secondaryPath = _createSecondaryWingPath(size);
    canvas.drawPath(secondaryPath, secondaryGradient);

    // Wing border
    final borderPaint = Paint()
      ..color = AppColors.limeGreen.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawPath(secondaryPath, borderPaint);

    canvas.restore();
  }

  void _drawWingDetails(
      Canvas canvas, Size size, double primaryFlap, double secondaryFlap) {
    // Wing patterns and spots
    final patternPaint = Paint()..color = Colors.white.withOpacity(0.4);
    final accentPaint = Paint()
      ..color = const Color(0xFF00FF88).withOpacity(0.7);

    // Primary wing patterns
    canvas.save();
    canvas.scale(1, primaryFlap);

    // Wing spots
    canvas.drawCircle(
        Offset(size.width * 0.2, -size.height * 0.2), 4, patternPaint);
    canvas.drawCircle(
        Offset(size.width * 0.3, -size.height * 0.1), 3, accentPaint);
    canvas.drawCircle(
        Offset(size.width * 0.25, -size.height * 0.25), 2, patternPaint);

    // Wing veins
    final veinPaint = Paint()
      ..color = Colors.white.withOpacity(0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final veinPath = Path()
      ..moveTo(size.width * 0.05, -size.height * 0.05)
      ..quadraticBezierTo(size.width * 0.2, -size.height * 0.25,
          size.width * 0.35, -size.height * 0.15)
      ..moveTo(size.width * 0.1, -size.height * 0.1)
      ..quadraticBezierTo(size.width * 0.25, -size.height * 0.3,
          size.width * 0.4, -size.height * 0.2);
    canvas.drawPath(veinPath, veinPaint);

    canvas.restore();

    // Secondary wing patterns
    canvas.save();
    canvas.scale(1, secondaryFlap);

    canvas.drawCircle(
        Offset(size.width * 0.15, size.height * 0.15), 2.5, accentPaint);
    canvas.drawCircle(
        Offset(size.width * 0.1, size.height * 0.1), 1.5, patternPaint);

    canvas.restore();
  }

  Path _createPrimaryWingPath(Size size) {
    final path = Path();

    // More elaborate primary wing shape
    path.moveTo(0, -size.height * 0.03);
    path.cubicTo(
      size.width * 0.15,
      -size.height * 0.35,
      size.width * 0.35,
      -size.height * 0.45,
      size.width * 0.45,
      -size.height * 0.35,
    );
    path.cubicTo(
      size.width * 0.5,
      -size.height * 0.25,
      size.width * 0.45,
      -size.height * 0.1,
      size.width * 0.35,
      -size.height * 0.05,
    );
    path.cubicTo(
      size.width * 0.25,
      -size.height * 0.02,
      size.width * 0.15,
      0,
      0,
      -size.height * 0.03,
    );
    path.close();

    return path;
  }

  Path _createSecondaryWingPath(Size size) {
    final path = Path();

    // Enhanced secondary wing shape
    path.moveTo(0, size.height * 0.03);
    path.cubicTo(
      size.width * 0.12,
      size.height * 0.2,
      size.width * 0.28,
      size.height * 0.35,
      size.width * 0.35,
      size.height * 0.3,
    );
    path.cubicTo(
      size.width * 0.38,
      size.height * 0.25,
      size.width * 0.35,
      size.height * 0.15,
      size.width * 0.25,
      size.height * 0.08,
    );
    path.cubicTo(
      size.width * 0.15,
      size.height * 0.04,
      size.width * 0.08,
      size.height * 0.02,
      0,
      size.height * 0.03,
    );
    path.close();

    return path;
  }

  void _drawEnhancedBody(Canvas canvas, Size size) {
    // Enhanced body with thicker, more rounded design and theme colors
    final bodyGradient = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF1E3A8A), // Deep blue from theme
          AppColors.navyBlue,
          const Color(0xFF312E81), // Purple-blue
          AppColors.navyBlue.withOpacity(0.9),
        ],
        stops: const [0.0, 0.3, 0.7, 1.0],
      ).createShader(
          Rect.fromLTWH(-6, -size.height * 0.45, 12, size.height * 0.9));

    // Main body - thicker and more rounded
    final bodyPath = Path();
    bodyPath.addRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset.zero,
        width: 8, // Increased from 5 to 8 for thickness
        height: size.height * 0.8,
      ),
      const Radius.circular(4), // Increased from 2.5 to 4 for roundness
    ));

    canvas.drawPath(bodyPath, bodyGradient);

    // Body segments with glow using theme colors
    final segmentPaint = Paint()
      ..color = AppColors.limeGreen.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);

    for (int i = -3; i <= 3; i++) {
      canvas.drawLine(
        Offset(-4, size.height * 0.08 * i),
        Offset(4, size.height * 0.08 * i),
        segmentPaint,
      );
    }

    // Body highlight with theme colors
    final highlightPaint = Paint()
      ..color = AppColors.limeGreen.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawLine(
      Offset(0, -size.height * 0.4),
      Offset(0, size.height * 0.4),
      highlightPaint,
    );
  }

  void _drawEnhancedAntennae(Canvas canvas, Size size) {
    final antennaPaint = Paint()
      ..color = AppColors.navyBlue.withOpacity(0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5 // Increased thickness
      ..strokeCap = StrokeCap.round;

    // Enhanced antennae with curves
    final leftAntennaPath = Path()
      ..moveTo(-1.5, -size.height * 0.4)
      ..quadraticBezierTo(-size.width * 0.08, -size.height * 0.55,
          -size.width * 0.12, -size.height * 0.58);
    canvas.drawPath(leftAntennaPath, antennaPaint);

    final rightAntennaPath = Path()
      ..moveTo(1.5, -size.height * 0.4)
      ..quadraticBezierTo(size.width * 0.08, -size.height * 0.55,
          size.width * 0.12, -size.height * 0.58);
    canvas.drawPath(rightAntennaPath, antennaPaint);

    // Enhanced antenna tips with glow using theme colors
    final tipPaint = Paint()
      ..color = AppColors.limeGreen
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    canvas.drawCircle(
        Offset(-size.width * 0.12, -size.height * 0.58), 2.5, tipPaint);
    canvas.drawCircle(
        Offset(size.width * 0.12, -size.height * 0.58), 2.5, tipPaint);

    // Tip cores with bright theme color
    final tipCorePaint = Paint()..color = const Color(0xFF00FF88);
    canvas.drawCircle(
        Offset(-size.width * 0.12, -size.height * 0.58), 1.5, tipCorePaint);
    canvas.drawCircle(
        Offset(size.width * 0.12, -size.height * 0.58), 1.5, tipCorePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _AnimatedDots extends StatefulWidget {
  final Color color;

  const _AnimatedDots({required this.color});

  @override
  State<_AnimatedDots> createState() => _AnimatedDotsState();
}

class _AnimatedDotsState extends State<_AnimatedDots>
    with TickerProviderStateMixin {
  late AnimationController _dotsController;

  @override
  void initState() {
    super.initState();
    _dotsController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _dotsController.repeat();
  }

  @override
  void dispose() {
    _dotsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _dotsController,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final delay = index * 0.2;
            final animValue = (_dotsController.value - delay).clamp(0.0, 1.0);
            final scale = math.sin(animValue * math.pi);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Transform.scale(
                scale: 0.5 + (scale * 0.5),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: widget.color.withOpacity(0.3 + (scale * 0.7)),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
