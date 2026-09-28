import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/utils/helpers.dart';
import 'package:harvest_hub/app/core/widgets/app_widgets.dart';
import 'package:harvest_hub/app/core/theme/app_colors.dart';
import 'package:harvest_hub/app/core/theme/app_spacing.dart';
import 'package:harvest_hub/app/core/theme/app_radius.dart';
import 'package:harvest_hub/app/core/theme/app_text_styles.dart';
import 'package:harvest_hub/app/modules/admin/models/product_model.dart';
import 'package:harvest_hub/app/modules/admin/products/controllers/products_controller.dart';
import 'package:harvest_hub/app/modules/admin/widgets/admin_drawer.dart';

// ── Status filter chip definitions ────────────────────────────────────────────
const _kStatusFilters = ['All', 'Pending', 'Approved', 'Flagged'];

({Color bg, Color text, IconData icon}) _statusStyle(String status) {
  switch (status) {
    case 'Pending':
      return (
        bg: const Color(0xFFFFF3E0),
        text: const Color(0xFFE65100),
        icon: Icons.hourglass_top_rounded,
      );
    case 'Approved':
      return (
        bg: AppColors.chipHerbsBg,
        text: AppColors.primaryDark,
        icon: Icons.check_circle_outline_rounded,
      );
    case 'Flagged':
      return (
        bg: const Color(0xFFFFEBEE),
        text: AppColors.accentRed,
        icon: Icons.flag_outlined,
      );
    default:
      return (
        bg: AppColors.surfaceMuted,
        text: AppColors.textSecondary,
        icon: Icons.grid_view_rounded,
      );
  }
}

// Module-level reactive status filter – UI-only, no logic touched.
final _productsStatusFilter = 'All'.obs;

class ProductsView extends GetView<ProductsController> {
  const ProductsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceMuted,
      appBar: AppAppBar(
        titleText: 'Products',
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
          // ── Search + Category Bar ───────────────────────────────────────────
          Container(
            color: AppColors.surfaceWhite,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.l,
              AppSpacing.s,
              AppSpacing.l,
              AppSpacing.m,
            ),
            child: Obx(() {
              final names = ['All', ...controller.categories.map((c) => c.name)];
              final effectiveCat = names.contains(controller.categoryFilter.value)
                  ? controller.categoryFilter.value
                  : 'All';
              return Column(
                children: [
                  // Search
                  AppSearchBar(
                    hintText: 'Search by product or farmer...',
                    onChanged: (v) => controller.search.value = v,
                    onFilterTap: names.length > 1
                        ? () => _showCategorySheet(context, names)
                        : null,
                    isFilterActive: effectiveCat != 'All',
                  ),
                  if (effectiveCat != 'All') ...[
                    const SizedBox(height: AppSpacing.s),
                    Row(
                      children: [
                        AppChip.pill(
                          label: effectiveCat,
                          backgroundColor: AppColors.chipHerbsBg,
                          textColor: AppColors.primaryDark,
                          iconData: Icons.category_outlined,
                          onTap: () => controller.categoryFilter.value = 'All',
                          isSelected: true,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        AppIconButton(
                          icon: Icons.close,
                          size: 20,
                          iconSize: 14,
                          backgroundColor: AppColors.surfaceMuted,
                          iconColor: AppColors.textSecondary,
                          onTap: () => controller.categoryFilter.value = 'All',
                        ),
                      ],
                    ),
                  ],
                ],
              );
            }),
          ),

          // ── Status Filter Chips ─────────────────────────────────────────────
          Container(
            color: AppColors.surfaceWhite,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.l,
              0,
              AppSpacing.l,
              AppSpacing.m,
            ),
            child: Obx(() => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _kStatusFilters.map((s) {
                  final isSelected = _productsStatusFilter.value == s;
                  final style = _statusStyle(s);
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.s),
                    child: AppChip.pill(
                      label: s,
                      iconData: style.icon,
                      backgroundColor: isSelected ? style.bg : AppColors.surfaceMuted,
                      textColor: isSelected ? style.text : AppColors.textSecondary,
                      isSelected: isSelected,
                      onTap: () => _productsStatusFilter.value = s,
                    ),
                  );
                }).toList(),
              ),
            )),
          ),

          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: AppSpacing.s),

          // ── Product List ────────────────────────────────────────────────────
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
                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.m),
                itemBuilder: (_, i) => _ProductOversightRow(
                  product: list[i],
                  farmerName: controller.farmerName(list[i].farmerId),
                  statusFilter: _productsStatusFilter.value,
                  onView: () => controller.openDetails(list[i]),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ── Category Bottom Sheet ───────────────────────────────────────────────────
  void _showCategorySheet(BuildContext context, List<String> names) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.card)),
        ),
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
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
            const SizedBox(height: AppSpacing.l),
            Text('Filter by Category', style: AppTextStyles.sectionHeading),
            const SizedBox(height: AppSpacing.m),
            Wrap(
              spacing: AppSpacing.s,
              runSpacing: AppSpacing.s,
              children: names.map((n) {
                return Obx(() => AppChip.pill(
                  label: n,
                  backgroundColor: controller.categoryFilter.value == n
                      ? AppColors.chipHerbsBg
                      : AppColors.surfaceMuted,
                  textColor: controller.categoryFilter.value == n
                      ? AppColors.primaryDark
                      : AppColors.textSecondary,
                  isSelected: controller.categoryFilter.value == n,
                  iconData: n == 'All' ? Icons.grid_view_rounded : AppChip.getCategoryIcon(n),
                  onTap: () {
                    controller.categoryFilter.value = n;
                    Navigator.of(ctx).pop();
                  },
                ));
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.l),
          ],
        ),
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
              child: const Icon(Icons.inventory_2_outlined, size: 40, color: AppColors.primaryDark),
            ),
            const SizedBox(height: AppSpacing.l),
            Text('No products found', style: AppTextStyles.sectionHeading, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.s),
            Text(
              'Try adjusting your search or filter.',
              style: AppTextStyles.bodyText.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
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
            const Icon(Icons.wifi_off_rounded, size: 48, color: AppColors.textSecondary),
            const SizedBox(height: AppSpacing.m),
            Text(
              controller.error.value,
              style: AppTextStyles.bodyText.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.l),
            AppButton.small(label: 'Retry', icon: Icons.refresh, onPressed: controller.load),
          ],
        ),
      ),
    );
  }
}

