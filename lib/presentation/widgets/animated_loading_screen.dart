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
  late AnimationController _particlesController;

  late Animation<double> _butterflyFly;
  late Animation<double> _butterflyScale;
  late Animation<double> _butterflyOpacity;
  late Animation<double> _butterflyFadeOut;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _quoteOpacity;
  late Animation<double> _backgroundFloat1;
  late Animation<double> _backgroundFloat2;
  late Animation<double> _particlesAnimation;

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
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _quoteController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 6000),
      vsync: this,
    );

    _particlesController = AnimationController(
      duration: const Duration(milliseconds: 8000),
      vsync: this,
    );

    // Butterfly animations - extended timeline
    _butterflyFly = Tween<double>(
      begin: -200.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _butterflyController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeInOutCubic),
    ));

    _butterflyScale = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _butterflyController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOutCubic),
    ));

    _butterflyOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _butterflyController,
      curve: const Interval(0.0, 0.2, curve: Curves.easeIn),
    ));

    // Butterfly fade out animation
    _butterflyFadeOut = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _butterflyController,
      curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
    ));

    // Smooth logo animations - no elastic bounce
    _logoScale = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOutCubic,
    ));

    _logoOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeIn,
    ));

    // Quote animation
    _quoteOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _quoteController,
      curve: Curves.easeInOut,
    ));

    // Background floating animations
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

    // Particles animation
    _particlesAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _particlesController,
      curve: Curves.linear,
    ));

    // Start animation sequence
    _startAnimationSequence();
  }

  void _startAnimationSequence() async {
    // Start background animations (infinite)
    _backgroundController.repeat();
    _particlesController.repeat();

    // Start butterfly flying in and hovering
    await _butterflyController.forward();

    // Small delay before logo appears
    await Future.delayed(const Duration(milliseconds: 200));

    // Trigger haptic feedback for logo appearance
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      HapticFeedback.lightImpact();
    }

    // Start logo appearance and quote
    _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    _quoteController.forward();
  }

  @override
  void dispose() {
    _butterflyController.dispose();
    _logoController.dispose();
    _quoteController.dispose();
    _backgroundController.dispose();
    _particlesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.navyBlue,
      body: Stack(
        children: [
          // Dynamic animated background - covers entire screen
          Positioned.fill(
            child: _buildAnimatedBackground(isDark),
          ),

          // Main content with SafeArea
          SafeArea(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              child: AnimatedBuilder(
                animation: Listenable.merge([
                  _butterflyController,
                  _logoController,
                  _quoteController,
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
                            // Butterfly animation with fade out
                            AnimatedBuilder(
                              animation: _butterflyFadeOut,
                              builder: (context, child) {
                                return Opacity(
                                  opacity: _butterflyFadeOut.value,
                                  child: Transform.translate(
                                    offset: Offset(
                                      _butterflyFly.value,
                                      math.sin(_butterflyController.value *
                                              4 *
                                              math.pi) *
                                          15,
                                    ),
                                    child: Transform.scale(
                                      scale: _butterflyScale.value,
                                      child: Opacity(
                                        opacity: _butterflyOpacity.value,
                                        child: Transform.rotate(
                                          angle: math.sin(
                                                  _butterflyController.value *
                                                      6 *
                                                      math.pi) *
                                              0.15,
                                          child: _ButterflyWidget(
                                            size: 120,
                                            animationValue:
                                                _butterflyController.value,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),

                            // Smooth logo transition with simple glow effect
                            if (_logoController.value > 0.0)
                              Transform.scale(
                                scale: _logoScale.value,
                                child: Opacity(
                                  opacity: _logoOpacity.value,
                                  child: Container(
                                    width: 140,
                                    height: 140,
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.limeGreen
                                              .withOpacity(0.4),
                                          blurRadius: 40,
                                          spreadRadius: 12,
                                        ),
                                        BoxShadow(
                                          color: AppColors.limeGreen
                                              .withOpacity(0.2),
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
                                    child: Image.asset(
                                      'assets/images/logo/logo.png',
                                      fit: BoxFit.contain,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppColors.limeGreen
                                                    .withOpacity(0.4),
                                                blurRadius: 40,
                                                spreadRadius: 12,
                                              ),
                                            ],
                                          ),
                                          child: const Icon(
                                            Icons.school,
                                            size: 70,
                                            color: Colors.white,
                                          ),
                                        );
                                      },
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
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  fontStyle: FontStyle.italic,
                                  height: 1.4,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.3),
                                      offset: const Offset(0, 1),
                                      blurRadius: 3,
                                    ),
                                  ],
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
                                      Colors.white,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(1),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          AppColors.limeGreen.withOpacity(0.4),
                                      blurRadius: 6,
                                      spreadRadius: 1,
                                    ),
                                  ],
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
                          color: AppColors.limeGreen,
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground(bool isDark) {
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
