import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/theme/app_colors.dart';
import 'package:harvest_hub/app/core/theme/app_radius.dart';
import 'package:harvest_hub/app/core/theme/app_spacing.dart';
import 'package:harvest_hub/app/core/theme/app_text_styles.dart';
import 'package:harvest_hub/app/core/widgets/app_widgets.dart';
import 'package:harvest_hub/app/routes/app_routes.dart';
import '../controllers/profile_controller.dart';

/// Profile screen revamped per UI Master Rules and Design Specification.
/// Structure:
///  AppAppBar → Avatar/Header block (initials, name, email, Edit button)
///  → AppCard.list: Personal Info (editable fields + Save)
///  → AppCard.list: Change Password
///  → AppCard.list: Quick Links (Wishlist, Chats, Followed Farmers)
///  → AppCard.list: App Info (About Us, Contact Us)
///  → AppButton.primary "Logout" (red)
/// Business logic (saveProfile, changePassword, logout) is UNTOUCHED.
class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceMuted,
      appBar: const AppAppBar(titleText: 'My Profile'),
      body: Obx(() {
        if (controller.isLoading.value && controller.user.value == null) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              strokeWidth: 2.5,
            ),
          );
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
              // ── Avatar / Header Block ───────────────────────────────────
              _ProfileHeader(name: name, email: email),

              const SizedBox(height: AppSpacing.m),

              // ── Personal Info Card ──────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontalPadding,
                ),
                child: AppCard.list(
                  title: 'Personal Information',
                  children: [
                    // Email — readonly, no edit allowed
                    _InfoField(
                      icon: Icons.email_outlined,
                      label: 'Email',
                      child: AppText.body(
                        email.isNotEmpty ? email : '—',
                        color: AppColors.textSecondary,
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
                        hintText: 'Enter your phone number',
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.m),

                    // Address — editable
                    _InfoField(
                      icon: Icons.home_outlined,
                      label: 'Delivery Address',
                      child: AppTextField(
                        controller: controller.addressC,
                        hintText: 'Enter your address',
                        maxLines: 2,
                        keyboardType: TextInputType.streetAddress,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Save Profile button — calls existing saveProfile()
                    Obx(() => AppButton.primary(
                          label: controller.isLoading.value
                              ? 'Saving...'
                              : 'Save Profile',
                          icon: Icons.check_circle_outline,
                          isLoading: controller.isLoading.value,
                          onPressed: controller.isLoading.value
                              ? null
                              : () => controller.saveProfile(),
                        )),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.m),

              // ── Change Password Card ────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontalPadding,
                ),
                child: AppCard.list(
                  title: 'Change Password',
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

                    // Change Password button — calls existing changePassword()
                    Obx(() => AppButton.primary(
                          label: 'Change Password',
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

              const SizedBox(height: AppSpacing.m),

              // ── Quick Links Card ────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontalPadding,
                ),
                child: AppCard.list(
                  title: 'My Account',
                  children: [
                    _NavRow(
                      icon: Icons.favorite_outline,
                      label: 'Wishlist',
                      onTap: () => Get.toNamed(Routes.customerWishlist),
                    ),
                    const Divider(color: AppColors.divider, height: 1),
                    _NavRow(
                      icon: Icons.chat_bubble_outline,
                      label: 'Chats',
                      subtitle: 'Messages with your farmers',
                      onTap: () => Get.toNamed(Routes.chatInbox),
                    ),
                    const Divider(color: AppColors.divider, height: 1),
                    _NavRow(
                      icon: Icons.people_alt_outlined,
                      label: 'Followed Farmers',
                      subtitle: 'Get restock alerts from favourites',
                      onTap: () =>
                          Get.toNamed(Routes.customerFollowedFarmers),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.m),

              // ── App Info Card ───────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontalPadding,
                ),
                child: AppCard.list(
                  title: 'Support',
                  children: [
                    _NavRow(
                      icon: Icons.info_outline,
                      iconColor: AppColors.primary,
                      label: 'About Us',
                      onTap: () => Get.toNamed(Routes.aboutUs),
                    ),
                    const Divider(color: AppColors.divider, height: 1),
                    _NavRow(
                      icon: Icons.contact_support_outlined,
                      iconColor: AppColors.primary,
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
}

// ─────────────────────────────────────────────────────────────────────────────
// Private: Profile header — avatar circle, name, email, Edit chip
// ─────────────────────────────────────────────────────────────────────────────
class _ProfileHeader extends StatelessWidget {
  final String name;
  final String email;

  const _ProfileHeader({required this.name, required this.email});

  /// Returns up to 2 initials from a display name
  String get _initials {
    final parts = name.trim().split(' ');
    if (parts.isEmpty || name.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts.last[0]).toUpperCase();
  }

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
          // Avatar circle with initials
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primaryButton, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.30),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                _initials,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
            ),
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
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.20)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified_outlined, size: 14, color: AppColors.primaryDark),
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
// Private: A labelled field row with icon + label above its child widget
// ─────────────────────────────────────────────────────────────────────────────
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

// ─────────────────────────────────────────────────────────────────────────────
// Private: A tappable navigation row for the Quick Links / Support cards
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
