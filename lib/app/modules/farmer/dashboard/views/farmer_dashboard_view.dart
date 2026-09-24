import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../data/models/farmer_order_model.dart';
import '../../farmer_theme.dart';
import '../../widgets/farmer_widgets.dart';
import '../controllers/dashboard_controller.dart';
import '../../products/views/products_view.dart';
import '../../products/views/product_form_view.dart';
import '../../products/controllers/products_controller.dart';
import '../../inventory/views/inventory_view.dart';
import '../../orders/views/orders_view.dart';
import '../../orders/views/order_detail_view.dart';
import '../../orders/controllers/orders_controller.dart';
import '../../reports/views/reports_view.dart';
import '../../profile/views/profile_view.dart';

/// Root shell of the Farmer module with an animated modern bottom navigation bar.
class FarmerDashboardView extends GetView<DashboardController> {
  const FarmerDashboardView({super.key});

  static const List<Widget> _pages = [
    _DashboardHomeTab(),
    ProductsView(),
    OrdersView(),
    ReportsView(),
    ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FarmerColors.background,
      body: Obx(() => IndexedStack(
            index: controller.currentIndex.value,
            children: _pages,
          )),
      bottomNavigationBar: Obx(() => _FarmerBottomNavBar(
            currentIndex: controller.currentIndex.value,
            onTap: controller.changeTab,
          )),
    );
  }
}

// ── Modern Animated Bottom Navigation Bar ─────────────────────────────────────

