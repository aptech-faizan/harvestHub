import 'package:flutter/material.dart';
import 'package:harvest_hub/app/core/theme/app_colors.dart';
import 'package:harvest_hub/app/core/theme/app_text_styles.dart';
import 'package:harvest_hub/app/data/models/product_model.dart';

// Reusable product card used across customer screens.
class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;
  final bool isWishlisted;
  final VoidCallback onWishlistTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onAddToCart,
    required this.isWishlisted,
    required this.onWishlistTap,
  });

  @override
  Widget build(BuildContext context) {
    // Full card wrapped in InkWell for tap ripple.
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ImageSection(product: product, isWishlisted: isWishlisted, onWishlistTap: onWishlistTap),
              _InfoSection(product: product, onAddToCart: onAddToCart),
            ],
          ),
        ),
      ),
    );
  }
}

// Top image area with 1:1 ratio and wishlist button overlay.
class _ImageSection extends StatelessWidget {
  final ProductModel product;
  final bool isWishlisted;
  final VoidCallback onWishlistTap;

  const _ImageSection({
    required this.product,
    required this.isWishlisted,
    required this.onWishlistTap,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        children: [
          // Product image or placeholder icon.
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: product.imageUrl.isNotEmpty
                ? Image.network(
                    product.imageUrl,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholder(),
                  )
                : _placeholder(),
          ),
          // Heart wishlist button at top-right.
          Positioned(
            top: 6,
            right: 6,
            child: GestureDetector(
              onTap: onWishlistTap,
              child: Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isWishlisted ? Icons.favorite : Icons.favorite_border,
                  size: 16,
                  color: isWishlisted ? AppColors.error : AppColors.textMuted,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Green leaf placeholder when imageUrl is empty.
  Widget _placeholder() {
    return Container(
      color: AppColors.background,
      child: const Center(
        child: Icon(Icons.eco, size: 40, color: AppColors.secondary),
      ),
    );
  }
}

// Bottom info area: name, farmer, price row, add-to-cart button.
class _InfoSection extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onAddToCart;

  const _InfoSection({required this.product, required this.onAddToCart});

  @override
  Widget build(BuildContext context) {
    final outOfStock = product.stockQty <= 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product name, max 2 lines.
          Text(
            product.itemName,
            style: AppTextStyles.headlineSm,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          // Farmer name in muted color.
          Text(
            product.farmerName,
            style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          // Out of stock label shown above price row.
          if (outOfStock)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                'Out of stock',
                style: AppTextStyles.bodySm.copyWith(color: AppColors.error),
              ),
            ),
          // Price and add-to-cart row.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Price with unit.
              Expanded(
                child: Text(
                  'Rs ${product.pricePerUnit.toStringAsFixed(0)} /${product.unit}',
                  style: AppTextStyles.priceMd,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Circular '+' button, disabled if out of stock.
              _AddButton(onAddToCart: outOfStock ? null : onAddToCart),
            ],
          ),
        ],
      ),
    );
  }
}

// Small circular add-to-cart button.
class _AddButton extends StatelessWidget {
  final VoidCallback? onAddToCart;

  const _AddButton({required this.onAddToCart});

  @override
  Widget build(BuildContext context) {
    final enabled = onAddToCart != null;
    return GestureDetector(
      onTap: onAddToCart,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: enabled ? AppColors.primary : Colors.grey.shade300,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.add,
          size: 18,
          color: enabled ? Colors.white : Colors.grey,
        ),
      ),
    );
  }
}
