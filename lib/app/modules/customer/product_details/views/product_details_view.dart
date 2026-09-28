import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/theme/app_colors.dart';
import 'package:harvest_hub/app/core/theme/app_radius.dart';
import 'package:harvest_hub/app/core/theme/app_spacing.dart';
import 'package:harvest_hub/app/core/theme/app_text_styles.dart';
import 'package:harvest_hub/app/core/widgets/app_widgets.dart';
import 'package:harvest_hub/app/modules/customer/follow/widgets/follow_farmer_button.dart';
import 'package:harvest_hub/app/modules/shared/chat/widgets/chat_farmer_button.dart';
import 'package:harvest_hub/app/routes/app_routes.dart';
import '../controllers/product_details_controller.dart';

/// Product Details screen revamped per UI Master Rules and Design Specification.
/// Structure:
/// Top image area (rounded per radiusCard) → AppText for produce name + price (totalPriceText style)
/// → AppChip for stock / organic / seasonal tags → AppCard.list for mini farmer profile (photo, name, rating, AppTextButton "View Farmer")
/// → Description block using AppText(bodyText) → AppStepper for quantity & AppButton.primary "Add to Cart" pinned at bottom.
class ProductDetailsView extends GetView<ProductDetailsController> {
  const ProductDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final p = controller.product;
    final isOutOfStock = p.stockQty <= 0;

    return Scaffold(
      backgroundColor: AppColors.surfaceWhite,
      // 2 & 3. App Bar: 40x40 circular back button, 40x40 wishlist button, title removed
      appBar: AppAppBar(
        leading: Center(
          child: AppIconButton(
            icon: Icons.arrow_back_rounded,
            size: 40.0,
            iconSize: 20.0,
            backgroundColor: AppColors.surfaceMuted,
            iconColor: AppColors.primaryDark,
            tooltip: 'Back',
            onTap: () => Get.back(),
          ),
        ),
        actions: [
          Obx(() => AppIconButton.wishlist(
                size: 40.0,
                iconSize: 20.0,
                isWishlisted: controller.isWishlisted.value,
                onTap: () => controller.toggleWishlist(),
              )),
        ],
      ),
      // 4. Scrollable area with bottom padding equal to bottom bar height plus 16px (100px)
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
          left: AppSpacing.screenHorizontalPadding,
          right: AppSpacing.screenHorizontalPadding,
          top: AppSpacing.m,
          bottom: 100.0, // bottom bar (~84px) + 16px
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Top Image Area: rounded per radiusCard (16px)
            ClipRRect(
              borderRadius: AppRadius.cardRadius,
              child: Container(
                height: 240,
                width: double.infinity,
                color: AppColors.surfaceMuted,
                child: p.imageUrl.isNotEmpty
                    ? Image.network(
                        p.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholderImage(),
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.primary,
                              ),
                              value: progress.expectedTotalBytes != null
                                  ? progress.cumulativeBytesLoaded /
                                      progress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                      )
                    : _placeholderImage(),
              ),
            ),

            const SizedBox(height: AppSpacing.l),

            // 2. Produce Name & Price Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Produce name
                Expanded(
                  child: AppText.screenTitle(
                    p.itemName,
                  ),
                ),
                const SizedBox(width: AppSpacing.m),
                // Price per unit (totalPriceText style: 18px Bold in success color)
                AppText.totalPrice(
                  '₹${p.pricePerUnit.toStringAsFixed(0)} / ${p.unit}',
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.m),

            // 1. AppChip Tags Row: In Stock, 100% Organic, category inside horizontal Wrap (8, 8)
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // Stock status tag
                AppChip.pill(
                  label: isOutOfStock ? 'Out of Stock' : 'In Stock',
                  backgroundColor: isOutOfStock
                      ? AppColors.accentRed.withValues(alpha: 0.12)
                      : AppColors.chipHerbsBg,
                  textColor: isOutOfStock
                      ? AppColors.accentRed
                      : AppColors.primaryDark,
                  iconData: isOutOfStock
                      ? Icons.cancel_outlined
                      : Icons.check_circle_outline,
                ),

                // Organic tag
                const AppChip.pill(
                  label: '100% Organic',
                  backgroundColor: AppColors.chipHerbsBg,
                  textColor: AppColors.primaryDark,
                  iconData: Icons.eco,
                ),

