// TODO(ui): design baad mein
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/models/product_model.dart';
import '../../checkout/bindings/checkout_binding.dart';
import '../../checkout/views/checkout_view.dart';
import '../controllers/cart_controller.dart';

// Ye cart ki simple placeholder UI screen hai
class CartView extends GetView<CartController> {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        actions: [
          // TODO: testing ke baad hata dena
          TextButton(
            onPressed: () => _addDummyProducts(),
            child: const Text('Add dummy products', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Obx(() {
        return Column(
          children: [
            Expanded(
              child: controller.items.isEmpty
                  ? const Center(child: Text('Cart khali hai'))
                  : ListView.builder(
                      itemCount: controller.items.length,
                      itemBuilder: (context, index) {
                        final item = controller.items[index];
                        return ListTile(
                          title: Text(item.product.itemName),
                          subtitle: Text('Price: Rs. ${item.product.pricePerUnit} x ${item.qty} = Rs. ${item.total}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () => controller.setQty(item.product.id, item.qty - 1),
                              ),
                              Text('${item.qty}'),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () => controller.setQty(item.product.id, item.qty + 1),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => controller.remove(item.product.id),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text('Subtotal: Rs. ${controller.subtotal}'),
                  Text('Total Items: ${controller.itemCount}'),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: controller.items.isEmpty ? null : () => controller.clear(),
                        child: const Text('Clear Cart'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: controller.items.isEmpty
                            ? null
                            : () => Get.to(
                                  () => const CheckoutView(),
                                  binding: CheckoutBinding(),
                                ),
                        child: const Text('Checkout'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  // Testing ke liye 3 dummy products add karne ka method
  void _addDummyProducts() {
    controller.add(ProductModel(
      id: 'p1',
      farmerId: 'farmer_1',
      farmerName: 'Ali Khan',
      itemName: 'Fresh Tomatoes',
      pricePerUnit: 120.0,
      unit: 'kg',
      stockQty: 5,
      imageUrl: '',
    ));
    controller.add(ProductModel(
      id: 'p2',
      farmerId: 'farmer_1',
      farmerName: 'Ali Khan',
      itemName: 'Organic Potatoes',
      pricePerUnit: 80.0,
      unit: 'kg',
      stockQty: 10,
      imageUrl: '',
    ));
    controller.add(ProductModel(
      id: 'p3',
      farmerId: 'farmer_2',
      farmerName: 'Ahmed Raza',
      itemName: 'Red Apples',
      pricePerUnit: 250.0,
      unit: 'kg',
      stockQty: 3,
      imageUrl: '',
    ));
  }
}
