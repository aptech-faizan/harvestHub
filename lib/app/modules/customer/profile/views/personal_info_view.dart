import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/theme/app_colors.dart';
import 'package:harvest_hub/app/core/theme/app_radius.dart';
import 'package:harvest_hub/app/core/theme/app_spacing.dart';
import 'package:harvest_hub/app/core/theme/app_text_styles.dart';
import 'package:harvest_hub/app/core/widgets/app_shimmer.dart';
import 'package:harvest_hub/app/core/widgets/app_widgets.dart';
import '../controllers/profile_controller.dart';
import 'package:harvest_hub/app/core/utils/validators.dart';

/// Personal Information edit screen conforming to UI Master Rules.
/// Contains the existing form (Email, Full Name, Phone, Delivery Address)
/// and saves via ProfileController.saveProfile() untouched.
class PersonalInfoView extends GetView<ProfileController> {
  const PersonalInfoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceMuted,
      appBar: const AppAppBar(titleText: 'Personal Information'),
      body: Obx(() {
        if (controller.isLoading.value && controller.user.value == null) {
          return const ShimmerDetailBlock();
        }

        final u = controller.user.value;
        final email = u?.email ?? '';

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontalPadding,
            vertical: AppSpacing.l,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppCard.list(
                children: [
                  // Email — readonly
                  _InfoField(
                    icon: Icons.email_outlined,
                    label: 'Email (Read-only)',
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

                  // Name — editable
                  _InfoField(
                    icon: Icons.person_outline,
                    label: 'Full Name',
                    child: AppTextField(
                      controller: controller.nameC,
                      hintText: 'Enter your name',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.m),

                  // Phone — editable
                  _InfoField(
                    icon: Icons.phone_outlined,
                    label: 'Phone',
                    child: AppTextField(
                      controller: controller.phoneC,
                      hintText: '03001234567',
                      keyboardType: TextInputType.phone,
                      // This screen is not wrapped in a Form, so the rule is
                      // repeated for the inline error text; the authoritative
                      // check is in ProfileController.saveProfile().
                      validator: AppValidators.phone(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.m),

                  // Address — editable
                  _InfoField(
                    icon: Icons.home_outlined,
                    label: 'Delivery Address',
                    child: AppTextField(
                      controller: controller.addressC,
                      hintText: 'Enter your delivery address',
                      maxLines: 2,
                      keyboardType: TextInputType.streetAddress,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Save Profile button
                  Obx(() => AppButton.primary(
                        label: controller.isLoading.value ? 'Saving...' : 'Save',
                        icon: Icons.check_circle_outline,
                        isLoading: controller.isLoading.value,
                        onPressed: controller.isLoading.value
                            ? null
                            : () => controller.saveProfile(),
                      )),
                ],
              ),
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
