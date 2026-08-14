import 'package:flutter/material.dart';
import 'glass_surface.dart';

/// Matte transparent Liquid Glass card.
/// Wraps GlassSurface with liquid glass styling and elevation.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blur;
  final double opacity;
  final double borderOpacity;
  final Color? tintColor;
  final Color? glowColor;
  final bool isLight;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.margin,
    this.borderRadius = 24,
    this.blur = 12,
    this.opacity = 0.06,
    this.borderOpacity = 0.12,
    this.tintColor,
    this.glowColor,
    this.isLight = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      padding: padding,
      margin: margin,
      borderRadius: borderRadius,
      blur: blur,
      fillOpacity: opacity,
      borderOpacity: borderOpacity,
      tintColor: tintColor,
      glowColor: glowColor,
      isLight: isLight,
      onTap: onTap,
      child: child,
    );
  }
}
