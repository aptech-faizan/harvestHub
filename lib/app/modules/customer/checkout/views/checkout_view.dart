// TODO(ui): design baad mein
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/checkout_controller.dart';

// Ye customer checkout ki placeholder UI screen hai
class CheckoutView extends GetView<CheckoutController> {
  const CheckoutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final grouped = controller.cartController.groupedByFarmer;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Har farmer ke items aur slot selection
              ...grouped.entries.map((entry) {
                final farmerId = entry.key;
                final items = entry.value;
                final farmerName = items.isNotEmpty ? items.first.product.farmerName : 'Farmer';
                final slots = controller.farmerSlots[farmerId] ?? [];

                return Card(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Farmer: $farmerName', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const Divider(),
                        ...items.map((item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Text('${item.product.itemName} x ${item.qty} = Rs. ${item.total}'),
                        )),
                        const SizedBox(height: 8),
                        const Text('Pickup Slot:', style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        if (slots.isEmpty)
                          const Text('Koi slot available nahi hai', style: TextStyle(color: Colors.red))
                        else
                          Wrap(
                            spacing: 8.0,
                            children: slots.map((slot) {
                              if (slot.isFull) {
                                return ChoiceChip(
                                  label: Text('${slot.label} (Full)'),
                                  selected: false,
                                  onSelected: null,
                                );
                              }
                              final isSelected = controller.selectedSlotId[farmerId] == slot.id;
                              return ChoiceChip(
                                label: Text(slot.label),
                                selected: isSelected,
                                onSelected: (_) => controller.selectSlot(farmerId, slot),
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 12),
              // Delivery Address Field
              TextField(
                controller: controller.addressController,
                decoration: const InputDecoration(
                  labelText: 'Delivery Address',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              // Grand Total Display
              Text(
                'Grand Total: Rs. ${controller.grandTotal}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              // Confirm Order Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.isPlacing.value ? null : () => controller.placeOrder(),
                  child: controller.isPlacing.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Confirm Order'),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
