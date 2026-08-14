import 'package:flutter/material.dart';
import 'glass_surface.dart';

/// Matte transparent Liquid Glass container.
/// Pure opacity & translucent blur surface with luminous stroke.
class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blur;
  final double fillOpacity;
  final double borderOpacity;
  final Color? glowColor;
  final Color? tintColor;
  final bool isLight;
  final VoidCallback? onTap;

  const GlassContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.margin,
    this.borderRadius = 24,
    this.blur = 10,
    this.fillOpacity = 0.05,
    this.borderOpacity = 0.1,
    this.glowColor,
    this.tintColor,
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
      fillOpacity: fillOpacity,
      borderOpacity: borderOpacity,
      tintColor: tintColor,
      glowColor: glowColor,
      isLight: isLight,
      onTap: onTap,
      child: child,
    );
  }
}
