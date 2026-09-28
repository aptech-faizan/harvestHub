import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/theme/app_colors.dart';
import 'package:harvest_hub/app/core/theme/app_spacing.dart';
import 'package:harvest_hub/app/core/theme/app_text_styles.dart';
import 'package:harvest_hub/app/core/utils/helpers.dart';
import 'package:harvest_hub/app/core/widgets/app_widgets.dart';
import 'package:harvest_hub/app/modules/admin/farmers/controllers/farmers_controller.dart';
import 'package:harvest_hub/app/modules/admin/models/farmer_model.dart';
import 'package:harvest_hub/app/modules/admin/widgets/admin_drawer.dart';

// ── Status Filter Definitions ────────────────────────────────────────────────
const _kFarmerFilters = ['All', 'Verified', 'Pending', 'Inactive'];

// Module-level reactive filter state — preserves const constructor on view
final _farmersStatusFilter = 'All'.obs;

/// Admin Farmers Management screen conforming to the HarvestHub Design System:
/// - AppAppBar with drawer toggle & refresh action
/// - AppSearchBar + AppChip filters (verified / pending / inactive)
/// - List of AppCard.list rows showing:
///   - Farmer photo / avatar
///   - Business & owner name
///   - Status AppChip (Verified, Pending, Inactive)
///   - Join date & market details
///   - Action buttons: "Verify", "Activate" / "Deactivate", "View"
class FarmersView extends GetView<FarmersController> {
  const FarmersView({super.key});

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Verified':
        return Icons.verified_rounded;
      case 'Pending':
        return Icons.hourglass_top_rounded;
      case 'Inactive':
        return Icons.block_rounded;
      default:
        return Icons.agriculture_rounded;
    }
  }

  ({Color bg, Color text}) _getStatusColors(String status) {
    switch (status) {
      case 'Verified':
        return (bg: AppColors.chipHerbsBg, text: AppColors.primaryDark);
      case 'Pending':
        return (bg: const Color(0xFFFFF3E0), text: const Color(0xFFE65100));
      case 'Inactive':
        return (bg: const Color(0xFFFFEBEE), text: AppColors.accentRed);
      default:
        return (bg: AppColors.surfaceMuted, text: AppColors.textSecondary);
    }
  }

  List<FarmerModel> _applyFilters(List<FarmerModel> list, String filter) {
    switch (filter) {
      case 'Verified':
        return list.where((f) => f.isActive && f.isVerified).toList();
      case 'Pending':
        return list.where((f) => f.isActive && !f.isVerified).toList();
      case 'Inactive':
        return list.where((f) => !f.isActive).toList();
      default:
        return list;
    }
  }

  Future<void> _verifyFarmer(FarmerModel f) async {
    final ok = await confirmDialog(
      'Verify Farmer',
      'Verify ${f.businessName}? This grants them full verified producer status on HarvestHub.',
    );
    if (!ok) return;
    try {
      await controller.repo.updateFarmer(
        f,
        {'isVerified': true},
        {},
      );
      showSuccess('${f.businessName} verified successfully');
      await controller.load();
    } catch (e) {
      showError('Could not verify farmer: ${errorText(e)}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceMuted,
      appBar: AppAppBar(
        titleText: 'Farmers Management',
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
          // ── Search & Filter Chips Bar ──────────────────────────────────────
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
                AppSearchBar(
                  hintText: 'Search by business, owner or email...',
                  onChanged: (v) => controller.search.value = v,
                ),
                const SizedBox(height: AppSpacing.m),
                Obx(() {
                  final activeFilter = _farmersStatusFilter.value;
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _kFarmerFilters.map((s) {
                        final isSelected = activeFilter == s;
                        final count = _getFilterCount(s);
                        final icon = _getStatusIcon(s);
                        final style = _getStatusColors(s);

                        return Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.s),
                          child: AppChip.pill(
                            label: '$s ($count)',
                            iconData: icon,
                            backgroundColor:
                                isSelected ? style.bg : AppColors.surfaceMuted,
                            textColor:
                                isSelected ? style.text : AppColors.textSecondary,
                            isSelected: isSelected,
                            onTap: () => _farmersStatusFilter.value = s,
                          ),
                        );
                      }).toList(),
                    ),
                  );
                }),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: AppSpacing.s),

          // ── Farmer Cards List ──────────────────────────────────────────────
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primaryButton),
                );
              }

              if (controller.error.value.isNotEmpty) {
                return _buildErrorState();
              }

              final filteredList =
                  _applyFilters(controller.filtered, _farmersStatusFilter.value);

              if (filteredList.isEmpty) {
                return _buildEmptyState();
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.l,
                  0,
                  AppSpacing.l,
                  AppSpacing.xl,
                ),
                itemCount: filteredList.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.m),
                itemBuilder: (_, i) {
                  final farmer = filteredList[i];
                  return _FarmerManagementRow(
                    farmer: farmer,
                    marketName:
                        controller.marketNames[farmer.marketId] ?? '',
                    onVerify: () => _verifyFarmer(farmer),
                    onToggleActive: () => controller.toggleActive(farmer),
                    onViewDetails: () => controller.openDetails(farmer),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  int _getFilterCount(String status) {
    final list = controller.filtered;
    switch (status) {
      case 'Verified':
        return list.where((f) => f.isActive && f.isVerified).length;
      case 'Pending':
        return list.where((f) => f.isActive && !f.isVerified).length;
      case 'Inactive':
        return list.where((f) => !f.isActive).length;
      default:
        return list.length;
    }
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
                Icons.agriculture_rounded,
                size: 40,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            Text(
              'No farmers found',
              style: AppTextStyles.sectionHeading,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.s),
            Text(
              'Try adjusting your search query or status filter.',
              style: AppTextStyles.bodyText.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.l),
            AppButton.small(
              label: 'Reset Filters',
              icon: Icons.refresh_rounded,
              onPressed: () {
                controller.search.value = '';
                _farmersStatusFilter.value = 'All';
              },
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

// ── Farmer Management Card Row Component ──────────────────────────────────────
class _FarmerManagementRow extends StatelessWidget {
  final FarmerModel farmer;
  final String marketName;
  final VoidCallback onVerify;
  final VoidCallback onToggleActive;
  final VoidCallback onViewDetails;

  const _FarmerManagementRow({
    required this.farmer,
    required this.marketName,
    required this.onVerify,
    required this.onToggleActive,
    required this.onViewDetails,
  });

  Widget _buildStatusChip() {
    if (!farmer.isActive) {
      return const AppChip.pill(
        label: 'Inactive',
        iconData: Icons.block_rounded,
        backgroundColor: Color(0xFFFFEBEE),
        textColor: AppColors.accentRed,
      );
    } else if (farmer.isVerified) {
      return const AppChip.pill(
        label: 'Verified',
        iconData: Icons.verified_rounded,
        backgroundColor: AppColors.chipHerbsBg,
        textColor: AppColors.primaryDark,
      );
    } else {
      return const AppChip.pill(
        label: 'Pending',
        iconData: Icons.hourglass_top_rounded,
        backgroundColor: Color(0xFFFFF3E0),
        textColor: Color(0xFFE65100),
      );
    }
  }

  Widget _farmerPlaceholder() {
    return Center(
      child: Icon(
        Icons.agriculture_rounded,
        size: 28,
        color: AppColors.primaryDark.withValues(alpha: 0.6),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppCard.list(
      onTap: onViewDetails,
      padding: const EdgeInsets.all(AppSpacing.l),
      children: [
        // ── Top Row: Photo + Name + Status Chip ──────────────────────────────
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Farmer Photo
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 52,
                height: 52,
                color: AppColors.chipHerbsBg,
                child: farmer.imageUrl.isNotEmpty
                    ? Image.network(
                        farmer.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _farmerPlaceholder(),
                      )
                    : _farmerPlaceholder(),
              ),
            ),
            const SizedBox(width: AppSpacing.m),

            // Business & Owner Names
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    farmer.businessName,
                    style: AppTextStyles.cardTitle.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(
                        Icons.person_outline_rounded,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          farmer.ownerName.isNotEmpty
                              ? farmer.ownerName
                              : 'Owner not specified',
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

            // Status Badge
            _buildStatusChip(),
          ],
        ),

        const SizedBox(height: AppSpacing.m),
        const Divider(color: AppColors.divider, height: 1),
        const SizedBox(height: AppSpacing.m),

        // ── Details Section: Market, Email, Join Date ────────────────────────
        if (marketName.isNotEmpty) ...[
          Row(
            children: [
              const Icon(
                Icons.storefront_outlined,
                size: 15,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Market: ',
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              Expanded(
                child: Text(
                  marketName,
                  style: AppTextStyles.bodyText.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
        ],

        if (farmer.email.isNotEmpty) ...[
          Row(
            children: [
              const Icon(
                Icons.email_outlined,
                size: 15,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  farmer.email,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
        ],

        // Join Date Row
        Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: 15,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              'Joined: ',
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              farmer.createdAt != null
                  ? '${farmer.createdAt!.day.toString().padLeft(2, "0")}/${farmer.createdAt!.month.toString().padLeft(2, "0")}/${farmer.createdAt!.year}'
                  : 'Sep 2026',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.m),
        const Divider(color: AppColors.divider, height: 1),
        const SizedBox(height: AppSpacing.s),

        // ── Actions Row: "Verify" / "Activate" / "View" ───────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Verify Action
            if (!farmer.isVerified && farmer.isActive) ...[
              AppTextButton(
                label: 'Verify',
                leadingIcon: Icons.verified_outlined,
                color: AppColors.primaryDark,
                onPressed: onVerify,
              ),
              const SizedBox(width: AppSpacing.s),
            ] else if (farmer.isVerified) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.chipHerbsBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 13,
                      color: AppColors.primaryDark,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Verified',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.s),
            ],

            // Activate / Deactivate Action
            AppTextButton(
              label: farmer.isActive ? 'Deactivate' : 'Activate',
              leadingIcon: farmer.isActive
                  ? Icons.block_outlined
                  : Icons.check_circle_outline_rounded,
              color: farmer.isActive ? AppColors.accentRed : AppColors.primaryDark,
              onPressed: onToggleActive,
            ),

            const SizedBox(width: AppSpacing.s),

            // View Details Action
            AppTextButton(
              label: 'View',
              leadingIcon: Icons.open_in_new_rounded,
              color: AppColors.textSecondary,
              onPressed: onViewDetails,
            ),
          ],
        ),
      ],
    );
  }
}
