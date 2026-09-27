import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'app_button.dart';
import 'app_icon.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color backgroundColor;
  final Border? border;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.l),
    this.onTap,
    this.backgroundColor = AppColors.surfaceWhite,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppRadius.cardRadius,
        border: border ?? Border.all(color: AppColors.divider, width: 1.0),
        boxShadow: AppRadius.cardElevation,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.cardRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.cardRadius,
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Product / Media card variant specified in Section 6.6 and Section 8
class AppMediaCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String price;
  final double rating;
  final int? ratingCount;
  final String? imageUrl;
  final bool isWishlisted;
  final VoidCallback? onWishlistTap;
  final VoidCallback? onAddToCart;
  final VoidCallback? onTap;
  final String buttonLabel;
  final bool isOutOfStock;
  final bool showBottomButton;

  const AppMediaCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.price,
    this.rating = 4.8,
    this.ratingCount,
    this.imageUrl,
    this.isWishlisted = false,
    this.onWishlistTap,
    this.onAddToCart,
    this.onTap,
    this.buttonLabel = 'Add to Cart',
    this.isOutOfStock = false,
    this.showBottomButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: AppRadius.cardRadius, // unified 16px
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
              // Top Image with rounded top corners + wishlist overlay top-right
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppRadius.card),
                    ),
                    child: Container(
                      height: 120.0,
                      width: double.infinity,
                      color: AppColors.surfaceMuted,
                      child: (imageUrl != null && imageUrl!.isNotEmpty)
                          ? Image.network(
                              imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _imagePlaceholder(),
                            )
                          : _imagePlaceholder(),
                    ),
                  ),
                  // Consistent wishlist heart on every card (Section 8 item 4)
                  Positioned(
                    top: AppSpacing.s,
                    right: AppSpacing.s,
                    child: AppIconButton.wishlist(
                      isWishlisted: isWishlisted,
                      onTap: onWishlistTap ?? () {},
                    ),
                  ),
                  // Out of stock badge if applicable
                  if (isOutOfStock)
                    Positioned(
                      top: AppSpacing.s,
                      left: AppSpacing.s,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
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

              // Content Section
              Padding(
                padding: const EdgeInsets.all(AppSpacing.m),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      title,
                      style: AppTextStyles.cardTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.s),

                    // Price and Rating Row (Section 8 item 3: price baseline left, rating baseline right)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          price,
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
                              rating.toStringAsFixed(1),
                              style: AppTextStyles.caption.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            if (ratingCount != null) ...[
                              const SizedBox(width: 2),
                              Text(
                                '($ratingCount)',
                                style: AppTextStyles.caption,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),

                    if (showBottomButton) ...[
                      const SizedBox(height: AppSpacing.m),
                      AppButton.small(
                        width: double.infinity,
                        label: isOutOfStock ? 'Sold Out' : buttonLabel,
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

  Widget _imagePlaceholder() {
    return Center(
      child: Icon(
        Icons.eco_outlined,
        size: 40,
        color: AppColors.primary.withValues(alpha: 0.35),
      ),
    );
  }
}

/// List / panel card variant for invoice, shipping, orders (Section 6.6)
class AppListCard extends StatelessWidget {
  final String? title;
  final Widget? trailingTitle;
  final List<Widget> children;
  final EdgeInsetsGeometry padding;

  const AppListCard({
    super.key,
    this.title,
    this.trailingTitle,
    required this.children,
    this.padding = const EdgeInsets.all(AppSpacing.l),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: AppRadius.cardRadius,
        border: Border.all(color: AppColors.divider, width: 1.0),
        boxShadow: AppRadius.cardElevation,
      ),
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title!, style: AppTextStyles.sectionHeading),
                if (trailingTitle != null) trailingTitle!,
              ],
            ),
            const SizedBox(height: AppSpacing.m),
            const Divider(color: AppColors.divider, height: 1),
            const SizedBox(height: AppSpacing.m),
          ],
          ...children,
        ],
      ),
    );
  }
}
