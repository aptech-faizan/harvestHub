import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/models/farmer_product_model.dart';
import '../../farmer_theme.dart';
import '../../widgets/farmer_widgets.dart';
import '../controllers/inventory_controller.dart';

/// Modern Inventory view featuring a low-stock alert banner,
/// colored stock progress indicators, and +/- quick stepper controls.
class InventoryView extends GetView<InventoryController> {
  const InventoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FarmerColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: Semantics(
          button: true,
          label: 'Back',
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 20, color: FarmerColors.text),
            onPressed: () => Get.back(),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Inventory Manager',
              style: TextStyle(
                color: FarmerColors.text,
                fontSize: 19,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
            Obx(() => Text(
                  '${controller.products.length} products tracked',
                  style: FarmerTextStyles.caption.copyWith(
                    color: FarmerColors.muted,
                  ),
                )),
          ],
        ),
        actions: [
          Semantics(
            button: true,
            label: 'Refresh inventory',
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: FarmerColors.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.refresh_rounded,
                    color: FarmerColors.primary, size: 20),
              ),
              onPressed: controller.loadInventory,
              tooltip: 'Refresh',
            ),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: FarmerColors.border, height: 1),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const CardListShimmer(count: 5);
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return _InventoryErrorState(
            message: controller.errorMessage.value,
            onRetry: controller.loadInventory,
          );
        }

        if (controller.products.isEmpty) {
          return const EmptyState(
            icon: Icons.inventory_2_outlined,
            title: 'No Inventory Items',
            message: 'Add products to your catalog to manage stock levels here.',
          );
        }

        // Count low-stock and out-of-stock items
        final outOfStockCount = controller.products
            .where((p) => p.isOutOfStock || p.stockQty <= 0)
            .length;
        final lowStockCount = controller.products
            .where((p) => !p.isOutOfStock && p.stockQty > 0 && p.stockQty <= 5)
            .length;

        return RefreshIndicator(
          color: FarmerColors.primary,
          backgroundColor: Colors.white,
          onRefresh: controller.loadInventory,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              // 1. Low-Stock Warning Banner
              _StockWarningBanner(
                outOfStockCount: outOfStockCount,
                lowStockCount: lowStockCount,
              ),
              const SizedBox(height: 14),

              // 2. Legend Row
              const _InventoryLegendRow(),
              const SizedBox(height: 14),

              // 3. Product Inventory Cards
              ...List.generate(controller.products.length, (index) {
                final product = controller.products[index];
                return StaggeredFadeSlide(
                  index: index,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _InventoryItemCard(
                      product: product,
                      controller: controller,
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      }),
    );
  }
}

// ── Stock Warning Banner ──────────────────────────────────────────────────────

class _StockWarningBanner extends StatelessWidget {
  final int outOfStockCount;
  final int lowStockCount;

  const _StockWarningBanner({
    required this.outOfStockCount,
    required this.lowStockCount,
  });

