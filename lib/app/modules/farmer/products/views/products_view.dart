import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/models/farmer_product_model.dart';
import '../../farmer_theme.dart';
import '../controllers/products_controller.dart';
import 'product_form_view.dart';

/// Displays all products for the farmer with load / error / empty states.
class ProductsView extends GetView<ProductsController> {
  const ProductsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FarmerColors.background,
      appBar: AppBar(
        backgroundColor: FarmerColors.primary,
        title: const Text(
          'My Products',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Refresh',
            onPressed: controller.loadProducts,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          controller.prepareForAdd();
          Get.to(() => const ProductFormView(),
              transition: Transition.rightToLeft);
        },
        backgroundColor: FarmerColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label:
            const Text('Add Product', style: TextStyle(color: Colors.white)),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: FarmerColors.primary),
          );
        }
        if (controller.errorMessage.value.isNotEmpty) {
          return _ErrorState(
            message: controller.errorMessage.value,
            onRetry: controller.loadProducts,
          );
        }
        if (controller.products.isEmpty) {
          return const _EmptyState();
        }
        return RefreshIndicator(
          color: FarmerColors.primary,
          onRefresh: controller.loadProducts,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: controller.products.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) =>
                _ProductCard(product: controller.products[i]),
          ),
        );
      }),
    );
  }
}

// ── Product card ─────────────────────────────────────────────────────────────

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});
  final FarmerProduct product;

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ProductsController>();
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product thumbnail / icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: FarmerColors.background,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: FarmerColors.secondary, width: 1),
              ),
              child: product.imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(product.imageUrl!, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.image_not_supported,
                                  color: FarmerColors.secondary)),
                    )
                  : const Icon(Icons.eco,
                      size: 36, color: FarmerColors.secondary),
            ),
            const SizedBox(width: 14),
            // Product details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name,
                      style: FarmerTextStyles.subheading
                          .copyWith(color: const Color(0xFF1B1B1B))),
                  const SizedBox(height: 2),
                  Text(product.category, style: FarmerTextStyles.caption),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        'PKR ${product.pricePerUnit.toStringAsFixed(0)}/${product.unit}',
                        style: FarmerTextStyles.price,
                      ),
                      const SizedBox(width: 12),
                      _StockBadge(product: product),
                    ],
                  ),
                ],
              ),
            ),
            // Action buttons
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ActionIconButton(
                  icon: Icons.edit_outlined,
                  color: FarmerColors.primary,
                  tooltip: 'Edit',
                  onTap: () {
                    ctrl.prepareForEdit(product);
                    Get.to(() => const ProductFormView(),
                        transition: Transition.rightToLeft);
                  },
                ),
                const SizedBox(height: 4),
                _ActionIconButton(
                  icon: Icons.delete_outline,
                  color: FarmerColors.error,
                  tooltip: 'Delete',
                  onTap: () => _confirmDelete(context, ctrl, product),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, ProductsController ctrl, FarmerProduct product) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text(
            'Are you sure you want to delete "${product.name}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: FarmerColors.error,
                foregroundColor: Colors.white),
            onPressed: () {
              Get.back();
              ctrl.deleteProduct(product.id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ── Stock badge ───────────────────────────────────────────────────────────────

class _StockBadge extends StatelessWidget {
  const _StockBadge({required this.product});
  final FarmerProduct product;

  @override
  Widget build(BuildContext context) {
    Color bg;
    String label;
    if (product.isOutOfStock) {
      bg = FarmerColors.outOfStock;
      label = 'Out of Stock';
    } else if (product.stockQty <= 5) {
      bg = FarmerColors.lowStock;
      label = 'Low Stock (${product.stockQty})';
    } else {
      bg = FarmerColors.statusCompleted;
      label = 'In Stock (${product.stockQty})';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
          color: bg.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: bg, width: 1)),
      child: Text(label,
          style: TextStyle(color: bg, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

// ── Small helpers ─────────────────────────────────────────────────────────────

class _ActionIconButton extends StatelessWidget {
  const _ActionIconButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: color, size: 22),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inventory_2_outlined,
              size: 80, color: FarmerColors.secondary.withValues(alpha: 0.7)),
          const SizedBox(height: 16),
          const Text('No products yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text('Tap the + button to add your first product.',
              style: FarmerTextStyles.body),
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
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline,
                size: 60, color: FarmerColors.error),
            const SizedBox(height: 12),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 16),
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
      ),
    );
  }
}
