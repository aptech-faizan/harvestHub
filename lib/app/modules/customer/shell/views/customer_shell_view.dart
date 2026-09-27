// TODO(ui): design baad mein
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../cart/views/cart_view.dart';
import '../../home/views/home_view.dart';
import '../../orders/views/orders_view.dart';
import '../../profile/views/profile_view.dart';
import '../../search/views/search_view.dart';
import '../controllers/customer_shell_controller.dart';

// Ye customer module ka main container aur bottom navigation bar view hai
class CustomerShellView extends GetView<CustomerShellController> {
  const CustomerShellView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final cart = Get.isRegistered<CartController>() ? Get.find<CartController>() : null;
      final cartCount = cart?.itemCount ?? 0;

      return Scaffold(
        body: IndexedStack(
          index: controller.currentIndex.value,
          children: [
            const HomeView(),
            const SearchView(),
            const CartView(),
            const OrdersView(),
            const ProfileView(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: controller.currentIndex.value,
          onDestinationSelected: controller.changeTab,
          destinations: [
            const NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
            const NavigationDestination(icon: Icon(Icons.search_outlined), selectedIcon: Icon(Icons.search), label: 'Search'),
            NavigationDestination(
              icon: Badge.count(
                count: cartCount,
                isLabelVisible: cartCount > 0,
                child: const Icon(Icons.shopping_cart_outlined),
              ),
              selectedIcon: Badge.count(
                count: cartCount,
                isLabelVisible: cartCount > 0,
                child: const Icon(Icons.shopping_cart),
              ),
              label: 'Cart',
            ),
            const NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'Orders'),
            const NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      );
    });
  }
}
