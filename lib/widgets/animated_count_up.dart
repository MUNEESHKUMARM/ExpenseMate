import 'package:flutter/material.dart';
import '../utils/helpers.dart';

/// Smoothly animates a currency value from 0 → [targetValue] over [duration].
/// Displays the formatted ₹ amount at each frame.
class AnimatedCountUp extends StatefulWidget {
  final double targetValue;
  final Duration duration;
  final TextStyle? style;
  final Alignment alignment;

  const AnimatedCountUp({
    super.key,
    required this.targetValue,
    this.duration = const Duration(milliseconds: 1000),
    this.style,
    this.alignment = Alignment.centerLeft,
  });

  @override
  State<AnimatedCountUp> createState() => _AnimatedCountUpState();
}

class _AnimatedCountUpState extends State<AnimatedCountUp>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _previousValue = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _animation = Tween<double>(begin: 0, end: widget.targetValue).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant AnimatedCountUp oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.targetValue != widget.targetValue) {
      _previousValue = oldWidget.targetValue;
      _animation = Tween<double>(
        begin: _previousValue,
        end: widget.targetValue,
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return FittedBox(
          fit: BoxFit.scaleDown,
          alignment: widget.alignment,
          child: Text(
            formatCurrency(_animation.value),
            style: widget.style,
          ),
        );
      },
    );
  }
}
