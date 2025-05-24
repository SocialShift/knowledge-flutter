import 'package:flutter/material.dart';
import 'package:knowledge/core/themes/app_theme.dart';
import 'dart:math' as math;

class ButterflyLoadingWidget extends StatefulWidget {
  final String? text;
  final double size;
  final bool showDots;
  final bool showBackground;

  const ButterflyLoadingWidget({
    super.key,
    this.text,
    this.size = 120,
    this.showDots = true,
    this.showBackground = true,
  });

  @override
  State<ButterflyLoadingWidget> createState() => _ButterflyLoadingWidgetState();
}

class _ButterflyLoadingWidgetState extends State<ButterflyLoadingWidget>
    with TickerProviderStateMixin {
  late AnimationController _butterflyController;
  late AnimationController _backgroundController;
  late AnimationController _rotationController;

  late Animation<double> _backgroundPulse;
  late Animation<double> _rotation;

  @override
  void initState() {
    super.initState();

    _butterflyController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 8000),
      vsync: this,
    );

    _backgroundPulse = Tween<double>(
      begin: 0.9,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeInOut,
    ));

    _rotation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    // Start continuous animations
    _butterflyController.repeat();
    if (widget.showBackground) {
      _backgroundController.repeat(reverse: true);
      _rotationController.repeat();
    }
  }

  @override
  void dispose() {
    _butterflyController.dispose();
    _backgroundController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Main butterfly animation with optional background effects
        SizedBox(
          height: widget.size * (widget.showBackground ? 1.8 : 1.2),
          width: widget.size * (widget.showBackground ? 1.8 : 1.2),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Conditional background effects
              if (widget.showBackground) ...[
                // Outer glow ring
                AnimatedBuilder(
                  animation: _rotation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _rotation.value,
                      child: Container(
                        width: widget.size * 1.6,
                        height: widget.size * 1.6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: SweepGradient(
                            colors: [
                              AppColors.limeGreen.withOpacity(0.1),
                              Colors.transparent,
                              AppColors.navyBlue.withOpacity(0.1),
                              Colors.transparent,
                              AppColors.limeGreen.withOpacity(0.1),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // Background glow effect
                AnimatedBuilder(
                  animation: _backgroundPulse,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _backgroundPulse.value,
                      child: Container(
                        width: widget.size * 1.4,
                        height: widget.size * 1.4,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.limeGreen.withOpacity(0.2),
                              AppColors.navyBlue.withOpacity(0.1),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // Inner shimmer effect
                AnimatedBuilder(
                  animation: _backgroundController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 0.8 + (_backgroundPulse.value - 0.9) * 0.5,
                      child: Container(
                        width: widget.size * 0.8,
                        height: widget.size * 0.8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.white.withOpacity(0.1),
                              AppColors.limeGreen.withOpacity(0.05),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],

              // Enhanced butterfly animation with floating effect
              AnimatedBuilder(
                animation: _butterflyController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      math.sin(_butterflyController.value * 2 * math.pi) *
                          (widget.showBackground ? 20 : 8),
                      math.cos(_butterflyController.value * 3 * math.pi) *
                          (widget.showBackground ? 12 : 5),
                    ),
                    child: Transform.rotate(
                      angle:
                          math.sin(_butterflyController.value * 8 * math.pi) *
                              0.08,
                      child: _EnhancedButterflyWidget(
                        size: widget.size,
                        animationValue: _butterflyController.value,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        if (widget.text != null) ...[
          const SizedBox(height: 24),
          Text(
            widget.text!,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: isDark
                      ? Colors.white.withOpacity(0.9)
                      : AppColors.navyBlue.withOpacity(0.9),
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
            textAlign: TextAlign.center,
          ),
        ],

        if (widget.showDots) ...[
          const SizedBox(height: 20),
          _AnimatedDots(
            color: isDark ? AppColors.limeGreen : AppColors.navyBlue,
          ),
        ],
      ],
    );
  }
}

class _EnhancedButterflyWidget extends StatelessWidget {
  final double size;
  final double animationValue;

  const _EnhancedButterflyWidget({
    required this.size,
    required this.animationValue,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _EnhancedButterflyPainter(
          animationValue: animationValue,
        ),
      ),
    );
  }
}

class _EnhancedButterflyPainter extends CustomPainter {
  final double animationValue;

  _EnhancedButterflyPainter({
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

    // Draw wing shadows first
    _drawWingShadows(canvas, size, primaryWingFlap, secondaryWingFlap);

    // Draw wings
    _drawEnhancedWing(canvas, size, true, primaryWingFlap, secondaryWingFlap);
    _drawEnhancedWing(canvas, size, false, primaryWingFlap, secondaryWingFlap);

    // Draw enhanced body
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

  void _drawEnhancedWing(Canvas canvas, Size size, bool isLeft,
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
      duration: const Duration(milliseconds: 1500),
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
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Transform.scale(
                scale: 0.4 + (scale * 0.6),
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: widget.color.withOpacity(0.2 + (scale * 0.8)),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: widget.color.withOpacity(0.3),
                        blurRadius: 4,
                        spreadRadius: scale * 2,
                      ),
                    ],
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
