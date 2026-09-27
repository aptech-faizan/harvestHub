// TODO(ui): design baad mein
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/models/farmer_model.dart';
import '../../../../data/models/product_model.dart';
import '../../../../routes/app_routes.dart';
import '../../follow/widgets/follow_farmer_button.dart';
import '../../../shared/chat/widgets/chat_farmer_button.dart';
import '../controllers/farmers_controller.dart';

// Ye ek farmer ka detail aur uske products dikhane ki placeholder screen hai
class FarmerDetailsView extends GetView<FarmersController> {
  const FarmerDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    // Route arguments se farmer model lo
    final farmer = Get.arguments as FarmerModel;

    return Scaffold(
      appBar: AppBar(title: Text(farmer.businessName)),
      body: FutureBuilder<List<ProductModel>>(
        future: controller.getProductsForFarmer(farmer),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final products = snapshot.data ?? [];
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Farmer info card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(farmer.businessName,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        if (farmer.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(farmer.description, style: const TextStyle(color: Colors.grey)),
                        ],
                        if (farmer.rating > 0) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.star, size: 16, color: Colors.amber),
                              Text(farmer.rating.toStringAsFixed(1)),
                            ],
                          ),
                        ],
                        const SizedBox(height: 8),
                        // Follow + chat, both driven by shared controllers so
                        // they stay in sync with every other surface.
                        Row(
                          children: [
                            Expanded(
                              child: FollowFarmerButton(
                                farmerId:
                                    farmer.id.isEmpty ? farmer.userId : farmer.id,
                                farmerName: farmer.businessName,
                              ),
                            ),
                            const SizedBox(width: 8),
                            ChatFarmerButton(
                              farmerId:
                                  farmer.id.isEmpty ? farmer.userId : farmer.id,
                              farmerName: farmer.businessName,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Products', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (products.isEmpty)
                  const Text('Is farmer ka koi product nahi mila')
                else
                  ...products.map((product) => ListTile(
                        title: Text(product.itemName),
                        subtitle: Text('Rs. ${product.pricePerUnit} / ${product.unit}'),
                        trailing: Text('Stock: ${product.stockQty}'),
                        onTap: () => Get.toNamed(
                          Routes.customerProductDetails,
                          arguments: product,
                        ),
                      )),
              ],
            ),
          );
        },
      ),
    );
  }
}
