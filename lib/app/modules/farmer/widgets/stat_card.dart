import 'package:flutter/material.dart';
import '../farmer_theme.dart';
import 'app_card.dart';

/// KPI stat card with icon in tinted circle, big number with count-up animation,
/// label, and small trend badge. Built to never overflow on any screen size.
class StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final num value;
  final String? prefix;
  final String? suffix;
  final int fractionDigits;
  final Color color;
  final String? trendLabel;
  final bool isTrendPositive;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.prefix,
    this.suffix,
    this.fractionDigits = 0,
    required this.color,
    this.trendLabel,
    this.isTrendPositive = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      borderRadius: 18,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top row: tinted icon circle + trend badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              if (trendLabel != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: (isTrendPositive
                            ? FarmerColors.primary
                            : FarmerColors.muted)
                        .withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isTrendPositive
                            ? Icons.arrow_upward_rounded
                            : Icons.horizontal_rule_rounded,
                        size: 10,
                        color: isTrendPositive
                            ? FarmerColors.primary
                            : FarmerColors.muted,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        trendLabel!,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isTrendPositive
                              ? FarmerColors.primary
                              : FarmerColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Count-up animated number
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: value.toDouble()),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOutCubic,
                  builder: (context, val, _) {
                    final formattedVal = fractionDigits > 0
                        ? val.toStringAsFixed(fractionDigits)
                        : val.round().toString();
                    return Text(
                      '${prefix ?? ''}$formattedVal${suffix ?? ''}',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: FarmerColors.text,
                        letterSpacing: -0.5,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // Label
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: FarmerTextStyles.caption.copyWith(
              color: FarmerColors.muted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
