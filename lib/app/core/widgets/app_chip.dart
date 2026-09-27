import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class AppChip extends StatelessWidget {
  final String label;
  final Widget? icon;
  final IconData? iconData;
  final Color backgroundColor;
  final Color? textColor;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool isCircular;

  const AppChip.pill({
    super.key,
    required this.label,
    this.icon,
    this.iconData,
    this.backgroundColor = AppColors.surfaceMuted,
    this.textColor,
    this.isSelected = false,
    this.onTap,
  }) : isCircular = false;

  const AppChip.circular({
    super.key,
    required this.label,
    this.icon,
    this.iconData,
    this.backgroundColor = AppColors.chipHerbsBg,
    this.textColor,
    this.isSelected = false,
    this.onTap,
  }) : isCircular = true;

  // Helper method to automatically pick soft tint color based on category name
  static Color getCategoryBgColor(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('fruit')) return AppColors.chipFruitsBg;
    if (lower.contains('grain') || lower.contains('wheat') || lower.contains('cereal')) {
      return AppColors.chipGrainsBg;
    }
    if (lower.contains('herb') || lower.contains('veg') || lower.contains('organic')) {
      return AppColors.chipHerbsBg;
    }
    return AppColors.chipFruitsBg;
  }

  // Helper method to get icon per category
  static IconData getCategoryIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('fruit')) return Icons.apple;
    if (lower.contains('grain') || lower.contains('wheat') || lower.contains('cereal')) {
      return Icons.grain;
    }
    if (lower.contains('veg')) return Icons.eco;
    if (lower.contains('herb')) return Icons.local_florist;
    if (lower.contains('dairy') || lower.contains('milk')) return Icons.water_drop_outlined;
    return Icons.spa_outlined;
  }

  @override
  Widget build(BuildContext context) {
    if (isCircular) {
      return GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 58.0,
              height: 58.0,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : backgroundColor,
                shape: BoxShape.circle,
                border: isSelected
                    ? Border.all(color: AppColors.primaryDark, width: 2.0)
                    : null,
                boxShadow: isSelected ? AppRadius.cardElevation : null,
              ),
              child: Center(
                child: icon ??
                    Icon(
                      iconData ?? Icons.eco,
                      size: 28.0,
                      color: isSelected ? Colors.white : AppColors.primaryDark,
                    ),
              ),
            ),
            const SizedBox(height: 6.0),
            SizedBox(
              width: 68.0,
              child: Text(
                label,
                style: AppTextStyles.chipLabel.copyWith(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppColors.primaryDark : AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    // Pill variant
    final effectiveBg = isSelected
        ? AppColors.primaryDark
        : backgroundColor;
    final effectiveText = isSelected
        ? Colors.white
        : (textColor ?? AppColors.textPrimary);

    return Material(
      color: effectiveBg,
      borderRadius: AppRadius.chipRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.chipRadius,
        child: Container(
          height: 32.0,
          padding: const EdgeInsets.symmetric(horizontal: 14.0),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (iconData != null) ...[
                Icon(
                  iconData,
                  size: 16.0,
                  color: effectiveText,
                ),
                const SizedBox(width: AppSpacing.xs),
              ] else if (icon != null) ...[
                icon!,
                const SizedBox(width: AppSpacing.xs),
              ],
              Text(
                label,
                style: AppTextStyles.chipLabel.copyWith(
                  color: effectiveText,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
