import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/theme/app_colors.dart';
import 'package:harvest_hub/app/core/theme/app_spacing.dart';
import 'package:harvest_hub/app/core/widgets/app_widgets.dart';
import 'package:harvest_hub/app/routes/app_routes.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../shell/controllers/customer_shell_controller.dart';
import '../../wishlist/controllers/wishlist_controller.dart';
import '../controllers/home_controller.dart';

/// Customer Home screen conforming to the Farmers App UI Design Specification (Section 7):
/// App bar → Search + filter → Promo banner → Categories (header + chips) → Browse Products (header + 2-col grid)
class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    // Safe lookup for Wishlist and Cart
    final wishlistController = Get.isRegistered<WishlistController>()
        ? Get.find<WishlistController>()
        : Get.put(WishlistController());

    return Scaffold(
      backgroundColor: AppColors.surfaceWhite,
      // 1. App Bar: Logo text "Farmers" (primaryDark), points pill badge, notification bell
      appBar: AppAppBar(
        isLogo: true,
        titleText: 'Farmers',
        actions: [
          AppPointsBadge(
            points: 320,
            onTap: () {},
          ),
          AppIconButton(
            icon: AppIcon.notification,
            tooltip: 'Notifications',
            onTap: () {},
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: controller.loadData,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontalPadding,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppSpacing.m),

                      // 2. Search + filter row (height 48px, radius 12px)
                      AppSearchBar(
                        hintText: 'Search vegetables, fruits, grains...',
                        readOnly: true,
                        onTap: () {
                          // Jump to Explore / Search tab in shell if present
                          if (Get.isRegistered<CustomerShellController>()) {
                            Get.find<CustomerShellController>().changeTab(1);
                          } else {
                            Get.toNamed(Routes.customerShell);
                          }
                        },
                        onFilterTap: () {
                          if (Get.isRegistered<CustomerShellController>()) {
                            Get.find<CustomerShellController>().changeTab(1);
                          }
                        },
                      ),

                      const SizedBox(height: AppSpacing.xxl),

                      // 3. Promo Banner (Section 6.3)
                      AppBanner(
                        badgeText: 'FRESH TODAY',
                        title: 'Farm Fresh Organic Harvest',
                        subtitle: '100% natural, direct from verified growers',
                        ctaText: 'Shop Now',
                        onTap: () {
                          if (Get.isRegistered<CustomerShellController>()) {
                            Get.find<CustomerShellController>().changeTab(1);
                          }
                        },
                      ),

                      const SizedBox(height: AppSpacing.xxl),

                      // 4. Categories: Section Header + Horizontal Circular Chips
                      AppSectionHeader(
                        title: 'Categories',
                        actionTitle: 'View all',
                        onActionTap: () {
                          controller.selectCategory('');
                        },
                      ),
                      const SizedBox(height: AppSpacing.s),

                      SizedBox(
                        height: 90,
                        child: Obx(() {
                          final cats = controller.categories;
                          final selectedId = controller.selectedCategoryId.value;

                          return ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: cats.length + 1,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: AppSpacing.m),
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                final isAllSelected = selectedId.isEmpty;
                                return AppChip.circular(
                                  label: 'All',
                                  iconData: Icons.grid_view_rounded,
                                  backgroundColor: AppColors.chipFruitsBg,
                                  isSelected: isAllSelected,
                                  onTap: () => controller.selectCategory(''),
                                );
                              }

                              final cat = cats[index - 1];
                              final isSelected = selectedId == cat.id;
                              final bgColor =
                                  AppChip.getCategoryBgColor(cat.name);
                              final icon =
                                  AppChip.getCategoryIcon(cat.name);

                              return AppChip.circular(
                                label: cat.name,
                                iconData: icon,
                                backgroundColor: bgColor,
                                isSelected: isSelected,
                                onTap: () => controller.selectCategory(cat.id),
                              );
                            },
                          );
                        }),
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // 5. Browse Products Header
                      AppSectionHeader(
                        title: 'Browse Products',
                        actionTitle: 'View all',
                        onActionTap: () {
                          if (Get.isRegistered<CustomerShellController>()) {
                            Get.find<CustomerShellController>().changeTab(1);
                          }
                        },
                      ),
                      const SizedBox(height: AppSpacing.s),
                    ],
                  ),
                ),
              ),

              // 2-Column Product Grid (12px horizontal gutter, 16px vertical gutter)
              Obx(() {
                if (controller.isLoading.value) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.xxl),
                      child: Center(
                        child: CircularProgressIndicator(color: AppColors.primary),
                      ),
                    ),
                  );
                }

                final products = controller.filteredProducts;
                if (products.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.xxl),
                      child: Center(
                        child: AppText.body(
                          'No products available in this category',
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.only(
                    left: AppSpacing.screenHorizontalPadding,
                    right: AppSpacing.screenHorizontalPadding,
                    bottom: AppSpacing.xxl,
                  ),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: AppSpacing.gridHorizontalGutter,
                      mainAxisSpacing: AppSpacing.gridVerticalGutter,
                      childAspectRatio: 0.64,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final product = products[index];

                        return Obx(() {
                          final isWishlisted =
                              wishlistController.isWishlisted(product.id);

                          return ProductCard(
                            product: product,
                            isWishlisted: isWishlisted,
                            onWishlistTap: () =>
                                wishlistController.toggle(product),
                            onTap: () => Get.toNamed(
                              Routes.customerProductDetails,
                              arguments: product,
                            ),
                            onAddToCart: () => controller.addToCart(product),
                          );
                        });
                      },
                      childCount: products.length,
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
