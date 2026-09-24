import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../farmer_theme.dart';
import '../controllers/dashboard_controller.dart';
import '../../products/views/products_view.dart';
import '../../inventory/views/inventory_view.dart';
import '../../orders/views/orders_view.dart';
import '../../reports/views/reports_view.dart';
import '../../profile/views/profile_view.dart';

/// Root shell of the Farmer module – owns the BottomNavigationBar.
/// Each tab body is a separate view with its own controller.
class FarmerDashboardView extends GetView<DashboardController> {
  const FarmerDashboardView({super.key});

  // Pages rendered per tab (index matches nav item order)
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
      body: Obx(() => IndexedStack(
            index: controller.currentIndex.value,
            children: _pages,
          )),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
            currentIndex: controller.currentIndex.value,
            onTap: controller.changeTab,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: FarmerColors.primary,
            unselectedItemColor: const Color(0xFF9E9E9E),
            backgroundColor: Colors.white,
            elevation: 12,
            selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w700, fontSize: 11),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_outlined),
                activeIcon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.eco_outlined),
                activeIcon: Icon(Icons.eco),
                label: 'Products',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.receipt_long_outlined),
                activeIcon: Icon(Icons.receipt_long),
                label: 'Orders',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart_outlined),
                activeIcon: Icon(Icons.bar_chart),
                label: 'Reports',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          )),
    );
  }
}

// ── Dashboard home tab ────────────────────────────────────────────────────────

/// The "Dashboard" tab content (index 0) – KPI overview + quick actions.
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
            return const Center(
                child:
                    CircularProgressIndicator(color: FarmerColors.primary));
          }
          if (controller.errorMessage.value.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline,
                      size: 56, color: FarmerColors.error),
                  const SizedBox(height: 12),
                  Text(controller.errorMessage.value,
                      textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: controller.loadStats,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: FarmerColors.primary,
                        foregroundColor: Colors.white),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: FarmerColors.primary,
            onRefresh: controller.loadStats,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              children: [
                // ── Header ───────────────────────────────────────────────
                _HeaderBanner(greeting: greeting, dateStr: dateStr),
                const SizedBox(height: 24),

                // ── KPI cards ────────────────────────────────────────────
                const Text('Overview', style: FarmerTextStyles.heading),
                const SizedBox(height: 14),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.2,
                  children: [
                    _KpiCard(
                      icon: Icons.eco,
                      label: 'Products',
                      value: controller.totalProducts.value.toString(),
                      color: FarmerColors.primary,
                      onTap: () => controller.changeTab(1),
                    ),
                    _KpiCard(
                      icon: Icons.receipt_long,
                      label: 'Total Orders',
                      value: controller.totalOrders.value.toString(),
                      color: FarmerColors.statusConfirmed,
                      onTap: () => controller.changeTab(2),
                    ),
                    _KpiCard(
                      icon: Icons.pending_actions,
                      label: 'Pending',
                      value: controller.pendingOrders.value.toString(),
                      color: FarmerColors.accent,
                      onTap: () => controller.changeTab(2),
                    ),
                    _KpiCard(
                      icon: Icons.attach_money,
                      label: 'Revenue (PKR)',
                      value: controller.totalRevenue.value
                          .toStringAsFixed(0),
                      color: FarmerColors.statusCompleted,
                      onTap: () => controller.changeTab(3),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // ── Quick actions ────────────────────────────────────────
                const Text('Quick Actions', style: FarmerTextStyles.heading),
                const SizedBox(height: 14),
                _QuickActionsRow(controller: controller),
                const SizedBox(height: 28),

                // ── Tips card ────────────────────────────────────────────
                _TipsCard(),
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

// ── Header banner ─────────────────────────────────────────────────────────────

class _HeaderBanner extends StatelessWidget {
  const _HeaderBanner({required this.greeting, required this.dateStr});
  final String greeting;
  final String dateStr;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [FarmerColors.primary, Color(0xFF43A047)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: FarmerColors.primary.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(greeting,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(dateStr,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 10),
                const Text('Welcome back, Farmer!',
                    style: TextStyle(color: Colors.white60, fontSize: 13)),
              ],
            ),
          ),
          const Icon(Icons.agriculture, size: 56, color: Colors.white24),
        ],
      ),
    );
  }
}

// ── KPI card ──────────────────────────────────────────────────────────────────

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 10),
            Text(value,
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w800, color: color)),
            const SizedBox(height: 4),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 12, color: Color(0xFF666666))),
          ],
        ),
      ),
    );
  }
}

// ── Quick actions row ─────────────────────────────────────────────────────────

class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow({required this.controller});
  final DashboardController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _QuickAction(
          icon: Icons.add_box_outlined,
          label: 'Add Product',
          color: FarmerColors.primary,
          onTap: () => controller.changeTab(1),
        ),
        const SizedBox(width: 12),
        _QuickAction(
          icon: Icons.inventory_2_outlined,
          label: 'Inventory',
          color: FarmerColors.secondary,
          onTap: () {
            // Navigate to inventory (outside of bottom nav)
            Get.to(() => const InventoryView(),
                transition: Transition.rightToLeft);
          },
        ),
        const SizedBox(width: 12),
        _QuickAction(
          icon: Icons.receipt_long_outlined,
          label: 'Orders',
          color: FarmerColors.accent,
          onTap: () => controller.changeTab(2),
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 6),
              Text(label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Tips card ─────────────────────────────────────────────────────────────────

class _TipsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FarmerColors.secondary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: FarmerColors.secondary.withValues(alpha: 0.4)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline, color: FarmerColors.secondary),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Farmer Tip',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: FarmerColors.primary)),
                SizedBox(height: 4),
                Text(
                  'Keep your stock updated daily. Products with 0 stock are automatically marked "Out of Stock" and hidden from customer orders.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF4A6741)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
