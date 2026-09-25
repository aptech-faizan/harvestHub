// TODO(ui): design baad mein
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../routes/app_routes.dart';
import '../controllers/product_search_controller.dart';

// Ye search aur filters ki placeholder UI screen hai
class SearchView extends GetView<ProductSearchController> {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Products')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                // Product name search field
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Search Product',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (val) => controller.query.value = val,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Category dropdown
                    Expanded(
                      child: Obx(() => DropdownButton<String>(
                        isExpanded: true,
                        value: controller.selectedCategoryId.value,
                        items: [
                          const DropdownMenuItem(value: '', child: Text('All Categories')),
                          ...controller.categories.map((c) =>
                            DropdownMenuItem(value: c.id, child: Text(c.name)),
                          ),
                        ],
                        onChanged: (val) {
                          controller.selectedCategoryId.value = val ?? '';
                          controller.applyFilters();
                        },
                      )),
                    ),
                    const SizedBox(width: 8),
                    // Market dropdown
                    Expanded(
                      child: Obx(() => DropdownButton<String>(
                        isExpanded: true,
                        value: controller.selectedMarketId.value,
                        items: [
                          const DropdownMenuItem(value: '', child: Text('All Markets')),
                          ...controller.markets.map((m) =>
                            DropdownMenuItem(value: m.id, child: Text(m.marketName)),
                          ),
                        ],
                        onChanged: (val) {
                          controller.selectedMarketId.value = val ?? '';
                          controller.applyFilters();
                        },
                      )),
                    ),
                  ],
                ),
                Row(
                  children: [
                    // Farmer name search field
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(labelText: 'Farmer Name'),
                        onChanged: (val) => controller.farmerQuery.value = val,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Distance dropdown
                    Obx(() => DropdownButton<double>(
                      value: controller.maxDistanceKm.value,
                      items: const [
                        DropdownMenuItem(value: 0, child: Text('Any dist')),
                        DropdownMenuItem(value: 2, child: Text('2 km')),
                        DropdownMenuItem(value: 5, child: Text('5 km')),
                        DropdownMenuItem(value: 10, child: Text('10 km')),
                        DropdownMenuItem(value: 25, child: Text('25 km')),
                      ],
                      onChanged: (val) => controller.selectDistance(val ?? 0),
                    )),
                    TextButton(
                      onPressed: () => controller.clearFilters(),
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(),
          // Filtered results list
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.results.isEmpty) {
                return const Center(child: Text('No products found'));
              }
              return ListView.builder(
                itemCount: controller.results.length,
                itemBuilder: (context, index) {
                  final p = controller.results[index];
                  final isOutOfStock = p.stockQty <= 0;
                  final distLabel = controller.distanceKmOf(p);

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: ListTile(
                      onTap: () => Get.toNamed(
                        Routes.customerProductDetails,
                        arguments: p,
                      ),
                      title: Text(p.itemName),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Farmer: ${p.farmerName} | Market: ${p.marketName}'),
                          Text('Price: Rs. ${p.pricePerUnit} / ${p.unit}'),
                          Text(
                            isOutOfStock ? 'Out of stock' : 'Stock: ${p.stockQty}',
                            style: TextStyle(color: isOutOfStock ? Colors.red : Colors.green),
                          ),
                          if (distLabel.isNotEmpty)
                            Text(distLabel, style: const TextStyle(color: Colors.blueGrey)),
                        ],
                      ),
                      trailing: ElevatedButton(
                        onPressed: isOutOfStock ? null : () => controller.addToCart(p),
                        child: const Text('Add to cart'),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
