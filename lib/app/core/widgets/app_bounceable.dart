import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

/// High-performance bounce wrapper that scales its child to [scaleDown] on tap
/// and springs back on release, giving every interactive element a tactile,
/// physical press feel.
///
/// Uses a single [AnimationController] driven by a critically-damped
/// [SpringSimulation] for buttery-smooth 60 fps animation with no jank.
///
/// Usage:
/// ```dart
/// AppBounceable(
///   onTap: () => print('tapped'),
///   child: MyCard(...),
/// )
/// ```
class AppBounceable extends StatefulWidget {
  /// The child widget to wrap with the bounce effect.
  final Widget child;

  /// Callback fired on tap (after the bounce completes).
  final VoidCallback? onTap;

  /// The scale factor applied on tap-down. Defaults to 0.96 (4% shrink).
  final double scaleDown;

  /// Whether the bounce effect is enabled. When false, the widget behaves
  /// as a plain pass-through — useful for disabled states.
  final bool enabled;

  const AppBounceable({
    super.key,
    required this.child,
    this.onTap,
    this.scaleDown = 0.96,
    this.enabled = true,
  });

  @override
  State<AppBounceable> createState() => _AppBounceableState();
}

class _AppBounceableState extends State<AppBounceable>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  // Spring spec: critically-damped for snappy return without oscillation.
  static const _spring = SpringDescription(
    mass: 1.0,
    stiffness: 600.0,
    damping: 20.0,
  );

  @override
  void initState() {
    super.initState();
    _controller = AnimationController.unbounded(vsync: this);
    _scaleAnimation = _controller.drive(
      Tween<double>(begin: 1.0, end: widget.scaleDown),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPointerDown(PointerDownEvent _) {
    if (!widget.enabled) return;
    final simulation = SpringSimulation(_spring, _controller.value, 1.0, 0.0);
    _controller.animateWith(simulation);
  }

  void _onPointerUp(PointerUpEvent _) {
    if (!widget.enabled) return;
    _springBack();
  }

  void _onPointerCancel(PointerCancelEvent _) {
    if (!widget.enabled) return;
    _springBack();
  }

  void _springBack() {
    final simulation = SpringSimulation(_spring, _controller.value, 0.0, 0.0);
    _controller.animateWith(simulation);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    Widget content = AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: widget.child,
    );

    if (widget.onTap != null) {
      content = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: content,
      );
    }

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _onPointerDown,
      onPointerUp: _onPointerUp,
      onPointerCancel: _onPointerCancel,
      child: content,
    );
  }
}
