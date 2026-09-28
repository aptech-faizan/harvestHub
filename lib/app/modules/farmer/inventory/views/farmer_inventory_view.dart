import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/theme/app_colors.dart';
import 'package:harvest_hub/app/core/theme/app_radius.dart';
import 'package:harvest_hub/app/core/theme/app_spacing.dart';
import 'package:harvest_hub/app/core/theme/app_text_styles.dart';
import 'package:harvest_hub/app/core/widgets/app_app_bar.dart';
import 'package:harvest_hub/app/core/widgets/app_chip.dart';
import 'package:harvest_hub/app/core/widgets/app_section_header.dart';
import 'package:harvest_hub/app/core/widgets/app_text_field.dart';
import 'package:harvest_hub/app/core/widgets/state_view.dart';
import 'package:harvest_hub/app/data/models/product_model.dart';
import 'package:harvest_hub/app/modules/farmer/inventory/controllers/farmer_inventory_controller.dart';

class FarmerInventoryView extends GetView<FarmerInventoryController> {
  const FarmerInventoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final searchCtrl = TextEditingController();
    final search = ''.obs;

    return Scaffold(
      backgroundColor: AppColors.surfaceMuted,
      appBar: AppAppBar(
        titleText: 'Inventory',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded,
                color: AppColors.textSecondary),
            tooltip: 'Refresh',
            onPressed: controller.load,
          ),
        ],
      ),
      body: Obx(() {
        return StateView(
          isLoading: controller.isLoading.value,
          error: controller.error.value,
          isEmpty: controller.products.isEmpty,
          emptyText:
              'No products to manage.\nAdd products first from the Products screen.',
          onRetry: controller.load,
          child: Column(
            children: [
              // ── Search bar ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.l,
                  AppSpacing.m,
                  AppSpacing.l,
                  AppSpacing.s,
                ),
                child: AppSearchBar(
                  controller: searchCtrl,
                  hintText: 'Search products…',
                  onChanged: (v) => search.value = v.toLowerCase().trim(),
                ),
              ),

              // ── Threshold info pill ─────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.l,
                  vertical: AppSpacing.xs,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.warning_amber_rounded,
                              size: 14, color: AppColors.accentOrange),
                          const SizedBox(width: 4),
                          Text(
                            'Low-stock threshold: ${controller.threshold} units',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.accentOrange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xs),

              // ── Inventory list ──────────────────────────────────────
              Expanded(
                child: Obx(() {
                  final q = search.value;
                  final allProducts = controller.products.where((p) {
                    if (q.isEmpty) return true;
                    return p.itemName.toLowerCase().contains(q) ||
                        p.categoryName.toLowerCase().contains(q);
                  }).toList();

                  // Sort: out-of-stock first, then low-stock, then rest
                  allProducts.sort((a, b) {
                    int level(ProductModel p) {
                      if (p.stockQty <= 0) return 0;
                      if (p.stockQty <= controller.threshold) return 1;
                      return 2;
                    }

                    return level(a).compareTo(level(b));
                  });

                  if (allProducts.isEmpty) {
                    return const Center(
                      child: Text(
                        'No products match your search.',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: controller.load,
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.l,
                        AppSpacing.xs,
                        AppSpacing.l,
                        AppSpacing.l,
                      ),
                      itemCount: allProducts.length + 1,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.s),
                      itemBuilder: (_, i) {
                        if (i == 0) {
                          // Section summary header
                          return _SummaryRow(controller: controller);
                        }
                        final p = allProducts[i - 1];
                        return _InventoryRow(
                          product: p,
                          threshold: controller.threshold,
                          onDecrement: () =>
                              controller.setStock(p, p.stockQty - 1),
                          onIncrement: () =>
                              controller.setStock(p, p.stockQty + 1),
                          onEdit: () => controller.promptStock(p),
                        );
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      }),
    );
  }
}

// ---------------------------------------------------------------------------
// Summary row (out-of-stock / low-stock count chips)
// ---------------------------------------------------------------------------
class _SummaryRow extends StatelessWidget {
  final FarmerInventoryController controller;

  const _SummaryRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    final zeroCount = controller.zeroStock.length;
    final lowCount = controller.lowStock.length;

    if (zeroCount == 0 && lowCount == 0) {
      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.xs),
        child: AppSectionHeader(
          title: 'All Products',
          actionTitle: '${controller.products.length} items',
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionHeader(
            title: 'All Products',
            actionTitle: '${controller.products.length} items',
          ),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.s,
            children: [
              if (zeroCount > 0)
                AppChip.pill(
                  label: '$zeroCount Out of Stock',
                  backgroundColor: const Color(0xFFFFEBEE),
                  textColor: AppColors.accentRed,
                  iconData: Icons.block_rounded,
                ),
              if (lowCount > 0)
                AppChip.pill(
                  label: '$lowCount Low Stock',
                  backgroundColor: const Color(0xFFFFF3E0),
                  textColor: AppColors.accentOrange,
                  iconData: Icons.warning_amber_rounded,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Individual inventory row card
// ---------------------------------------------------------------------------
class _InventoryRow extends StatelessWidget {
  final ProductModel product;
  final int threshold;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final VoidCallback onEdit;

  const _InventoryRow({
    required this.product,
    required this.threshold,
    required this.onDecrement,
    required this.onIncrement,
    required this.onEdit,
  });

  /// Returns (label, bgColor, textColor) for the stock-level chip
  ({String label, Color bg, Color text}) _stockLevel() {
    if (product.stockQty <= 0) {
      return (
        label: 'Out of Stock',
        bg: const Color(0xFFFFEBEE),
        text: AppColors.accentRed,
      );
    }
    if (product.stockQty <= threshold) {
      return (
        label: 'Low Stock',
        bg: const Color(0xFFFFF3E0),
        text: AppColors.accentOrange,
      );
    }
    return (
      label: 'In Stock',
      bg: AppColors.chipHerbsBg,
      text: AppColors.primaryDark,
    );
  }

  @override
  Widget build(BuildContext context) {
    final level = _stockLevel();
    final isOut = product.stockQty <= 0;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: AppRadius.cardRadius,
        border: Border.all(
          color: isOut
              ? const Color(0xFFFFCDD2)
              : product.stockQty <= threshold
                  ? const Color(0xFFFFE0B2)
                  : AppColors.divider,
          width: 1.0,
        ),
        boxShadow: AppRadius.cardElevation,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Row(
          children: [
            // ── Product thumbnail ───────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 52,
                height: 52,
                color: AppColors.surfaceMuted,
                child: product.imageUrl.isNotEmpty
                    ? Image.network(
                        product.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _fallbackIcon(),
                      )
                    : _fallbackIcon(),
              ),
            ),
            const SizedBox(width: AppSpacing.m),

            // ── Name + category + stock chip ────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.itemName,
                    style: AppTextStyles.cardTitle.copyWith(fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  if (product.categoryName.isNotEmpty)
                    Text(
                      product.categoryName,
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 6),
                  // Stock level chip
                  AppChip.pill(
                    label: level.label,
                    backgroundColor: level.bg,
                    textColor: level.text,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.s),

            // ── Stock stepper + qty + edit ──────────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Current quantity display
                Text(
                  '${product.stockQty} ${product.unit}',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                // +/- stepper row
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _StepButton(
                      icon: Icons.remove_rounded,
                      onTap: product.stockQty > 0 ? onDecrement : null,
                      color: AppColors.accentRed,
                      bg: const Color(0xFFFFEBEE),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    _StepButton(
                      icon: Icons.add_rounded,
                      onTap: onIncrement,
                      color: AppColors.primaryDark,
                      bg: AppColors.chipHerbsBg,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    // Edit / set exact value
                    _StepButton(
                      icon: Icons.edit_rounded,
                      onTap: onEdit,
                      color: AppColors.textSecondary,
                      bg: AppColors.surfaceMuted,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _fallbackIcon() {
    return Center(
      child: Icon(
        Icons.eco_outlined,
        size: 26,
        color: AppColors.primary.withValues(alpha: 0.35),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Small square step button (+, -, edit)
// ---------------------------------------------------------------------------
class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color color;
  final Color bg;

  const _StepButton({
    required this.icon,
    required this.onTap,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: onTap == null ? AppColors.surfaceMuted : bg,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 32,
          height: 32,
          child: Center(
            child: Icon(
              icon,
              size: 16,
              color: onTap == null ? AppColors.textDisabled : color,
            ),
          ),
        ),
      ),
    );
  }
}
