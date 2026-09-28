import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/theme/app_colors.dart';
import 'package:harvest_hub/app/core/theme/app_radius.dart';
import 'package:harvest_hub/app/core/theme/app_spacing.dart';
import 'package:harvest_hub/app/core/theme/app_text_styles.dart';
import 'package:harvest_hub/app/core/responsive/responsive.dart';
import 'package:harvest_hub/app/core/utils/helpers.dart';
import 'package:harvest_hub/app/core/widgets/app_shimmer.dart';
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

  String _formatToday() {
    final now = DateTime.now();
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    const weekdays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
    ];
    return '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}, ${now.year}';
  }

  Widget _platformSalesHeroCard({
    required num revenue,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: AppRadius.cardRadius,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryDark,
            AppColors.primaryButton,
          ],
        ),
        boxShadow: AppRadius.cardElevation,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.cardRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.cardRadius,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Platform Sales',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13.0,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Container(
                      width: 40.0,
                      height: 40.0,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.20),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: const Icon(
                        Icons.payments_rounded,
                        size: 22.0,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s),
                Text(
                  money(revenue),
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 28.0,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2.0),
                Text(
                  'excluding cancelled orders',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12.0,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withValues(alpha: 0.80),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _quickShortcut({
    required String title,
    required IconData icon,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 88.0,
      height: 88.0,
      margin: const EdgeInsets.only(right: AppSpacing.gridHorizontalGutter),
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
              vertical: AppSpacing.s,
              horizontal: 6.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 40.0,
                  height: 40.0,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Icon(
                    icon,
                    size: 20.0,
                    color: iconColor,
                  ),
                ),
                const SizedBox(height: 6.0),
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
      drawerScrimColor: Colors.black.withValues(alpha: 0.35),
      appBar: AppAppBar(
        titleText: 'Admin Dashboard',
        leadingWidth: 56.0,
        leading: Builder(
          builder: (ctx) => Padding(
            padding: const EdgeInsets.only(left: AppSpacing.l),
            child: AppIconButton(
              icon: Icons.menu_rounded,
              iconColor: AppColors.primaryDark,
              backgroundColor: AppColors.surfaceMuted,
              size: 40.0,
              tooltip: 'Menu',
              onTap: () => Scaffold.of(ctx).openDrawer(),
            ),
          ),
        ),
        actions: [
          AppIconButton(
            icon: Icons.refresh_rounded,
            iconColor: AppColors.primaryDark,
            backgroundColor: AppColors.surfaceMuted,
            size: 40.0,
            tooltip: 'Refresh',
            onTap: controller.load,
          ),
        ],
      ),
      drawer: const AdminDrawer(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const ShimmerDetailBlock();
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
                // 1. Greeting & Date from Device
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppText.sectionHeading(
                      'Welcome back',
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                    const SizedBox(height: 2.0),
                    AppText.caption(
                      _formatToday(),
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.l),

                // 2. Hero Platform Sales Card with Primary Gradient
                _platformSalesHeroCard(
                  revenue: controller.revenue.value,
                  onTap: () => Get.toNamed(Routes.reports),
                ),

                const SizedBox(height: AppSpacing.m),

                // 3. Platform Stats Grid (2-column AppStatCards with 12px gutters)
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  // 2 columns on a phone (unchanged); the count is derived so a
                  // tablet adds a column instead of stretching each card to
                  // half the screen width. Fixed 156px height is preserved.
                  gridDelegate: context.resp.statGridDelegate(
                    minTileWidth: 160,
                    gutter: AppSpacing.gridHorizontalGutter,
                    extent: 156,
                  ),
                  itemCount: 6,
                  itemBuilder: (context, index) {
                    switch (index) {
                      case 0:
                        return AppStatCard(
                          title: 'Total Orders',
                          value: '${controller.totalOrders.value}',
                          icon: Icons.receipt_long_rounded,
                          iconColor: const Color(0xFF1565C0),
                          iconBgColor: const Color(0xFFE3F2FD),
                          onTap: () => Get.toNamed(Routes.orders),
                        );
                      case 1:
                        return AppStatCard(
                          title: 'Active Customers',
                          value: '${controller.customers.value}',
                          icon: Icons.people_rounded,
                          iconColor: const Color(0xFFE65100),
                          iconBgColor: AppColors.chipFruitsBg,
                          onTap: () => Get.toNamed(Routes.customers),
                        );
                      case 2:
                        return AppStatCard(
                          title: 'Verified Farmers',
                          value: '${controller.farmers.value}',
                          icon: Icons.agriculture_rounded,
                          iconColor: const Color(0xFF5D4037),
                          iconBgColor: AppColors.chipGrainsBg,
                          onTap: () => Get.toNamed(Routes.farmers),
                        );
                      case 3:
                        return AppStatCard(
                          title: 'Listed Produce',
                          value: '${controller.products.value}',
                          icon: Icons.inventory_2_rounded,
                          iconColor: AppColors.primaryDark,
                          iconBgColor: AppColors.chipHerbsBg,
                          onTap: () => Get.toNamed(Routes.products),
                        );
                      case 4:
                        return AppStatCard(
                          title: 'Partner Markets',
                          value: '${controller.markets.value}',
                          icon: Icons.storefront_rounded,
                          iconColor: const Color(0xFF4527A0),
                          iconBgColor: const Color(0xFFEDE7F6),
                          onTap: () => Get.toNamed(Routes.markets),
                        );
                      case 5:
                      default:
                        return AppStatCard(
                          title: 'Categories',
                          value: '${controller.categories.value}',
                          icon: Icons.category_rounded,
                          iconColor: const Color(0xFF00695C),
                          iconBgColor: const Color(0xFFE0F2F1),
                          onTap: () => Get.toNamed(Routes.categories),
                        );
                    }
                  },
                ),

                const SizedBox(height: AppSpacing.xxl), // 24px between sections

                // 4. Quick Management Section
                AppSectionHeader(
                  title: 'Quick Management',
                  actionTitle: 'All Reports',
                  onActionTap: () => Get.toNamed(Routes.reports),
                ),
                const SizedBox(height: AppSpacing.m), // 12px between header and content
                SizedBox(
                  height: 92.0,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    clipBehavior: Clip.none,
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

                const SizedBox(height: AppSpacing.xxl), // 24px between sections

                // 5. Recent Activity: Recent Orders Section
                AppSectionHeader(
                  title: 'Recent Orders',
                  actionTitle: 'View All',
                  onActionTap: () => Get.toNamed(Routes.orders),
                ),
                const SizedBox(height: AppSpacing.m), // 12px between header and content
                if (controller.recentOrders.isEmpty)
                  AppCard(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.xxl,
                      horizontal: AppSpacing.l,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const AppIcon(
                            Icons.receipt_long_outlined,
                            size: 32.0,
                            color: AppColors.textDisabled,
                          ),
                          const SizedBox(height: AppSpacing.s),
                          const AppText.cardTitle(
                            'No recent orders yet',
                            color: AppColors.textSecondary,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 2.0),
                          const AppText.caption(
                            'New customer orders will appear here automatically',
                            color: AppColors.textDisabled,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  AppCard.list(
                    padding: const EdgeInsets.all(AppSpacing.l),
                    children: [
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

                const SizedBox(height: AppSpacing.xxl), // 24px between sections

                // 6. Most Active Farmers Section
                AppSectionHeader(
                  title: 'Most Active Farmers',
                  actionTitle: 'View All',
                  onActionTap: () => Get.toNamed(Routes.farmers),
                ),
                const SizedBox(height: AppSpacing.m), // 12px between header and content
                if (controller.topFarmers.isEmpty)
                  AppCard(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.xxl,
                      horizontal: AppSpacing.l,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const AppIcon(
                            Icons.agriculture_outlined,
                            size: 32.0,
                            color: AppColors.textDisabled,
                          ),
                          const SizedBox(height: AppSpacing.s),
                          const AppText.cardTitle(
                            'No active farmer activity recorded yet',
                            color: AppColors.textSecondary,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 2.0),
                          const AppText.caption(
                            'Farmer fulfilled orders will be ranked here',
                            color: AppColors.textDisabled,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  AppCard.list(
                    padding: const EdgeInsets.all(AppSpacing.l),
                    children: [
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
