import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/constants/app_constants.dart';
import 'package:harvest_hub/app/core/utils/helpers.dart';
import 'package:harvest_hub/app/core/widgets/info_row.dart';
import 'package:harvest_hub/app/modules/admin/orders/controllers/orders_controller.dart';

class OrderDetailsView extends GetView<OrdersController> {
  const OrderDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order details')),
      body: Obx(() {
        final o = controller.selected.value;
        if (o == null) return const Center(child: Text('Order not found'));
        return ListView(padding: const EdgeInsets.all(16), children: [
          InfoRow('Order ID', o.id),
          InfoRow('Customer', controller.customerName(o.customerId)),
          InfoRow('Farmer', o.farmerName.isNotEmpty ? o.farmerName : controller.farmerName(o.farmerId)),
          if (o.deliveryAddress.isNotEmpty) InfoRow('Delivery address', o.deliveryAddress),
          InfoRow('Order date', formatDate(o.createdAt)),
          InfoRow('Pickup slot', o.pickupSlot),
          InfoRow('Total price', money(o.totalPrice)),
          const SizedBox(height: 8),
          Row(children: [
            const Text('Status:  ', style: TextStyle(fontWeight: FontWeight.bold)),
            // Only legal next states are offered. Completed and cancelled are
            // terminal, so this renders as a plain label for them.
            Builder(builder: (context) {
              final next = controller.nextStatuses(o);
              if (next.isEmpty) {
                return Chip(
                  label: Text(OrderStatus.label(o.status)),
                  avatar: const Icon(Icons.lock_outline, size: 16),
                );
              }
              return DropdownButton<String>(
                value: o.status,
                hint: Text(o.status),
                items: [
                  DropdownMenuItem(
                    value: o.status,
                    child: Text('${OrderStatus.label(o.status)} (current)'),
                  ),
                  ...next.map(
                    (s) => DropdownMenuItem(
                      value: s,
                      child: Text(OrderStatus.label(s)),
                    ),
                  ),
                ],
                onChanged: (v) {
                  if (v != null && v != o.status) controller.updateStatus(o, v);
                },
              );
            }),
          ]),
          const Divider(height: 32),
          const Text('Items', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          if (o.items.isEmpty) const Padding(padding: EdgeInsets.all(8), child: Text('No items')),
          for (final item in o.items)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(item.itemName),
              subtitle: Text('${item.quantity}${item.unit.isNotEmpty ? ' ${item.unit}' : ''} × ${money(item.price)}'),
              trailing: Text(money(item.quantity * item.price)),
            ),
        ]);
      }),
    );
  }
}
