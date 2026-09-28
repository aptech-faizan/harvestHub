import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/theme/app_colors.dart';
import 'package:harvest_hub/app/core/theme/app_spacing.dart';
import 'package:harvest_hub/app/core/theme/app_text_styles.dart';
import 'package:harvest_hub/app/core/widgets/app_shimmer.dart';
import 'package:harvest_hub/app/core/widgets/app_widgets.dart';
import 'package:harvest_hub/app/routes/app_routes.dart';
import '../../../../data/models/farmer_model.dart';
import '../controllers/farmers_controller.dart';

/// Farmers List screen revamped per UI Master Rules and Design Specification.
/// Structure:
/// AppAppBar → AppSearchBar (search farmers) → AppChip row (location/category filters)
/// → vertical list of AppCard.list items — each with farmer avatar, name, rating,
/// location/market line, and a Follow/Following AppButton.small.
class FarmersView extends GetView<FarmersController> {
  const FarmersView({super.key});

  // Filter chip labels for browsing farmers by category
  static const List<String> _filterLabels = [
    'All',
    'Near Me',
    'Top Rated',
    'Organic',
    'Fruits',
    'Vegetables',
    'Grains',
  ];

  @override
  Widget build(BuildContext context) {
    // Local reactive filter index — UI only, no business logic
    final selectedFilter = 0.obs;
    // Local search text — UI only, drives display filter
    final searchQuery = ''.obs;
    final searchController = TextEditingController();

    return Scaffold(
      backgroundColor: AppColors.surfaceWhite,
      appBar: const AppAppBar(titleText: 'Our Farmers'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Search Bar ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenHorizontalPadding,
              AppSpacing.m,
              AppSpacing.screenHorizontalPadding,
              0,
            ),
            child: AppSearchBar(
              controller: searchController,
              hintText: 'Search farmers by name or market...',
              onChanged: (q) => searchQuery.value = q.trim().toLowerCase(),
            ),
          ),

          // ── Filter Chips Row ──────────────────────────────────────────────
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontalPadding,
                vertical: AppSpacing.s,
              ),
              itemCount: _filterLabels.length,
              separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.s),
              itemBuilder: (context, index) {
                return Obx(() => AppChip.pill(
                      label: _filterLabels[index],
                      backgroundColor: selectedFilter.value == index
                          ? AppColors.primaryDark
                          : AppColors.surfaceMuted,
                      textColor: selectedFilter.value == index
                          ? Colors.white
                          : AppColors.textPrimary,
                      isSelected: selectedFilter.value == index,
                      onTap: () => selectedFilter.value = index,
                    ));
              },
            ),
          ),

          // ── Section Header + Count ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenHorizontalPadding,
              AppSpacing.s,
              AppSpacing.screenHorizontalPadding,
              AppSpacing.xs,
            ),
            child: Obx(() {
              final count = _filteredFarmers(
                controller.farmers,
                searchQuery.value,
              ).length;
              return AppText.caption(
                '$count farmer${count == 1 ? '' : 's'} found',
                color: AppColors.textSecondary,
              );
            }),
          ),

          // ── Farmer List ───────────────────────────────────────────────────
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const ShimmerListSkeleton();
              }

              final farmers = _filteredFarmers(
                controller.farmers,
                searchQuery.value,
              );

              if (farmers.isEmpty) {
                return _EmptyState(
                  hasQuery: searchQuery.value.isNotEmpty,
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenHorizontalPadding,
                  AppSpacing.xs,
                  AppSpacing.screenHorizontalPadding,
                  AppSpacing.xxl,
                ),
                itemCount: farmers.length,
                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.m),
                itemBuilder: (context, index) {
                  final farmer = farmers[index];
                  return Obx(() => _FarmerCard(
                        farmer: farmer,
                        isFollowed: controller.isFollowed(farmer.id),
                        onFollow: () => controller.toggleFollow(farmer.id),
                        onTap: () => Get.toNamed(
                          Routes.customerFarmerDetails,
                          arguments: farmer,
                        ),
                      ));
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  /// Simple in-widget display filter — only filters the displayed list,
  /// does NOT touch the controller data or any API calls.
  List<FarmerModel> _filteredFarmers(
    List<FarmerModel> all,
    String query,
  ) {
    if (query.isEmpty) return all;
    return all.where((f) {
      return f.businessName.toLowerCase().contains(query) ||
          f.marketName.toLowerCase().contains(query) ||
          f.description.toLowerCase().contains(query);
    }).toList();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private: Farmer Card  (AppCard.list with avatar, name, rating, follow)
// ─────────────────────────────────────────────────────────────────────────────
class _FarmerCard extends StatelessWidget {
  final FarmerModel farmer;
  final bool isFollowed;
  final VoidCallback onFollow;
  final VoidCallback onTap;

  const _FarmerCard({
    required this.farmer,
    required this.isFollowed,
    required this.onFollow,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Farmer Avatar ─────────────────────────────────────────────────
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.chipHerbsBg,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.divider, width: 1.5),
            ),
            child: const Center(
              child: Icon(
                Icons.storefront_outlined,
                size: 28,
                color: AppColors.primaryDark,
              ),
            ),
          ),

          const SizedBox(width: AppSpacing.m),

          // ── Name, Rating, Market ──────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Business name
                AppText.cardTitle(
                  farmer.businessName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 3),

                // Rating row
                if (farmer.rating > 0)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star,
                        size: 13,
                        color: AppColors.ratingStar,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        farmer.rating.toStringAsFixed(1),
                        style: AppTextStyles.caption.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      AppText.caption(
                        '• Verified Farmer',
                        color: AppColors.textSecondary,
                      ),
                    ],
                  )
                else
                  AppText.caption(
                    'Verified Farmer',
                    color: AppColors.textSecondary,
                  ),

                // Market / Location line
                if (farmer.marketName.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 13,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 3),
                      Flexible(
                        child: AppText.caption(
                          farmer.marketName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(width: AppSpacing.s),

          // ── Follow / Following Button ─────────────────────────────────────
          AppButton.small(
            label: isFollowed ? 'Following' : 'Follow',
            icon: isFollowed ? Icons.check : Icons.add,
            backgroundColor: isFollowed
                ? AppColors.chipHerbsBg
                : AppColors.primaryButton,
            textColor: isFollowed ? AppColors.primaryDark : Colors.white,
            onPressed: onFollow,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private: Empty state widget
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final bool hasQuery;
  const _EmptyState({required this.hasQuery});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasQuery ? Icons.search_off : Icons.storefront_outlined,
              size: 64,
              color: AppColors.primary.withValues(alpha: 0.30),
            ),
            const SizedBox(height: AppSpacing.l),
            AppText.sectionHeading(
              hasQuery ? 'No farmers found' : 'No farmers yet',
              color: AppColors.textPrimary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.s),
            AppText.body(
              hasQuery
                  ? 'Try a different name or market to find farmers.'
                  : 'Check back soon — local farmers will be listed here.',
              color: AppColors.textSecondary,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
