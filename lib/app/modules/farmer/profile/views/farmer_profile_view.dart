import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/theme/app_colors.dart';
import 'package:harvest_hub/app/core/theme/app_radius.dart';
import 'package:harvest_hub/app/core/theme/app_spacing.dart';
import 'package:harvest_hub/app/core/theme/app_text_styles.dart';
import 'package:harvest_hub/app/core/widgets/app_widgets.dart';
import 'package:harvest_hub/app/modules/farmer/profile/controllers/farmer_profile_controller.dart';
import 'package:harvest_hub/app/routes/app_routes.dart';

/// Farmer Profile screen restructured as a menu conforming to UI Master Rules:
/// a) Header: avatar, farm business name, email, and "Verified" AppChip (only if verified)
/// b) Vertical menu of AppCard.list rows navigating to sub-pages:
///    - Farm Bio
///    - Address
///    - Contact Details
///    - Change Password
/// c) Back button and refresh action in AppAppBar
/// d) All sub-pages share FarmerProfileController with fenix: true
class FarmerProfileView extends GetView<FarmerProfileController> {
  const FarmerProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceMuted,
      appBar: AppAppBar(
        titleText: 'Farmer Profile',
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
        actions: [
          AppIconButton(
            icon: Icons.refresh_rounded,
            iconSize: 20,
            backgroundColor: AppColors.surfaceMuted,
            iconColor: AppColors.textSecondary,
            tooltip: 'Refresh Profile',
            isCircle: true,
            onTap: controller.load,
          ),
        ],
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
          padding: const EdgeInsets.only(bottom: AppSpacing.xxl * 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header Block ───────────────────────────────────────────
              _ProfileHeader(controller: controller),

              const SizedBox(height: AppSpacing.l),

              // ── Settings Menu ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontalPadding,
                ),
                child: AppCard.list(
                  title: 'Farm Settings',
                  children: [
                    _NavRow(
                      icon: Icons.storefront_outlined,
                      label: 'Farm Bio',
                      subtitle: 'Business name, description, and market',
                      onTap: () => Get.toNamed(Routes.farmerBio),
                    ),
                    const Divider(color: AppColors.divider, height: 1),
                    _NavRow(
                      icon: Icons.location_on_outlined,
                      label: 'Address',
                      subtitle: 'Farm location and pickup address',
                      onTap: () => Get.toNamed(Routes.farmerAddress),
                    ),
                    const Divider(color: AppColors.divider, height: 1),
                    _NavRow(
                      icon: Icons.person_outline,
                      label: 'Contact Details',
                      subtitle: 'Owner name, email, and phone',
                      onTap: () => Get.toNamed(Routes.farmerContact),
                    ),
                    const Divider(color: AppColors.divider, height: 1),
                    _NavRow(
                      icon: Icons.lock_outline,
                      label: 'Change Password',
                      subtitle: 'Update your security credentials',
                      onTap: () => Get.toNamed(Routes.farmerChangePassword),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header Block: Avatar, Farm Business Name, Email, and Verified Chip
// ─────────────────────────────────────────────────────────────────────────────
class _ProfileHeader extends StatelessWidget {
  final FarmerProfileController controller;

  const _ProfileHeader({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.surfaceWhite,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontalPadding,
        vertical: AppSpacing.xl,
      ),
      child: Column(
        children: [
          // Farm photo / avatar circle
          Obx(() {
            final photoUrl =
                controller.authService.currentUserModel.value?.photoUrl;
            if (photoUrl != null && photoUrl.trim().isNotEmpty) {
              return AppAvatar(
                imageUrl: photoUrl,
                name: controller.businessC.text.isNotEmpty
                    ? controller.businessC.text
                    : controller.nameC.text,
                size: 90,
              );
            }
            return Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2E7D32), AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryDark.withValues(alpha: 0.25),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.agriculture_rounded,
                  size: 46,
                  color: Colors.white,
                ),
              ),
            );
          }),
          const SizedBox(height: AppSpacing.m),

          // Farm / Business Name
          AnimatedBuilder(
            animation: Listenable.merge([controller.businessC, controller.nameC]),
            builder: (context, _) {
              final farmName = controller.businessC.text.trim().isNotEmpty
                  ? controller.businessC.text.trim()
                  : (controller.nameC.text.trim().isNotEmpty
                      ? "${controller.nameC.text.trim()}'s Farm"
                      : 'My Farm');
              return AppText.screenTitle(
                farmName,
                textAlign: TextAlign.center,
              );
            },
          ),
          const SizedBox(height: 4),

          // Email
          Obx(() {
            final email = controller.email.value;
            return AppText.caption(
              email.isNotEmpty ? email : '',
              color: AppColors.textSecondary,
              textAlign: TextAlign.center,
            );
          }),

          // Verified Chip — displayed ONLY if real isVerified is true
          Obx(() {
            if (!controller.isVerified.value) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(top: AppSpacing.m),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.chipHerbsBg,
                  borderRadius: AppRadius.chipRadius,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.20),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.verified_rounded,
                      size: 14,
                      color: AppColors.primaryDark,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Verified',
                      style: AppTextStyles.chipLabel.copyWith(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Navigation Row Component
// ─────────────────────────────────────────────────────────────────────────────
class _NavRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;

  const _NavRow({
    required this.icon,
    required this.label,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 18,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppText.cardTitle(label),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    AppText.caption(
                      subtitle!,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 20,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
