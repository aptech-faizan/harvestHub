import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

/// Reusable metric statistic card conforming to Master Rules and Section 6.6.
/// Features metric label + big number + trend indicator pill + icon container.
class AppStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? trend;
  final bool isPositiveTrend;
  final bool showTrendIcon;
  final IconData? icon;
  final Color? iconColor;
  final Color? iconBgColor;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  const AppStatCard({
    super.key,
    required this.title,
    required this.value,
    this.trend,
    this.isPositiveTrend = true,
    this.showTrendIcon = true,
    this.icon,
    this.iconColor,
    this.iconBgColor,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.l),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: AppRadius.cardRadius,
        border: Border.all(color: AppColors.divider, width: 1.0),
        boxShadow: AppRadius.cardElevation,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.cardRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.cardRadius,
          child: Padding(
            padding: padding,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final hasBoundedHeight = constraints.hasBoundedHeight;

                Widget valueWidget = Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 24.0,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                );

                Widget titleWidget = Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13.0,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                );

                if (hasBoundedHeight) {
                  valueWidget = Flexible(child: valueWidget);
                  titleWidget = Flexible(child: titleWidget);
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: hasBoundedHeight
                      ? MainAxisSize.max
                      : MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (icon != null)
                          Container(
                            width: 40.0,
                            height: 40.0,
                            decoration: BoxDecoration(
                              color: iconBgColor ?? AppColors.chipHerbsBg,
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Icon(
                              icon,
                              size: 22.0,
                              color: iconColor ?? AppColors.primaryDark,
                            ),
                          ),
                        if (trend != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 3.0,
                            ),
                            decoration: BoxDecoration(
                              color: isPositiveTrend
                                  ? AppColors.chipHerbsBg
                                  : const Color(0xFFFFEBEE),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (showTrendIcon) ...[
                                  Icon(
                                    isPositiveTrend
                                        ? Icons.trending_up
                                        : Icons.trending_down,
                                    size: 13.0,
                                    color: isPositiveTrend
                                        ? AppColors.primaryDark
                                        : AppColors.accentRed,
                                  ),
                                  const SizedBox(width: 3.0),
                                ],
                                Text(
                                  trend!,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 11.0,
                                    fontWeight: FontWeight.w700,
                                    color: isPositiveTrend
                                        ? AppColors.primaryDark
                                        : AppColors.accentRed,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.m),
                    valueWidget,
                    const SizedBox(height: 2.0),
                    titleWidget,
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
