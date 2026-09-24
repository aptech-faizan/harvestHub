import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../data/models/farmer_order_model.dart';
import '../../farmer_theme.dart';
import '../../widgets/farmer_widgets.dart';
import '../controllers/orders_controller.dart';
import 'order_detail_view.dart';

/// Modern Airbnb/Notion-inspired Orders view with animated filter chips,
/// rich order cards, bottom-sheet status changer, and shimmer loading.
class OrdersView extends GetView<OrdersController> {
  const OrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FarmerColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Orders',
              style: TextStyle(
                color: FarmerColors.text,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
            Obx(() => Text(
                  '${controller.orders.length} orders total',
                  style: FarmerTextStyles.caption.copyWith(
                    color: FarmerColors.muted,
                  ),
                )),
          ],
        ),
        actions: [
          Semantics(
            button: true,
            label: 'Refresh orders',
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
              onPressed: controller.loadOrders,
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
      body: Column(
        children: [
          // ── Scrollable status filter chips with animated selection ────
          _AnimatedOrderFilterBar(controller: controller),

          // ── Orders list ───────────────────────────────────────────────
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const CardListShimmer(count: 4);
              }
              if (controller.errorMessage.value.isNotEmpty) {
                return _OrdersErrorState(
                  message: controller.errorMessage.value,
                  onRetry: controller.loadOrders,
                );
              }
              if (controller.orders.isEmpty) {
                return EmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: 'No Orders Found',
                  message: controller.selectedFilter.value != null
                      ? 'There are no ${controller.selectedFilter.value!.label.toLowerCase()} orders right now.'
                      : 'When customers place orders, they will appear here.',
                );
              }

              return RefreshIndicator(
                color: FarmerColors.primary,
                backgroundColor: Colors.white,
                onRefresh: controller.loadOrders,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                  itemCount: controller.orders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, index) {
                    final order = controller.orders[index];
                    return StaggeredFadeSlide(
                      index: index,
                      child: _OrderCard(
                        order: order,
                        controller: controller,
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ── Scrollable Status Filter Bar ──────────────────────────────────────────────

class _AnimatedOrderFilterBar extends StatelessWidget {
  final OrdersController controller;
  const _AnimatedOrderFilterBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    const statuses = [null, ...OrderStatus.values];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Obx(() => Row(
              children: statuses.map((status) {
                final isSelected = controller.selectedFilter.value == status;
                final label = status?.label ?? 'All';

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Semantics(
                    button: true,
                    selected: isSelected,
                    label: '$label filter',
                    child: InkWell(
                      onTap: () => controller.applyFilter(status),
                      borderRadius: BorderRadius.circular(20),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? FarmerColors.primaryDark
                              : FarmerColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? FarmerColors.primaryDark
                                : FarmerColors.border,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : FarmerColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            )),
      ),
    );
  }
}

// ── Rich Order Card ───────────────────────────────────────────────────────────

class _OrderCard extends StatelessWidget {
  final FarmerOrder order;
  final OrdersController controller;

  const _OrderCard({
    required this.order,
    required this.controller,
  });

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty || parts[0].isEmpty) return 'C';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('d MMM yyyy, h:mm a').format(order.createdAt);
    final initials = _getInitials(order.customerName);

    // Items summary string
    final itemsSummary = order.items
        .map((i) => '${i.productName} ×${i.quantity}')
        .join(', ');

    return AppCard(
      padding: const EdgeInsets.all(14),
      onTap: () {
        Get.to(
          () => OrderDetailView(order: order),
          transition: Transition.rightToLeft,
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Customer Initials + Name + Status Chip
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Initials Avatar
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      FarmerColors.primary.withValues(alpha: 0.15),
                      FarmerColors.secondary.withValues(alpha: 0.25),
                    ],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: FarmerColors.primary.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: FarmerColors.primaryDark,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Customer Name & Order ID
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.customerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: FarmerColors.text,
                      ),
                    ),
                    Text(
                      '#${order.id.substring(0, order.id.length > 8 ? 8 : order.id.length).toUpperCase()}',
                      style: FarmerTextStyles.caption.copyWith(
                        color: FarmerColors.muted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              // Status Chip
              StatusChip.fromOrderStatus(order.status),
            ],
          ),
          const SizedBox(height: 10),

          // Items summary
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: FarmerColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.shopping_basket_outlined,
                  size: 16,
                  color: FarmerColors.muted,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    itemsSummary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: FarmerColors.textSecondary,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Time & Pickup Slot Pill Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: FarmerColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.access_time_rounded,
                        size: 12, color: FarmerColors.muted),
                    const SizedBox(width: 4),
                    Text(
                      dateStr,
                      style: const TextStyle(
                        fontSize: 11,
                        color: FarmerColors.muted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: FarmerColors.secondaryLight.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.storefront_outlined,
                        size: 12, color: FarmerColors.primaryDark),
                    SizedBox(width: 4),
                    Text(
                      'Pickup Slot: Today',
                      style: TextStyle(
                        fontSize: 11,
                        color: FarmerColors.primaryDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // Footer: Total Price + Status Changer Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Price
              RichText(
                text: TextSpan(
                  children: [
                    const TextSpan(
                      text: 'Total: ',
                      style: TextStyle(
                        fontSize: 12,
                        color: FarmerColors.muted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextSpan(
                      text: FarmerCurrency.format(order.totalAmount),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: FarmerColors.primaryDark,
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom-sheet status changer button
              Semantics(
                button: true,
                label: 'Change status for order ${order.id}',
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _openStatusChangerSheet(context),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: FarmerColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: FarmerColors.primary.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.sync_rounded,
                              size: 14, color: FarmerColors.primaryDark),
                          SizedBox(width: 5),
                          Text(
                            'Update Status',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: FarmerColors.primaryDark,
                            ),
                          ),
                          SizedBox(width: 2),
                          Icon(Icons.keyboard_arrow_down_rounded,
                              size: 16, color: FarmerColors.primaryDark),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openStatusChangerSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: FarmerColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Update Order Status',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: FarmerColors.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Select the new progress status for this customer order.',
                  style: FarmerTextStyles.caption.copyWith(
                    color: FarmerColors.muted,
                  ),
                ),
                const SizedBox(height: 16),

                // Status options
                ...OrderStatus.values.map((status) {
                  final isCurrent = order.status == status;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      onTap: () {
                        Navigator.of(ctx).pop();
                        if (!isCurrent) {
                          controller.updateStatus(order, status);
                        }
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? FarmerColors.primary.withValues(alpha: 0.08)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isCurrent
                                ? FarmerColors.primary
                                : FarmerColors.border,
                            width: isCurrent ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            StatusChip.fromOrderStatus(status),
                            const Spacer(),
                            if (isCurrent)
                              const Icon(
                                Icons.check_circle_rounded,
                                color: FarmerColors.primary,
                                size: 20,
                              )
                            else
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: FarmerColors.muted,
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Orders Error State ────────────────────────────────────────────────────────

class _OrdersErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _OrdersErrorState({
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
              'Failed to Load Orders',
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
