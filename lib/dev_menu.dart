// TEMP: test data, baad mein delete karna
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/modules/customer/home/views/home_view.dart';
import 'app/modules/customer/home/bindings/home_binding.dart';
import 'app/modules/customer/search/views/search_view.dart';
import 'app/modules/customer/search/bindings/search_binding.dart';
import 'app/modules/customer/wishlist/views/wishlist_view.dart';
import 'app/modules/customer/wishlist/bindings/wishlist_binding.dart';
import 'app/modules/customer/cart/views/cart_view.dart';
import 'app/modules/customer/cart/bindings/cart_binding.dart';
import 'dev_seed.dart';

// Development aur testing ke liye temporary navigation menu
class DevMenu extends StatelessWidget {
  const DevMenu({super.key});

  // Test data Firestore mein daalne ka handler
  Future<void> _handleSeedData() async {
    try {
      await seedTestData();
      Get.snackbar('Done', 'Test data add ho gaya');
    } catch (e) {
      Get.snackbar('Error', 'Seed data fail: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dev Menu - HarvestHub'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ElevatedButton(
            onPressed: () => Get.to(
              () => const HomeView(),
              binding: HomeBinding(),
            ),
            child: const Text('Customer Home'),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => Get.to(
              () => const SearchView(),
              binding: SearchBinding(),
            ),
            child: const Text('Customer Search'),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => Get.to(
              () => const WishlistView(),
              binding: WishlistBinding(),
            ),
            child: const Text('Customer Wishlist'),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => Get.to(
              () => const CartView(),
              binding: CartBinding(),
            ),
            child: const Text('Customer Cart'),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
            ),
            onPressed: _handleSeedData,
            child: const Text('Seed test data'),
          ),
        ],
      ),
    );
  }
}
