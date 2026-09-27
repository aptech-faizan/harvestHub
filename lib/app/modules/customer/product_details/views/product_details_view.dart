import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/modules/customer/follow/widgets/follow_farmer_button.dart';
import 'package:harvest_hub/app/modules/shared/chat/widgets/chat_farmer_button.dart';
import '../controllers/product_details_controller.dart';

// Ye Product Details screen ki simple placeholder UI hai
class ProductDetailsView extends GetView<ProductDetailsController> {  const ProductDetailsView({super.key});

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
            // Product image. Cloudinary URLs can be empty (image is optional
            // when an admin creates a product) or dead, so both the empty case
            // and a load failure fall back to a placeholder instead of
            // rendering a broken image widget.
            _ProductImage(url: p.imageUrl),
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
                    // Real rating from farmers/{id}.rating - never a hardcoded
                    // value, and hidden entirely until the farmer has one.
                    Obx(() {
                      final rating = controller.farmerRating;
                      if (rating == null) {
                        return controller.isLoadingFarmer.value
                            ? const SizedBox.shrink()
                            : const Text(
                                'No rating yet',
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              );
                      }
                      return Row(
                        children: [
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            '${rating.toStringAsFixed(1)} / 5.0',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      );
                    }),
                    if (p.marketName.isNotEmpty)
                      Text('Market: ${p.marketName}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 8),
                    // Follow the farmer so restock alerts can reach this customer.
                    Obx(() {
                      final resolvedId = controller.farmer.value?.id.isNotEmpty == true
                          ? controller.farmer.value!.id
                          : p.farmerId;
                      return Row(
                        children: [
                          Expanded(
                            child: FollowFarmerButton(
                              farmerId: resolvedId,
                              farmerName: p.farmerName,
                            ),
                          ),
                          const SizedBox(width: 8),
                          ChatFarmerButton(
                            farmerId: resolvedId,
                            farmerName: p.farmerName,
                          ),
                        ],
                      );
                    }),
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

/// Product image with an explicit placeholder for the empty-URL and load-failure
/// cases. `imageUrl` is optional in the data model, so an empty string is an
/// expected value rather than an error.
class _ProductImage extends StatelessWidget {
  final String url;
  const _ProductImage({required this.url});

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      height: 200,
      width: double.infinity,
      color: Colors.grey.shade300,
      alignment: Alignment.center,
      child: const Icon(Icons.image_not_supported, size: 56, color: Colors.grey),
    );

    if (url.trim().isEmpty) return placeholder;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        url,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            height: 200,
            width: double.infinity,
            color: Colors.grey.shade300,
            alignment: Alignment.center,
            child: const CircularProgressIndicator(strokeWidth: 2),
          );
        },
        errorBuilder: (context, error, stack) => placeholder,
      ),
    );
  }
}
