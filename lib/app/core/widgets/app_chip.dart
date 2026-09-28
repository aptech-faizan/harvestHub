import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
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

  /// Consistent status chip variant with predefined palettes
  factory AppChip.status({
    Key? key,
    required String status,
    VoidCallback? onTap,
  }) {
    final colors = getStatusColors(status);
    final label = OrderStatus.label(status);
    return AppChip.pill(
      key: key,
      label: label,
      backgroundColor: colors.bg,
      textColor: colors.text,
      onTap: onTap,
    );
  }

  // Predefined consistent order status color palettes
  static ({Color bg, Color text}) getStatusColors(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return (bg: Color(0xFFFFF3E0), text: Color(0xFFE65100)); // soft amber / orange
      case 'confirmed':
        return (bg: Color(0xFFE3F2FD), text: Color(0xFF1565C0)); // soft blue
      case 'ready_for_pickup':
      case 'ready':
        return (bg: Color(0xFFE0F2F1), text: Color(0xFF00695C)); // soft teal
      case 'completed':
        return (bg: AppColors.chipHerbsBg, text: AppColors.primaryDark); // soft green
      case 'cancelled':
        return (bg: Color(0xFFFFEBEE), text: AppColors.accentRed); // soft red
      default:
        return (bg: AppColors.surfaceMuted, text: AppColors.textSecondary);
    }
  }

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
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
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
