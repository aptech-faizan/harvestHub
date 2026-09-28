import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/responsive/responsive.dart';
import 'package:harvest_hub/app/core/widgets/app_shimmer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_chip.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../data/models/farmer_model.dart';
import '../../../../data/models/product_model.dart';
import '../../../../routes/app_routes.dart';
import '../../follow/widgets/follow_farmer_button.dart';
import '../../../shared/chat/widgets/chat_farmer_button.dart';
import '../controllers/farmers_controller.dart';

/// Farmer Details screen — UI revamp per Master Rules.
///
/// Layout (top → bottom):
///   1. Hero header  — gradient banner (AppBanner styling) + circular avatar
///   2. Identity row — AppText.screenTitle (name) + AppChip.pill (verified badge)
///   3. Rating chip  — AppChip.pill with star rating (when rating > 0)
///   4. Bio          — AppText.body (description)
///   5. Location row — AppIcon + AppText.caption (marketName)
///   6. Action row   — FollowFarmerButton + ChatFarmerButton (compact)
///   7. AppSectionHeader ("Listed Produce")
///   8. 2-column grid of AppMediaCard for the farmer's products
///
/// Follow-state logic and product-fetching logic are intentionally untouched.
class FarmerDetailsView extends GetView<FarmersController> {
  const FarmerDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    // Route arguments se farmer model lo — unchanged from original
    final farmer = Get.arguments as FarmerModel;
    final String effectiveFarmerId =
        farmer.id.isEmpty ? farmer.userId : farmer.id;

