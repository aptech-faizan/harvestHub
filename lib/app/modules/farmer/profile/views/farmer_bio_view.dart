import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/theme/app_colors.dart';
import 'package:harvest_hub/app/core/theme/app_radius.dart';
import 'package:harvest_hub/app/core/theme/app_spacing.dart';
import 'package:harvest_hub/app/core/theme/app_text_styles.dart';
import 'package:harvest_hub/app/core/widgets/app_widgets.dart';
import '../controllers/farmer_profile_controller.dart';

/// Farm Bio edit screen conforming to UI Master Rules.
/// Displays Business Name, Bio/Description, and Associated Farmers Market (optional).
class FarmerBioView extends GetView<FarmerProfileController> {
  const FarmerBioView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceMuted,
      appBar: AppAppBar(
        titleText: 'Farm Bio',
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

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontalPadding,
            vertical: AppSpacing.l,
          ),
          child: AppCard.list(
            title: 'Farm Story & Details',
            children: [
              // Farm / Business Name
              _InfoField(
                icon: Icons.storefront_outlined,
                label: 'Farm / Business Name',
                child: AppTextField(
                  controller: controller.businessC,
                  hintText: 'e.g. Green Valley Organic Farm',
                  prefixIcon: const Icon(
                    Icons.storefront_outlined,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.m),
              const Divider(color: AppColors.divider, height: 1),
              const SizedBox(height: AppSpacing.m),

              // Farm Bio & Story
              _InfoField(
                icon: Icons.description_outlined,
                label: 'Farm Story & Bio',
                child: AppTextField(
                  controller: controller.descriptionC,
                  hintText:
                      'Share your farming background, heirloom varieties, organic methods, or farm values...',
                  maxLines: 5,
                  keyboardType: TextInputType.multiline,
                ),
              ),
              const SizedBox(height: AppSpacing.m),
              const Divider(color: AppColors.divider, height: 1),
              const SizedBox(height: AppSpacing.m),

              // Farmers Market Dropdown (optional)
              _InfoField(
                icon: Icons.store_mall_directory_outlined,
                label: 'Associated Farmers Market (optional)',
                child: Obx(() {
                  final currentId = controller.selectedMarketId.value;
                  final marketIds =
                      controller.markets.map((m) => m.id).toSet();
                  final effectiveValue =
                      (currentId.isNotEmpty && marketIds.contains(currentId))
                          ? currentId
                          : '';

                  return DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: effectiveValue,
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Color.fromARGB(255, 88, 88, 88),
                      ),
                      items: [
                        DropdownMenuItem<String>(
                          value: '',
                          child: Text(
                            'No market assigned (optional)',
                            style: AppTextStyles.bodyText.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        ...controller.markets.map(
                          (m) => DropdownMenuItem<String>(
                            value: m.id,
                            child: Text(
                              '${m.marketName} — ${m.address}',
                              style: AppTextStyles.bodyText.copyWith(
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                      onChanged: (v) {
                        controller.selectedMarketId.value = v ?? '';
                      },
                    ),
                  );
                }),
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
