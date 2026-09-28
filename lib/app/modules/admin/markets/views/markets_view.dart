import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/theme/app_colors.dart';
import 'package:harvest_hub/app/core/theme/app_spacing.dart';
import 'package:harvest_hub/app/core/theme/app_text_styles.dart';
import 'package:harvest_hub/app/core/widgets/app_shimmer.dart';
import 'package:harvest_hub/app/core/widgets/app_widgets.dart';
import 'package:harvest_hub/app/modules/admin/markets/controllers/markets_controller.dart';
import 'package:harvest_hub/app/modules/admin/models/market_model.dart';
import 'package:harvest_hub/app/modules/admin/widgets/admin_drawer.dart';

/// Admin Markets Directory screen conforming to the HarvestHub Design System:
/// - AppAppBar with drawer toggle & refresh action
/// - Top action row with AppSearchBar + AppButton "Add Market"
/// - List of AppCard.list rows showing:
///   - Market name & active status AppChip
///   - Address & operating hours
///   - Active pickup-slot count
///   - GPS location coordinates
///   - Active toggle switch and AppIconButton edit / delete actions
class MarketsView extends GetView<MarketsController> {
  const MarketsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceMuted,
      appBar: AppAppBar(
        titleText: 'Markets Directory',
        leading: Builder(
          builder: (ctx) => AppIconButton(
            icon: Icons.menu,
            iconSize: 22,
            backgroundColor: Colors.transparent,
            iconColor: AppColors.textPrimary,
            isCircle: false,
            onTap: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        actions: [
          AppIconButton(
            icon: Icons.refresh_rounded,
            iconSize: 20,
            backgroundColor: AppColors.surfaceMuted,
            iconColor: AppColors.primaryDark,
            tooltip: 'Refresh',
            onTap: controller.load,
          ),
        ],
      ),
      drawer: const AdminDrawer(),
      body: Column(
        children: [
          // ── Search & "Add Market" Action Header ─────────────────────────────
          Container(
            color: AppColors.surfaceWhite,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.l,
              AppSpacing.s,
              AppSpacing.l,
              AppSpacing.m,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: AppSearchBar(
                        hintText: 'Search by name or address...',
                        onChanged: (v) => controller.search.value = v,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s),
                    AppButton.small(
                      label: 'Add Market',
                      icon: Icons.add_rounded,
                      onPressed: () => controller.openForm(),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: AppSpacing.s),

          // ── Markets List ────────────────────────────────────────────────────
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const ShimmerListSkeleton();
              }

              if (controller.error.value.isNotEmpty) {
                return _buildErrorState();
              }

              final list = controller.filtered;
              if (list.isEmpty) {
                return _buildEmptyState();
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.l,
                  0,
                  AppSpacing.l,
                  AppSpacing.xl,
                ),
                itemCount: list.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.m),
                itemBuilder: (_, i) {
                  final market = list[i];
                  final slotCount = controller.getSlotCount(market.id);
                  return _MarketDirectoryCard(
                    market: market,
                    slotCount: slotCount,
                    onEdit: () => controller.openForm(market),
                    onDelete: () => controller.delete(market),
                    onToggleActive: (val) =>
                        controller.setActive(market, val),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  // ── Empty State ─────────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.chipHerbsBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.storefront_outlined,
                size: 40,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            Text(
              'No markets found',
              style: AppTextStyles.sectionHeading,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.s),
            Text(
              'No registered market locations match your criteria. Tap Add Market to create one.',
              style: AppTextStyles.bodyText.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.l),
            AppButton.small(
              label: 'Add Market',
              icon: Icons.add_rounded,
              onPressed: () => controller.openForm(),
            ),
          ],
        ),
      ),
    );
  }

