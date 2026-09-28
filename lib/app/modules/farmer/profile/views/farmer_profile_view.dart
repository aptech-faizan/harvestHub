import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/theme/app_colors.dart';
import 'package:harvest_hub/app/core/theme/app_radius.dart';
import 'package:harvest_hub/app/core/theme/app_spacing.dart';
import 'package:harvest_hub/app/core/theme/app_text_styles.dart';
import 'package:harvest_hub/app/core/widgets/app_widgets.dart';
import 'package:harvest_hub/app/modules/farmer/profile/controllers/farmer_profile_controller.dart';

/// Farmer Profile screen conforming to HarvestHub Design System & UI Master Rules:
/// - AppAppBar with refresh action
/// - Header block (farm photo/logo, farm name, rating badge, AppTextButton "Edit")
/// - AppCard.list sections:
///     1. Farm Bio & Story (Business Name, Bio/Description, Farmers Market)
///     2. Farm Address (Physical/Stall Address)
///     3. Contact Details (Owner Name, Readonly Email, Phone Number)
/// - AppButton.primary "Save"
/// - AppCard.list for Change Password (security preservation)
/// - Controller business logic (save, changePassword, load) remains 100% untouched.
class FarmerProfileView extends StatefulWidget {
  const FarmerProfileView({super.key});

  @override
  State<FarmerProfileView> createState() => _FarmerProfileViewState();
}

class _FarmerProfileViewState extends State<FarmerProfileView> {
  final FarmerProfileController controller = Get.find<FarmerProfileController>();
  final FocusNode _businessFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _businessFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToForm() {
    _scrollController.animateTo(
      180,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
    _businessFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceMuted,
      appBar: AppAppBar(
        titleText: 'Farmer Profile',
        actions: [
          AppIconButton(
            icon: Icons.refresh_rounded,
            iconSize: 20,
            backgroundColor: AppColors.surfaceMuted,
            iconColor: AppColors.textSecondary,
            tooltip: 'Refresh Profile',
            isCircle: false,
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
          controller: _scrollController,
          padding: const EdgeInsets.only(bottom: AppSpacing.xxl * 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header Block ───────────────────────────────────────────
              _ProfileHeader(
                controller: controller,
                onEdit: _scrollToForm,
              ),

              const SizedBox(height: AppSpacing.l),

              // ── Farm Bio Section ────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontalPadding,
                ),
                child: AppCard.list(
                  title: 'Farm Bio',
                  children: [
                    _InfoField(
                      icon: Icons.storefront_outlined,
                      label: 'Farm / Business Name',
                      child: AppTextField(
                        controller: controller.businessC,
                        focusNode: _businessFocusNode,
                        hintText: 'e.g. Green Acres Organic Farm',
                        prefixIcon: const Icon(
                          Icons.storefront,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.m),

                    _InfoField(
                      icon: Icons.description_outlined,
                      label: 'Bio / Farm Story',
                      child: AppTextField(
                        controller: controller.descriptionC,
                        hintText:
                            'Share your farm history, organic practices, and produce specialties...',
                        maxLines: 3,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.m),

                    _InfoField(
                      icon: Icons.store_mall_directory_outlined,
                      label: 'Associated Farmers Market',
                      child: Obx(() {
                        final ids =
                            controller.markets.map((m) => m.id).toList();
                        final value = ids.contains(
                                controller.selectedMarketId.value)
                            ? controller.selectedMarketId.value
                            : null;

                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceMuted,
                            borderRadius: AppRadius.inputRadius,
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: value,
                              hint: Text(
                                'Select your primary market',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textDisabled,
                                ),
                              ),
                              icon: const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: AppColors.textSecondary,
                              ),
                              items: controller.markets
                                  .map(
                                    (m) => DropdownMenuItem(
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
                                  )
                                  .toList(),
                              onChanged: (v) {
                                if (v != null) {
                                  controller.selectedMarketId.value = v;
                                }
                              },
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.m),

              // ── Farm Address Section ────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontalPadding,
                ),
                child: AppCard.list(
                  title: 'Address',
                  children: [
                    _InfoField(
                      icon: Icons.location_on_outlined,
                      label: 'Farm / Pickup Location Address',
                      child: AppTextField(
                        controller: controller.addressC,
                        hintText: 'e.g. 104 Orchard Valley Rd, Rural Route 3',
                        maxLines: 2,
                        keyboardType: TextInputType.streetAddress,
                        prefixIcon: const Icon(
                          Icons.location_on,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.m),

              // ── Contact Details Section ─────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontalPadding,
                ),
                child: AppCard.list(
                  title: 'Contact Details',
                  children: [
                    _InfoField(
                      icon: Icons.person_outline,
                      label: 'Owner / Manager Name',
                      child: AppTextField(
                        controller: controller.nameC,
                        hintText: 'Enter your full name',
                        prefixIcon: const Icon(
                          Icons.person,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.m),

                    _InfoField(
                      icon: Icons.email_outlined,
                      label: 'Registered Email (Read-only)',
                      child: Container(
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
                              color: AppColors.textDisabled,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Obx(() => Text(
                                    controller.email.value.isNotEmpty
                                        ? controller.email.value
                                        : '—',
                                    style: AppTextStyles.bodyText.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  )),
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

                    _InfoField(
                      icon: Icons.phone_outlined,
                      label: 'Phone Number',
                      child: AppTextField(
                        controller: controller.phoneC,
                        hintText: 'e.g. +1 555-0199',
                        keyboardType: TextInputType.phone,
                        prefixIcon: const Icon(
                          Icons.phone,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.l),

              // ── Save Profile Button ─────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontalPadding,
                ),
                child: Obx(() => AppButton.primary(
                      label: controller.isSaving.value ? 'Saving...' : 'Save',
                      icon: Icons.check_circle_outline_rounded,
                      isLoading: controller.isSaving.value,
                      onPressed:
                          controller.isSaving.value ? null : controller.save,
                    )),
              ),

              const SizedBox(height: AppSpacing.xl),

              // ── Security & Change Password Card ─────────────────────────
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
                    const SizedBox(height: AppSpacing.l),

                    Obx(() => AppButton.primary(
                          label: 'Update Password',
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
            ],
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header Block: Farm photo/logo, Farm Name, Rating / Market, AppTextButton "Edit"
// ─────────────────────────────────────────────────────────────────────────────
class _ProfileHeader extends StatelessWidget {
  final FarmerProfileController controller;
  final VoidCallback onEdit;

  const _ProfileHeader({
    required this.controller,
    required this.onEdit,
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
          // Farm photo / logo circle with verified badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
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
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.accentGold,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.surfaceWhite,
                      width: 2,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.verified_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),

          // Farm / Business Name
          AnimatedBuilder(
            animation: controller.businessC,
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
          const SizedBox(height: AppSpacing.xs),

          // Rating & Market subtitle
          Obx(() {
            final market = controller.markets.firstWhereOrNull(
              (m) => m.id == controller.selectedMarketId.value,
            );
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (controller.rating.value > 0) ...[
                  const Icon(
                    Icons.star_rounded,
                    size: 16,
                    color: Color(0xFFF57F17),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    controller.rating.value.toStringAsFixed(1),
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('•', style: TextStyle(color: AppColors.divider)),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    market?.marketName ?? 'Verified Local Producer',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            );
          }),

          const SizedBox(height: AppSpacing.m),

          // AppTextButton "Edit"
          AppTextButton(
            label: 'Edit',
            leadingIcon: Icons.edit_outlined,
            color: AppColors.primaryDark,
            onPressed: onEdit,
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
            const SizedBox(width: 6),
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
