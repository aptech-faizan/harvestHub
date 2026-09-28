import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/theme/app_colors.dart';
import 'package:harvest_hub/app/core/theme/app_spacing.dart';
import 'package:harvest_hub/app/core/theme/app_text_styles.dart';
import 'package:harvest_hub/app/core/widgets/app_widgets.dart';
import '../controllers/profile_controller.dart';

/// Change Password screen conforming to UI Master Rules.
/// Reuses existing changePassword() logic from ProfileController untouched.
class ChangePasswordView extends GetView<ProfileController> {
  const ChangePasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceMuted,
      appBar: const AppAppBar(titleText: 'Change Password'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenHorizontalPadding,
          vertical: AppSpacing.l,
        ),
        child: AppCard.list(
          children: [
            _InfoField(
              icon: Icons.lock_outline,
              label: 'Current Password',
              child: AppTextField(
                controller: controller.currentPassC,
                hintText: 'Enter current password',
                keyboardType: TextInputType.visiblePassword,
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            _InfoField(
              icon: Icons.lock_reset_outlined,
              label: 'New Password',
              child: AppTextField(
                controller: controller.newPassC,
                hintText: 'Enter new password (min 6 chars)',
                keyboardType: TextInputType.visiblePassword,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Update Password button
            Obx(() => AppButton.primary(
                  label: 'Update Password',
                  icon: Icons.security,
                  backgroundColor: AppColors.primary,
                  isLoading: controller.isLoading.value,
                  onPressed: controller.isLoading.value
                      ? null
                      : () => controller.changePassword(
                            controller.currentPassC.text,
                            controller.newPassC.text,
                          ),
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
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
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
