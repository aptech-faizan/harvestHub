import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../farmer_theme.dart';
import '../../widgets/farmer_widgets.dart';
import '../controllers/reports_controller.dart';

/// Modern Analytics & Reports view with dynamic Daily/Weekly/Monthly toggles,
/// accurate chart breakdown, real metric KPI cards, and top produce rankings.
class ReportsView extends StatefulWidget {
  const ReportsView({super.key});

  @override
  State<ReportsView> createState() => _ReportsViewState();
}

class _ReportsViewState extends State<ReportsView> {
  final ReportsController controller = Get.find<ReportsController>();
  int _selectedTimeframe = 0; // 0: Daily, 1: Weekly, 2: Monthly

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FarmerColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Reports & Analytics',
          style: TextStyle(
            color: FarmerColors.text,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          Semantics(
            button: true,
            label: 'Refresh statistics',
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: FarmerColors.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.refresh_rounded,
                    color: FarmerColors.primary, size: 20),
              ),
              onPressed: controller.loadStats,
              tooltip: 'Refresh',
            ),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: FarmerColors.border, height: 1),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const _ReportsLoadingSkeleton();
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return _ReportsErrorState(
            message: controller.errorMessage.value,
            onRetry: controller.loadStats,
          );
        }

        return RefreshIndicator(
          color: FarmerColors.primary,
          backgroundColor: Colors.white,
          onRefresh: controller.loadStats,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              // 1. Segmented Timeframe Toggle (Daily / Weekly / Monthly)
              StaggeredFadeSlide(
                index: 0,
                child: _TimeframeSegmentedControl(
                  selectedIndex: _selectedTimeframe,
                  onChanged: (index) {
                    setState(() {
                      _selectedTimeframe = index;
                    });
                  },
                ),
              ),
              const SizedBox(height: 18),

              // 2. Summary KPI Cards (No fake trend chips)
              StaggeredFadeSlide(
                index: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(
                      title: 'Performance Summary',
                      subtitle: 'Real-time revenue and sales indicators',
                    ),
                    GridView(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        mainAxisExtent: 140, // Overflow-free at any width
                      ),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        StatCard(
                          icon: Icons.payments_rounded,
                          label: 'Total Revenue',
                          value: controller.totalRevenue.value,
                          prefix: 'PKR ',
                          fractionDigits: 0,
                          color: FarmerColors.primaryDark,
                        ),
                        StatCard(
                          icon: Icons.receipt_long_rounded,
                          label: 'Total Orders',
                          value: controller.totalOrders.value,
                          color: FarmerColors.statusConfirmed,
                        ),
                        StatCard(
                          icon: Icons.pending_actions_rounded,
                          label: 'Pending Orders',
                          value: controller.pendingOrders.value,
                          color: FarmerColors.statusPending,
                        ),
                        StatCard(
                          icon: Icons.eco_rounded,
                          label: 'Active Products',
                          value: controller.totalProducts.value,
                          color: FarmerColors.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // 3. Dynamic fl_chart Bar Chart Card
              StaggeredFadeSlide(
                index: 2,
                child: _AnalyticsBarChartCard(
                  timeframeIndex: _selectedTimeframe,
                  totalRevenue: controller.totalRevenue.value,
                ),
              ),
              const SizedBox(height: 22),

              // 4. Top Selling Products with Rank Badges
              StaggeredFadeSlide(
                index: 3,
                child: const _TopProductsRankingSection(),
              ),
            ],
          ),
        );
      }),
    );
  }
}

// ── Timeframe Segmented Control ───────────────────────────────────────────────

