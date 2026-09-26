import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/utils/helpers.dart';
import 'package:harvest_hub/app/core/widgets/search_box.dart';
import 'package:harvest_hub/app/core/widgets/state_view.dart';
import 'package:harvest_hub/app/modules/farmer/products/controllers/farmer_products_controller.dart';

class FarmerProductsView extends GetView<FarmerProductsController> {
  const FarmerProductsView({super.key});

  Widget _thumb(String url) {
    if (url.isEmpty) return const Icon(Icons.image_not_supported);
    return Image.network(
      url,
      width: 56,
      height: 56,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Products'),
        actions: [IconButton(onPressed: controller.load, icon: const Icon(Icons.refresh))],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => controller.openForm(),
        child: const Icon(Icons.add),
      ),
      body: Column(children: [
        SearchBox(hint: 'Search products', onChanged: (v) => controller.search.value = v),
        Expanded(
          child: Obx(() {
            final list = controller.filtered;
            return StateView(
              isLoading: controller.isLoading.value,
              error: controller.error.value,
              isEmpty: list.isEmpty,
              emptyText: 'No products yet. Tap + to add one.',
              onRetry: controller.load,
              child: ListView.separated(
                itemCount: list.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final p = list[i];
                  final out = p.stockQty <= 0;
                  return ListTile(
                    leading: _thumb(p.imageUrl),
                    title: Text(p.itemName),
                    subtitle: Text(
                      '${p.categoryName.isEmpty ? '-' : p.categoryName}  •  ${money(p.pricePerUnit)} / ${p.unit}\n'
                      '${out ? 'Out of stock' : 'Stock: ${p.stockQty}'}',
                    ),
                    isThreeLine: true,
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                      IconButton(icon: const Icon(Icons.edit), onPressed: () => controller.openForm(p)),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => controller.delete(p),
                      ),
                    ]),
                  );
                },
              ),
            );
          }),
        ),
      ]),
    );
  }
}