  // ── Error State ─────────────────────────────────────────────────────────────
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              size: 48,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.m),
            Text(
              controller.error.value,
              style: AppTextStyles.bodyText.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.l),
            AppButton.small(
              label: 'Retry',
              icon: Icons.refresh,
              onPressed: controller.load,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Market Directory Card Row Component ───────────────────────────────────────
class _MarketDirectoryCard extends StatelessWidget {
  final MarketModel market;
  final int slotCount;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<bool> onToggleActive;

  const _MarketDirectoryCard({
    required this.market,
    required this.slotCount,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleActive,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard.list(
      onTap: onEdit,
      padding: const EdgeInsets.all(AppSpacing.l),
      children: [
        // ── Top Row: Market Name + Status Chip ───────────────────────────────
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Store Icon Marker
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: market.activeStatus
                    ? AppColors.chipHerbsBg
                    : AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                market.activeStatus
                    ? Icons.store_rounded
                    : Icons.storefront_outlined,
                size: 24,
                color: market.activeStatus
                    ? AppColors.primaryDark
                    : AppColors.textDisabled,
              ),
            ),
            const SizedBox(width: AppSpacing.m),

            // Market Name
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    market.marketName,
                    style: AppTextStyles.cardTitle.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 13,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          market.operatingHours.isNotEmpty
                              ? market.operatingHours
                              : 'Hours not set',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: AppSpacing.s),

            // Active / Inactive Badge
            AppChip.pill(
              label: market.activeStatus ? 'Active' : 'Inactive',
              iconData: market.activeStatus
                  ? Icons.check_circle_outline_rounded
                  : Icons.pause_circle_outline_rounded,
              backgroundColor: market.activeStatus
                  ? AppColors.chipHerbsBg
                  : const Color(0xFFFFEBEE),
              textColor: market.activeStatus
                  ? AppColors.primaryDark
                  : AppColors.accentRed,
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.m),
        const Divider(color: AppColors.divider, height: 1),
        const SizedBox(height: AppSpacing.m),

        // ── Details Section: Address, Slots, Coordinates ─────────────────────
        // Address
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.location_on_outlined,
              size: 16,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                market.address.isNotEmpty
                    ? market.address
                    : 'Address not available',
                style: AppTextStyles.bodyText.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.s),

        // Active Pickup-Slot Count
        Row(
          children: [
            const Icon(
              Icons.schedule_outlined,
              size: 16,
              color: AppColors.primaryDark,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              'Active Pickup Slots: ',
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: slotCount > 0
                    ? AppColors.chipHerbsBg
                    : AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '$slotCount slots',
                style: AppTextStyles.caption.copyWith(
                  color: slotCount > 0
                      ? AppColors.primaryDark
                      : AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),

        // GPS Coordinates (if available)
        if (market.hasCoordinates) ...[
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              const Icon(
                Icons.pin_drop_outlined,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Coordinates: ',
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '${market.latitude.toStringAsFixed(4)}, ${market.longitude.toStringAsFixed(4)}',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textPrimary,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ],

        const SizedBox(height: AppSpacing.m),
        const Divider(color: AppColors.divider, height: 1),
        const SizedBox(height: AppSpacing.s),

        // ── Action Buttons Row: Status switch + Edit + Delete ─────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Active status quick toggle
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Enabled',
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                Transform.scale(
                  scale: 0.8,
                  child: Switch(
                    value: market.activeStatus,
                    activeThumbColor: AppColors.primaryDark,
                    onChanged: onToggleActive,
                  ),
                ),
              ],
            ),

            // Edit & Delete IconButtons
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppIconButton(
                  icon: Icons.edit_outlined,
                  size: 34,
                  iconSize: 18,
                  backgroundColor: AppColors.surfaceMuted,
                  iconColor: AppColors.primaryDark,
                  tooltip: 'Edit Market',
                  onTap: onEdit,
                ),
                const SizedBox(width: AppSpacing.s),
                AppIconButton(
                  icon: Icons.delete_outline_rounded,
                  size: 34,
                  iconSize: 18,
                  backgroundColor: const Color(0xFFFFEBEE),
                  iconColor: AppColors.accentRed,
                  tooltip: 'Delete Market',
                  onTap: onDelete,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
