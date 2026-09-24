import 'package:flutter/material.dart';

/// Staggered fade and slide-up transition for lists, cards, and sections.
/// Smooth 200-300ms easing without jank or external dependencies.
class StaggeredFadeSlide extends StatelessWidget {
  final int index;
  final Widget child;
  final Duration baseDuration;
  final Duration stepDelay;
  final double slideOffset;

  const StaggeredFadeSlide({
    super.key,
    required this.index,
    required this.child,
    this.baseDuration = const Duration(milliseconds: 260),
    this.stepDelay = const Duration(milliseconds: 35),
    this.slideOffset = 14.0,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveDelay = stepDelay * index;
    final totalDuration = baseDuration + effectiveDelay;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: totalDuration,
      curve: Curves.easeOutCubic,
      builder: (context, value, animChild) {
        return Opacity(
          opacity: value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, slideOffset * (1.0 - value)),
            child: animChild,
          ),
        );
      },
      child: child,
    );
  }
}
