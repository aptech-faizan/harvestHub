import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/theme/app_colors.dart';
import 'package:harvest_hub/app/core/theme/app_radius.dart';
import 'package:harvest_hub/app/core/theme/app_spacing.dart';
import 'package:harvest_hub/app/core/theme/app_text_styles.dart';
import 'package:harvest_hub/app/core/widgets/app_shimmer.dart';
import 'package:harvest_hub/app/core/widgets/app_widgets.dart';
import 'package:harvest_hub/app/routes/app_routes.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/profile_controller.dart';

/// Customer Profile screen restructured as a menu per UI Master Rules:
/// a) Header: avatar (initial letter), name, email, and "Verified Member" AppChip.
/// b) Vertical menu of AppCard.list rows (leading AppIcon, title AppText, trailing chevron)
///    navigating to existing screens: Personal Information, Change Password, Wishlist,
///    Followed Farmers, Chats, About Us, and Contact Us.
/// c) Logout at the bottom, existing logic untouched.
class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceMuted,
      appBar: const AppAppBar(titleText: 'My Profile'),
      body: Obx(() {
        if (controller.isLoading.value && controller.user.value == null) {
          return const ShimmerDetailBlock();
        }

        final u = controller.user.value;
        final email = u?.email ?? '';
        final name = u?.name ?? '';

        return SingleChildScrollView(
          padding: const EdgeInsets.only(
            bottom: AppSpacing.xxl * 2,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header: Avatar, Name, Email, Verified Member ───────────
              _ProfileHeader(
                name: name,
                email: email,
                photoUrl: u?.photoUrl,
                isUploading: controller.isUploadingPhoto.value,
                onPhotoTap: () => _showPhotoBottomSheet(context, controller),
              ),

              const SizedBox(height: AppSpacing.l),

              // ── Account Settings Menu ──────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontalPadding,
                ),
                child: AppCard.list(
                  title: 'Account Settings',
                  children: [
                    _NavRow(
                      icon: Icons.person_outline,
                      label: 'Personal Information',
                      subtitle: 'Name, phone number, and delivery address',
                      onTap: () => Get.toNamed(Routes.customerPersonalInfo),
                    ),
                    const Divider(color: AppColors.divider, height: 1),
                    _NavRow(
                      icon: Icons.lock_outline,
                      label: 'Change Password',
                      subtitle: 'Update your security credentials',
                      onTap: () => Get.toNamed(Routes.customerChangePassword),
                    ),
                    const Divider(color: AppColors.divider, height: 1),
                    _NavRow(
                      icon: Icons.favorite_outline,
                      label: 'Wishlist',
                      subtitle: 'Your saved favorite produce',
                      onTap: () => Get.toNamed(Routes.customerWishlist),
                    ),
                    const Divider(color: AppColors.divider, height: 1),
                    _NavRow(
                      icon: Icons.people_alt_outlined,
                      label: 'Followed Farmers',
                      subtitle: 'Get restock alerts from favourites',
                      onTap: () =>
                          Get.toNamed(Routes.customerFollowedFarmers),
                    ),
                    const Divider(color: AppColors.divider, height: 1),
                    _NavRow(
                      icon: Icons.chat_bubble_outline,
                      label: 'Chats',
                      subtitle: 'Messages with your farmers',
                      onTap: () => Get.toNamed(Routes.chatInbox),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.m),

              // ── Support Menu ───────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontalPadding,
                ),
                child: AppCard.list(
                  title: 'Support & Info',
                  children: [
                    _NavRow(
                      icon: Icons.info_outline,
                      iconColor: AppColors.primaryDark,
                      label: 'About Us',
                      onTap: () => Get.toNamed(Routes.aboutUs),
                    ),
                    const Divider(color: AppColors.divider, height: 1),
                    _NavRow(
                      icon: Icons.contact_support_outlined,
                      iconColor: AppColors.primaryDark,
                      label: 'Contact Us & Feedback',
                      onTap: () => Get.toNamed(Routes.contactUs),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // ── Logout Button ───────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontalPadding,
                ),
                child: AppButton.primary(
                  label: 'Logout',
                  icon: Icons.logout,
                  backgroundColor: AppColors.accentRed,
                  onPressed: () => controller.logout(),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  void _showPhotoBottomSheet(
      BuildContext context, ProfileController controller) {
    final hasPhoto = controller.user.value?.photoUrl.isNotEmpty == true;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(AppSpacing.l),
        decoration: const BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.card),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.m),
              const AppText.sectionHeading('Profile Photo'),
              const SizedBox(height: AppSpacing.s),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined,
                    color: AppColors.primaryDark),
                title: const AppText.body('Choose from gallery'),
                onTap: () {
                  Get.back();
                  controller.pickAndUploadPhoto(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined,
                    color: AppColors.primaryDark),
                title: const AppText.body('Take photo'),
                onTap: () {
                  Get.back();
                  controller.pickAndUploadPhoto(ImageSource.camera);
                },
              ),
              if (hasPhoto)
                ListTile(
                  leading: const Icon(Icons.delete_outline_rounded,
                      color: AppColors.accentRed),
                  title: const AppText.body('Remove photo',
                      color: AppColors.accentRed),
                  onTap: () {
                    Get.back();
                    controller.removePhoto();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private: Profile header — AppAvatar, name, email, Verified Member chip
// ─────────────────────────────────────────────────────────────────────────────
class _ProfileHeader extends StatelessWidget {
  final String name;
  final String email;
  final String? photoUrl;
  final bool isUploading;
  final VoidCallback onPhotoTap;

  const _ProfileHeader({
    required this.name,
    required this.email,
    this.photoUrl,
    this.isUploading = false,
    required this.onPhotoTap,
  });

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
          // AppAvatar with network image, fallback initials, camera badge & loading spinner
          AppAvatar(
            imageUrl: photoUrl,
            name: name,
            size: 88,
            showCameraBadge: true,
            isUploading: isUploading,
            onTap: onPhotoTap,
          ),

          const SizedBox(height: AppSpacing.m),

          // Name
          AppText.screenTitle(
            name.isNotEmpty ? name : 'Your Name',
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 4),

          // Email
          AppText.caption(
            email.isNotEmpty ? email : '',
            color: AppColors.textSecondary,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSpacing.m),

          // Member badge chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
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
                  Icons.verified_outlined,
                  size: 14,
                  color: AppColors.primaryDark,
                ),
                const SizedBox(width: 5),
                Text(
                  'Verified Member',
                  style: AppTextStyles.chipLabel.copyWith(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private: A tappable navigation row for the menu cards
// ─────────────────────────────────────────────────────────────────────────────
class _NavRow extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;

  const _NavRow({
    required this.icon,
    this.iconColor,
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
                  color: iconColor ?? AppColors.textPrimary,
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