                // Category tag
                AppChip.pill(
                  label: p.categoryName.isNotEmpty
                      ? p.categoryName
                      : 'Fruits',
                  backgroundColor: AppChip.getCategoryBgColor(p.categoryName),
                  textColor: AppColors.textPrimary,
                  iconData: AppChip.getCategoryIcon(p.categoryName),
                ),
              ],
            ),

                  const SizedBox(height: AppSpacing.xl),

                  // 4. Mini Farmer Profile Section using AppCard.list
                  AppCard.list(
                    title: 'Farmer Details',
                    trailingTitle: AppTextButton(
                      label: 'View Farmer',
                      trailingIcon: Icons.chevron_right,
                      onPressed: () {
                        final f = controller.farmer.value;
                        if (f != null) {
                          Get.toNamed(Routes.customerFarmerDetails, arguments: f);
                        } else {
                          Get.toNamed(Routes.customerFarmers);
                        }
                      },
                    ),
                    children: [
                      Row(
                        children: [
                          // Farmer Avatar / Photo
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.chipHerbsBg,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.divider,
                                width: 1.0,
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.person,
                                size: 28,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.m),
                          // Farmer Name & Rating
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppText.cardTitle(
                                  p.farmerName.isNotEmpty
                                      ? p.farmerName
                                      : 'Verified Local Farmer',
                                ),
                                const SizedBox(height: 3),
                                Obx(() {
                                  final rating = controller.farmerRating;
                                  if (rating == null) {
                                    return AppText.caption(
                                      controller.isLoadingFarmer.value
                                          ? 'Loading rating...'
                                          : 'Verified Farmer • No reviews yet',
                                    );
                                  }
                                  return Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        size: 14,
                                        color: AppColors.ratingStar,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        rating.toStringAsFixed(1),
                                        style: AppTextStyles.caption.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const AppText.caption('(Verified Rating)'),
                                    ],
                                  );
                                }),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (p.marketName.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.s),
                        Row(
                          children: [
                            const Icon(
                              Icons.storefront_outlined,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: AppText.caption(
                                'Trading at ${p.marketName}',
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: AppSpacing.m),
                      // Follow and Chat actions (both Expanded with label 'Chat' to prevent overflow on 360px screens)
                      Obx(() {
                        final resolvedId = controller.farmer.value?.id.isNotEmpty == true
                            ? controller.farmer.value!.id
                            : p.farmerId;
                        return Row(
                          children: [
                            Expanded(
                              child: FollowFarmerButton(
                                farmerId: resolvedId,
                                farmerName: p.farmerName,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.s),
                            Expanded(
                              child: ChatFarmerButton(
                                farmerId: resolvedId,
                                farmerName: p.farmerName,
                                label: 'Chat',
                              ),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // 5. Description Block using AppText(bodyText)
                  const AppSectionHeader(title: 'Description'),
                  const SizedBox(height: AppSpacing.xs),
                  AppText(
                    p.description.isEmpty
                        ? 'Fresh and authentic organic farm harvest grown with careful natural practices, free from synthetic pesticides.'
                        : p.description,
                    variant: AppTextStyleVariant.bodyText,
                  ),
                ],
              ),
            ),
      // 4. Pinned Bottom Bar: white surface, top hairline divider & safe-area padding
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenHorizontalPadding,
          vertical: AppSpacing.m,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surfaceWhite,
          border: Border(
            top: BorderSide(color: AppColors.divider, width: 1.0),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              // AppStepper for quantity (min: 1, max: stockQty)
              Obx(() => AppStepper(
                    value: controller.qty.value,
                    min: 1,
                    max: p.stockQty > 0 ? p.stockQty : 1,
                    onChanged: (newQty) {
                      if (newQty > controller.qty.value) {
                        controller.increment();
                      } else if (newQty < controller.qty.value) {
                        controller.decrement();
                      }
                    },
                  )),
              const SizedBox(width: AppSpacing.m),
              // AppButton.primary "Add to Cart"
              Expanded(
                child: AppButton.primary(
                  label: isOutOfStock ? 'Out of Stock' : 'Add to Cart',
                  icon: isOutOfStock ? null : Icons.add_shopping_cart,
                  onPressed: isOutOfStock ? null : () => controller.addToCart(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholderImage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.eco_outlined,
            size: 56,
            color: AppColors.primary.withValues(alpha: 0.35),
          ),
          const SizedBox(height: AppSpacing.s),
          const AppText.caption('Fresh Farm Produce'),
        ],
      ),
    );
  }
}
