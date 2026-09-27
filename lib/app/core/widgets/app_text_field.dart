import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final bool readOnly;
  final bool isOutlined;
  final int maxLines;
  final TextInputType? keyboardType;
  final FocusNode? focusNode;

  const AppTextField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.readOnly = false,
    this.isOutlined = false,
    this.maxLines = 1,
    this.keyboardType,
    this.focusNode,
  });

  const AppTextField.outlined({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.readOnly = false,
    this.maxLines = 1,
    this.keyboardType,
    this.focusNode,
  }) : isOutlined = true;

  @override
  Widget build(BuildContext context) {
    final borderSide = isOutlined
        ? const BorderSide(color: AppColors.divider, width: 1.2)
        : BorderSide.none;

    final border = OutlineInputBorder(
      borderRadius: AppRadius.inputRadius,
      borderSide: borderSide,
    );

    return SizedBox(
      height: maxLines == 1 ? 48.0 : null,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        readOnly: readOnly,
        onTap: onTap,
        maxLines: maxLines,
        keyboardType: keyboardType,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        style: AppTextStyles.bodyText.copyWith(color: AppColors.textPrimary),
        decoration: InputDecoration(
          isDense: true,
          filled: !isOutlined,
          fillColor: isOutlined ? Colors.transparent : AppColors.surfaceMuted,
          hintText: hintText,
          labelText: labelText,
          hintStyle: AppTextStyles.caption.copyWith(color: AppColors.textDisabled),
          labelStyle: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
          prefixIcon: prefixIcon != null
              ? Padding(
                  padding: const EdgeInsets.only(left: 12.0, right: 8.0),
                  child: prefixIcon,
                )
              : null,
          prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 20),
          suffixIcon: suffixIcon,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14.0,
            vertical: 13.0,
          ),
          border: border,
          enabledBorder: border,
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.inputRadius,
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
      ),
    );
  }
}

/// Search bar with attached filter button as specified in Section 6.2
class AppSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterTap;
  final VoidCallback? onTap;
  final bool readOnly;
  final bool isFilterActive;

  const AppSearchBar({
    super.key,
    this.controller,
    this.hintText = 'Search "Vegetables", "Milk"...',
    this.onChanged,
    this.onFilterTap,
    this.onTap,
    this.readOnly = false,
    this.isFilterActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AppTextField(
            controller: controller,
            hintText: hintText,
            readOnly: readOnly,
            onTap: onTap,
            onChanged: onChanged,
            prefixIcon: const Icon(
              Icons.search,
              size: 20,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        if (onFilterTap != null) ...[
          const SizedBox(width: AppSpacing.s),
          Material(
            color: isFilterActive ? AppColors.chipHerbsBg : AppColors.surfaceMuted,
            borderRadius: AppRadius.inputRadius,
            child: InkWell(
              borderRadius: AppRadius.inputRadius,
              onTap: onFilterTap,
              child: SizedBox(
                width: 48,
                height: 48,
                child: Center(
                  child: Icon(
                    Icons.tune,
                    size: 20,
                    color: isFilterActive ? AppColors.primaryDark : AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
