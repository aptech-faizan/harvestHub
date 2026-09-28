import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/theme/app_colors.dart';
import 'package:harvest_hub/app/core/theme/app_radius.dart';
import 'package:harvest_hub/app/core/theme/app_spacing.dart';
import 'package:harvest_hub/app/core/theme/app_text_styles.dart';
import 'package:harvest_hub/app/core/utils/helpers.dart';
import 'package:harvest_hub/app/core/widgets/app_widgets.dart';
import 'package:harvest_hub/app/modules/admin/dashboard/controllers/dashboard_controller.dart';
import 'package:harvest_hub/app/modules/admin/widgets/admin_drawer.dart';
import 'package:harvest_hub/app/routes/app_routes.dart';

/// Admin Dashboard screen conforming to the HarvestHub Design System:
/// - AppAppBar with refresh action & AdminDrawer
/// - Top grid of shared AppStatCard widgets for platform stats (sales, users, orders, etc.)
/// - AppSectionHeader + quick-link shortcuts to Categories/Products/Orders/etc.
/// - Recent Activity section in AppCard.list pattern (recent orders & active farmers)
class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  Widget _quickShortcut({
    required String title,
    required IconData icon,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 90.0,
      margin: const EdgeInsets.only(right: AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: AppRadius.cardRadius,
        border: Border.all(color: AppColors.divider, width: 1.0),
        boxShadow: AppRadius.cardElevation,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.cardRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.cardRadius,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.m,
              horizontal: AppSpacing.s,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 42.0,
                  height: 42.0,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 20.0,
                    color: iconColor,
                  ),
                ),
                const SizedBox(height: AppSpacing.s),
                Text(
                  title,
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceWhite,
      appBar: AppAppBar(
        titleText: 'Admin Dashboard',
        actions: [
          AppIconButton(
            icon: Icons.refresh_rounded,
            tooltip: 'Refresh',
            onTap: controller.load,
          ),
        ],
      ),
      drawer: const AdminDrawer(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (controller.error.value.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    size: 48.0,
                    color: AppColors.accentRed,
                  ),
                  const SizedBox(height: AppSpacing.m),
                  AppText.sectionHeading(
                    'Failed to load dashboard',
                    color: AppColors.accentRed,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  AppText.body(
                    controller.error.value,
                    color: AppColors.textSecondary,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.l),
                  AppButton.small(
                    label: 'Retry',
                    icon: Icons.refresh_rounded,
                    onPressed: controller.load,
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: controller.load,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontalPadding,
              vertical: AppSpacing.l,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Hero Revenue Stat Card
                AppStatCard(
                  title: 'Platform Sales (excluding cancelled orders)',
                  value: money(controller.revenue.value),
                  trend: '+18.4%',
                  isPositiveTrend: true,
                  icon: Icons.payments_rounded,
                  iconColor: AppColors.primaryDark,
                  iconBgColor: AppColors.chipHerbsBg,
                  onTap: () => Get.toNamed(Routes.reports),
                ),

                const SizedBox(height: AppSpacing.m),

                // 2. Platform Stats Grid (2-column AppStatCards)
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: AppSpacing.gridHorizontalGutter, // 12
                  mainAxisSpacing: AppSpacing.gridVerticalGutter,   // 16
                  childAspectRatio: 1.25,
                  children: [
                    AppStatCard(
                      title: 'Total Orders',
                      value: '${controller.totalOrders.value}',
                      trend: '+12%',
                      isPositiveTrend: true,
                      icon: Icons.receipt_long_rounded,
                      iconColor: const Color(0xFF1565C0),
                      iconBgColor: const Color(0xFFE3F2FD),
                      onTap: () => Get.toNamed(Routes.orders),
                    ),
                    AppStatCard(
                      title: 'Active Customers',
                      value: '${controller.customers.value}',
                      trend: '+8%',
                      isPositiveTrend: true,
                      icon: Icons.people_rounded,
                      iconColor: const Color(0xFFE65100),
                      iconBgColor: AppColors.chipFruitsBg,
                      onTap: () => Get.toNamed(Routes.customers),
                    ),
                    AppStatCard(
                      title: 'Verified Farmers',
                      value: '${controller.farmers.value}',
                      trend: '+5%',
                      isPositiveTrend: true,
                      icon: Icons.agriculture_rounded,
                      iconColor: const Color(0xFF5D4037),
                      iconBgColor: AppColors.chipGrainsBg,
                      onTap: () => Get.toNamed(Routes.farmers),
                    ),
                    AppStatCard(
                      title: 'Listed Produce',
                      value: '${controller.products.value}',
                      trend: 'Active',
                      isPositiveTrend: true,
                      icon: Icons.inventory_2_rounded,
                      iconColor: AppColors.primaryDark,
                      iconBgColor: AppColors.chipHerbsBg,
                      onTap: () => Get.toNamed(Routes.products),
                    ),
                    AppStatCard(
                      title: 'Partner Markets',
                      value: '${controller.markets.value}',
                      trend: 'Hubs',
                      isPositiveTrend: true,
                      icon: Icons.storefront_rounded,
                      iconColor: const Color(0xFF4527A0),
                      iconBgColor: const Color(0xFFEDE7F6),
                      onTap: () => Get.toNamed(Routes.markets),
                    ),
                    AppStatCard(
                      title: 'Categories',
                      value: '${controller.categories.value}',
                      trend: 'Live',
                      isPositiveTrend: true,
                      icon: Icons.category_rounded,
                      iconColor: const Color(0xFF00695C),
                      iconBgColor: const Color(0xFFE0F2F1),
                      onTap: () => Get.toNamed(Routes.categories),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.xl),

                // 3. Quick-Link Row with AppSectionHeader
                AppSectionHeader(
                  title: 'Quick Management',
                  actionTitle: 'All Reports',
                  onActionTap: () => Get.toNamed(Routes.reports),
                ),
                const SizedBox(height: AppSpacing.s),
                SizedBox(
                  height: 104.0,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _quickShortcut(
                        title: 'Categories',
                        icon: Icons.category_rounded,
                        color: AppColors.chipFruitsBg,
                        iconColor: AppColors.accentOrange,
                        onTap: () => Get.toNamed(Routes.categories),
                      ),
                      _quickShortcut(
                        title: 'Products',
                        icon: Icons.inventory_2_rounded,
                        color: AppColors.chipHerbsBg,
                        iconColor: AppColors.primaryDark,
                        onTap: () => Get.toNamed(Routes.products),
                      ),
                      _quickShortcut(
                        title: 'Orders',
                        icon: Icons.receipt_long_rounded,
                        color: const Color(0xFFE3F2FD),
                        iconColor: const Color(0xFF1976D2),
                        onTap: () => Get.toNamed(Routes.orders),
                      ),
                      _quickShortcut(
                        title: 'Farmers',
                        icon: Icons.agriculture_rounded,
                        color: AppColors.chipGrainsBg,
                        iconColor: const Color(0xFF8D6E63),
                        onTap: () => Get.toNamed(Routes.farmers),
                      ),
                      _quickShortcut(
                        title: 'Markets',
                        icon: Icons.storefront_rounded,
                        color: const Color(0xFFEDE7F6),
                        iconColor: const Color(0xFF5E35B1),
                        onTap: () => Get.toNamed(Routes.markets),
                      ),
                      _quickShortcut(
                        title: 'Reports',
                        icon: Icons.bar_chart_rounded,
                        color: const Color(0xFFE0F2F1),
                        iconColor: const Color(0xFF00695C),
                        onTap: () => Get.toNamed(Routes.reports),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xxl),

                // 4. Recent Activity: Recent Orders Section
                AppSectionHeader(
                  title: 'Recent Orders',
                  actionTitle: 'View All',
                  onActionTap: () => Get.toNamed(Routes.orders),
                ),
                const SizedBox(height: AppSpacing.s),
                AppCard.list(
                  padding: const EdgeInsets.all(AppSpacing.l),
                  children: [
                    if (controller.recentOrders.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.l,
                        ),
                        child: Center(
                          child: Text(
                            'No recent orders yet',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      )
                    else
                      ...controller.recentOrders.map((o) {
                        final isLast = controller.recentOrders.last == o;
                        final customerName =
                            controller.userNames[o.customerId] ??
                                'Customer #${o.customerId.length >= 4 ? o.customerId.substring(0, 4) : o.customerId}';

                        return Column(
                          children: [
                            InkWell(
                              onTap: () => Get.toNamed(Routes.orders),
                              borderRadius: BorderRadius.circular(8.0),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4.0,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            customerName,
                                            style: AppTextStyles.cardTitle,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2.0),
                                          Text(
                                            formatDate(o.createdAt),
                                            style:
                                                AppTextStyles.caption.copyWith(
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.m),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          money(o.totalPrice),
                                          style: AppTextStyles.priceText,
                                        ),
                                        const SizedBox(height: 4.0),
                                        AppChip.status(status: o.status),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (!isLast)
                              const Divider(
                                color: AppColors.divider,
                                height: 16.0,
                              ),
                          ],
                        );
                      }),
                  ],
                ),

                const SizedBox(height: AppSpacing.xxl),

                // 5. Most Active Farmers Section
                AppSectionHeader(
                  title: 'Most Active Farmers',
                  actionTitle: 'View All',
                  onActionTap: () => Get.toNamed(Routes.farmers),
                ),
                const SizedBox(height: AppSpacing.s),
                AppCard.list(
                  padding: const EdgeInsets.all(AppSpacing.l),
                  children: [
                    if (controller.topFarmers.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.l,
                        ),
                        child: Center(
                          child: Text(
                            'No active farmer activity recorded yet',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      )
                    else
                      ...controller.topFarmers.map((f) {
                        final isLast = controller.topFarmers.last == f;
                        return Column(
                          children: [
                            InkWell(
                              onTap: () => Get.toNamed(Routes.farmers),
                              borderRadius: BorderRadius.circular(8.0),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4.0,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 36.0,
                                      height: 36.0,
                                      decoration: BoxDecoration(
                                        color: AppColors.chipHerbsBg,
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      child: const Icon(
                                        Icons.agriculture_rounded,
                                        size: 20.0,
                                        color: AppColors.primaryDark,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.m),
                                    Expanded(
                                      child: Text(
                                        f.key,
                                        style: AppTextStyles.cardTitle,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0,
                                        vertical: 4.0,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceMuted,
                                        borderRadius:
                                            BorderRadius.circular(999),
                                        border: Border.all(
                                          color: AppColors.divider,
                                          width: 1.0,
                                        ),
                                      ),
                                      child: Text(
                                        '${f.value} ${f.value == 1 ? "order" : "orders"}',
                                        style: AppTextStyles.caption.copyWith(
                                          color: AppColors.primaryDark,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (!isLast)
                              const Divider(
                                color: AppColors.divider,
                                height: 16.0,
                              ),
                          ],
                        );
                      }),
                  ],
                ),

                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        );
      }),
    );
  }
}
