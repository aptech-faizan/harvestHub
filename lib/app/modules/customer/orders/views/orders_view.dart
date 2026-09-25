// TODO(ui): design baad mein
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/models/order_model.dart';
import '../controllers/orders_controller.dart';

// Ye customer ke orders ki list aur management screen hai
class OrdersView extends GetView<OrdersController> {
  const OrdersView({super.key});

  // Slot tabdeel karne ke liye bottom sheet dikhata hai
  void _openChangeSlotSheet(OrderModel order) {
    controller.loadSlotsFor(order);
    Get.bottomSheet(
      Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: Obx(() {
          if (controller.availableSlots.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Koi doosra slot dastiyab nahi hai'),
            );
          }
          return ListView.builder(
            shrinkWrap: true,
            itemCount: controller.availableSlots.length,
            itemBuilder: (context, index) {
              final slot = controller.availableSlots[index];
              return ListTile(
                title: Text(slot.label),
                trailing: slot.isFull ? const Text('Full', style: TextStyle(color: Colors.red)) : null,
                enabled: !slot.isFull,
                onTap: slot.isFull ? null : () => controller.changeSlot(order, slot),
              );
            },
          );
        }),
      ),
    );
  }

  // Order cancel karne ka confirmation dialog dikhata hai
  void _showCancelDialog(OrderModel order) {
    Get.defaultDialog(
      title: 'Cancel Order',
      middleText: 'Kya aap waqai ye order cancel karna chahte hain?',
      textConfirm: 'Haan, Cancel',
      textCancel: 'Nahi',
      onConfirm: () {
        Get.back();
        controller.cancelOrder(order);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Orders')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.orders.isEmpty) {
          return const Center(child: Text('Koi order nahi'));
        }

        return RefreshIndicator(
          onRefresh: controller.loadOrders,
          child: ListView.builder(
            padding: const EdgeInsets.all(12.0),
            itemCount: controller.orders.length,
            itemBuilder: (context, index) {
              final order = controller.orders[index];
              final orderShortId = order.id.length >= 6 ? order.id.substring(0, 6) : order.id;
              final orderDate = order.createdAt != null
                  ? '${order.createdAt!.day}/${order.createdAt!.month}/${order.createdAt!.year}'
                  : 'Date not available';

              return Card(
                margin: const EdgeInsets.only(bottom: 12.0),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Order #$orderShortId', style: const TextStyle(fontWeight: FontWeight.bold)),
                          Chip(label: Text(order.status)),
                        ],
                      ),
                      Text('Date: $orderDate', style: const TextStyle(color: Colors.grey)),
                      Text('Farmer: ${order.farmerName}', style: const TextStyle(fontWeight: FontWeight.w500)),
                      const Divider(),
                      ...order.items.map((item) => Text('${item['name']} x ${item['qty']}')),
                      const Divider(),
                      Text('Total: Rs. ${order.totalPrice}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      if (order.pickupSlotTime.isNotEmpty)
                        Text('Pickup Slot: ${order.pickupSlotTime}', style: const TextStyle(color: Colors.blueGrey)),
                      if (order.canModify) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            SizedBox(
                              height: 40,
                              child: OutlinedButton(
                                onPressed: () => _openChangeSlotSheet(order),
                                child: const Text('Change slot'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              height: 40,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700, foregroundColor: Colors.white),
                                onPressed: () => _showCancelDialog(order),
                                child: const Text('Cancel'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
