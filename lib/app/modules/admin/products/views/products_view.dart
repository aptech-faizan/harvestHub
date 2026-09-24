import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/utils/helpers.dart';
import 'package:harvest_hub/app/core/widgets/search_box.dart';
import 'package:harvest_hub/app/core/widgets/state_view.dart';
import 'package:harvest_hub/app/modules/admin/products/controllers/products_controller.dart';
import 'package:harvest_hub/app/modules/admin/widgets/admin_drawer.dart';

// Shows the product image, or an icon if there is no image / it fails to load.
Widget productImage(String url, {double size = 56}) {
  if (url.isEmpty) return Icon(Icons.image_not_supported, size: size);
  return Image.network(
    url,
    width: size,
    height: size,
    fit: BoxFit.cover,
    errorBuilder: (_, _, _) => Icon(Icons.broken_image, size: size),
  );
}

class ProductsView extends GetView<ProductsController> {
  const ProductsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [IconButton(onPressed: controller.load, icon: const Icon(Icons.refresh))],
      ),
      drawer: const AdminDrawer(),
      body: Column(children: [
        SearchBox(hint: 'Search by product or farmer', onChanged: (v) => controller.search.value = v),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Obx(() {
            final names = {'All', ...controller.categories.map((c) => c.name)}.toList();
            return DropdownButton<String>(
              isExpanded: true,
              value: names.contains(controller.categoryFilter.value)
                  ? controller.categoryFilter.value
                  : 'All',
              items: names.map((n) => DropdownMenuItem(value: n, child: Text(n))).toList(),
              onChanged: (v) => controller.categoryFilter.value = v ?? 'All',
            );
          }),
        ),
        Expanded(
          child: Obx(() {
            final list = controller.filtered;
            return StateView(
              isLoading: controller.isLoading.value,
              error: controller.error.value,
              isEmpty: list.isEmpty,
              emptyText: 'No products found',
              onRetry: controller.load,
              child: ListView.builder(
                itemCount: list.length,
                itemBuilder: (_, i) {
                  final p = list[i];
                  return ListTile(
                    leading: productImage(p.imageUrl),
                    title: Text(p.itemName),
                    subtitle: Text(
                        '${p.category}  •  ${controller.farmerName(p.farmerId)}\nStock: ${p.stockQty}'),
                    isThreeLine: true,
                    trailing: Text(money(p.pricePerUnit)),
                    onTap: () => controller.openDetails(p),
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
