import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/constants/app_constants.dart';
import 'package:harvest_hub/app/core/theme/app_colors.dart';
import 'package:harvest_hub/app/core/theme/app_radius.dart';
import 'package:harvest_hub/app/core/theme/app_spacing.dart';
import 'package:harvest_hub/app/core/theme/app_text_styles.dart';
import 'package:harvest_hub/app/core/utils/helpers.dart';
import 'package:harvest_hub/app/core/widgets/app_app_bar.dart';
import 'package:harvest_hub/app/core/widgets/app_button.dart';
import 'package:harvest_hub/app/core/widgets/app_card.dart';
import 'package:harvest_hub/app/core/widgets/app_chip.dart';
import 'package:harvest_hub/app/core/widgets/app_icon.dart';
import 'package:harvest_hub/app/core/widgets/app_section_header.dart';
import 'package:harvest_hub/app/core/widgets/app_stat_card.dart';
import 'package:harvest_hub/app/core/widgets/state_view.dart';
import 'package:harvest_hub/app/modules/farmer/reports/controllers/farmer_reports_controller.dart';

/// Farmer Business Reports screen — UI only, per Master Rules.
/// Charts use design-system color tokens; all aggregation logic lives in
/// [FarmerReportsController] and is untouched.
class FarmerReportsView extends GetView<FarmerReportsController> {
  const FarmerReportsView({super.key});

