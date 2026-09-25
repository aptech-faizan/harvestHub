// TODO(ui): design baad mein
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../routes/app_routes.dart';
import '../controllers/home_controller.dart';

// Ye Customer Home screen ki simple placeholder UI hai
class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HarvestHub Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.people_outline),
            onPressed: () => Get.toNamed(Routes.customerFarmers),
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () => Get.toNamed(Routes.customerWishlist),
          ),
        ],
      ),
      body: Column(
        children: [
          // Horizontal category chips
          SizedBox(
            height: 50,
            child: Obx(() {
              return ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                children: [
                  // 'All' category chip
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ChoiceChip(
                      label: const Text('All'),
                      selected: controller.selectedCategoryId.value.isEmpty,
                      onSelected: (selected) => controller.selectCategory(''),
                    ),
                  ),
                  // Dynamic categories chips
                  ...controller.categories.map((category) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ChoiceChip(
                        label: Text(category.name),
                        selected: controller.selectedCategoryId.value == category.id,
                        onSelected: (selected) => controller.selectCategory(category.id),
                      ),
                    );
                  }),
                ],
              );
            }),
          ),
          const Divider(),
          // Products list view
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final products = controller.filteredProducts;
              if (products.isEmpty) {
                return const Center(child: Text('Koi product nahi mila'));
              }

              return ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final p = products[index];
                  final isOutOfStock = p.stockQty <= 0;

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: ListTile(
                      onTap: () => Get.toNamed(
                        Routes.customerProductDetails,
                        arguments: p,
                      ),
                      title: Text(p.itemName),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Farmer: ${p.farmerName}'),
                          Text('Price: Rs. ${p.pricePerUnit} / ${p.unit}'),
                          Text(
                            isOutOfStock ? 'Out of stock' : 'Stock: ${p.stockQty}',
                            style: TextStyle(
                              color: isOutOfStock ? Colors.red : Colors.green,
                            ),
                          ),
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
