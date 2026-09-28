import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/theme/app_colors.dart';
import 'package:harvest_hub/app/core/theme/app_spacing.dart';
import 'package:harvest_hub/app/core/widgets/app_widgets.dart';
import 'package:harvest_hub/app/routes/app_routes.dart';
import '../../shell/controllers/customer_shell_controller.dart';
import '../controllers/wishlist_controller.dart';

/// Customer Wishlist screen conforming to the HarvestHub Design System:
/// - AppAppBar with screen title and reactive item count
/// - 2-column grid of AppCard.media items (same card style as Home/Search results)
/// - Each card features an AppIconButton.wishlist toggle and an AppButton.small "Add to Cart"
/// - Empty state featuring AppText and an AppButton pointing to browse/explore
class WishlistView extends GetView<WishlistController> {
  const WishlistView({super.key});

  void _navigateToBrowse(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Get.back();
      if (Get.isRegistered<CustomerShellController>()) {
        Get.find<CustomerShellController>().changeTab(1);
      }
    } else if (Get.isRegistered<CustomerShellController>()) {
      Get.find<CustomerShellController>().changeTab(1);
    } else {
      Get.offAllNamed(Routes.customerShell);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceWhite,
      appBar: AppAppBar(
        titleText: 'My Wishlist',
        actions: [
          Obx(() {
            final count = controller.items.length;
            if (count == 0) return const SizedBox.shrink();
            return Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.chipHerbsBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: AppText.caption(
                  '$count ${count == 1 ? "item" : "items"}',
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.items.isEmpty) {
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: controller.loadWishlist,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.xxl),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 88,
                              height: 88,
                              decoration: const BoxDecoration(
                                color: AppColors.surfaceMuted,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.favorite_border_rounded,
                                size: 44,
                                color: AppColors.textDisabled,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.l),
                            const AppText.sectionHeading(
                              'Your Wishlist is Empty',
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppSpacing.s),
                            const AppText.body(
                              'Explore fresh farm produce and save your favorite items here to purchase later.',
                              textAlign: TextAlign.center,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 280),
                              child: AppButton.primary(
                                label: 'Browse Products',
                                icon: Icons.search_rounded,
                                width: double.infinity,
                                onPressed: () => _navigateToBrowse(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: controller.loadWishlist,
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontalPadding,
              vertical: AppSpacing.l,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppSpacing.gridHorizontalGutter, // 12px gutter
              mainAxisSpacing: AppSpacing.gridVerticalGutter,   // 16px gutter
              childAspectRatio: 0.64, // Matches Home and Explore card proportions
            ),
            itemCount: controller.items.length,
            itemBuilder: (context, index) {
              final product = controller.items[index];
              final isOutOfStock = product.stockQty <= 0;

              return AppCard.media(
                title: product.itemName,
                subtitle: product.farmerName.isNotEmpty
                    ? product.farmerName
                    : (product.unit.isNotEmpty ? 'Per ${product.unit}' : null),
                price: 'Rs. ${product.pricePerUnit.toStringAsFixed(0)} / ${product.unit}',
                imageUrl: product.imageUrl,
                isWishlisted: true,
                isOutOfStock: isOutOfStock,
                showBottomButton: true,
                onWishlistTap: () => controller.remove(product.id),
                onAddToCart: isOutOfStock ? null : () => controller.addToCart(product),
                onTap: () => Get.toNamed(
                  Routes.customerProductDetails,
                  arguments: product,
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