class _FarmerBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _FarmerBottomNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  static const _navItems = [
    _NavItem(icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard_rounded, label: 'Dashboard'),
    _NavItem(icon: Icons.eco_outlined, activeIcon: Icons.eco_rounded, label: 'Products'),
    _NavItem(icon: Icons.receipt_long_outlined, activeIcon: Icons.receipt_long_rounded, label: 'Orders'),
    _NavItem(icon: Icons.bar_chart_outlined, activeIcon: Icons.bar_chart_rounded, label: 'Reports'),
    _NavItem(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: FarmerColors.border, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1F2A1F).withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_navItems.length, (index) {
              final isSelected = currentIndex == index;
              final item = _navItems[index];

              return Expanded(
                child: Semantics(
                  button: true,
                  selected: isSelected,
                  label: item.label,
                  child: InkWell(
                    onTap: () => onTap(index),
                    splashColor: FarmerColors.primary.withValues(alpha: 0.1),
                    highlightColor: Colors.transparent,
                    child: Center(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOutCubic,
                        padding: EdgeInsets.symmetric(
                          horizontal: isSelected ? 12 : 6,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? FarmerColors.primary.withValues(alpha: 0.12)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isSelected ? item.activeIcon : item.icon,
                              color: isSelected
                                  ? FarmerColors.primaryDark
                                  : FarmerColors.muted,
                              size: 22,
                            ),
                            const SizedBox(height: 3),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                item.label,
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? FarmerColors.primaryDark
                                      : FarmerColors.muted,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

// ── Dashboard Home Tab ────────────────────────────────────────────────────────

class _DashboardHomeTab extends GetView<DashboardController> {
  const _DashboardHomeTab();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final greeting = _getGreeting(now.hour);
    final dateStr = DateFormat('EEEE, d MMMM').format(now);

    return Scaffold(
      backgroundColor: FarmerColors.background,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const _DashboardLoadingSkeleton();
          }
          if (controller.errorMessage.value.isNotEmpty) {
            return _DashboardErrorState(
              message: controller.errorMessage.value,
              onRetry: controller.loadStats,
            );
          }

          return RefreshIndicator(
            color: FarmerColors.primary,
            backgroundColor: Colors.white,
            onRefresh: () async {
              await controller.loadStats();
              if (Get.isRegistered<OrdersController>()) {
                await Get.find<OrdersController>().loadOrders();
              }
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                // 1. Premium Gradient Header Banner
                StaggeredFadeSlide(
                  index: 0,
                  child: _HeaderBanner(
                    greeting: greeting,
                    dateStr: dateStr,
                    farmName: 'Green Valley Farm',
                  ),
                ),
                const SizedBox(height: 20),

                // 2. Horizontal Quick Actions
                StaggeredFadeSlide(
                  index: 1,
                  child: _HorizontalQuickActions(controller: controller),
                ),
                const SizedBox(height: 22),

                // 3. 2x2 Overview Stat Cards
                StaggeredFadeSlide(
                  index: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader(
                        title: 'Farm Overview',
                        subtitle: 'Real-time performance metrics',
                      ),
                      GridView(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          mainAxisExtent: 140, // Prevents bottom overflow on any screen
                        ),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          StatCard(
                            icon: Icons.eco_rounded,
                            label: 'Total Products',
                            value: controller.totalProducts.value,
                            color: FarmerColors.primary,
                            onTap: () => controller.changeTab(1),
                          ),
                          StatCard(
                            icon: Icons.receipt_long_rounded,
                            label: 'Total Orders',
                            value: controller.totalOrders.value,
                            color: FarmerColors.statusConfirmed,
                            onTap: () => controller.changeTab(2),
                          ),
                          StatCard(
                            icon: Icons.pending_actions_rounded,
                            label: 'Pending Orders',
                            value: controller.pendingOrders.value,
                            color: FarmerColors.statusPending,
                            onTap: () => controller.changeTab(2),
                          ),
                          StatCard(
                            icon: Icons.payments_rounded,
                            label: 'Total Revenue',
                            value: controller.totalRevenue.value,
                            prefix: 'PKR ',
                            color: FarmerColors.primaryDark,
                            onTap: () => controller.changeTab(3),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),

                // 4. Revenue Mini Bar Chart (fl_chart)
                StaggeredFadeSlide(
                  index: 3,
                  child: _RevenueMiniBarChart(
                    totalRevenue: controller.totalRevenue.value,
                    onViewReports: () => controller.changeTab(3),
                  ),
                ),
                const SizedBox(height: 22),

                // 5. Recent Orders List
                StaggeredFadeSlide(
                  index: 4,
                  child: _RecentOrdersSection(
                    onViewAll: () => controller.changeTab(2),
                  ),
                ),
                const SizedBox(height: 20),

                // 6. Farmer Tip & Insights Card
                StaggeredFadeSlide(
                  index: 5,
                  child: const _ProTipCard(),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  String _getGreeting(int hour) {
    if (hour < 12) return 'Good Morning 🌱';
    if (hour < 17) return 'Good Afternoon ☀️';
    return 'Good Evening 🌙';
  }
}

// ── Header Banner ─────────────────────────────────────────────────────────────

class _HeaderBanner extends StatelessWidget {
  final String greeting;
  final String dateStr;
  final String farmName;

  const _HeaderBanner({
    required this.greeting,
    required this.dateStr,
    required this.farmName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: FarmerColors.heroGradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: FarmerColors.primaryGlow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Avatar + Farm Name + Notification Bell
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.2),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Center(
                  child: Icon(Icons.person_rounded, color: Colors.white, size: 26),
                ),
              ),
              const SizedBox(width: 12),
              // Name & Greeting
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      farmName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),
              // Notification Bell
              Semantics(
                button: true,
                label: 'Notifications',
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Get.snackbar(
                        'Notifications',
                        'You are all caught up for today!',
                        snackPosition: SnackPosition.TOP,
                        backgroundColor: Colors.white,
                        colorText: FarmerColors.text,
                        margin: const EdgeInsets.all(16),
                      );
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(Icons.notifications_outlined,
                              color: Colors.white, size: 22),
                          Positioned(
                            top: 8,
                            right: 9,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: FarmerColors.accent,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Bottom status row in banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded,
                        color: Colors.white70, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      dateStr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: FarmerColors.secondary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle, size: 12, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        'Store Open',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Horizontal Quick Actions ──────────────────────────────────────────────────

class _HorizontalQuickActions extends StatelessWidget {
  final DashboardController controller;
  const _HorizontalQuickActions({required this.controller});

  @override
  Widget build(BuildContext context) {
    final actions = [
      _QuickActionData(
        icon: Icons.add_circle_outline_rounded,
        label: 'Add Product',
        color: FarmerColors.primary,
        onTap: () {
          if (Get.isRegistered<ProductsController>()) {
            Get.find<ProductsController>().prepareForAdd();
          }
          Get.to(() => const ProductFormView(),
              transition: Transition.rightToLeft);
        },
      ),
      _QuickActionData(
        icon: Icons.inventory_2_outlined,
        label: 'Inventory',
        color: FarmerColors.secondary,
        onTap: () {
          Get.to(() => const InventoryView(),
              transition: Transition.rightToLeft);
        },
      ),
      _QuickActionData(
        icon: Icons.receipt_long_outlined,
        label: 'Orders',
        color: FarmerColors.statusConfirmed,
        onTap: () => controller.changeTab(2),
      ),
      _QuickActionData(
        icon: Icons.insights_rounded,
        label: 'Analytics',
        color: FarmerColors.accent,
        onTap: () => controller.changeTab(3),
      ),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: actions.map((item) {
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Semantics(
              button: true,
              label: item.label,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: item.onTap,
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                          color: item.color.withValues(alpha: 0.3), width: 1),
                      boxShadow: FarmerColors.cardShadow,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: item.color.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(item.icon, color: item.color, size: 16),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: FarmerColors.text,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _QuickActionData {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionData({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}

// ── Revenue Mini Bar Chart with fl_chart ──────────────────────────────────────

class _RevenueMiniBarChart extends StatelessWidget {
  final double totalRevenue;
  final VoidCallback onViewReports;

  const _RevenueMiniBarChart({
    required this.totalRevenue,
    required this.onViewReports,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Revenue Pulse',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: FarmerColors.text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Weekly sales performance',
                    style: FarmerTextStyles.caption.copyWith(
                      color: FarmerColors.muted,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: onViewReports,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Row(
                    children: const [
                      Text(
                        'Details',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: FarmerColors.primary,
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded,
                          size: 16, color: FarmerColors.primary),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Mini bar chart
          SizedBox(
            height: 110,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 100,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => FarmerColors.primaryDark,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        FarmerCurrency.format((rod.toY * 65).toInt()),
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitlesWidget: (value, meta) {
                        const days = [
                          'Mon',
                          'Tue',
                          'Wed',
                          'Thu',
                          'Fri',
                          'Sat',
                          'Sun'
                        ];
                        final idx = value.toInt();
                        if (idx >= 0 && idx < days.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              days[idx],
                              style: TextStyle(
                                fontSize: 10,
                                color: idx == 5
                                    ? FarmerColors.primaryDark
                                    : FarmerColors.muted,
                                fontWeight: idx == 5
                                    ? FontWeight.w800
                                    : FontWeight.w500,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: [
                  _makeBarGroup(0, 35),
                  _makeBarGroup(1, 52),
                  _makeBarGroup(2, 40),
                  _makeBarGroup(3, 70),
                  _makeBarGroup(4, 62),
                  _makeBarGroup(5, 92, isHighlight: true),
                  _makeBarGroup(6, 68),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _makeBarGroup(int x, double y, {bool isHighlight = false}) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          width: 14,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          color: isHighlight ? FarmerColors.primary : const Color(0xFFC8E6C9),
        ),
      ],
    );
  }
}

// ── Recent Orders Section ─────────────────────────────────────────────────────

class _RecentOrdersSection extends StatelessWidget {
  final VoidCallback onViewAll;
  const _RecentOrdersSection({required this.onViewAll});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<OrdersController>()) {
      return const SizedBox.shrink();
    }

    final ordersCtrl = Get.find<OrdersController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Recent Orders',
          subtitle: 'Latest customer requests',
          actionLabel: 'View All',
          onActionTap: onViewAll,
        ),
        Obx(() {
          if (ordersCtrl.isLoading.value) {
            return const CardListShimmer(count: 2);
          }
          if (ordersCtrl.orders.isEmpty) {
            return AppCard(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.shopping_bag_outlined,
                      size: 40,
                      color: FarmerColors.muted.withValues(alpha: 0.6),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'No recent orders',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: FarmerColors.text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'New orders from customers will appear here.',
                      style: TextStyle(fontSize: 12, color: FarmerColors.muted),
                    ),
                  ],
                ),
              ),
            );
          }

          final recent = ordersCtrl.orders.take(3).toList();

          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recent.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, index) {
              final order = recent[index];
              return _RecentOrderCard(order: order);
            },
          );
        }),
      ],
    );
  }
}

class _RecentOrderCard extends StatelessWidget {
  final FarmerOrder order;
  const _RecentOrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('d MMM, h:mm a').format(order.createdAt);
    final itemCount = order.items.length;
    final itemText = itemCount == 1 ? '1 item' : '$itemCount items';

    return AppCard(
      padding: const EdgeInsets.all(14),
      onTap: () {
        Get.to(
          () => OrderDetailView(order: order),
          transition: Transition.rightToLeft,
        );
      },
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: FarmerColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.receipt_rounded,
              color: FarmerColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        order.customerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: FarmerColors.text,
                        ),
                      ),
                    ),
                    Text(
                      FarmerCurrency.format(order.totalAmount),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: FarmerColors.primaryDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$itemText • $dateStr',
                      style: const TextStyle(
                        fontSize: 12,
                        color: FarmerColors.muted,
                      ),
                    ),
                    StatusChip.fromOrderStatus(order.status),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Pro Tip Card ──────────────────────────────────────────────────────────────

class _ProTipCard extends StatelessWidget {
  const _ProTipCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F8EC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: FarmerColors.secondary.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: FarmerColors.secondary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.tips_and_updates_outlined,
              color: FarmerColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'HarvestHub Tip',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: FarmerColors.primaryDark,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Updating stock levels every morning boosts visibility to nearby buyers by up to 35%.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF384D35),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Skeleton Loader for Dashboard ─────────────────────────────────────────────

class _DashboardLoadingSkeleton extends StatelessWidget {
  const _DashboardLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        const ShimmerBox(height: 130),
        const SizedBox(height: 18),
        Row(
          children: const [
            Expanded(child: ShimmerBox(height: 40)),
            SizedBox(width: 8),
            Expanded(child: ShimmerBox(height: 40)),
            SizedBox(width: 8),
            Expanded(child: ShimmerBox(height: 40)),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          children: const [
            Expanded(child: ShimmerBox(height: 135)),
            SizedBox(width: 12),
            Expanded(child: ShimmerBox(height: 135)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: const [
            Expanded(child: ShimmerBox(height: 135)),
            SizedBox(width: 12),
            Expanded(child: ShimmerBox(height: 135)),
          ],
        ),
        const SizedBox(height: 18),
        const ShimmerBox(height: 160),
      ],
    );
  }
}

// ── Error State ───────────────────────────────────────────────────────────────

class _DashboardErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _DashboardErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: FarmerColors.errorBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline_rounded,
                  size: 48, color: FarmerColors.error),
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to Load Dashboard',
              style: FarmerTextStyles.title.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: FarmerTextStyles.body.copyWith(color: FarmerColors.muted),
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: 'Retry',
              icon: Icons.refresh_rounded,
              onPressed: onRetry,
              width: 140,
              height: 44,
            ),
          ],
        ),
      ),
    );
  }
}
