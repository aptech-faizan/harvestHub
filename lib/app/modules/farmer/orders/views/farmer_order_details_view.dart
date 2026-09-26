import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/utils/helpers.dart';
import 'package:harvest_hub/app/core/widgets/info_row.dart';
import 'package:harvest_hub/app/modules/farmer/orders/controllers/farmer_orders_controller.dart';
import 'package:harvest_hub/app/modules/farmer/utils/farmer_order_status.dart';

class FarmerOrderDetailsView extends GetView<FarmerOrdersController> {
  const FarmerOrderDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order details')),
      body: Obx(() {
        final o = controller.selected.value;
        if (o == null) return const Center(child: Text('Order not found'));
        final next = nextFarmerStatuses(o.status);
        return ListView(padding: const EdgeInsets.all(16), children: [
          InfoRow('Order ID', o.id),
          InfoRow('Customer', controller.customerName(o.customerId)),
          InfoRow('Order date', formatDate(o.createdAt)),
          InfoRow('Pickup slot', o.pickupSlotTime),
          if (o.deliveryAddress.isNotEmpty) InfoRow('Address', o.deliveryAddress),
          InfoRow('Status', orderStatusLabel(o.status)),
          InfoRow('Total', money(o.totalPrice)),
          const SizedBox(height: 12),
          if (next.isNotEmpty) ...[
            const Text('Update status', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final s in next)
                  ElevatedButton(
                    onPressed: () => controller.updateStatus(o, s),
                    child: Text(orderStatusLabel(s)),
                  ),
              ],
            ),
          ],
          const Divider(height: 32),
          const Text('Items', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          if (o.items.isEmpty) const Padding(padding: EdgeInsets.all(8), child: Text('No items')),
          for (final item in o.items)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('${item['name'] ?? item['itemName'] ?? 'Item'}'),
              subtitle: Text(
                '${item['qty'] ?? item['quantity'] ?? 0}${item['unit'] != null && '${item['unit']}'.isNotEmpty ? ' ${item['unit']}' : ''} × ${money(item['price'] ?? item['pricePerUnit'] ?? 0)}',
              ),
              trailing: Text(
                money(
                  ((item['qty'] ?? item['quantity'] ?? 0) as num).toDouble() *
                      ((item['price'] ?? item['pricePerUnit'] ?? 0) as num).toDouble(),
                ),
              ),
            ),
        ]);
      }),
    );
  }
}
