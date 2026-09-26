import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/product_details_controller.dart';

// Ye Product Details screen ki simple placeholder UI hai
class ProductDetailsView extends GetView<ProductDetailsController> {
  const ProductDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final p = controller.product;
    final isOutOfStock = p.stockQty <= 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(p.itemName),
        actions: [
          Obx(() => IconButton(
            icon: Icon(
              controller.isWishlisted.value ? Icons.favorite : Icons.favorite_border,
              color: controller.isWishlisted.value ? Colors.red : null,
            ),
            onPressed: () => controller.toggleWishlist(),
          )),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            Container(
              height: 200,
              width: double.infinity,
              color: Colors.grey.shade300,
              child: Image.network(p.imageUrl),
            ),
            const SizedBox(height: 16),
            Text(p.itemName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            // Category ProductModel se dikhana
            Text('Category: ${p.categoryName.isEmpty ? '-' : p.categoryName}', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Text('Price: Rs. ${p.pricePerUnit} / ${p.unit}', style: const TextStyle(fontSize: 18, color: Colors.green)),
            const SizedBox(height: 6),
            Text(isOutOfStock ? 'Out of stock' : 'Available Stock: ${p.stockQty}', style: TextStyle(color: isOutOfStock ? Colors.red : Colors.black87)),
            const SizedBox(height: 12),
            // Description ProductModel se dikhana
            Text('Description: ${p.description.isEmpty ? 'Koi description nahi' : p.description}'),
            const SizedBox(height: 16),
            // Farmer info card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Farmer: ${p.farmerName}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    // TODO: farmer profile/rating baad mein
                    const Text('Rating: 4.8 / 5.0 (Verified Farmer)', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Quantity selector
            Row(
              children: [
                const Text('Quantity: ', style: TextStyle(fontSize: 16)),
                IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: isOutOfStock ? null : () => controller.decrement()),
                Obx(() => Text('${controller.qty.value}', style: const TextStyle(fontSize: 18))),
                IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: isOutOfStock ? null : () => controller.increment()),
              ],
            ),
            const SizedBox(height: 20),
            // Add to cart button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isOutOfStock ? null : () => controller.addToCart(),
                child: const Text('Add to Cart'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
