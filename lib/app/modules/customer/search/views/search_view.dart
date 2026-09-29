import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/responsive/responsive.dart';
import 'package:harvest_hub/app/core/theme/app_colors.dart';
import 'package:harvest_hub/app/core/theme/app_radius.dart';
import 'package:harvest_hub/app/core/theme/app_spacing.dart';
import 'package:harvest_hub/app/core/theme/app_text_styles.dart';
import 'package:harvest_hub/app/core/widgets/app_shimmer.dart';
import 'package:harvest_hub/app/core/widgets/app_widgets.dart';
import 'package:harvest_hub/app/data/models/market_model.dart';
import 'package:harvest_hub/app/routes/app_routes.dart';
import '../../follow/widgets/follow_farmer_button.dart';
import '../../../shared/chat/widgets/chat_farmer_button.dart';
import '../../wishlist/controllers/wishlist_controller.dart';
import '../controllers/product_search_controller.dart';
import '../widgets/market_map_view.dart';

/// Explore / Product Listing screen conforming to the Farmers App UI Design Specification (Section 7):
/// Screen title + wishlist/filter icons → Category chips → Discount banner → Product grid with Add-to-Cart buttons
class SearchView extends GetView<ProductSearchController> {
  const SearchView({super.key});

  void _openFilterSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.l,
            right: AppSpacing.l,
            top: AppSpacing.l,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + AppSpacing.l,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Filters', style: AppTextStyles.sectionHeading),
                  TextButton(
                    onPressed: () {
                      controller.clearFilters();
                      Navigator.of(sheetContext).pop();
                    },
                    child: Text('Reset', style: AppTextStyles.linkText),
                  ),
                ],
              ),
              const Divider(color: AppColors.divider),
              const SizedBox(height: AppSpacing.s),

              // Farmer Search
              Text('Search by Farmer', style: AppTextStyles.cardTitle),
              const SizedBox(height: AppSpacing.xs),
              AppTextField(
                hintText: 'e.g. Faizan Farm, Green Valley...',
                onChanged: (val) => controller.farmerQuery.value = val,
              ),
              const SizedBox(height: AppSpacing.m),

              // Market selection
              Text('Market', style: AppTextStyles.cardTitle),
              const SizedBox(height: AppSpacing.xs),
              Obx(() => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: AppRadius.inputRadius,
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: controller.selectedMarketId.value,
                        style: AppTextStyles.bodyText.copyWith(color: AppColors.textPrimary),
                        items: [
                          const DropdownMenuItem(value: '', child: Text('All Markets')),
                          ...controller.markets.map((m) =>
                              DropdownMenuItem(value: m.id, child: Text(m.marketName))),
                        ],
                        onChanged: (val) {
                          controller.selectedMarketId.value = val ?? '';
                          controller.applyFilters();
                        },
                      ),
                    ),
                  )),
             
              const SizedBox(height: AppSpacing.xl),

              // Apply button
              AppButton.primary(
                label: 'Apply Filters',
                onPressed: () {
                  controller.applyFilters();
                  Navigator.of(sheetContext).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openMarketSheet(BuildContext context, MarketModel market) {
    final farmers = controller.farmersAtMarket(market.id);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppColors.surfaceWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(sheetContext).size.height * 0.70,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  market.marketName,
                  style: AppTextStyles.sectionHeading.copyWith(fontSize: 18),
                ),
                const SizedBox(height: AppSpacing.s),
                if (market.address.isNotEmpty)
                  _infoRow(Icons.location_on_outlined, market.address),
                if (market.operatingHours.isNotEmpty)
                  _infoRow(Icons.schedule, market.operatingHours),
                Obx(() {
                  final label = controller.distanceLabelToMarket(market);
                  if (label.isEmpty) return const SizedBox.shrink();
                  return _infoRow(Icons.near_me, label);
                }),
                if (farmers.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.s),
                  Text('Farmers at this market', style: AppTextStyles.cardTitle),
                  const SizedBox(height: 4),
                  for (final f in farmers)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      leading: const Icon(Icons.agriculture, size: 20, color: AppColors.primary),
                      title: Text(
                        f.farmerName.isEmpty ? 'Farmer' : f.farmerName,
                        style: AppTextStyles.bodyText,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ChatFarmerButton(
                            farmerId: f.farmerId,
                            farmerName: f.farmerName,
                            compact: true,
                          ),
                          FollowFarmerButton(
                            farmerId: f.farmerId,
                            farmerName: f.farmerName,
                            compact: true,
                          ),
                        ],
                      ),
                    ),
                ],
                const SizedBox(height: AppSpacing.l),
                AppButton.primary(
                  label: 'View Products from this Market',
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    controller.filterByMarket(market);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.s),
          Expanded(child: Text(text, style: AppTextStyles.bodyText)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wishlistController = Get.isRegistered<WishlistController>()
        ? Get.find<WishlistController>()
        : Get.put(WishlistController());

    return Scaffold(
      backgroundColor: AppColors.surfaceWhite,
      // 1. Screen Title + wishlist & filter icons (App bar slot)
      appBar: AppAppBar(
        automaticallyImplyLeading: false,
        titleText: 'Explore',
        actions: [
          // List / Map toggle button
          Obx(() {
            final isMap = controller.viewMode.value == SearchViewMode.map;
            return AppIconButton(
              icon: isMap ? Icons.view_list_rounded : Icons.map_outlined,
              tooltip: isMap ? 'List View' : 'Map View',
              onTap: () {
                controller.setViewMode(
                  isMap ? SearchViewMode.list : SearchViewMode.map,
                );
              },
            );
          }),
          // Wishlist icon
          AppIconButton(
            icon: AppIcon.heartOutlined,
            tooltip: 'Wishlist',
            onTap: () => Get.toNamed(Routes.customerWishlist),
          ),
          // Filter icon
          Obx(() {
            final hasFilter = controller.activeFilterCount > 0;
            return AppIconButton.filter(
              isActive: hasFilter,
              onTap: () => _openFilterSheet(context),
            );
          }),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Obx(() {
          // If in Map View, show MarketMapView
          if (controller.viewMode.value == SearchViewMode.map) {
            return MarketMapView(
              markets: controller.visibleMarkets,
              onMarkerTap: (m) => _openMarketSheet(context, m),
            );
          }

          // Otherwise show Explore layout:
          // Category chips → Discount banner → Product grid with Add-to-Cart buttons
          return CustomScrollView(
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

                      // Search text field
                      AppTextField(
                        hintText: 'Search fresh items, veggies, grains...',
                        prefixIcon: const Icon(
                          Icons.search,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                        onChanged: (val) => controller.query.value = val,
                      ),

                      const SizedBox(height: AppSpacing.l),

                      // 2. Category Chips (Section 6.5 & Section 7)
                      SizedBox(
                        height: 36,
                        child: Obx(() {
                          final cats = controller.categories;
                          final selectedId = controller.selectedCategoryId.value;

                          return ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: cats.length + 1,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: AppSpacing.m), // 12px gap
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                final isSelected = selectedId.isEmpty;
                                return AppChip.pill(
                                  label: 'All',
                                  isSelected: isSelected,
                                  onTap: () {
                                    controller.selectedCategoryId.value = '';
                                    controller.applyFilters();
                                  },
                                );
                              }

                              final cat = cats[index - 1];
                              final isSelected = selectedId == cat.id;
                              final bgColor =
                                  AppChip.getCategoryBgColor(cat.name);

                              return AppChip.pill(
                                label: cat.name,
                                backgroundColor: isSelected
                                    ? AppColors.primaryDark
                                    : bgColor,
                                isSelected: isSelected,
                                onTap: () {
                                  controller.selectedCategoryId.value = cat.id;
                                  controller.applyFilters();
                                },
                              );
                            },
                          );
                        }),
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // 3. Discount Banner ("50% Off") (Section 6.3 & Section 7)
                      AppBanner.discount(
                        badgeText: '50% Off',
                        title: 'Seasonal Harvest Flash Sale',
                        subtitle: 'Exclusive discounts on organic farm picks',
                        ctaText: 'Grab Now',
                        onTap: () {},
                      ),

                      const SizedBox(height: AppSpacing.xxl),

                      // Section Header for Products
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('All Products', style: AppTextStyles.sectionHeading),
                          Obx(() => Text(
                                '${controller.results.length} items',
                                style: AppTextStyles.caption,
                              )),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.m),
                    ],
                  ),
                ),
              ),

              // 4. Product grid with Add-to-Cart buttons (2 columns, 12px horizontal, 16px vertical gutter)
              Obx(() {
                if (controller.isLoading.value) {
                  // Shimmer grid using the same column derivation as the real
                  // grid below, so results do not reflow when they arrive.
                  return SliverToBoxAdapter(
                    child: ShimmerProductGrid(
                      count: context.resp.productColumns * 3,
                    ),
                  );
                }

                final products = controller.results;
                if (products.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.xxl),
                      child: Center(
                        child: AppText.body(
                          'No products found matching your search',
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
                    bottom: 84.0, // Space for floating assistant button
                  ),
                  sliver: SliverGrid(
                    // Derived from the available width instead of a fixed
                    // 2-column / 270px grid, which clipped on small phones and
                    // stretched on tablets. Same proportions at 360px.
                    gridDelegate: context.resp.productGridDelegate(
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
                            showFullButton: true, // Add-to-Cart buttons in Explore
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
          );
        }),
      ),
    );
  }
}
