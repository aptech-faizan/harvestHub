// TODO(ui): design baad mein
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../routes/app_routes.dart';
import '../controllers/cart_controller.dart';

// Ye cart ki simple placeholder UI screen hai
class CartView extends GetView<CartController> {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
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
                            : () => Get.toNamed(Routes.customerCheckout),
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
}
