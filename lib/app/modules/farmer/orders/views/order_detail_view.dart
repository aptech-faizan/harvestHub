import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../data/models/farmer_order_model.dart';
import '../../farmer_theme.dart';
import '../../widgets/farmer_widgets.dart';
import '../controllers/orders_controller.dart';

/// Full order details screen featuring a 4-step progress timeline/stepper,
/// customer details, items breakdown, and bottom status action sheet.
class OrderDetailView extends StatelessWidget {
  const OrderDetailView({super.key, required this.order});
  final FarmerOrder order;

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<OrdersController>();
    final dateStr =
        DateFormat('dd MMM yyyy, h:mm a').format(order.createdAt);

    return Scaffold(
      backgroundColor: FarmerColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: Semantics(
          button: true,
          label: 'Back to orders',
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 20, color: FarmerColors.text),
            onPressed: () => Get.back(),
          ),
        ),
        title: Text(
          'Order #${order.id.substring(0, order.id.length > 8 ? 8 : order.id.length).toUpperCase()}',
          style: const TextStyle(
            color: FarmerColors.text,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: StatusChip.fromOrderStatus(order.status),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: FarmerColors.border, height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. Order Progress Timeline / Stepper ────────────────────
            if (order.status == OrderStatus.cancelled)
              _CancelledAlertBanner(order: order)
            else
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Order Progress',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: FarmerColors.text,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _OrderProgressTimeline(currentStatus: order.status),
                  ],
                ),
              ),
            const SizedBox(height: 16),

            // ── 2. Customer Information Card ────────────────────────────
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Customer Information',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: FarmerColors.text,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: FarmerColors.primary.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(Icons.person_outline_rounded,
                              color: FarmerColors.primaryDark, size: 26),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.customerName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: FarmerColors.text,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Customer ID: ${order.customerId}',
                              style: FarmerTextStyles.caption.copyWith(
                                color: FarmerColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── 3. Ordered Items List ───────────────────────────────────
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Order Items',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: FarmerColors.text,
                        ),
                      ),
                      Text(
                        '${order.items.length} items',
                        style: FarmerTextStyles.caption.copyWith(
                          color: FarmerColors.muted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...order.items.map((item) => _DetailedItemRow(item: item)),
                  const SizedBox(height: 8),
                  const Divider(height: 1),
                  const SizedBox(height: 12),

                  // Total calculation breakdown
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Payable',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: FarmerColors.text,
                        ),
                      ),
                      Text(
                        FarmerCurrency.format(order.totalAmount),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: FarmerColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── 4. Order Meta Info ──────────────────────────────────────
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Order Summary',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: FarmerColors.text,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _MetaRow(label: 'Order ID', value: order.id.toUpperCase()),
                  _MetaRow(label: 'Date Placed', value: dateStr),
                  _MetaRow(
                    label: 'Last Updated',
                    value: DateFormat('dd MMM yyyy, h:mm a')
                        .format(order.updatedAt),
                  ),
                  if (order.notes != null && order.notes!.isNotEmpty)
                    _MetaRow(label: 'Customer Note', value: order.notes!),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── 5. Quick Status Update Action ───────────────────────────
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Change Status',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: FarmerColors.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap a status to immediately update this order.',
                    style: FarmerTextStyles.caption.copyWith(
                      color: FarmerColors.muted,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: OrderStatus.values.map((s) {
                      final isCurrent = order.status == s;

                      return ChoiceChip(
                        label: Text(s.label),
                        selected: isCurrent,
                        selectedColor:
                            FarmerColors.primary.withValues(alpha: 0.15),
                        backgroundColor: FarmerColors.surfaceMuted,
                        labelStyle: TextStyle(
                          color: isCurrent
                              ? FarmerColors.primaryDark
                              : FarmerColors.textSecondary,
                          fontWeight:
                              isCurrent ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 12,
                        ),
                        side: BorderSide(
                          color: isCurrent
                              ? FarmerColors.primaryDark
                              : FarmerColors.border,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        showCheckmark: isCurrent,
                        checkmarkColor: FarmerColors.primaryDark,
                        onSelected: (selected) {
                          if (selected && !isCurrent) {
                            ctrl.updateStatus(order, s);
                            Get.back();
                          }
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 4-step Timeline Stepper ───────────────────────────────────────────────────

class _OrderProgressTimeline extends StatelessWidget {
  final OrderStatus currentStatus;
  const _OrderProgressTimeline({required this.currentStatus});

  static const _steps = [
    OrderStatus.pending,
    OrderStatus.confirmed,
    OrderStatus.readyForPickup,
    OrderStatus.completed,
  ];

  int get _currentIndex {
    switch (currentStatus) {
      case OrderStatus.pending:
        return 0;
      case OrderStatus.confirmed:
        return 1;
      case OrderStatus.readyForPickup:
        return 2;
      case OrderStatus.completed:
        return 3;
      case OrderStatus.cancelled:
        return -1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeIdx = _currentIndex;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(_steps.length, (index) {
        final step = _steps[index];
        final isDone = activeIdx > index;
        final isCurrent = activeIdx == index;
        final isFuture = activeIdx < index;

        final Color circleColor = isDone || isCurrent
            ? FarmerColors.primary
            : const Color(0xFFD4DDD2);

        final Color lineColor =
            isDone ? FarmerColors.primary : const Color(0xFFE2EBE0);

        return Expanded(
          child: Column(
            children: [
              // Circle + Connecting Line
              Row(
                children: [
                  // Left connector
                  Expanded(
                    child: index == 0
                        ? const SizedBox.shrink()
                        : Container(height: 3, color: isDone || isCurrent ? FarmerColors.primary : lineColor),
                  ),
                  // Icon node
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isDone || isCurrent
                          ? circleColor
                          : const Color(0xFFF0F5EE),
                      shape: BoxShape.circle,
                      border: Border.all(color: circleColor, width: 2),
                    ),
                    child: Center(
                      child: isDone
                          ? const Icon(Icons.check,
                              color: Colors.white, size: 16)
                          : isCurrent
                              ? Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                )
                              : Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: FarmerColors.muted,
                                  ),
                                ),
                    ),
                  ),
                  // Right connector
                  Expanded(
                    child: index == _steps.length - 1
                        ? const SizedBox.shrink()
                        : Container(height: 3, color: isDone ? FarmerColors.primary : lineColor),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Step title
              Text(
                step.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight:
                      isCurrent || isDone ? FontWeight.w700 : FontWeight.w500,
                  color: isCurrent
                      ? FarmerColors.primaryDark
                      : isFuture
                          ? FarmerColors.muted
                          : FarmerColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

// ── Cancelled Alert Banner ────────────────────────────────────────────────────

class _CancelledAlertBanner extends StatelessWidget {
  final FarmerOrder order;
  const _CancelledAlertBanner({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FarmerColors.errorBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: FarmerColors.error.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.cancel_outlined,
              color: FarmerColors.error,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Order Cancelled',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: FarmerColors.error,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  order.notes != null && order.notes!.isNotEmpty
                      ? 'Reason: ${order.notes}'
                      : 'This order was marked as cancelled and is no longer active.',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF5C2B2B),
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

// ── Item Row with Subtotal ────────────────────────────────────────────────────

class _DetailedItemRow extends StatelessWidget {
  final OrderItem item;
  const _DetailedItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: FarmerColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.eco_outlined,
                color: FarmerColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: FarmerColors.text,
                  ),
                ),
                Text(
                  '${item.quantity} ${item.unit} × ${FarmerCurrency.format(item.pricePerUnit)}',
                  style: FarmerTextStyles.caption.copyWith(
                    color: FarmerColors.muted,
                  ),
                ),
              ],
            ),
          ),
          Text(
            FarmerCurrency.format(item.subtotal),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: FarmerColors.text,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Meta Info Row ─────────────────────────────────────────────────────────────

class _MetaRow extends StatelessWidget {
  final String label;
  final String value;

  const _MetaRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: FarmerTextStyles.caption.copyWith(
                color: FarmerColors.muted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: FarmerColors.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
