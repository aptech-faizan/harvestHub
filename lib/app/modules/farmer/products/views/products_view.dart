import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/models/farmer_product_model.dart';
import '../../farmer_theme.dart';
import '../../widgets/farmer_widgets.dart';
import '../controllers/products_controller.dart';
import 'product_form_view.dart';

/// Modern Airbnb/Notion-inspired Products view with instant search,
/// category filter chips, swipe-to-delete, Hero transitions, and shimmer loading.
class ProductsView extends StatefulWidget {
  const ProductsView({super.key});

  @override
  State<ProductsView> createState() => _ProductsViewState();
}

class _ProductsViewState extends State<ProductsView> {
  final ProductsController controller = Get.find<ProductsController>();
  final TextEditingController _searchCtrl = TextEditingController();
  String _selectedCategory = 'All';
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FarmerColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'My Products',
              style: TextStyle(
                color: FarmerColors.text,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
            Obx(() => Text(
                  '${controller.products.length} items catalogued',
                  style: FarmerTextStyles.caption.copyWith(
                    color: FarmerColors.muted,
                  ),
                )),
          ],
        ),
        actions: [
          Semantics(
            button: true,
            label: 'Refresh products list',
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
              tooltip: 'Refresh',
              onPressed: controller.loadProducts,
            ),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: FarmerColors.border,
            height: 1,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          controller.prepareForAdd();
          Get.to(
            () => const ProductFormView(),
            transition: Transition.rightToLeft,
          );
        },
        backgroundColor: FarmerColors.primaryDark,
        elevation: 4,
        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
        label: const Text(
          'Add Product',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 14,
            letterSpacing: 0.2,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const _ProductsLoadingSkeleton();
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return _ProductsErrorState(
            message: controller.errorMessage.value,
            onRetry: controller.loadProducts,
          );
        }

        if (controller.products.isEmpty) {
          return EmptyState(
            icon: Icons.eco_outlined,
            title: 'No Products Yet',
            message:
                'Start listing your fresh farm produce so nearby customers can discover and buy.',
            actionLabel: 'Add Product',
            onActionPressed: () {
              controller.prepareForAdd();
              Get.to(
                () => const ProductFormView(),
                transition: Transition.rightToLeft,
              );
            },
          );
        }

        // Apply view-level search and category filtering
        final query = _searchQuery.toLowerCase().trim();
        final filteredList = controller.products.where((p) {
          final matchesCat = _selectedCategory == 'All' ||
              p.category.toLowerCase() == _selectedCategory.toLowerCase();
          final matchesQuery = query.isEmpty ||
              p.name.toLowerCase().contains(query) ||
              p.category.toLowerCase().contains(query);
          return matchesCat && matchesQuery;
        }).toList();

        final filterCategories = ['All', ...controller.categories];

        return RefreshIndicator(
          color: FarmerColors.primary,
          backgroundColor: Colors.white,
          onRefresh: controller.loadProducts,
          child: CustomScrollView(
            slivers: [
              // Search & Filter header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Search bar
                      Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: FarmerColors.border),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1F2A1F)
                                  .withValues(alpha: 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchCtrl,
                          onChanged: (val) {
                            setState(() {
                              _searchQuery = val;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Search products by name or category...',
                            hintStyle: const TextStyle(
                              color: FarmerColors.muted,
                              fontSize: 13,
                            ),
                            prefixIcon: const Icon(
                              Icons.search_rounded,
                              color: FarmerColors.primary,
                              size: 20,
                            ),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear_rounded,
                                        size: 18, color: FarmerColors.muted),
                                    onPressed: () {
                                      _searchCtrl.clear();
                                      setState(() {
                                        _searchQuery = '';
                                      });
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Horizontal category chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        clipBehavior: Clip.none,
                        child: Row(
                          children: filterCategories.map((cat) {
                            final isSelected = _selectedCategory == cat;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(cat),
                                selected: isSelected,
                                onSelected: (sel) {
                                  if (sel) {
                                    setState(() {
                                      _selectedCategory = cat;
                                    });
                                  }
                                },
                                selectedColor: FarmerColors.primaryDark,
                                backgroundColor: Colors.white,
                                labelStyle: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? Colors.white
                                      : FarmerColors.textSecondary,
                                ),
                                side: BorderSide(
                                  color: isSelected
                                      ? FarmerColors.primaryDark
                                      : FarmerColors.border,
                                  width: 1,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                showCheckmark: false,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Filtered product items
              if (filteredList.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 54,
                            color: FarmerColors.muted.withValues(alpha: 0.6),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'No matching products',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: FarmerColors.text,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Try modifying your search query or category filter.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: FarmerColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final product = filteredList[index];
                        return StaggeredFadeSlide(
                          index: index,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _DismissibleProductCard(
                              product: product,
                              controller: controller,
                            ),
                          ),
                        );
                      },
                      childCount: filteredList.length,
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}

// ── Swipe-to-delete Dismissible Product Card ──────────────────────────────────

class _DismissibleProductCard extends StatelessWidget {
  final FarmerProduct product;
  final ProductsController controller;

  const _DismissibleProductCard({
    required this.product,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('product-${product.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await _showDeleteConfirmationSheet(context, product);
      },
      onDismissed: (_) {
        controller.deleteProduct(product.id);
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: FarmerColors.error,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline_rounded, color: Colors.white, size: 28),
            SizedBox(height: 4),
            Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      child: _ProductCard(
        product: product,
        controller: controller,
      ),
    );
  }

  Future<bool> _showDeleteConfirmationSheet(
      BuildContext context, FarmerProduct p) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: FarmerColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: const BoxDecoration(
                    color: FarmerColors.errorBg,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    size: 36,
                    color: FarmerColors.error,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Delete Product?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: FarmerColors.text,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Are you sure you want to delete "${p.name}"? This action cannot be undone and will remove it from the market.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: FarmerColors.muted,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 48),
                          side: const BorderSide(color: FarmerColors.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: FarmerColors.text,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 48),
                          backgroundColor: FarmerColors.error,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Delete',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
    return result ?? false;
  }
}

// ── Product Card UI ───────────────────────────────────────────────────────────

class _ProductCard extends StatelessWidget {
  final FarmerProduct product;
  final ProductsController controller;

  const _ProductCard({
    required this.product,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      onTap: () {
        controller.prepareForEdit(product);
        Get.to(
          () => const ProductFormView(),
          transition: Transition.rightToLeft,
        );
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Hero Image / Category placeholder
          ProductImagePlaceholder(
            imageUrl: product.imageUrl,
            category: product.category,
            width: 76,
            height: 76,
            borderRadius: 14,
            heroTag: 'product-img-${product.id}',
          ),
          const SizedBox(width: 14),

          // 2. Product Information
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Chip & Stock badge row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: FarmerColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        product.category,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: FarmerColors.textSecondary,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ),
                    StatusChip.stockBadge(
                      stockQty: product.stockQty,
                      isOutOfStock: product.isOutOfStock,
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Product Name
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: FarmerColors.text,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 6),

                // Price Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: FarmerCurrency.format(product.pricePerUnit),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: FarmerColors.primaryDark,
                            ),
                          ),
                          TextSpan(
                            text: ' / ${product.unit}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: FarmerColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Clean Action Menu Button
                    _ProductActionMenu(
                      product: product,
                      controller: controller,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Product Action Menu ───────────────────────────────────────────────────────

class _ProductActionMenu extends StatelessWidget {
  final FarmerProduct product;
  final ProductsController controller;

  const _ProductActionMenu({
    required this.product,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'edit') {
          controller.prepareForEdit(product);
          Get.to(
            () => const ProductFormView(),
            transition: Transition.rightToLeft,
          );
        } else if (value == 'delete') {
          _confirmDeleteDialog(context);
        }
      },
      icon: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: FarmerColors.surfaceMuted,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.more_horiz_rounded,
          size: 18,
          color: FarmerColors.textSecondary,
        ),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 6,
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_outlined, size: 18, color: FarmerColors.primary),
              SizedBox(width: 10),
              Text('Edit Details', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline_rounded, size: 18, color: FarmerColors.error),
              SizedBox(width: 10),
              Text('Delete Product', style: TextStyle(fontSize: 13, color: FarmerColors.error, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }

  void _confirmDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Delete Product', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text(
          'Are you sure you want to delete "${product.name}"? This action cannot be undone.',
          style: const TextStyle(fontSize: 14, color: FarmerColors.muted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: FarmerColors.muted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: FarmerColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              controller.deleteProduct(product.id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ── Products Loading Skeleton ─────────────────────────────────────────────────

class _ProductsLoadingSkeleton extends StatelessWidget {
  const _ProductsLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        const ShimmerBox(height: 48),
        const SizedBox(height: 12),
        Row(
          children: const [
            ShimmerBox(width: 60, height: 32),
            SizedBox(width: 8),
            ShimmerBox(width: 90, height: 32),
            SizedBox(width: 8),
            ShimmerBox(width: 75, height: 32),
          ],
        ),
        const SizedBox(height: 16),
        const CardListShimmer(count: 5),
      ],
    );
  }
}

// ── Products Error State ──────────────────────────────────────────────────────

class _ProductsErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ProductsErrorState({
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
              'Failed to Load Products',
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
