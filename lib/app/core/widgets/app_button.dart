import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isSmall;
  final bool isLoading;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;

  const AppButton.primary({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.width = double.infinity,
  }) : isSmall = false;

  const AppButton.small({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.width,
  }) : isSmall = true;

  @override
  Widget build(BuildContext context) {
    final effectiveHeight = isSmall ? 38.0 : 52.0;
    final effectiveRadius =
        isSmall ? AppRadius.buttonSmallRadius : AppRadius.buttonPrimaryRadius;
    final effectiveBg = backgroundColor ?? AppColors.primaryButton;
    final effectiveTextColor = textColor ?? Colors.white;

    Widget content;
    if (isLoading) {
      content = SizedBox(
        width: isSmall ? 18 : 22,
        height: isSmall ? 18 : 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.2,
          valueColor: AlwaysStoppedAnimation<Color>(effectiveTextColor),
        ),
      );
    } else {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: isSmall ? 16 : 18, color: effectiveTextColor),
            const SizedBox(width: AppSpacing.s),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: isSmall
                  ? AppTextStyles.buttonText.copyWith(
                      fontSize: 13.5,
                      color: effectiveTextColor,
                    )
                  : AppTextStyles.buttonText.copyWith(
                      fontSize: 15.0,
                      color: effectiveTextColor,
                    ),
            ),
          ),
        ],
      );
    }

    return SizedBox(
      height: effectiveHeight,
      width: width,
      child: Material(
        color: onPressed == null ? AppColors.textDisabled : effectiveBg,
        borderRadius: effectiveRadius,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: effectiveRadius,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isSmall ? AppSpacing.m : AppSpacing.l,
            ),
            child: Center(child: content),
          ),
        ),
      ),
    );
  }
}

class AppTextButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final Color? color;

  const AppTextButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.leadingIcon,
    this.trailingIcon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.primaryDark;

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (leadingIcon != null) ...[
              Icon(leadingIcon, size: 16, color: effectiveColor),
              const SizedBox(width: 4),
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.linkText.copyWith(color: effectiveColor),
              ),
            ),
            if (trailingIcon != null) ...[
              const SizedBox(width: 4),
              Icon(trailingIcon, size: 16, color: effectiveColor),
            ],
          ],
        ),
      ),
    );
  }
}

/// Pill-shaped quantity stepper matching Section 6.7
class AppStepper extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;

  const AppStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 999,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.primaryButton,
        borderRadius: AppRadius.chipRadius, // pill
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Minus button
          InkWell(
            onTap: value > min ? () => onChanged(value - 1) : null,
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(999)),
            child: Container(
              width: 32,
              height: 36,
              alignment: Alignment.center,
              child: const Icon(
                Icons.remove,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
          // Value text
          Container(
            constraints: const BoxConstraints(minWidth: 28),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              '$value',
              style: AppTextStyles.buttonText.copyWith(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
          // Plus button
          InkWell(
            onTap: value < max ? () => onChanged(value + 1) : null,
            borderRadius: const BorderRadius.horizontal(right: Radius.circular(999)),
            child: Container(
              width: 32,
              height: 36,
              alignment: Alignment.center,
              child: const Icon(
                Icons.add,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