  @override
  Widget build(BuildContext context) {
    final hasIssues = outOfStockCount > 0 || lowStockCount > 0;

    if (!hasIssues) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: FarmerColors.inStockBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: FarmerColors.primary.withValues(alpha: 0.25),
            width: 1,
          ),
        ),
        child: Row(
          children: const [
            Icon(Icons.check_circle_rounded,
                color: FarmerColors.primary, size: 22),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'All stock levels are optimal! No urgent restock needed.',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: FarmerColors.primaryDark,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final isSevere = outOfStockCount > 0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isSevere ? FarmerColors.errorBg : FarmerColors.statusPendingBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isSevere ? FarmerColors.error : FarmerColors.accent)
              .withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isSevere ? Icons.warning_rounded : Icons.info_outline_rounded,
            color: isSevere ? FarmerColors.error : FarmerColors.accent,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isSevere ? 'Urgent Restock Required' : 'Low Stock Warning',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: isSevere ? FarmerColors.error : FarmerColors.lowStock,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${outOfStockCount > 0 ? '$outOfStockCount item(s) out of stock. ' : ''}'
                  '${lowStockCount > 0 ? '$lowStockCount item(s) running low (≤5).' : ''}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isSevere ? const Color(0xFF6B2424) : const Color(0xFF664119),
                    fontWeight: FontWeight.w500,
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

// ── Inventory Legend Row ──────────────────────────────────────────────────────

class _InventoryLegendRow extends StatelessWidget {
  const _InventoryLegendRow();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: FarmerColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          _LegendItem(color: FarmerColors.outOfStock, label: 'Out of Stock'),
          _LegendItem(color: FarmerColors.lowStock, label: 'Low Stock (≤5)'),
          _LegendItem(color: FarmerColors.inStock, label: 'In Stock'),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: FarmerColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ── Inventory Item Card with Colored Stock Progress Bar ───────────────────────

class _InventoryItemCard extends StatefulWidget {
  final FarmerProduct product;
  final InventoryController controller;

  const _InventoryItemCard({
    required this.product,
    required this.controller,
  });

  @override
  State<_InventoryItemCard> createState() => _InventoryItemCardState();
}

class _InventoryItemCardState extends State<_InventoryItemCard> {
  @override
  Widget build(BuildContext context) {
    final stockCtrl = widget.controller.stockControllers[widget.product.id] ??
        TextEditingController(text: widget.product.stockQty.toString());

    // Calculate progress ratio (cap at 30 units for display calculation)
    final double maxRef = 30.0;
    final double progress = (widget.product.stockQty / maxRef).clamp(0.0, 1.0);

    // Dynamic color depending on stock quantity
    Color barColor;
    if (widget.product.isOutOfStock || widget.product.stockQty <= 0) {
      barColor = FarmerColors.outOfStock;
    } else if (widget.product.stockQty <= 5) {
      barColor = FarmerColors.lowStock;
    } else {
      barColor = FarmerColors.inStock;
    }

    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Product thumbnail + Name + Stock Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ProductImagePlaceholder(
                imageUrl: widget.product.imageUrl,
                category: widget.product.category,
                width: 44,
                height: 44,
                borderRadius: 10,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: FarmerColors.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${widget.product.category} • ${FarmerCurrency.format(widget.product.pricePerUnit)}/${widget.product.unit}',
                      style: FarmerTextStyles.caption.copyWith(
                        color: FarmerColors.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              StatusChip.stockBadge(
                stockQty: widget.product.stockQty,
                isOutOfStock: widget.product.isOutOfStock,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Colored Stock Progress Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Current Stock: ${widget.product.stockQty} ${widget.product.unit}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: barColor,
                    ),
                  ),
                  Text(
                    '${(progress * 100).toInt()}% Capacity',
                    style: FarmerTextStyles.caption.copyWith(
                      color: FarmerColors.muted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: const Color(0xFFE9F0E6),
                  valueColor: AlwaysStoppedAnimation<Color>(barColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Quick-edit stepper and Save Button (Overflow-safe on 320px)
          Row(
            children: [
              // Stepper Controls
              _StepperButton(
                icon: Icons.remove_rounded,
                tooltip: 'Decrease stock',
                onTap: () {
                  widget.controller.decrement(widget.product);
                  setState(() {});
                },
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 58,
                height: 38,
                child: TextField(
                  controller: stockCtrl,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: FarmerColors.text,
                  ),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    filled: true,
                    fillColor: FarmerColors.surfaceMuted,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: FarmerColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: FarmerColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                          color: FarmerColors.primary, width: 1.5),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _StepperButton(
                icon: Icons.add_rounded,
                tooltip: 'Increase stock',
                onTap: () {
                  widget.controller.increment(widget.product);
                  setState(() {});
                },
              ),
              const SizedBox(width: 8),
              Text(
                widget.product.unit,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: FarmerColors.muted,
                ),
              ),
              const Spacer(),

              // Save button
              SizedBox(
                height: 38,
                child: ElevatedButton.icon(
                  onPressed: () => widget.controller.updateStock(widget.product),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FarmerColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.check_rounded, size: 16),
                  label: const Text(
                    'Save',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  const _StepperButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: FarmerColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: FarmerColors.primary.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Icon(icon, size: 18, color: FarmerColors.primaryDark),
          ),
        ),
      ),
    );
  }
}

// ── Inventory Error State ─────────────────────────────────────────────────────

class _InventoryErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _InventoryErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: FarmerColors.errorBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline_rounded,
                  size: 48, color: FarmerColors.error),
            ),
            const SizedBox(height: 16),
            const Text(
              'Failed to Load Inventory',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: FarmerColors.text,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: FarmerColors.muted),
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: 'Retry',
              icon: Icons.refresh_rounded,
              onPressed: onRetry,
              width: 140,
              height: 44,
            ),
          ],
        ),
      ),
    );
  }
}