  // ── Chart color palette (mirrors Admin Reports for consistency) ─────────────
  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFFFA726);
      case 'confirmed':
        return const Color(0xFF42A5F5);
      case 'ready_for_pickup':
      case 'ready':
        return const Color(0xFF26A69A);
      case 'completed':
        return AppColors.primaryDark;
      case 'cancelled':
        return AppColors.accentRed;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _periodIcon(String p) {
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
        titleText: 'Sales Report',
        actions: [
          Obx(() => AppIconButton(
                icon: Icons.picture_as_pdf_outlined,
                iconSize: 20,
                backgroundColor: AppColors.surfaceMuted,
                iconColor: AppColors.primaryDark,
                tooltip: 'Export PDF',
                isCircle: false,
                onTap: controller.isExporting.value
                    ? null
                    : controller.exportPdf,
              )),
          AppIconButton(
            icon: Icons.refresh_rounded,
            iconSize: 20,
            backgroundColor: AppColors.surfaceMuted,
            iconColor: AppColors.textSecondary,
            tooltip: 'Refresh',
            isCircle: false,
            onTap: controller.load,
          ),
        ],
      ),
      body: Obx(() => StateView(
            isLoading: controller.isLoading.value,
            error: controller.error.value,
            isEmpty: false,
            onRetry: controller.load,
            child: _buildContent(),
          )),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Date-Range Filter + Range Banner ──────────────────────────
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
                // Period filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Obx(() {
                    return Row(
                      children: FarmerReportsController.periods.map((p) {
                        final selected = controller.period.value == p;
                        final label = p == 'All' ? 'All Time' : p;
                        return Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.s),
                          child: AppChip.pill(
                            label: label,
                            iconData: _periodIcon(p),
                            isSelected: selected,
                            backgroundColor: selected
                                ? AppColors.primaryDark
                                : AppColors.surfaceMuted,
                            textColor: selected
                                ? Colors.white
                                : AppColors.textSecondary,
                            onTap: () => controller.period.value = p,
                          ),
                        );
                      }).toList(),
                    );
                  }),
                ),

                const SizedBox(height: AppSpacing.m),

                // Range label + PDF button
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
                      const Icon(Icons.access_time_rounded,
                          size: 16, color: AppColors.primaryDark),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Obx(() => Text(
                              'Showing: ${controller.rangeLabel}',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )),
                      ),
                      const SizedBox(width: AppSpacing.s),
                      Obx(() => AppButton.small(
                            label: controller.isExporting.value
                                ? 'Exporting…'
                                : 'PDF Export',
                            icon: Icons.download_rounded,
                            isLoading: controller.isExporting.value,
                            onPressed: controller.isExporting.value
                                ? null
                                : controller.exportPdf,
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: AppSpacing.l),

          // ── Headline Stat Cards ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontalPadding),
            child: Obx(() {
              final validOrders = controller.valid;
              final rev = controller.revenue;
              final qtyMap = controller.qtyByProduct;
              final topProduct = qtyMap.entries.isEmpty
                  ? '—'
                  : (qtyMap.entries.toList()
                        ..sort((a, b) => b.value.compareTo(a.value)))
                      .first
                      .key;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppSectionHeader(title: 'Performance Overview'),
                  const SizedBox(height: AppSpacing.m),
                  Row(
                    children: [
                      Expanded(
                        child: AppStatCard(
                          title: 'Revenue',
                          value: money(rev),
                          icon: Icons.payments_rounded,
                          iconBgColor: AppColors.chipHerbsBg,
                          iconColor: AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.m),
                      Expanded(
                        child: AppStatCard(
                          title: 'Valid Orders',
                          value: '${validOrders.length}',
                          icon: Icons.receipt_long_rounded,
                          iconBgColor: const Color(0xFFE3F2FD),
                          iconColor: const Color(0xFF1565C0),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.m),
                  AppStatCard(
                    title: 'Top Product',
                    value: topProduct,
                    icon: Icons.emoji_events_rounded,
                    iconBgColor: AppColors.chipFruitsBg,
                    iconColor: const Color(0xFFF57F17),
                    padding: const EdgeInsets.all(AppSpacing.m),
                  ),
                ],
              );
            }),
          ),

          const SizedBox(height: AppSpacing.l),

          // ── Orders by Status Donut Chart ────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontalPadding),
            child: Obx(() {
              final byStatus = controller.byStatus;
              final periodOrders = controller.periodOrders;
              final total = periodOrders.length;
              return _buildStatusChart(byStatus, total);
            }),
          ),

          const SizedBox(height: AppSpacing.l),

          // ── Top Selling Produce ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontalPadding),
            child: Obx(() {
              final qtyMap = controller.qtyByProduct;
              return _buildTopProduceCard(qtyMap);
            }),
          ),
        ],
      ),
    );
  }

  // ── Orders by Status Chart ────────────────────────────────────────────────
  Widget _buildStatusChart(Map<String, int> byStatus, int total) {
    final nonZero =
        byStatus.entries.where((e) => e.value > 0).toList();

    return AppCard.list(
      title: 'Orders by Status',
      trailingTitle: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
        if (total == 0)
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: AppSpacing.xl),
            child: Center(
              child: Text(
                'No orders in this period.',
                style: AppTextStyles.bodyText
                    .copyWith(color: AppColors.textSecondary),
              ),
            ),
          )
        else ...[
          // Donut + legend row
          SizedBox(
            height: 180,
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 3,
                      centerSpaceRadius: 36,
                      sections: nonZero.map((e) {
                        final color = _statusColor(e.key);
                        final pct = total > 0
                            ? e.value / total * 100
                            : 0.0;
                        return PieChartSectionData(
                          color: color,
                          value: e.value.toDouble(),
                          title: pct >= 10
                              ? '${pct.toStringAsFixed(0)}%'
                              : '',
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
                Expanded(
                  flex: 6,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: byStatus.entries.map((e) {
                      final color = _statusColor(e.key);
                      return Padding(
                        padding:
                            const EdgeInsets.symmetric(vertical: 3),
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

          // Per-status progress bars
          ...byStatus.entries.map((e) {
            final pct = total > 0 ? e.value / total : 0.0;
            final color = _statusColor(e.key);
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      AppChip.status(status: e.key),
                      Text(
                        '${e.value} (${(pct * 100).toStringAsFixed(1)}%)',
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
                      valueColor:
                          AlwaysStoppedAnimation<Color>(color),
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

  // ── Top Selling Produce ───────────────────────────────────────────────────
  Widget _buildTopProduceCard(Map<String, int> qtyMap) {
    final sorted = qtyMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(
          title: 'Top Selling Produce',
          actionTitle: '${sorted.length} product${sorted.length == 1 ? '' : 's'}',
        ),
        const SizedBox(height: AppSpacing.s),
        AppCard.list(
          children: [
            if (sorted.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                child: Center(
                  child: Text(
                    'No sales recorded in this period.',
                    style: AppTextStyles.bodyText
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ),
              )
            else ...[
              for (int i = 0; i < sorted.length; i++) ...[
                _ProduceRow(
                  rank: i + 1,
                  name: sorted[i].key,
                  qty: sorted[i].value,
                  maxQty: sorted.first.value,
                ),
                if (i < sorted.length - 1)
                  const Divider(
                    color: AppColors.divider,
                    height: 1,
                    indent: AppSpacing.l,
                    endIndent: AppSpacing.l,
                  ),
              ],
            ],
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Top produce leaderboard row
// ---------------------------------------------------------------------------
class _ProduceRow extends StatelessWidget {
  final int rank;
  final String name;
  final int qty;
  final int maxQty;

  const _ProduceRow({
    required this.rank,
    required this.name,
    required this.qty,
    required this.maxQty,
  });

  Color get _rankColor {
    switch (rank) {
      case 1:
        return const Color(0xFFF57F17); // Gold
      case 2:
        return const Color(0xFF78909C); // Silver
      case 3:
        return const Color(0xFF8D6E63); // Bronze
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final share = maxQty > 0 ? qty / maxQty : 0.0;
    final isTopThree = rank <= 3;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Rank badge
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: _rankColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '#$rank',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: _rankColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.m),

              // Product name
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isTopThree
                            ? AppColors.chipHerbsBg
                            : AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Icons.eco_rounded,
                        size: 15,
                        color: isTopThree
                            ? AppColors.primaryDark
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s),
                    Expanded(
                      child: Text(
                        name,
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

              // Qty badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.chipHerbsBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$qty units',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          // Bar showing relative qty
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 44),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: share,
                minHeight: 5,
                backgroundColor: AppColors.surfaceMuted,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isTopThree
                      ? AppColors.primaryButton
                      : AppColors.textDisabled,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
