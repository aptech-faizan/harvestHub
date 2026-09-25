// TODO(ui): design baad mein
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../product_details/bindings/product_details_binding.dart';
import '../../product_details/views/product_details_view.dart';
import '../controllers/wishlist_controller.dart';

// Ye customer wishlist ki placeholder UI screen hai
class WishlistView extends GetView<WishlistController> {
  const WishlistView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wishlist'),
      ),
      body: Obx(() {
        if (controller.items.isEmpty) {
          return const Center(
            child: Text('Wishlist khali hai'),
          );
        }

        return ListView.builder(
          itemCount: controller.items.length,
          itemBuilder: (context, index) {
            final p = controller.items[index];
            final isOutOfStock = p.stockQty <= 0;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: ListTile(
                onTap: () => Get.to(
                  () => const ProductDetailsView(),
                  binding: ProductDetailsBinding(),
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
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => controller.remove(p.id),
                    ),
                    SizedBox(
                      height: 40,
                      child: ElevatedButton(
                        onPressed: isOutOfStock ? null : () => controller.addToCart(p),
                        child: const Text('Add to cart'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
