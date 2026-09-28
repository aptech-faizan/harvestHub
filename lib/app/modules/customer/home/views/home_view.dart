import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/responsive/responsive.dart';
import 'package:harvest_hub/app/core/theme/app_colors.dart';
import 'package:harvest_hub/app/core/theme/app_spacing.dart';
import 'package:harvest_hub/app/core/widgets/app_shimmer.dart';
import 'package:harvest_hub/app/core/widgets/app_widgets.dart';
import 'package:harvest_hub/app/data/services/auth_service.dart';
import 'package:harvest_hub/app/routes/app_routes.dart';
import '../../shell/controllers/customer_shell_controller.dart';
import '../../wishlist/controllers/wishlist_controller.dart';
import '../controllers/home_controller.dart';
/// Customer Home screen conforming to the Farmers App UI Design Specification:
/// Screen Layout Order (Section 7):
/// App bar → Search + filter → Promo banner → Categories (header + chips) → Browse Products (header + 2-col grid) → Bottom nav
class HomeView extends GetView<HomeController> {
  const HomeView({super.key});
  @override
  Widget build(BuildContext context) {
    // Safe lookup for WishlistController
    final wishlistController = Get.isRegistered<WishlistController>()
        ? Get.find<WishlistController>()
        : Get.put(WishlistController());
    // Responsive metrics for this screen. Read once per build, which is enough:
    // MediaQuery changes (rotation, resize) rebuild this widget anyway.
    final resp = context.resp;
    final searchController = TextEditingController(text: controller.searchQuery.value);
    return Scaffold(
      backgroundColor: AppColors.surfaceWhite,
      // 1. App Bar: Left-aligned logo image with fallback, Notification bell, and Profile button
      appBar: AppAppBar(
        title: const AppLogo(),
        actions: [
          // Notification bell with circular muted background touch target 40px (Section 5 & 6.1)
          AppIconButton(
            icon: AppIcon.notification,
            tooltip: 'Notifications',
            onTap: () {
              AppSnackbar.info(
                'No new notifications right now.',
                title: 'Notifications',
              );
            },
          ),
          // Profile avatar / icon button opening customer Profile screen via same route/tab as bottom nav
          Obx(() {
            final authService = Get.isRegistered<AuthService>() ? Get.find<AuthService>() : null;
            final user = authService?.currentUserModel.value;
            void openProfile() {
              if (Get.isRegistered<CustomerShellController>()) {
                Get.find<CustomerShellController>().changeTab(4);
              } else {
                Get.toNamed(Routes.customerShell);
              }
            }
            return Semantics(
              label: 'Profile',
              button: true,
              child: AppAvatar(
                size: 38,
                imageUrl: user?.photoUrl,
                name: user?.name ?? '',
                onTap: openProfile,
              ),
            );
          }),
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
                  padding: EdgeInsets.symmetric(
                    horizontal: resp.dx(AppSpacing.screenHorizontalPadding),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: resp.dy(AppSpacing.m)),
                      // 2. Search + Filter: 48px height, 12px radius, surfaceMuted fill, matching adjacent filter button (Section 6.2 & Section 8 item 5)
                      Obx(() {
                        final isFiltering = controller.searchQuery.value.isNotEmpty;
                        return AppSearchBar(
                          controller: searchController,
                          hintText: 'Search vegetables, fruits, grains...',
                          isFilterActive: isFiltering,
                          onChanged: (val) => controller.searchQuery.value = val,
                          onFilterTap: () {
                            // Quick jump to Explore tab for advanced filter controls
                            if (Get.isRegistered<CustomerShellController>()) {
                              Get.find<CustomerShellController>().changeTab(1);
                            } else {
                              Get.toNamed(Routes.customerShell);
                            }
                          },
                        );
                      }),
                      SizedBox(height: resp.dy(AppSpacing.xxl)),
                      // 3. Promo Banner: 16px radius, gradient bannerBgStart -> bannerBgEnd, pill badge in corner, headline in bold (Section 6.3)
                      AppBanner(
                        badgeText: 'FRESH TODAY',
                        title: 'Farm Fresh Organic Harvest',
                        subtitle: '100% natural, direct from verified local growers',
                        ctaText: 'Shop Now',
                        onTap: () {
                          if (Get.isRegistered<CustomerShellController>()) {
                            Get.find<CustomerShellController>().changeTab(1);
                          }
                        },
                      ),
                      SizedBox(height: resp.dy(AppSpacing.xxl)),
                      // 4. Categories: Section Header ("Categories" + "View all" link) (Section 6.4)
                      AppSectionHeader(
                        title: 'Categories',
                        actionTitle: 'View all',
                        onActionTap: () {
                          controller.selectCategory('');
                        },
                      ),
                      SizedBox(height: resp.dy(AppSpacing.s)),
                      // Horizontal category chips list: AppChip.circular (58px diameter, soft pastel tint, icon, chipLabel below, 12px gap) (Section 6.5)
                      SizedBox(
                        height: resp.dy(96),
                        child: Obx(() {
                          final cats = controller.categories;
                          final selectedId = controller.selectedCategoryId.value;
                          return ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: cats.length + 1,
                            separatorBuilder: (_, __) =>
                                SizedBox(width: resp.dx(AppSpacing.m)),
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
                      // 5. Browse Products Header ("Browse Products" + "View all" link) (Section 6.4)
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
              // Product Grid: 2 columns, 12px horizontal gutter, 16px vertical gutter, 16px horizontal padding (Section 3 & Section 7)
              Obx(() {
                if (controller.isLoading.value) {
                  // Shimmer grid rather than a centred spinner: it matches the
                  // shape and column count of the real grid, so nothing shifts
                  // when the products arrive.
                  return SliverToBoxAdapter(
                    child: ShimmerProductGrid(count: resp.productColumns * 3),
                  );
                }
                final products = controller.filteredProducts;
                if (products.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.screenHorizontalPadding,
                        vertical: AppSpacing.xxl,
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(
                              Icons.eco_outlined,
                              size: 48,
                              color: AppColors.textDisabled,
                            ),
                            const SizedBox(height: AppSpacing.m),
                            AppText.body(
                              controller.searchQuery.value.isNotEmpty
                                  ? 'No products matching "${controller.searchQuery.value}"'
                                  : 'No products available in this category',
                              color: AppColors.textSecondary,
                            ),
                            if (controller.searchQuery.value.isNotEmpty ||
                                controller.selectedCategoryId.value.isNotEmpty) ...[
                              const SizedBox(height: AppSpacing.m),
                              AppButton.small(
                                label: 'Clear Filters',
                                onPressed: () {
                                  controller.searchQuery.value = '';
                                  searchController.clear();
                                  controller.selectCategory('');
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                }
                // Product grid. Column count and tile height are derived from the
                // available width instead of being hardcoded, which is what stops
                // the 2-column layout clipping on a small phone and stretching
                // oddly on a tablet. The aspect ratio reproduces the current
                // ~270px card height at the 360px design width, so the approved
                // design is unchanged on a standard phone.
                return SliverPadding(
                  padding: EdgeInsets.only(
                    left: resp.dx(AppSpacing.screenHorizontalPadding),
                    right: resp.dx(AppSpacing.screenHorizontalPadding),
                    bottom: resp.dy(84), // Space for floating assistant button
                  ),
                  sliver: SliverGrid(
                    // Column count and tile height come from the shared
                    // responsive helper, so this grid and the loading shimmer
                    // below it can never disagree.
                    gridDelegate: resp.productGridDelegate(
                      horizontalPad: AppSpacing.screenHorizontalPadding,
                      horizontalGutter: AppSpacing.gridHorizontalGutter,
                      verticalGutter: AppSpacing.gridVerticalGutter,
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
                            showFullButton: true, // AppButton.small on every product card
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
