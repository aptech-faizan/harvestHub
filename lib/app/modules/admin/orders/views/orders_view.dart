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
import 'package:harvest_hub/app/modules/admin/models/order_model.dart';
import 'package:harvest_hub/app/modules/admin/orders/controllers/orders_controller.dart';
import 'package:harvest_hub/app/modules/admin/widgets/admin_drawer.dart';

/// Admin Orders Oversight screen conforming to the HarvestHub Design System:
/// - AppAppBar with drawer toggle & refresh action
/// - AppSearchBar + AppChip status filter row (All, Pending, Confirmed, Ready, Completed, Cancelled)
/// - List of order rows (AppCard.list) showing:
///   - Order ID, date
///   - Customer name, farmer name, item preview, pickup slot
///   - Total amount
///   - Status AppChip (reusing status-AppChip coloring from Customer Orders screen)
///   - Action to update status via bottom sheet preserving order-lifecycle state machine
class OrdersView extends GetView<OrdersController> {
  const OrdersView({super.key});

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.hourglass_top_rounded;
      case 'confirmed':
        return Icons.thumb_up_outlined;
      case 'ready_for_pickup':
      case 'ready':
        return Icons.inventory_2_outlined;
      case 'completed':
        return Icons.check_circle_outline_rounded;
      case 'cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.receipt_long_outlined;
    }
  }

  void _showUpdateStatusSheet(BuildContext context, OrderModel order) {
    final next = controller.nextStatuses(order);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.card)),
        ),
        padding: const EdgeInsets.all(AppSpacing.l),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.m),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Update Order Status', style: AppTextStyles.sectionHeading),
                  AppIconButton(
                    icon: Icons.close,
                    size: 28,
                    iconSize: 18,
                    backgroundColor: AppColors.surfaceMuted,
                    iconColor: AppColors.textSecondary,
                    onTap: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s),
              Row(
                children: [
                  Text(
                    'Current Status:  ',
                    style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
                  ),
                  AppChip.status(status: order.status),
                ],
              ),
              const SizedBox(height: AppSpacing.l),
              if (next.isEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(AppSpacing.m),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(AppRadius.input),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lock_outline, size: 20, color: AppColors.textSecondary),
                      const SizedBox(width: AppSpacing.s),
                      Expanded(
                        child: Text(
                          'This order is ${OrderStatus.label(order.status)}. Terminal orders cannot transition to any other status.',
                          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.l),
                AppButton.primary(
                  label: 'View Full Order Details',
                  icon: Icons.open_in_new_rounded,
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    controller.openDetails(order);
                  },
                ),
              ] else ...[
                Text(
                  'Select Next Status:',
                  style: AppTextStyles.bodyText.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.m),
                ...next.map((s) {
                  final colors = AppChip.getStatusColors(s);
                  final isCancel = s == OrderStatus.cancelled;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.s),
                    child: Material(
                      color: colors.bg,
                      borderRadius: BorderRadius.circular(AppRadius.input),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(AppRadius.input),
                        onTap: () {
                          Navigator.of(ctx).pop();
                          controller.updateStatus(order, s);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.m,
                            vertical: AppSpacing.m,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isCancel
                                    ? Icons.cancel_outlined
                                    : Icons.check_circle_outline_rounded,
                                color: colors.text,
                                size: 22,
                              ),
                              const SizedBox(width: AppSpacing.m),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Mark as ${OrderStatus.label(s)}',
                                      style: AppTextStyles.bodyText.copyWith(
                                        color: colors.text,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      isCancel
                                          ? 'Cancel order and release reserved stock'
                                          : 'Transition order to ${OrderStatus.label(s)}',
                                      style: AppTextStyles.caption.copyWith(
                                        color: colors.text.withValues(alpha: 0.8),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.chevron_right_rounded, color: colors.text),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
              const SizedBox(height: AppSpacing.s),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceMuted,
      appBar: AppAppBar(
        titleText: 'Orders Oversight',
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
      body: Column(
        children: [
          // ── Search & Status Filters Bar ─────────────────────────────────────
          Container(
            color: AppColors.surfaceWhite,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.l,
              AppSpacing.s,
              AppSpacing.l,
              AppSpacing.m,
            ),
            child: Column(
              children: [
                AppSearchBar(
                  hintText: 'Search by order ID, customer or farmer...',
                  onChanged: (v) => controller.search.value = v,
                ),
                const SizedBox(height: AppSpacing.m),
                Obx(() {
                  final currentFilter = controller.statusFilter.value;
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final s in ['All', ...OrderStatus.all]) ...[
                          Builder(builder: (context) {
                            final isSelected = currentFilter == s;
                            final label = s == 'All' ? 'All' : OrderStatus.label(s);
                            final count = s == 'All'
                                ? controller.orders.length
                                : controller.orders.where((o) => o.status == s).length;
                            final icon = _getStatusIcon(s);
                            final statusColors = s == 'All'
                                ? (bg: AppColors.chipHerbsBg, text: AppColors.primaryDark)
                                : AppChip.getStatusColors(s);

                            return Padding(
                              padding: const EdgeInsets.only(right: AppSpacing.s),
                              child: AppChip.pill(
                                label: '$label ($count)',
                                iconData: icon,
                                backgroundColor: isSelected ? statusColors.bg : AppColors.surfaceMuted,
                                textColor: isSelected ? statusColors.text : AppColors.textSecondary,
                                isSelected: isSelected,
                                onTap: () => controller.statusFilter.value = s,
                              ),
                            );
                          }),
                        ],
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: AppSpacing.s),

          // ── Orders List ─────────────────────────────────────────────────────
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const ShimmerOrderList();
              }

              if (controller.error.value.isNotEmpty) {
                return _buildErrorState();
              }

              final list = controller.filtered;
              if (list.isEmpty) {
                return _buildEmptyState();
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.l,
                  0,
                  AppSpacing.l,
                  AppSpacing.xl,
                ),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.m),
                itemBuilder: (_, i) {
                  final order = list[i];
                  return _OrderOversightRow(
                    order: order,
                    customerName: controller.customerName(order.customerId),
                    farmerName: order.farmerName.isNotEmpty
                        ? order.farmerName
                        : controller.farmerName(order.farmerId),
                    onUpdateStatus: () => _showUpdateStatusSheet(context, order),
                    onViewDetails: () => controller.openDetails(order),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  // ── Empty State ─────────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.chipHerbsBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                size: 40,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            Text(
              'No orders found',
              style: AppTextStyles.sectionHeading,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.s),
            Text(
              'Try adjusting your search query or status filter.',
              style: AppTextStyles.bodyText.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.l),
            AppButton.small(
              label: 'Reset Filters',
              icon: Icons.refresh_rounded,
              onPressed: () {
                controller.search.value = '';
                controller.statusFilter.value = 'All';
              },
            ),
          ],
        ),
      ),
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

// ── Order Oversight Row Component ─────────────────────────────────────────────
class _OrderOversightRow extends StatelessWidget {
  final OrderModel order;
  final String customerName;
  final String farmerName;
  final VoidCallback onUpdateStatus;
  final VoidCallback onViewDetails;

  const _OrderOversightRow({
    required this.order,
    required this.customerName,
    required this.farmerName,
    required this.onUpdateStatus,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final shortId = order.id.length > 8
        ? order.id.substring(0, 8).toUpperCase()
        : order.id.toUpperCase();
    final dateStr = order.createdAt != null
        ? formatDate(order.createdAt)
        : 'Date not available';
    final hasNextStatuses = OrderStatus.next(order.status).isNotEmpty;

    return AppCard.list(
      onTap: onViewDetails,
      padding: const EdgeInsets.all(AppSpacing.l),
      children: [
        // ── Header: Order ID, Date & Status Chip ─────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.receipt_outlined,
                      size: 16,
                      color: AppColors.primaryDark,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'Order #$shortId',
                      style: AppTextStyles.cardTitle.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  dateStr,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            AppChip.status(
              status: order.status,
              onTap: hasNextStatuses ? onUpdateStatus : null,
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.m),
        const Divider(color: AppColors.divider, height: 1),
        const SizedBox(height: AppSpacing.m),

        // ── Customer & Farmer Info ───────────────────────────────────────────
        Row(
          children: [
            const Icon(
              Icons.person_outline_rounded,
              size: 16,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              'Customer: ',
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            Expanded(
              child: Text(
                customerName,
                style: AppTextStyles.bodyText.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            const Icon(
              Icons.storefront_outlined,
              size: 16,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              'Farmer: ',
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            Expanded(
              child: Text(
                farmerName,
                style: AppTextStyles.bodyText.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),

        // ── Items Summary (if available) ──────────────────────────────────────
        if (order.items.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.shopping_bag_outlined,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Items: ',
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              Expanded(
                child: Text(
                  order.items
                      .map((item) => '${item.itemName} x${item.quantity}')
                      .join(', '),
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],

        // ── Pickup Slot (if available) ────────────────────────────────────────
        if (order.pickupSlot.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              const Icon(
                Icons.schedule_outlined,
                size: 16,
                color: AppColors.primaryDark,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Slot: ',
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryDark,
                ),
              ),
              Expanded(
                child: Text(
                  order.pickupSlot,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],

        const SizedBox(height: AppSpacing.m),
        const Divider(color: AppColors.divider, height: 1),
        const SizedBox(height: AppSpacing.s),

        // ── Total & Actions ──────────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Amount', style: AppTextStyles.caption),
                Text(
                  money(order.totalPrice),
                  style: AppTextStyles.priceText,
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasNextStatuses) ...[
                  AppTextButton(
                    label: 'Update Status',
                    leadingIcon: Icons.edit_note_rounded,
                    color: AppColors.primaryDark,
                    onPressed: onUpdateStatus,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.lock_outline,
                          size: 13,
                          color: AppColors.textDisabled,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          'Final',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textDisabled,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s),
                ],
                AppTextButton(
                  label: 'Details',
                  leadingIcon: Icons.open_in_new_rounded,
                  color: AppColors.textSecondary,
                  onPressed: onViewDetails,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
