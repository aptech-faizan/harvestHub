import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/utils/helpers.dart';
import 'package:harvest_hub/app/core/widgets/info_row.dart';
import 'package:harvest_hub/app/modules/admin/products/controllers/products_controller.dart';
import 'package:harvest_hub/app/modules/admin/products/views/products_view.dart';

class ProductDetailsView extends GetView<ProductsController> {
  const ProductDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product details')),
      body: Obx(() {
        final p = controller.selected.value;
        if (p == null) return const Center(child: Text('Product not found'));
        return ListView(padding: const EdgeInsets.all(16), children: [
          Center(child: productImage(p.imageUrl, size: 180)),
          const SizedBox(height: 16),
          InfoRow('Name', p.itemName),
          InfoRow('Category', p.category),
          InfoRow('Farmer', controller.farmerName(p.farmerId)),
          InfoRow('Price', money(p.pricePerUnit)),
          InfoRow('Stock', '${p.stockQty}'),
          InfoRow('Description', p.description),
          const SizedBox(height: 16),
          Wrap(spacing: 8, runSpacing: 8, children: [
            ElevatedButton.icon(
                onPressed: () => controller.edit(p),
                icon: const Icon(Icons.edit),
                label: const Text('Edit')),
            OutlinedButton.icon(
              onPressed: () async {
                if (await controller.delete(p)) Get.back();
              },
              icon: const Icon(Icons.delete, color: Colors.red),
              label: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ]),
        ]);
      }),
    );
  }
}
