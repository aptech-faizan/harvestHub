import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../data/models/farmer_order_model.dart';
import '../../farmer_theme.dart';
import '../controllers/orders_controller.dart';
import 'order_detail_view.dart';

/// Orders list with status filter chips and in-row status update dropdown.
class OrdersView extends GetView<OrdersController> {
  const OrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FarmerColors.background,
      appBar: AppBar(
        backgroundColor: FarmerColors.primary,
        title: const Text('Orders',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: controller.loadOrders,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Filter chips ──────────────────────────────────────────────
          _FilterBar(controller: controller),
          // ── Orders list ───────────────────────────────────────────────
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                    child: CircularProgressIndicator(
                        color: FarmerColors.primary));
              }
              if (controller.errorMessage.value.isNotEmpty) {
                return _ErrorState(
                    message: controller.errorMessage.value,
                    onRetry: controller.loadOrders);
              }
              if (controller.orders.isEmpty) {
                return const _EmptyState();
              }
              return RefreshIndicator(
                color: FarmerColors.primary,
                onRefresh: controller.loadOrders,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  itemCount: controller.orders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) =>
                      _OrderCard(order: controller.orders[i]),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ── Filter bar ────────────────────────────────────────────────────────────────

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.controller});
  final OrdersController controller;

  @override
  Widget build(BuildContext context) {
    const statuses = [null, ...OrderStatus.values];
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Obx(() => Row(
              children: statuses.map((s) {
                final isSelected = controller.selectedFilter.value == s;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(s?.label ?? 'All'),
                    selected: isSelected,
                    onSelected: (_) => controller.applyFilter(s),
                    selectedColor:
                        FarmerColors.primary.withValues(alpha: 0.15),
                    checkmarkColor: FarmerColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? FarmerColors.primary
                          : const Color(0xFF555555),
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w400,
                    ),
                    side: BorderSide(
                        color: isSelected
                            ? FarmerColors.primary
                            : Colors.grey.shade300),
                  ),
                );
              }).toList(),
            )),
      ),
    );
  }
}

// ── Order card ────────────────────────────────────────────────────────────────

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});
  final FarmerOrder order;

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<OrdersController>();
    final dateStr =
        DateFormat('dd MMM yyyy, h:mm a').format(order.createdAt);

    return GestureDetector(
      onTap: () => Get.to(
        () => OrderDetailView(order: order),
        transition: Transition.rightToLeft,
      ),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  Expanded(
                    child: Text(
                      order.customerName,
                      style: FarmerTextStyles.subheading
                          .copyWith(color: const Color(0xFF1B1B1B)),
                    ),
                  ),
                  _StatusBadge(status: order.status),
                ],
              ),
              const SizedBox(height: 4),
              Text('Placed: $dateStr', style: FarmerTextStyles.caption),
              const SizedBox(height: 8),

              // Items summary
              Text(
                order.items
                    .map((i) => '${i.productName} ×${i.quantity}')
                    .join(', '),
                style: FarmerTextStyles.body
                    .copyWith(color: const Color(0xFF555555)),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 10),

              // Footer: total + status update
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'PKR ${order.totalAmount.toStringAsFixed(0)}',
                      style: FarmerTextStyles.price,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Status update dropdown
                  _StatusDropdown(order: order, controller: ctrl),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Status dropdown ───────────────────────────────────────────────────────────

class _StatusDropdown extends StatelessWidget {
  const _StatusDropdown({required this.order, required this.controller});
  final FarmerOrder order;
  final OrdersController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: FarmerColors.secondary),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<OrderStatus>(
          value: order.status,
          isDense: true,
          icon: const Icon(Icons.expand_more,
              size: 18, color: FarmerColors.primary),
          style: const TextStyle(
              fontSize: 13,
              color: FarmerColors.primary,
              fontWeight: FontWeight.w600),
          items: OrderStatus.values
              .map((s) => DropdownMenuItem(
                    value: s,
                    child: Text(s.label),
                  ))
              .toList(),
          onChanged: (newStatus) {
            if (newStatus != null && newStatus != order.status) {
              controller.updateStatus(order, newStatus);
            }
          },
        ),
      ),
    );
  }
}

// ── Status badge ──────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final OrderStatus status;

  Color get _color {
    switch (status) {
      case OrderStatus.pending:
        return FarmerColors.statusPending;
      case OrderStatus.confirmed:
        return FarmerColors.statusConfirmed;
      case OrderStatus.readyForPickup:
        return FarmerColors.statusReady;
      case OrderStatus.completed:
        return FarmerColors.statusCompleted;
      case OrderStatus.cancelled:
        return FarmerColors.statusCancelled;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color),
      ),
      child: Text(status.label,
          style: TextStyle(
              color: _color, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}

// ── Empty / error states ──────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.receipt_long_outlined,
              size: 72, color: FarmerColors.secondary),
          SizedBox(height: 12),
          Text('No orders found', style: TextStyle(fontSize: 17)),
          SizedBox(height: 4),
          Text('Try a different filter.', style: FarmerTextStyles.caption),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline,
              size: 56, color: FarmerColors.error),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: onRetry,
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
}