// ── Product Oversight Row ─────────────────────────────────────────────────────
class _ProductOversightRow extends StatelessWidget {
  final ProductModel product;
  final String farmerName;
  final String statusFilter;
  final VoidCallback onView;

  const _ProductOversightRow({
    required this.product,
    required this.farmerName,
    required this.statusFilter,
    required this.onView,
  });

  // Derive a display status from the filter (UI-only — no logic touched)
  String get _displayStatus => statusFilter == 'All' ? 'Pending' : statusFilter;

  @override
  Widget build(BuildContext context) {
    final style = _statusStyle(_displayStatus);

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.m),
      onTap: onView,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top Row: thumbnail + info ───────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 64,
                  height: 64,
                  color: AppColors.surfaceMuted,
                  child: product.imageUrl.isNotEmpty
                      ? Image.network(
                          product.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _placeholder(),
                        )
                      : _placeholder(),
                ),
              ),
              const SizedBox(width: AppSpacing.m),

              // Name, farmer, category chip
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.itemName,
                      style: AppTextStyles.cardTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.person_outline, size: 13, color: AppColors.textSecondary),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            farmerName,
                            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s),
                    Wrap(
                      spacing: AppSpacing.xs,
                      children: [
                        if (product.category.isNotEmpty)
                          AppChip.pill(
                            label: product.category,
                            backgroundColor: AppChip.getCategoryBgColor(product.category),
                            textColor: AppColors.primaryDark,
                            iconData: AppChip.getCategoryIcon(product.category),
                          ),
                        AppChip.pill(
                          label: _displayStatus,
                          backgroundColor: style.bg,
                          textColor: style.text,
                          iconData: style.icon,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Price (top-right)
              Padding(
                padding: const EdgeInsets.only(left: AppSpacing.s),
                child: Text(
                  money(product.pricePerUnit),
                  style: AppTextStyles.priceText,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.m),
          const Divider(color: AppColors.divider, height: 1),
          const SizedBox(height: AppSpacing.s),

          // ── Action Row ──────────────────────────────────────────────────────
          Row(
            children: [
              // Stock badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: product.stockQty > 0 ? AppColors.chipHerbsBg : const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  product.stockQty > 0 ? 'Stock: ${product.stockQty}' : 'Out of stock',
                  style: AppTextStyles.caption.copyWith(
                    color: product.stockQty > 0 ? AppColors.primaryDark : AppColors.accentRed,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const Spacer(),

              // Moderation actions — UI only, logic untouched
              AppTextButton(
                label: 'Approve',
                leadingIcon: Icons.check_circle_outline_rounded,
                color: AppColors.primaryDark,
                onPressed: () {},
              ),
              const SizedBox(width: AppSpacing.s),
              AppTextButton(
                label: 'Reject',
                leadingIcon: Icons.cancel_outlined,
                color: AppColors.accentRed,
                onPressed: () {},
              ),
              const SizedBox(width: AppSpacing.s),
              AppTextButton(
                label: 'View',
                leadingIcon: Icons.open_in_new_rounded,
                onPressed: onView,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _placeholder() => Center(
    child: Icon(
      Icons.eco_outlined,
      size: 28,
      color: AppColors.primary.withValues(alpha: 0.35),
    ),
  );
}
