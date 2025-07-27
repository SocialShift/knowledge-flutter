import 'package:flutter/material.dart';
import 'package:knowledge/core/themes/app_colors.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ProBadgeWidget extends StatelessWidget {
  final double size;
  final bool showGlow;
  final EdgeInsets? margin;

  const ProBadgeWidget({
    super.key,
    this.size = 60,
    this.showGlow = true,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.only(top: 8),
      child: Container(
        width: size,
        height: size * 0.4, // Height proportional to width
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.amber[400]!,
              Colors.amber[600]!,
              Colors.orange[700]!,
            ],
            stops: const [0.0, 0.6, 1.0],
          ),
          borderRadius: BorderRadius.circular(size * 0.15),
          border: Border.all(
            color: Colors.white,
            width: 2,
          ),
          boxShadow: showGlow
              ? [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.4),
                    blurRadius: 8,
                    spreadRadius: 2,
                    offset: const Offset(0, 2),
                  ),
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.2),
                    blurRadius: 12,
                    spreadRadius: 4,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Stack(
          children: [
            // Background shine effect
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(size * 0.15),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.center,
                    colors: [
                      Colors.white.withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Main content
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.diamond,
                    color: Colors.white,
                    size: size * 0.2,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        offset: const Offset(0, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                  const SizedBox(width: 2),
                  Text(
                    'PRO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: size * 0.18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.3),
                          offset: const Offset(0, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Subtle animated shine
            if (showGlow)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(size * 0.15),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.0),
                        Colors.white.withOpacity(0.1),
                        Colors.white.withOpacity(0.0),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ).animate(onPlay: (controller) => controller.repeat()).shimmer(
                      duration: const Duration(seconds: 2),
                      curve: Curves.easeInOut,
                    ),
              ),
          ],
        ),
      ).animate().fadeIn().scale(
            delay: const Duration(milliseconds: 200),
            duration: const Duration(milliseconds: 600),
            curve: Curves.elasticOut,
          ),
    );
  }
}
