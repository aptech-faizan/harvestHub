import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../../data/models/product_model.dart';
import 'app_button.dart';
import 'app_icon.dart';

/// Standardized product card used across customer screens (Home, Explore/Search).
/// Conforms to Section 6.6 (AppCard.media) and Section 8 (Consistency Fixes).
class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;
  final bool isWishlisted;
  final VoidCallback onWishlistTap;
  final bool showFullButton;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onAddToCart,
    required this.isWishlisted,
    required this.onWishlistTap,
    this.showFullButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final isOutOfStock = product.stockQty <= 0;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: AppRadius.cardRadius, // Section 8: Unify to 16px everywhere
        border: Border.all(color: AppColors.divider, width: 1.0),
        boxShadow: AppRadius.cardElevation,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.cardRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.cardRadius,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top image section with 16px top corner radius
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppRadius.card),
                    ),
                    child: Container(
                      height: 120,
                      width: double.infinity,
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
                  // Section 8: Add wishlist heart consistently to EVERY product card
                  Positioned(
                    top: AppSpacing.s,
                    right: AppSpacing.s,
                    child: AppIconButton.wishlist(
                      isWishlisted: isWishlisted,
                      onTap: onWishlistTap,
                    ),
                  ),
                  if (isOutOfStock)
                    Positioned(
                      top: AppSpacing.s,
                      left: AppSpacing.s,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.accentRed,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Out of stock',
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              // Bottom info section
              Padding(
                padding: const EdgeInsets.all(AppSpacing.m),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      product.itemName,
                      style: AppTextStyles.cardTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    // Farmer Name
                    Text(
                      product.farmerName.isNotEmpty ? product.farmerName : 'Local Farmer',
                      style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.s),

                    // Section 8: Standardize price/rating row alignment:
                    // price baseline-aligned left, rating baseline-aligned right
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '₹${product.pricePerUnit.toStringAsFixed(0)}/${product.unit}',
                          style: AppTextStyles.priceText,
                        ),
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
                              '4.8',
                              style: AppTextStyles.caption.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    if (showFullButton) ...[
                      const SizedBox(height: AppSpacing.s),
                      AppButton.small(
                        width: double.infinity,
                        label: isOutOfStock ? 'Sold Out' : 'Add to Cart',
                        icon: isOutOfStock ? null : Icons.add_shopping_cart,
                        onPressed: isOutOfStock ? null : onAddToCart,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Center(
      child: Icon(
        Icons.eco_outlined,
        size: 38,
        color: AppColors.primary.withValues(alpha: 0.35),
      ),
    );
  }
}
