import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Immersive Apple Liquid Glass Background with ambient light drift.
/// Features a near-black base (#050505) and multi-layered radial ambient lighting
/// (violet, electric blue, cyan) that shifts extremely slowly behind content.
class GlassBackground extends StatefulWidget {
  final Widget child;
  final bool isLight;

  const GlassBackground({
    super.key,
    required this.child,
    this.isLight = false,
  });

  @override
  State<GlassBackground> createState() => _GlassBackgroundState();
}

class _GlassBackgroundState extends State<GlassBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _driftController;

  @override
  void initState() {
    super.initState();
    _driftController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _driftController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLight) return _buildLightBackground();
    return _buildDarkBackground();
  }

  Widget _buildDarkBackground() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFF050505),
      child: AnimatedBuilder(
        animation: _driftController,
        builder: (context, child) {
          final val = _driftController.value;
          final offsetX1 = math.sin(val * math.pi * 2) * 25.0;
          final offsetY1 = math.cos(val * math.pi * 2) * 20.0;
          final offsetX2 = math.cos(val * math.pi * 2) * 30.0;

          return Stack(
            children: [
              // Top-center Violet Glow Blob
              Positioned(
                top: -140 + offsetY1,
                left: -60 + offsetX1,
                child: Container(
                  width: 380,
                  height: 380,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF7C4DFF).withValues(alpha: 0.07),
                        const Color(0xFF7C4DFF).withValues(alpha: 0.02),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),

              // Right Center Electric Blue Ambient Light Blob
              Positioned(
                top: 220 - offsetY1,
                right: -100 + offsetX2,
                child: Container(
                  width: 320,
                  height: 320,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF448AFF).withValues(alpha: 0.05),
                        const Color(0xFF448AFF).withValues(alpha: 0.01),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.55, 1.0],
                    ),
                  ),
                ),
              ),

              // Bottom Left Cyan Ambient Blob
              Positioned(
                bottom: -100 + offsetY1,
                left: -80 - offsetX1,
                child: Container(
                  width: 340,
                  height: 340,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF00E5FF).withValues(alpha: 0.04),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 1.0],
                    ),
                  ),
                ),
              ),

              // Child Content Layer on top
              widget.child,
            ],
          );
        },
      ),
    );
  }

  Widget _buildLightBackground() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF8F8FF), Color(0xFFF0F0FA), Color(0xFFF5F5FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -80,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF7C4DFF).withValues(alpha: 0.06),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          widget.child,
        ],
      ),
    );
  }
}