    return Scaffold(
      backgroundColor: AppColors.surfaceMuted,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Material(
            color: AppColors.surfaceWhite.withValues(alpha: 0.88),
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: Get.back,
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.arrow_back_ios_new_rounded,
                    size: 18, color: AppColors.primaryDark),
              ),
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<ProductModel>>(
        // Product-fetching logic unchanged — only wrapping its output in new UI
        future: controller.getProductsForFarmer(farmer),
        builder: (context, snapshot) {
          final isLoading = snapshot.connectionState == ConnectionState.waiting;
          final products = snapshot.data ?? [];

          return CustomScrollView(
            slivers: [
              // ── 1. Hero Header ──────────────────────────────────────────────
              SliverToBoxAdapter(
                child: _HeroBanner(farmer: farmer),
              ),

              // ── Profile card (name, chips, bio, location, actions) ──────────
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(
                    AppSpacing.l,
                    0,
                    AppSpacing.l,
                    AppSpacing.m,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceWhite,
                    borderRadius: AppRadius.cardRadius,
                    border: Border.all(color: AppColors.divider, width: 1.0),
                    boxShadow: AppRadius.cardElevation,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.l),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── 2. Name + Verified chip ───────────────────────────
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: AppText.screenTitle(
                                farmer.businessName,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.s),
                            AppChip.pill(
                              label: 'Verified',
                              iconData: Icons.verified_outlined,
                              backgroundColor: AppColors.chipHerbsBg,
                              textColor: AppColors.primaryDark,
                            ),
                          ],
                        ),

                        // ── 3. Rating chip ────────────────────────────────────
                        if (farmer.rating > 0) ...[
                          const SizedBox(height: AppSpacing.s),
                          AppChip.pill(
                            label:
                                '${farmer.rating.toStringAsFixed(1)}  ★  Rating',
                            backgroundColor: AppColors.chipFruitsBg,
                            textColor: AppColors.accentOrange,
                          ),
                        ],

                        // ── 4. Bio ────────────────────────────────────────────
                        if (farmer.description.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.m),
                          AppText.body(
                            farmer.description,
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],

                        // ── 5. Location row ───────────────────────────────────
                        if (farmer.marketName.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.m),
                          Row(
                            children: [
                              AppIcon(
                                Icons.location_on_outlined,
                                size: 16,
                                color: AppColors.primaryDark,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Flexible(
                                child: AppText.caption(
                                  farmer.marketName,
                                  color: AppColors.textSecondary,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],

                        // ── 6. Action row: Follow + Chat ──────────────────────
                        const SizedBox(height: AppSpacing.l),
                        Row(
                          children: [
                            // FollowFarmerButton — follow-state logic untouched
                            Expanded(
                              child: FollowFarmerButton(
                                farmerId: effectiveFarmerId,
                                farmerName: farmer.businessName,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.s),
                            // ChatFarmerButton compact — chat logic untouched
                            ChatFarmerButton(
                              farmerId: effectiveFarmerId,
                              farmerName: farmer.businessName,
                              compact: true,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── 7. "Listed Produce" section header ───────────────────────────
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.l,
                ),
                sliver: SliverToBoxAdapter(
                  child: AppSectionHeader(
                    title: 'Listed Produce',
                    trailing: isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.0,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.primary),
                            ),
                          )
                        : AppText.caption(
                            '${products.length} item${products.length == 1 ? '' : 's'}',
                            color: AppColors.textSecondary,
                          ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.s)),

              // ── 8. Product grid ───────────────────────────────────────────────
              if (isLoading)
                // Shimmer grid using the same column derivation as the real grid
                // below, so the products do not reflow when they arrive.
                SliverToBoxAdapter(
                  child: ShimmerProductGrid(count: context.resp.productColumns * 2),
                )
              else if (products.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyProducts(farmerName: farmer.businessName),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.l,
                    0,
                    AppSpacing.l,
                    AppSpacing.xxl,
                  ),
                  sliver: SliverGrid(
                    gridDelegate: context.resp.productGridDelegate(
                      horizontalPad: AppSpacing.screenHorizontalPadding,
                      horizontalGutter: AppSpacing.gridHorizontalGutter,
                      verticalGutter: AppSpacing.m,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final product = products[index];
                        return AppMediaCard(
                          title: product.itemName,
                          subtitle:
                              product.unit.isNotEmpty ? product.unit : null,
                          price: 'Rs. ${product.pricePerUnit}/${product.unit}',
                          imageUrl: product.imageUrl,
                          isOutOfStock: product.stockQty <= 0,
                          showBottomButton: false,
                          onTap: () => Get.toNamed(
                            Routes.customerProductDetails,
                            arguments: product,
                          ),
                        );
                      },
                      childCount: products.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero Banner — AppBanner container styling applied to a custom header
// ─────────────────────────────────────────────────────────────────────────────
class _HeroBanner extends StatelessWidget {
  final FarmerModel farmer;

  const _HeroBanner({required this.farmer});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Gradient banner background — matches AppBanner gradient colours
          Container(
            height: 180,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.bannerBgStart, AppColors.bannerBgEnd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                // Decorative circles — mirrors AppBanner inner decoration
                Positioned(
                  right: -24,
                  bottom: -24,
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withValues(alpha: 0.07),
                    ),
                  ),
                ),
                Positioned(
                  left: -16,
                  top: -16,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryDark.withValues(alpha: 0.05),
                    ),
                  ),
                ),
                // Eco leaf decorative icon matching AppBanner icon style
                Positioned(
                  right: 28,
                  top: 56,
                  child: Icon(
                    Icons.eco_rounded,
                    size: 80,
                    color: AppColors.primaryDark.withValues(alpha: 0.12),
                  ),
                ),
              ],
            ),
          ),

          // Circular farmer avatar — centred, overhangs banner bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: AppColors.chipHerbsBg,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.surfaceWhite, width: 3.0),
                  boxShadow: AppRadius.cardElevation,
                ),
                child: const Center(
                  child: Icon(
                    Icons.storefront_rounded,
                    size: 42,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty state when farmer has no listed products
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyProducts extends StatelessWidget {
  final String farmerName;
  const _EmptyProducts({required this.farmerName});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: AppColors.primary.withValues(alpha: 0.28),
          ),
          const SizedBox(height: AppSpacing.l),
          AppText.sectionHeading(
            'No produce listed yet',
            color: AppColors.textPrimary,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.s),
          AppText.body(
            '$farmerName hasn\'t listed any products yet. Check back soon!',
            color: AppColors.textSecondary,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