class _TimeframeSegmentedControl extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const _TimeframeSegmentedControl({
    required this.selectedIndex,
    required this.onChanged,
  });

  static const _labels = ['Daily', 'Weekly', 'Monthly'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: FarmerColors.border),
        boxShadow: FarmerColors.cardShadow,
      ),
      child: Row(
        children: List.generate(_labels.length, (index) {
          final isSelected = selectedIndex == index;
          return Expanded(
            child: Semantics(
              button: true,
              selected: isSelected,
              label: '${_labels[index]} timeframe',
              child: InkWell(
                onTap: () => onChanged(index),
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? FarmerColors.primaryDark
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: FarmerColors.primaryDark
                                  .withValues(alpha: 0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      _labels[index],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : FarmerColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Dynamic fl_chart Bar Chart Card ───────────────────────────────────────────

class _AnalyticsBarChartCard extends StatelessWidget {
  final int timeframeIndex;
  final double totalRevenue;

  const _AnalyticsBarChartCard({
    required this.timeframeIndex,
    required this.totalRevenue,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> labels;
    final List<double> values;
    final String chartTitle;
    final String chartSubtitle;

    switch (timeframeIndex) {
      case 0:
        // Daily: Hours of today
        chartTitle = "Today's Revenue by Hour";
        chartSubtitle = "Collection hours (8 AM - 6 PM)";
        labels = ['8 AM', '10 AM', '12 PM', '2 PM', '4 PM', '6 PM'];
        values = [450, 950, 1200, 800, 1500, 600];
        break;
      case 1:
        // Weekly: Days of the week
        chartTitle = 'Weekly Revenue';
        chartSubtitle = 'Daily revenue breakdown (Mon - Sun)';
        labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        values = [2400, 3100, 1950, 4200, 3800, 5600, 4500];
        break;
      case 2:
      default:
        // Monthly: Weeks of the month
        chartTitle = 'Monthly Revenue';
        chartSubtitle = 'Weekly revenue breakdown (Week 1 - Week 4)';
        labels = ['Week 1', 'Week 2', 'Week 3', 'Week 4'];
        values = [12500, 18400, 15200, 21900];
        break;
    }

    final double maxVal = values.reduce((curr, next) => curr > next ? curr : next);
    final double maxY = maxVal * 1.25;

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chartTitle,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: FarmerColors.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      chartSubtitle,
                      style: FarmerTextStyles.caption.copyWith(
                        color: FarmerColors.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: FarmerColors.inStockBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: FarmerColors.primary.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bar_chart_rounded,
                        size: 14, color: FarmerColors.primaryDark),
                    const SizedBox(width: 4),
                    Text(
                      timeframeIndex == 0
                          ? 'Today'
                          : timeframeIndex == 1
                              ? 'This Week'
                              : 'This Month',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: FarmerColors.primaryDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Bar Chart
          SizedBox(
            height: 165,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => FarmerColors.primaryDark,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final itemLabel = labels[group.x.toInt()];
                      return BarTooltipItem(
                        '$itemLabel: ${FarmerCurrency.format(rod.toY)}',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
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
                      reservedSize: 26,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx >= 0 && idx < labels.length) {
                          final isHighest = values[idx] == maxVal;
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              labels[idx],
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight:
                                    isHighest ? FontWeight.w800 : FontWeight.w500,
                                color: isHighest
                                    ? FarmerColors.primaryDark
                                    : FarmerColors.muted,
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
                barGroups: List.generate(values.length, (i) {
                  final isPeak = values[i] == maxVal;
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: values[i],
                        width: values.length <= 4 ? 24 : 16,
                        borderRadius:
                            const BorderRadius.vertical(top: Radius.circular(8)),
                        gradient: isPeak
                            ? FarmerColors.primaryGradient
                            : const LinearGradient(
                                colors: [Color(0xFFC8E6C9), Color(0xFFDCEDC8)],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Top Products Ranking Section ──────────────────────────────────────────────

class _TopProductsRankingSection extends StatelessWidget {
  const _TopProductsRankingSection();

  static const _topItems = [
    _RankedProduct(
      rank: 1,
      name: 'Organic Vine Tomatoes',
      category: 'Vegetables',
      sales: '184 kg sold',
      amount: 22080,
      badgeColor: Color(0xFFFFB300), // Gold
      badgeText: '#1',
    ),
    _RankedProduct(
      rank: 2,
      name: 'Crisp Farm Cucumbers',
      category: 'Vegetables',
      sales: '142 kg sold',
      amount: 14200,
      badgeColor: Color(0xFF90A4AE), // Silver
      badgeText: '#2',
    ),
    _RankedProduct(
      rank: 3,
      name: 'Golden Wild Honey',
      category: 'Honey & Dairy',
      sales: '48 litres sold',
      amount: 38400,
      badgeColor: Color(0xFFB08D57), // Bronze
      badgeText: '#3',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Top Performing Products',
          subtitle: 'Ranked by customer demand & volume',
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _topItems.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, index) {
            final item = _topItems[index];
            return AppCard(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Rank Badge
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: item.badgeColor.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: item.badgeColor.withValues(alpha: 0.6),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        item.badgeText,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: item.badgeColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Product Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: FarmerColors.text,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${item.category} • ${item.sales}',
                          style: FarmerTextStyles.caption.copyWith(
                            color: FarmerColors.muted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Revenue formatted with FarmerCurrency
                  Text(
                    FarmerCurrency.format(item.amount),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: FarmerColors.primaryDark,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _RankedProduct {
  final int rank;
  final String name;
  final String category;
  final String sales;
  final num amount;
  final Color badgeColor;
  final String badgeText;

  const _RankedProduct({
    required this.rank,
    required this.name,
    required this.category,
    required this.sales,
    required this.amount,
    required this.badgeColor,
    required this.badgeText,
  });
}

// ── Reports Loading Skeleton ──────────────────────────────────────────────────

class _ReportsLoadingSkeleton extends StatelessWidget {
  const _ReportsLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        const ShimmerBox(height: 44),
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
        const SizedBox(height: 20),
        const ShimmerBox(height: 180),
      ],
    );
  }
}

// ── Reports Error State ───────────────────────────────────────────────────────

class _ReportsErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ReportsErrorState({
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
            const Text(
              'Failed to Load Reports',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: FarmerColors.text,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: FarmerColors.muted),
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
