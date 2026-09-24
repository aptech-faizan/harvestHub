import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../farmer_theme.dart';
import '../controllers/reports_controller.dart';

/// Reports / Analytics screen showing summary KPI cards.
class ReportsView extends GetView<ReportsController> {
  const ReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FarmerColors.background,
      appBar: AppBar(
        backgroundColor: FarmerColors.primary,
        title: const Text('Reports & Analytics',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: controller.loadStats,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
              child: CircularProgressIndicator(color: FarmerColors.primary));
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
            padding: const EdgeInsets.all(20),
            children: [
              const Text('Summary', style: FarmerTextStyles.heading),
              const SizedBox(height: 16),

              // ── KPI grid ──────────────────────────────────────────────
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 1.25,
                children: [
                  _KpiCard(
                    icon: Icons.inventory_2_outlined,
                    label: 'Total Products',
                    value: controller.totalProducts.value.toString(),
                    color: FarmerColors.primary,
                  ),
                  _KpiCard(
                    icon: Icons.receipt_long_outlined,
                    label: 'Total Orders',
                    value: controller.totalOrders.value.toString(),
                    color: FarmerColors.statusConfirmed,
                  ),
                  _KpiCard(
                    icon: Icons.pending_actions_outlined,
                    label: 'Pending Orders',
                    value: controller.pendingOrders.value.toString(),
                    color: FarmerColors.accent,
                  ),
                  _KpiCard(
                    icon: Icons.attach_money,
                    label: 'Total Revenue',
                    value:
                        'PKR ${controller.totalRevenue.value.toStringAsFixed(0)}',
                    color: FarmerColors.statusCompleted,
                  ),
                ],
              ),

              const SizedBox(height: 28),
              // ── Chart placeholder ─────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
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
                  children: [
                    Icon(Icons.bar_chart,
                        size: 64,
                        color: FarmerColors.secondary.withValues(alpha: 0.7)),
                    const SizedBox(height: 12),
                    const Text('Sales Chart',
                        style: FarmerTextStyles.subheading),
                    const SizedBox(height: 8),
                    const Text(
                      'Detailed revenue charts will be available once Firebase integration is complete.',
                      textAlign: TextAlign.center,
                      style: FarmerTextStyles.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

// ── KPI card widget ───────────────────────────────────────────────────────────

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
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
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 10),
          Text(value,
              style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 4),
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Color(0xFF666666))),
        ],
      ),
    );
  }
}
