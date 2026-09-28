import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/theme/app_colors.dart';
import 'package:harvest_hub/app/core/theme/app_radius.dart';
import 'package:harvest_hub/app/core/theme/app_spacing.dart';
import 'package:harvest_hub/app/core/theme/app_text_styles.dart';
import 'package:harvest_hub/app/core/widgets/app_widgets.dart';
import 'package:harvest_hub/app/data/models/farmer_model.dart';
import 'package:harvest_hub/app/modules/customer/follow/controllers/follow_controller.dart';
import 'package:harvest_hub/app/modules/customer/follow/widgets/follow_farmer_button.dart';
import 'package:harvest_hub/app/modules/shared/chat/widgets/chat_farmer_button.dart';
import 'package:harvest_hub/app/routes/app_routes.dart';

/// Followed ("favourite") farmers view revamped per HarvestHub UI Master Rules:
/// - AppAppBar with refresh action
/// - Vertical list of AppCard.list items
/// - Each card features farmer avatar/name, rating/market, quick chat/follow actions,
///   and their latest update/produce banner (thumbnail + AppText + timestamp caption)
/// - Empty state uses AppText + AppButton pointing to the Farmers List
/// - FollowController underlying logic remains 100% untouched
class FollowedFarmersView extends StatelessWidget {
  const FollowedFarmersView({super.key});

  @override
  Widget build(BuildContext context) {
    final follow = FollowController.instance;

    return Scaffold(
      backgroundColor: AppColors.surfaceMuted,
      appBar: AppAppBar(
        titleText: 'Followed Farmers',
        actions: [
          AppIconButton(
            icon: Icons.refresh_rounded,
            iconSize: 20,
            backgroundColor: AppColors.surfaceMuted,
            iconColor: AppColors.textSecondary,
            tooltip: 'Refresh',
            isCircle: false,
            onTap: follow.loadFollowedFarmers,
          ),
        ],
      ),
      body: Obx(() {
        if (follow.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          );
        }

        // Surface actual errors instead of silently showing an empty screen
        if (follow.error.value.isNotEmpty) {
          return _buildErrorState(follow);
        }

        final farmers = follow.followedFarmers;
        if (farmers.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: follow.loadFollowedFarmers,
          color: AppColors.primary,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontalPadding,
              vertical: AppSpacing.l,
            ),
            itemCount: farmers.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.m),
            itemBuilder: (context, i) => _FollowedFarmerCard(
              farmer: farmers[i],
              follow: follow,
            ),
          ),
        );
      }),
    );
  }

  // ── Empty State ─────────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenHorizontalPadding,
          vertical: AppSpacing.xxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.chipHerbsBg,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.people_outline_rounded,
                  size: 44,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            AppText.screenTitle(
              'No Followed Farmers Yet',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.s),
            AppText.body(
              'Follow your favourite local farmers to get real-time restock alerts, fresh harvest updates, and seasonal produce directly from the source.',
              textAlign: TextAlign.center,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: 220,
              child: AppButton.primary(
                label: 'Explore Farmers',
                icon: Icons.storefront_rounded,
                onPressed: () => Get.toNamed(Routes.customerFarmers),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Error State ─────────────────────────────────────────────────────────────
  Widget _buildErrorState(FollowController follow) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 48,
              color: AppColors.textDisabled,
            ),
            const SizedBox(height: AppSpacing.m),
            AppText.cardTitle(
              'Unable to Load Farmers',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            AppText.caption(
              follow.error.value,
              textAlign: TextAlign.center,
              color: AppColors.accentRed,
            ),
            const SizedBox(height: AppSpacing.l),
            AppButton.small(
              label: 'Retry',
              icon: Icons.refresh_rounded,
              onPressed: follow.refreshForCurrentUser,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private: Followed Farmer Card with latest update / product preview
// ─────────────────────────────────────────────────────────────────────────────
class _FollowedFarmerCard extends StatelessWidget {
  final FarmerModel farmer;
  final FollowController follow;

  const _FollowedFarmerCard({
    required this.farmer,
    required this.follow,
  });

  @override
  Widget build(BuildContext context) {
    final farmerId = farmer.id.isEmpty ? farmer.userId : farmer.id;
    final hasRating = farmer.rating > 0;
    final updateText = farmer.description.trim().isNotEmpty
        ? farmer.description.trim()
        : 'Fresh seasonal harvests and daily farm-to-table produce available.';

    return AppCard.list(
      onTap: () => Get.toNamed(
        Routes.customerFarmerDetails,
        arguments: farmer,
      ),
      children: [
        // ── Farmer Profile Header Row ───────────────────────────────────────
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Farmer Avatar / Logo
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.chipHerbsBg, Color(0xFFD7ECD9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.divider, width: 1.2),
              ),
              child: const Center(
                child: Icon(
                  Icons.agriculture_rounded,
                  size: 26,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.m),

            // Name & Market / Rating
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.cardTitle(
                    farmer.businessName.isNotEmpty
                        ? farmer.businessName
                        : 'Local Farmer',
                    maxLines: 1,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      if (farmer.marketName.isNotEmpty) ...[
                        const Icon(
                          Icons.storefront_outlined,
                          size: 13,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            farmer.marketName,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                      if (farmer.marketName.isNotEmpty && hasRating) ...[
                        const SizedBox(width: 6),
                        const Text(
                          '•',
                          style: TextStyle(
                            color: AppColors.divider,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      if (hasRating) ...[
                        const Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: Color(0xFFF57F17),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          farmer.rating.toStringAsFixed(1),
                          style: AppTextStyles.caption.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Action Buttons (Chat & Follow Toggle)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ChatFarmerButton(
                  farmerId: farmerId,
                  farmerName: farmer.businessName,
                  compact: true,
                ),
                FollowFarmerButton(
                  farmerId: farmerId,
                  farmerName: farmer.businessName,
                  compact: true,
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.m),
        const Divider(color: AppColors.divider, height: 1),
        const SizedBox(height: AppSpacing.m),

        // ── Latest Update / New Product Block ───────────────────────────────
        Container(
          padding: const EdgeInsets.all(AppSpacing.m),
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(AppRadius.input),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Small thumbnail
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.chipHerbsBg,
                  borderRadius: BorderRadius.circular(AppRadius.chip),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.15),
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.eco_rounded,
                    size: 22,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.m),

              // Update details & timestamp
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceWhite,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.divider),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF26A69A),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Fresh Harvest',
                                style: AppTextStyles.caption.copyWith(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Timestamp caption
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time_rounded,
                              size: 12,
                              color: AppColors.textDisabled,
                            ),
                            const SizedBox(width: 3),
                            AppText.caption(
                              'Active today',
                              color: AppColors.textDisabled,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    AppText.body(
                      updateText,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
