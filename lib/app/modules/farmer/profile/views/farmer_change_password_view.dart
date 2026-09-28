import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/theme/app_colors.dart';
import 'package:harvest_hub/app/core/theme/app_radius.dart';
import 'package:harvest_hub/app/core/theme/app_spacing.dart';
import 'package:harvest_hub/app/core/theme/app_text_styles.dart';
import 'package:harvest_hub/app/core/widgets/app_widgets.dart';
import '../controllers/farmer_profile_controller.dart';

/// Change Password screen for Farmers conforming to UI Master Rules.
/// Reuses existing changePassword() logic from FarmerProfileController untouched.
class FarmerChangePasswordView extends GetView<FarmerProfileController> {
  const FarmerChangePasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceMuted,
      appBar: AppAppBar(
        titleText: 'Change Password',
        leading: Center(
          child: AppIconButton(
            icon: Icons.arrow_back_rounded,
            iconSize: 20,
            backgroundColor: AppColors.surfaceMuted,
            iconColor: AppColors.primaryDark,
            isCircle: true,
            tooltip: 'Back',
            onTap: () => Get.back(),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontalPadding,
            vertical: AppSpacing.l),
        child: AppCard.list(
          title: 'Security Credentials',
          children: [
            // Current Password
            _InfoField(
              icon: Icons.lock_outline,
              label: 'Current Password',
              child: Obx(() => TextField(
                    controller: controller.currentPassC,
                    obscureText: controller.hideCurrent.value,
                    style: AppTextStyles.bodyText.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      filled: true,
                      fillColor: AppColors.surfaceMuted,
                      hintText: 'Enter current password',
                      hintStyle: AppTextStyles.caption.copyWith(
                        color: AppColors.textDisabled,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14.0,
                        vertical: 13.0,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: AppRadius.inputRadius,
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: AppRadius.inputRadius,
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: AppRadius.inputRadius,
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 1.5,
                        ),
                      ),
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(left: 12.0, right: 8.0),
                        child: Icon(
                          Icons.lock_outline,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      prefixIconConstraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 20,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.hideCurrent.value
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: controller.hideCurrent.toggle,
                      ),
                    ),
                  )),
            ),
            const SizedBox(height: AppSpacing.m),
            const Divider(color: AppColors.divider, height: 1),
            const SizedBox(height: AppSpacing.m),

            // New Password
            _InfoField(
              icon: Icons.lock_reset_outlined,
              label: 'New Password',
              child: Obx(() => TextField(
                    controller: controller.newPassC,
                    obscureText: controller.hideNew.value,
                    style: AppTextStyles.bodyText.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      filled: true,
                      fillColor: AppColors.surfaceMuted,
                      hintText: 'Enter new password (min. 6 chars)',
                      hintStyle: AppTextStyles.caption.copyWith(
                        color: AppColors.textDisabled,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14.0,
                        vertical: 13.0,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: AppRadius.inputRadius,
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: AppRadius.inputRadius,
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: AppRadius.inputRadius,
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 1.5,
                        ),
                      ),
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(left: 12.0, right: 8.0),
                        child: Icon(
                          Icons.lock_reset_outlined,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      prefixIconConstraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 20,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.hideNew.value
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: controller.hideNew.toggle,
                      ),
                    ),
                  )),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Update Password Button
            Obx(() => AppButton.primary(
                  label: controller.isSaving.value ? 'Updating...' : 'Update Password',
                  icon: Icons.lock_reset_rounded,
                  backgroundColor: AppColors.primaryDark,
                  isLoading: controller.isSaving.value,
                  onPressed: controller.isSaving.value
                      ? null
                      : controller.changePassword,
                )),
          ],
        ),
      ),
    );
  }
}

class _InfoField extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget child;

  const _InfoField({
    required this.icon,
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(icon, size: 15, color: AppColors.textSecondary),
            const SizedBox(width: 5),
            // Flexible: a long label (or a large OS font) previously overflowed
            // the row. No visual change when the text fits; ellipsis when it
            // does not.
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        child,
      ],
    );
  }
}
