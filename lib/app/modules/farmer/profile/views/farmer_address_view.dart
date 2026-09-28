import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/theme/app_colors.dart';
import 'package:harvest_hub/app/core/theme/app_spacing.dart';
import 'package:harvest_hub/app/core/theme/app_text_styles.dart';
import 'package:harvest_hub/app/core/widgets/app_shimmer.dart';
import 'package:harvest_hub/app/core/widgets/app_widgets.dart';
import '../controllers/farmer_profile_controller.dart';

/// Farm Address edit screen conforming to UI Master Rules.
/// Edits physical/stall/pickup location and saves via FarmerProfileController.save().
class FarmerAddressView extends GetView<FarmerProfileController> {
  const FarmerAddressView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceMuted,
      appBar: AppAppBar(
        titleText: 'Address',
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
          return const ShimmerDetailBlock();
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontalPadding,
            vertical: AppSpacing.l,
          ),
          child: AppCard.list(
            title: 'Farm Location',
            children: [
              _InfoField(
                icon: Icons.location_on_outlined,
                label: 'Farm / Pickup Location Address',
                child: AppTextField(
                  controller: controller.addressC,
                  hintText: 'e.g. 104 Orchard Valley Rd, Rural Route 3',
                  maxLines: 3,
                  keyboardType: TextInputType.streetAddress,
                  prefixIcon: const Icon(
                    Icons.location_on_outlined,
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
