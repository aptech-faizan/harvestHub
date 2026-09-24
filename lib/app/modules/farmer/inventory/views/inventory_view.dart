import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/models/farmer_product_model.dart';
import '../../farmer_theme.dart';
import '../controllers/inventory_controller.dart';

/// Inventory screen: quick stock update with highlight for low/out-of-stock.
class InventoryView extends GetView<InventoryController> {
  const InventoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FarmerColors.background,
      appBar: AppBar(
        backgroundColor: FarmerColors.primary,
        title: const Text('Inventory',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: controller.loadInventory,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
              child:
                  CircularProgressIndicator(color: FarmerColors.primary));
        }
        if (controller.errorMessage.value.isNotEmpty) {
          return _ErrorState(
              message: controller.errorMessage.value,
              onRetry: controller.loadInventory);
        }
        if (controller.products.isEmpty) {
          return const _EmptyState();
        }

        // Legend row
        return Column(
          children: [
            _LegendRow(),
            Expanded(
              child: RefreshIndicator(
                color: FarmerColors.primary,
                onRefresh: controller.loadInventory,
                child: ListView.separated(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: controller.products.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) =>
                      _InventoryCard(product: controller.products[i]),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

// ── Legend ────────────────────────────────────────────────────────────────────

class _LegendRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(child: _LegendDot(color: FarmerColors.outOfStock, label: 'Out of Stock')),
          Expanded(child: _LegendDot(color: FarmerColors.lowStock, label: 'Low Stock (≤5)')),
          Expanded(child: _LegendDot(color: FarmerColors.statusCompleted, label: 'In Stock')),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            style: const TextStyle(fontSize: 11),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ── Inventory card ────────────────────────────────────────────────────────────

class _InventoryCard extends StatefulWidget {
  const _InventoryCard({required this.product});
  final FarmerProduct product;

  @override
  State<_InventoryCard> createState() => _InventoryCardState();
}

class _InventoryCardState extends State<_InventoryCard> {
  late final InventoryController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<InventoryController>();
  }

  Color get _borderColor {
    if (widget.product.isOutOfStock) return FarmerColors.outOfStock;
    if (widget.product.stockQty <= 5) return FarmerColors.lowStock;
    return FarmerColors.secondary;
  }

  Color get _bgColor {
    if (widget.product.isOutOfStock) {
      return FarmerColors.outOfStock.withValues(alpha: 0.05);
    }
    if (widget.product.stockQty <= 5) {
      return FarmerColors.lowStock.withValues(alpha: 0.05);
    }
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    final stockCtrl =
        _ctrl.stockControllers[widget.product.id] ?? TextEditingController();

    return Container(
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product name + category
          Row(
            children: [
              Expanded(
                child: Text(widget.product.name,
                    style: FarmerTextStyles.subheading
                        .copyWith(color: const Color(0xFF1B1B1B))),
              ),
              // Stock status chip
              _StatusChip(product: widget.product),
            ],
          ),
          const SizedBox(height: 4),
          Text(widget.product.category, style: FarmerTextStyles.caption),
          const SizedBox(height: 12),

          // Quick-edit stock row
          Row(
            children: [
              const Text('Stock:', style: FarmerTextStyles.body),
              const SizedBox(width: 6),
              // Decrement
              _CircleIconButton(
                icon: Icons.remove,
                onTap: () {
                  _ctrl.decrement(widget.product);
                  setState(() {});
                },
              ),
              const SizedBox(width: 6),
              // Quantity field
              SizedBox(
                width: 54,
                child: TextField(
                  controller: stockCtrl,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 4, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          const BorderSide(color: FarmerColors.secondary),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          const BorderSide(color: FarmerColors.primary),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              // Increment
              _CircleIconButton(
                icon: Icons.add,
                onTap: () {
                  _ctrl.increment(widget.product);
                  setState(() {});
                },
              ),
              const SizedBox(width: 6),
              Text(widget.product.unit,
                  style: FarmerTextStyles.caption
                      .copyWith(fontWeight: FontWeight.w600)),
              const Spacer(),
              // Save button
              SizedBox(
                height: 34,
                child: ElevatedButton(
                  onPressed: () => _ctrl.updateStock(widget.product),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FarmerColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.product});
  final FarmerProduct product;

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    if (product.isOutOfStock) {
      color = FarmerColors.outOfStock;
      label = 'Out of Stock';
    } else if (product.stockQty <= 5) {
      color = FarmerColors.lowStock;
      label = 'Low Stock';
    } else {
      color = FarmerColors.statusCompleted;
      label = 'In Stock';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: FarmerColors.primary.withValues(alpha: 0.1),
          border: Border.all(color: FarmerColors.primary),
        ),
        child: Icon(icon, size: 18, color: FarmerColors.primary),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inventory_2_outlined,
              size: 72, color: FarmerColors.secondary),
          SizedBox(height: 12),
          Text('No inventory items', style: TextStyle(fontSize: 17)),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 56, color: FarmerColors.error),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
                backgroundColor: FarmerColors.primary,
                foregroundColor: Colors.white),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
