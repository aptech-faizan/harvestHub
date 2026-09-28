import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/theme/app_colors.dart';
import 'package:harvest_hub/app/core/theme/app_spacing.dart';
import 'package:harvest_hub/app/core/theme/app_text_styles.dart';
import 'package:harvest_hub/app/core/utils/helpers.dart';
import 'package:harvest_hub/app/core/widgets/app_app_bar.dart';
import 'package:harvest_hub/app/core/widgets/app_button.dart';
import 'package:harvest_hub/app/core/widgets/app_chip.dart';
import 'package:harvest_hub/app/core/widgets/app_icon.dart';
import 'package:harvest_hub/app/core/widgets/app_text_field.dart';
import 'package:harvest_hub/app/core/widgets/state_view.dart';
import 'package:harvest_hub/app/data/models/product_model.dart';
import 'package:harvest_hub/app/modules/farmer/products/controllers/farmer_products_controller.dart';

class FarmerProductsView extends GetView<FarmerProductsController> {
  const FarmerProductsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceMuted,
      appBar: AppAppBar(
        titleText: 'My Products',
        actions: [
          
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.textSecondary),
            tooltip: 'Refresh',
            onPressed: controller.load,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.openForm,
        tooltip: 'Add Product',
        child: const Icon(Icons.add_rounded),
      ),
      body: Column(
        children: [
          // ── Search bar ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.l,
              AppSpacing.m,
              AppSpacing.l,
              AppSpacing.s,
            ),
            child: AppSearchBar(
              hintText: 'Search by name or category…',
              onChanged: (v) => controller.search.value = v,
            ),
          ),

          // ── Product grid ──────────────────────────────────────────────
          Expanded(
            child: Obx(() {
              final list = controller.filtered;
              return StateView(
                isLoading: controller.isLoading.value,
                error: controller.error.value,
                isEmpty: list.isEmpty,
                emptyText: 'No products yet.\nTap "Add Product" to list your first item.',
                onRetry: controller.load,
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.l,
                    AppSpacing.s,
                    AppSpacing.l,
                    AppSpacing.l,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: AppSpacing.m,
                    mainAxisSpacing: AppSpacing.m,
                    childAspectRatio: 0.55,
                  ),
                  itemCount: list.length,
                  itemBuilder: (_, i) => _ProductCard(
                    product: list[i],
                    onEdit: () => controller.openForm(list[i]),
                    onDelete: () => controller.delete(list[i]),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Product card (AppCard.media-style)
// ---------------------------------------------------------------------------
class _ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProductCard({
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final outOfStock = product.stockQty <= 0;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Product image ───────────────────────────────────────────
          Stack(
            children: [
              Container(
                height: 120,
                width: double.infinity,
                color: AppColors.surfaceMuted,
                child: product.imageUrl.isNotEmpty
                    ? Image.network(
                        product.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _imageFallback(),
                      )
                    : _imageFallback(),
              ),
              // Out-of-stock badge
              if (outOfStock)
                Positioned(
                  top: AppSpacing.s,
                  left: AppSpacing.s,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.accentRed,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Out of stock',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // ── Content ─────────────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.s),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category chip
                  if (product.categoryName.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: AppChip.pill(
                        label: product.categoryName,
                        backgroundColor:
                            AppChip.getCategoryBgColor(product.categoryName),
                      ),
                    ),

                  // Product name
                  Text(
                    product.itemName,
                    style: AppTextStyles.cardTitle.copyWith(fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const Spacer(),

                  // Price
                  Text(
                    '${money(product.pricePerUnit)} / ${product.unit}',
                    style: AppTextStyles.priceText.copyWith(fontSize: 13),
                  ),
                  const SizedBox(height: 4),

                  // Stock chip
                  AppChip.pill(
                    label: outOfStock
                        ? 'Out of stock'
                        : 'Stock: ${product.stockQty}',
                    backgroundColor: outOfStock
                        ? const Color(0xFFFFEBEE)
                        : AppColors.chipHerbsBg,
                    textColor: outOfStock
                        ? AppColors.accentRed
                        : AppColors.primaryDark,
                  ),

                  const SizedBox(height: AppSpacing.s),

                  // Action row
                  Row(
                    children: [
                      Expanded(
                        child: AppButton.small(
                          label: 'Edit',
                          icon: Icons.edit_rounded,
                          onPressed: onEdit,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      AppIconButton(
                        icon: Icons.delete_outline_rounded,
                        onTap: onDelete,
                        size: 34,
                        iconSize: 18,
                        backgroundColor: const Color(0xFFFFEBEE),
                        iconColor: AppColors.accentRed,
                        tooltip: 'Delete',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imageFallback() {
    return Center(
      child: Icon(
        Icons.eco_outlined,
        size: 36,
        color: AppColors.primary.withValues(alpha: 0.35),
      ),
    );
  }
}
