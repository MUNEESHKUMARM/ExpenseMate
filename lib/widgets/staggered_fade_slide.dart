import 'package:flutter/material.dart';

/// Wraps a child widget with a staggered fade + slide-up entrance animation.
///
/// [index] determines the stagger delay (each index adds [staggerDelay]).
/// Use inside a `Column` or `SliverList` for a sequential reveal effect.
class StaggeredFadeSlide extends StatelessWidget {
  final Widget child;
  final int index;
  final Duration staggerDelay;
  final Duration duration;
  final Offset slideOffset;

  const StaggeredFadeSlide({
    super.key,
    required this.child,
    this.index = 0,
    this.staggerDelay = const Duration(milliseconds: 80),
    this.duration = const Duration(milliseconds: 500),
    this.slideOffset = const Offset(0, 0.15),
  });

  @override
  Widget build(BuildContext context) {
    final delay = staggerDelay * index;
    return _DelayedFadeSlide(
      delay: delay,
      duration: duration,
      slideOffset: slideOffset,
      child: child,
    );
  }
}

class _DelayedFadeSlide extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset slideOffset;

  const _DelayedFadeSlide({
    required this.child,
    required this.delay,
    required this.duration,
    required this.slideOffset,
  });

  @override
  State<_DelayedFadeSlide> createState() => _DelayedFadeSlideState();
}

class _DelayedFadeSlideState extends State<_DelayedFadeSlide>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _slideAnimation = Tween<Offset>(
      begin: widget.slideOffset,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}
