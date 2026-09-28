import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/constants/app_constants.dart';
import 'package:harvest_hub/app/core/theme/app_colors.dart';
import 'package:harvest_hub/app/core/theme/app_radius.dart';
import 'package:harvest_hub/app/core/theme/app_spacing.dart';
import 'package:harvest_hub/app/core/theme/app_text_styles.dart';
import 'package:harvest_hub/app/core/utils/helpers.dart';
import 'package:harvest_hub/app/core/widgets/app_shimmer.dart';
import 'package:harvest_hub/app/core/widgets/app_widgets.dart';
import 'package:harvest_hub/app/modules/admin/reports/controllers/reports_controller.dart';
import 'package:harvest_hub/app/modules/admin/widgets/admin_drawer.dart';

/// Admin Reports & Analytics screen conforming to the HarvestHub Design System:
/// - AppAppBar with drawer toggle, refresh, and PDF export actions
/// - AppChip date-range filter pills (All, Daily, Weekly, Monthly)
/// - Row of AppStatCard metric widgets for headline numbers
/// - FlChart PieChart for Orders by Status with design system tokens
/// - Market Revenue Breakdown & Most Active Farmers leaderboards
class ReportsView extends GetView<ReportsController> {
  const ReportsView({super.key});

  Color _getStatusChartColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFFFA726); // Amber
      case 'confirmed':
        return const Color(0xFF42A5F5); // Blue
      case 'ready_for_pickup':
      case 'ready':
        return const Color(0xFF26A69A); // Teal
      case 'completed':
        return AppColors.primaryDark; // Brand green
      case 'cancelled':
        return AppColors.accentRed; // Red
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getPeriodIcon(String p) {
    switch (p) {
      case 'Daily':
        return Icons.today_rounded;
      case 'Weekly':
        return Icons.date_range_rounded;
      case 'Monthly':
        return Icons.calendar_month_rounded;
      default:
        return Icons.calendar_today_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceMuted,
      appBar: AppAppBar(
        titleText: 'Reports & Analytics',
        leading: Builder(
          builder: (ctx) => AppIconButton(
            icon: Icons.menu,
            iconSize: 22,
            backgroundColor: Colors.transparent,
            iconColor: AppColors.textPrimary,
            isCircle: false,
            onTap: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        actions: [
          Obx(() => AppIconButton(
                icon: Icons.picture_as_pdf_outlined,
                iconSize: 20,
                backgroundColor: AppColors.surfaceMuted,
                iconColor: AppColors.primaryDark,
                tooltip: 'Export PDF Report',
                onTap: controller.isExporting.value ? null : controller.exportPdf,
              )),
          AppIconButton(
            icon: Icons.refresh_rounded,
            iconSize: 20,
            backgroundColor: AppColors.surfaceMuted,
            iconColor: AppColors.primaryDark,
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
          return _buildErrorState();
        }

        return _buildContent(context);
      }),
    );
  }

  Widget _buildContent(BuildContext context) {
    final c = controller;
    final orders = c.periodOrders;
    final validCount = c.validOrdersCount(orders);
    final totalRevenue = c.revenueOf(orders);
    final byStatus = c.ordersByStatus(orders);
    final byMarket = c.revenueByMarket(orders);
    final farmers = c.topFarmers(orders);

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Date-Range Filter & Export Header ──────────────────────────────
          Container(
            color: AppColors.surfaceWhite,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.l,
              AppSpacing.s,
              AppSpacing.l,
              AppSpacing.m,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date Range Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ReportsController.periods.map((p) {
                      final isSelected = c.period.value == p;
                      final label = p == 'All' ? 'All Time' : p;
                      return Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.s),
                        child: AppChip.pill(
                          label: label,
                          iconData: _getPeriodIcon(p),
                          backgroundColor: isSelected
                              ? AppColors.primaryDark
                              : AppColors.surfaceMuted,
                          textColor: isSelected
                              ? Colors.white
                              : AppColors.textSecondary,
                          isSelected: isSelected,
                          onTap: () => c.period.value = p,
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: AppSpacing.m),

                // Range Label & PDF Export Banner
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.m,
                    vertical: AppSpacing.s,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(AppRadius.input),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 16,
                        color: AppColors.primaryDark,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          'Showing: ${c.rangeLabel}',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s),
                      AppButton.small(
                        label: c.isExporting.value ? 'Exporting...' : 'PDF Export',
                        icon: Icons.download_rounded,
                        onPressed: c.isExporting.value ? null : c.exportPdf,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: AppSpacing.l),

          // ── Headline Metric Stat Cards ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontalPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Performance Overview', style: AppTextStyles.sectionHeading),
                const SizedBox(height: AppSpacing.m),

                // 2x2 Responsive Stat Cards
                Row(
                  children: [
                    Expanded(
                      child: AppStatCard(
                        title: 'Net Revenue',
                        value: money(totalRevenue),
                        trend: '+12.4%',
                        isPositiveTrend: true,
                        icon: Icons.payments_rounded,
                        iconBgColor: AppColors.chipHerbsBg,
                        iconColor: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.m),
                    Expanded(
                      child: AppStatCard(
                        title: 'Valid Orders',
                        value: '$validCount',
                        trend: '+8.1%',
                        isPositiveTrend: true,
                        icon: Icons.receipt_long_rounded,
                        iconBgColor: const Color(0xFFE3F2FD),
                        iconColor: const Color(0xFF1565C0),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.m),
                Row(
                  children: [
                    Expanded(
                      child: AppStatCard(
                        title: 'Active Markets',
                        value: '${byMarket.length}',
                        icon: Icons.storefront_rounded,
                        iconBgColor: const Color(0xFFFFF3E0),
                        iconColor: const Color(0xFFE65100),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.m),
                    Expanded(
                      child: AppStatCard(
                        title: 'Active Farmers',
                        value: '${farmers.length}',
                        icon: Icons.agriculture_rounded,
                        iconBgColor: AppColors.chipFruitsBg,
                        iconColor: AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // ── Section 1: Orders by Status Chart ──────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontalPadding,
            ),
            child: _buildOrdersByStatusCard(byStatus, orders.length),
          ),

          const SizedBox(height: AppSpacing.l),

          // ── Section 2: Revenue by Market Breakdown ─────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontalPadding,
            ),
            child: _buildRevenueByMarketCard(byMarket, totalRevenue),
          ),

          const SizedBox(height: AppSpacing.l),

          // ── Section 3: Most Active Farmers Leaderboard ─────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontalPadding,
            ),
            child: _buildTopFarmersCard(farmers),
          ),
        ],
      ),
    );
  }

  // ── Orders by Status Chart Card ─────────────────────────────────────────────
  Widget _buildOrdersByStatusCard(Map<String, int> byStatus, int total) {
    final nonZeroEntries = byStatus.entries.where((e) => e.value > 0).toList();

    return AppCard.list(
      title: 'Orders by Status',
      trailingTitle: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          '$total total',
          style: AppTextStyles.caption.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      children: [
        if (total == 0) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
            child: Center(
              child: Text(
                'No orders recorded in this date range.',
                style: AppTextStyles.bodyText.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ] else ...[
          // Donut Chart Container
          SizedBox(
            height: 180,
            child: Row(
              children: [
                // Chart
                Expanded(
                  flex: 5,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 3,
                      centerSpaceRadius: 36,
                      sections: nonZeroEntries.map((e) {
                        final color = _getStatusChartColor(e.key);
                        final pct = total > 0 ? (e.value / total * 100) : 0;
                        return PieChartSectionData(
                          color: color,
                          value: e.value.toDouble(),
                          title: pct >= 10 ? '${pct.toStringAsFixed(0)}%' : '',
                          radius: 36,
                          titleStyle: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                const SizedBox(width: AppSpacing.m),

                // Quick Summary List
                Expanded(
                  flex: 6,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: byStatus.entries.map((e) {
                      final color = _getStatusChartColor(e.key);
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                OrderStatus.label(e.key),
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '${e.value}',
                              style: AppTextStyles.caption.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.m),
          const Divider(color: AppColors.divider, height: 1),
          const SizedBox(height: AppSpacing.m),

          // Horizontal Progress breakdown
          Column(
            children: byStatus.entries.map((e) {
              final pct = total > 0 ? (e.value / total) : 0.0;
              final color = _getStatusChartColor(e.key);

              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.s),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AppChip.status(status: e.key),
                        Text(
                          '${e.value} orders (${(pct * 100).toStringAsFixed(1)}%)',
                          style: AppTextStyles.caption.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pct,
                        minHeight: 6,
                        backgroundColor: AppColors.surfaceMuted,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  // ── Revenue by Market Breakdown Card ────────────────────────────────────────
  Widget _buildRevenueByMarketCard(
    Map<String, double> byMarket,
    double totalRevenue,
  ) {
    final sortedMarkets = byMarket.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return AppCard.list(
      title: 'Revenue by Market',
      trailingTitle: Text(
        money(totalRevenue),
        style: AppTextStyles.cardTitle.copyWith(
          color: AppColors.primaryDark,
          fontWeight: FontWeight.w700,
        ),
      ),
      children: [
        if (sortedMarkets.isEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
            child: Center(
              child: Text(
                'No revenue recorded for any market in this period.',
                style: AppTextStyles.bodyText.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ] else ...[
          ...sortedMarkets.map((e) {
            final share = totalRevenue > 0 ? (e.value / totalRevenue) : 0.0;

            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.m),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.storefront_rounded,
                            size: 16,
                            color: AppColors.primaryDark,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            e.key,
                            style: AppTextStyles.bodyText.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        money(e.value),
                        style: AppTextStyles.bodyText.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: share,
                      minHeight: 8,
                      backgroundColor: AppColors.surfaceMuted,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${(share * 100).toStringAsFixed(1)}% of total revenue',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ],
    );
  }

  // ── Most Active Farmers Leaderboard Card ────────────────────────────────────
  Widget _buildTopFarmersCard(List<MapEntry<String, int>> farmers) {
    return AppCard.list(
      title: 'Most Active Farmers',
      trailingTitle: Text(
        'Top Producers',
        style: AppTextStyles.caption.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
      children: [
        if (farmers.isEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
            child: Center(
              child: Text(
                'No orders completed by farmers in this period.',
                style: AppTextStyles.bodyText.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ] else ...[
          for (int i = 0; i < farmers.length; i++) ...[
            Builder(builder: (context) {
              final item = farmers[i];
              final isTopThree = i < 3;
              final rankColor = i == 0
                  ? const Color(0xFFF57F17) // Gold
                  : i == 1
                      ? const Color(0xFF78909C) // Silver
                      : i == 2
                          ? const Color(0xFF8D6E63) // Bronze
                          : AppColors.textSecondary;

              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.s),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.m,
                    vertical: AppSpacing.s,
                  ),
                  decoration: BoxDecoration(
                    color: isTopThree
                        ? AppColors.chipHerbsBg.withValues(alpha: 0.5)
                        : AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(AppRadius.input),
                  ),
                  child: Row(
                    children: [
                      // Rank Badge
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: rankColor.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '#${i + 1}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: rankColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.m),

                      // Farmer Name
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(
                              Icons.agriculture_rounded,
                              size: 16,
                              color: AppColors.primaryDark,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Expanded(
                              child: Text(
                                item.key,
                                style: AppTextStyles.bodyText.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Order Count Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceWhite,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Text(
                          '${item.value} ${item.value == 1 ? "order" : "orders"}',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ],
      ],
    );
  }

  // ── Error State ─────────────────────────────────────────────────────────────
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              size: 48,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.m),
            Text(
              controller.error.value,
              style: AppTextStyles.bodyText.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.l),
            AppButton.small(
              label: 'Retry',
              icon: Icons.refresh,
              onPressed: controller.load,
            ),
          ],
        ),
      ),
    );
  }
}
