import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/widgets/state_view.dart';
import 'package:harvest_hub/app/data/models/product_model.dart';
import 'package:harvest_hub/app/modules/farmer/inventory/controllers/farmer_inventory_controller.dart';

class FarmerInventoryView extends GetView<FarmerInventoryController> {
  const FarmerInventoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        actions: [IconButton(onPressed: controller.load, icon: const Icon(Icons.refresh))],
      ),
      body: Obx(() {
        return StateView(
          isLoading: controller.isLoading.value,
          error: controller.error.value,
          isEmpty: controller.products.isEmpty,
          emptyText: 'No products to manage.',
          onRetry: controller.load,
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              Text(
                'Zero-stock items cannot be ordered. Low-stock threshold: ${controller.threshold}',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 8),
              if (controller.zeroStock.isNotEmpty) ...[
                const Text('Out of stock', style: TextStyle(fontWeight: FontWeight.bold)),
                ...controller.zeroStock.map((p) => _tile(p, Colors.red)),
                const SizedBox(height: 12),
              ],
              if (controller.lowStock.isNotEmpty) ...[
                const Text('Low stock', style: TextStyle(fontWeight: FontWeight.bold)),
                ...controller.lowStock.map((p) => _tile(p, Colors.orange)),
                const SizedBox(height: 12),
              ],
              const Text('All products', style: TextStyle(fontWeight: FontWeight.bold)),
              ...controller.products.map((p) => _tile(p, null)),
            ],
          ),
        );
      }),
    );
  }

  Widget _tile(ProductModel p, Color? color) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text(p.itemName),
        subtitle: Text('Stock: ${p.stockQty} ${p.unit}'),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: () => controller.setStock(p, p.stockQty - 1),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => controller.setStock(p, p.stockQty + 1),
          ),
          IconButton(
            icon: Icon(Icons.edit, color: color),
            onPressed: () => controller.promptStock(p),
          ),
        ]),
      ),
    );
  }
}
