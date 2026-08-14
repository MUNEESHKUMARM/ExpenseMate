import 'dart:ui';
import 'package:flutter/material.dart';

/// Premium Apple Liquid Glass Surface widget.
/// Offers controlled backdrop blur, translucent fill, thin luminous borders,
/// soft internal highlight reflections, and gentle floating drop shadow.
class GlassSurface extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blur;
  final double fillOpacity;
  final double borderOpacity;
  final Color? tintColor;
  final Color? glowColor;
  final bool isLight;
  final VoidCallback? onTap;

  const GlassSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.margin,
    this.borderRadius = 24,
    this.blur = 12,
    this.fillOpacity = 0.06,
    this.borderOpacity = 0.12,
    this.tintColor,
    this.glowColor,
    this.isLight = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = tintColor ?? (isLight ? Colors.black : Colors.white);
    final effectiveFillOpacity = isLight ? 0.04 : fillOpacity;
    final effectiveBorderOpacity = isLight ? 0.08 : borderOpacity;

    Widget containerWidget = Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          if (glowColor != null)
            BoxShadow(
              color: glowColor!.withValues(alpha: isLight ? 0.08 : 0.15),
              blurRadius: 24,
              spreadRadius: -4,
              offset: const Offset(0, 6),
            ),
          BoxShadow(
            color: Colors.black.withValues(alpha: isLight ? 0.04 : 0.25),
            blurRadius: 20,
            spreadRadius: -6,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: baseColor.withValues(alpha: effectiveFillOpacity),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: (isLight ? Colors.black : Colors.white)
                    .withValues(alpha: effectiveBorderOpacity),
                width: 0.8,
              ),
              gradient: isLight
                  ? null
                  : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: effectiveFillOpacity * 1.5),
                        Colors.white.withValues(alpha: effectiveFillOpacity * 0.4),
                      ],
                    ),
            ),
            child: child,
          ),
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: containerWidget,
      );
    }

    return containerWidget;
  }
}
