import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../data/models/farmer_order_model.dart';
import '../../farmer_theme.dart';
import '../controllers/orders_controller.dart';

/// Full order detail screen (read-only + status update).
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
        backgroundColor: FarmerColors.primary,
        foregroundColor: Colors.white,
        title: Text('Order #${order.id.substring(0, 8).toUpperCase()}',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Customer info card ────────────────────────────────────
            _SectionCard(
              title: 'Customer',
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundColor: FarmerColors.secondary,
                    child: Icon(Icons.person, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order.customerName,
                          style: FarmerTextStyles.subheading
                              .copyWith(color: const Color(0xFF1B1B1B))),
                      Text('Customer ID: ${order.customerId}',
                          style: FarmerTextStyles.caption),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Order info ────────────────────────────────────────────
            _SectionCard(
              title: 'Order Info',
              child: Column(
                children: [
                  _InfoRow('Order ID', order.id.toUpperCase()),
                  _InfoRow('Placed', dateStr),
                  _InfoRow('Last Updated',
                      DateFormat('dd MMM yyyy').format(order.updatedAt)),
                  if (order.notes != null && order.notes!.isNotEmpty)
                    _InfoRow('Notes', order.notes!),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Items ─────────────────────────────────────────────────
            _SectionCard(
              title: 'Items',
              child: Column(
                children: [
                  ...order.items.map((item) => _ItemRow(item: item)),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700)),
                      Text(
                        'PKR ${order.totalAmount.toStringAsFixed(0)}',
                        style: FarmerTextStyles.price
                            .copyWith(fontSize: 18),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Status update ─────────────────────────────────────────
            _SectionCard(
              title: 'Update Status',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Change the order status:',
                    style: FarmerTextStyles.body,
                  ),
                  const SizedBox(height: 12),
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
                        labelStyle: TextStyle(
                          color: isCurrent
                              ? FarmerColors.primary
                              : const Color(0xFF555555),
                          fontWeight: isCurrent
                              ? FontWeight.w700
                              : FontWeight.w400,
                        ),
                        side: BorderSide(
                          color: isCurrent
                              ? FarmerColors.primary
                              : Colors.grey.shade300,
                        ),
                        onSelected: (selected) {
                          if (selected && !isCurrent) {
                            ctrl.updateStatus(order, s);
                            Get.back(); // go back to list after update
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

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: FarmerTextStyles.subheading),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: FarmerTextStyles.caption),
          ),
          Expanded(
            child: Text(value, style: FarmerTextStyles.body),
          ),
        ],
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.item});
  final OrderItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.eco, size: 16, color: FarmerColors.secondary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.productName,
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                Text(
                    '${item.quantity} ${item.unit} × PKR ${item.pricePerUnit.toStringAsFixed(0)}',
                    style: FarmerTextStyles.caption),
              ],
            ),
          ),
          Text('PKR ${item.subtotal.toStringAsFixed(0)}',
              style: FarmerTextStyles.body
                  .copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
