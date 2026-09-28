import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/theme/app_colors.dart';
import 'package:harvest_hub/app/core/theme/app_radius.dart';
import 'package:harvest_hub/app/core/theme/app_spacing.dart';
import 'package:harvest_hub/app/core/theme/app_text_styles.dart';
import 'package:harvest_hub/app/core/widgets/app_widgets.dart';
import '../controllers/farmer_profile_controller.dart';

/// Contact Details edit screen conforming to UI Master Rules.
/// Edits Owner Name and Phone, shows Read-only Email, and saves via FarmerProfileController.save().
class FarmerContactView extends GetView<FarmerProfileController> {
  const FarmerContactView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceMuted,
      appBar: AppAppBar(
        titleText: 'Contact Details',
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
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          );
        }

        final email = controller.email.value;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontalPadding,
            vertical: AppSpacing.l,
          ),
          child: AppCard.list(
            title: 'Owner & Contact Info',
            children: [
              // Owner / Manager Name
              _InfoField(
                icon: Icons.person_outline,
                label: 'Owner / Manager Name',
                child: AppTextField(
                  controller: controller.nameC,
                  hintText: 'Enter your full name',
                  prefixIcon: const Icon(
                    Icons.person_outline,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.m),
              const Divider(color: AppColors.divider, height: 1),
              const SizedBox(height: AppSpacing.m),

              // Registered Email (Read-only)
              _InfoField(
                icon: Icons.email_outlined,
                label: 'Registered Email (Read-only)',
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14.0,
                    vertical: 13.0,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: AppRadius.inputRadius,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.email_outlined,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppSpacing.s),
                      Expanded(
                        child: Text(
                          email.isNotEmpty ? email : '—',
                          style: AppTextStyles.bodyText.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(
                        Icons.lock_outline,
                        size: 16,
                        color: AppColors.textDisabled,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.m),
              const Divider(color: AppColors.divider, height: 1),
              const SizedBox(height: AppSpacing.m),

              // Phone Number
              _InfoField(
                icon: Icons.phone_outlined,
                label: 'Phone Number',
                child: AppTextField(
                  controller: controller.phoneC,
                  hintText: 'e.g. +1 555-0199',
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(
                    Icons.phone_outlined,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Save Changes Button
              Obx(() => AppButton.primary(
                    label: controller.isSaving.value ? 'Saving...' : 'Save Changes',
                    icon: Icons.check_circle_outline,
                    isLoading: controller.isSaving.value,
                    onPressed: controller.isSaving.value
                        ? null
                        : controller.save,
                  )),
            ],
          ),
        );
      }),
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
