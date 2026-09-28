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
import 'package:harvest_hub/app/core/widgets/app_chip.dart';
import 'package:harvest_hub/app/core/widgets/app_section_header.dart';
import 'package:harvest_hub/app/core/widgets/state_view.dart';
import 'package:harvest_hub/app/data/models/order_model.dart';
import 'package:harvest_hub/app/modules/farmer/orders/controllers/farmer_orders_controller.dart';
import 'package:harvest_hub/app/modules/farmer/utils/farmer_order_status.dart';

class FarmerOrdersView extends GetView<FarmerOrdersController> {
  const FarmerOrdersView({super.key});

  // Filter options: 'All' plus only the actionable/in-progress statuses
  static const _filters = [
    'All',
    OrderStatus.pending,
    OrderStatus.confirmed,
    OrderStatus.ready,
    OrderStatus.completed,
    OrderStatus.cancelled,
  ];

  static String _filterLabel(String s) =>
      s == 'All' ? 'All' : orderStatusLabel(s);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceMuted,
      appBar: AppAppBar(
        titleText: 'Orders',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded,
                color: AppColors.textSecondary),
            tooltip: 'Refresh',
            onPressed: controller.load,
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Status filter chips ───────────────────────────────────
          SizedBox(
            height: 52,
            child: Obx(() {
              final active = controller.statusFilter.value;
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.l,
                  vertical: AppSpacing.s,
                ),
                separatorBuilder: (_, __) =>
                    const SizedBox(width: AppSpacing.s),
                itemCount: _filters.length,
                itemBuilder: (_, i) {
                  final f = _filters[i];
                  final selected = active == f;
                  return AppChip.pill(
                    label: _filterLabel(f),
                    isSelected: selected,
                    onTap: () => controller.statusFilter.value = f,
                    backgroundColor: selected
                        ? AppColors.primaryDark
                        : AppChip.getStatusColors(f).bg,
                    textColor: selected
                        ? Colors.white
                        : (f == 'All'
                            ? AppColors.textPrimary
                            : AppChip.getStatusColors(f).text),
                  );
                },
              );
            }),
          ),

          // ── Order list ────────────────────────────────────────────
          Expanded(
            child: Obx(() {
              final list = controller.filtered;
              return StateView(
                isLoading: controller.isLoading.value,
                error: controller.error.value,
                isEmpty: list.isEmpty,
                emptyText: 'No orders for this filter.',
                onRetry: controller.load,
                variant: StateViewVariant.order,
                child: RefreshIndicator(
                  onRefresh: controller.load,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.l,
                      AppSpacing.xs,
                      AppSpacing.l,
                      AppSpacing.l,
                    ),
                    itemCount: list.length + 1,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.s),
                    itemBuilder: (_, i) {
                      if (i == 0) {
                        return Padding(
                          padding:
                              const EdgeInsets.only(bottom: AppSpacing.xs),
                          child: AppSectionHeader(
                            title: controller.statusFilter.value == 'All'
                                ? 'All Orders'
                                : orderStatusLabel(
                                    controller.statusFilter.value),
                            actionTitle: '${list.length} order${list.length == 1 ? '' : 's'}',
                          ),
                        );
                      }
                      final o = list[i - 1];
                      return _OrderRow(
                        order: o,
                        customerName: controller.customerName(o.customerId),
                        onTap: () => controller.openDetails(o),
                        onAction: (status) =>
                            controller.updateStatus(o, status),
                      );
                    },
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Order card row
// ---------------------------------------------------------------------------
class _OrderRow extends StatelessWidget {
  final OrderModel order;
  final String customerName;
  final VoidCallback onTap;
  final void Function(String status) onAction;

  const _OrderRow({
    required this.order,
    required this.customerName,
    required this.onTap,
    required this.onAction,
  });

  /// Readable items summary: "Tomatoes ×2, Spinach ×1"
  String _itemsSummary() {
    if (order.items.isEmpty) return 'No items';
    final parts = order.items.take(3).map((item) {
      final name = (item['name'] ?? item['itemName'] ?? 'Item').toString();
      final qty = item['qty'] ?? item['quantity'] ?? 0;
      return '$name ×$qty';
    }).toList();
    final extra = order.items.length > 3 ? ' +${order.items.length - 3} more' : '';
    return parts.join(', ') + extra;
  }

  /// Returns the primary action label + target status for the CTA button
  ({String label, String status, IconData icon})? _primaryAction() {
    final next = nextFarmerStatuses(order.status);
    if (next.isEmpty) return null;
    // Map the first available transition to a friendly label
    final target = next.first;
    switch (target) {
      case OrderStatus.confirmed:
        return (
          label: 'Confirm',
          status: target,
          icon: Icons.check_circle_rounded,
        );
      case OrderStatus.ready:
        return (
          label: 'Mark Ready',
          status: target,
          icon: Icons.storefront_rounded,
        );
      case OrderStatus.completed:
        return (
          label: 'Complete',
          status: target,
          icon: Icons.done_all_rounded,
        );
      default:
        return (
          label: orderStatusLabel(target),
          status: target,
          icon: Icons.arrow_forward_rounded,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColors = AppChip.getStatusColors(order.status);
    final action = _primaryAction();
    final shortId = order.id.length > 8 ? order.id.substring(0, 8) : order.id;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: AppRadius.cardRadius,
        border: Border.all(color: AppColors.divider),
        boxShadow: AppRadius.cardElevation,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.cardRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.cardRadius,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Top row: order ID + status chip ────────────────
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: statusColors.bg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.receipt_long_rounded,
                        size: 18,
                        color: statusColors.text,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '#${shortId.toUpperCase()}',
                            style: AppTextStyles.cardTitle
                                .copyWith(fontSize: 13),
                          ),
                          Text(
                            customerName,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    AppChip.status(status: order.status),
                  ],
                ),

                const SizedBox(height: AppSpacing.s),
                const Divider(color: AppColors.divider, height: 1),
                const SizedBox(height: AppSpacing.s),

                // ── Items summary ───────────────────────────────────
                Row(
                  children: [
                    const Icon(Icons.shopping_bag_outlined,
                        size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        _itemsSummary(),
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                // ── Pickup time + total ─────────────────────────────
                Row(
                  children: [
                    const Icon(Icons.schedule_rounded,
                        size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        order.pickupSlotTime.isNotEmpty
                            ? order.pickupSlotTime
                            : formatDate(order.createdAt),
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      money(order.totalPrice),
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),

                // ── Action buttons ──────────────────────────────────
                if (action != null) ...[
                  const SizedBox(height: AppSpacing.m),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton.small(
                          label: action.label,
                          icon: action.icon,
                          onPressed: () => onAction(action.status),
                        ),
                      ),
                      // Cancel button (if allowed)
                      if (nextFarmerStatuses(order.status)
                          .contains(OrderStatus.cancelled)) ...[
                        const SizedBox(width: AppSpacing.s),
                        AppButton.small(
                          label: 'Cancel',
                          icon: Icons.close_rounded,
                          onPressed: () =>
                              onAction(OrderStatus.cancelled),
                          backgroundColor: const Color(0xFFFFEBEE),
                          textColor: AppColors.accentRed,
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
