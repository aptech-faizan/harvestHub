import 'package:flutter/material.dart';
import '../farmer_theme.dart';

/// Premium container card with 18px border radius, subtle 1px border,
/// and soft layered elevation shadow (blur 16, opacity 0.06).
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final Gradient? gradient;
  final VoidCallback? onTap;
  final Border? border;
  final double borderRadius;
  final List<BoxShadow>? shadows;
  final double? width;
  final double? height;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.color = FarmerColors.surface,
    this.gradient,
    this.onTap,
    this.border,
    this.borderRadius = 18.0,
    this.shadows,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorder = border ?? Border.all(color: FarmerColors.border, width: 1);
    final effectiveShadows = shadows ?? FarmerColors.cardShadow;

    Widget content = Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: gradient == null ? color : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
        border: effectiveBorder,
        boxShadow: effectiveShadows,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Material(
          color: Colors.transparent,
          child: onTap != null
              ? InkWell(
                  onTap: onTap,
                  splashColor: FarmerColors.primary.withValues(alpha: 0.08),
                  highlightColor: FarmerColors.primary.withValues(alpha: 0.04),
                  child: Padding(
                    padding: padding ?? EdgeInsets.zero,
                    child: child,
                  ),
                )
              : Padding(
                  padding: padding ?? EdgeInsets.zero,
                  child: child,
                ),
        ),
      ),
    );

    return content;
  }
}
