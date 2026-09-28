import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/theme/app_colors.dart';
import 'package:harvest_hub/app/core/widgets/app_widgets.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../cart/views/cart_view.dart';
import '../../home/views/home_view.dart';
import '../../orders/views/orders_view.dart';
import '../../profile/views/profile_view.dart';
import '../../search/views/search_view.dart';
import '../controllers/customer_shell_controller.dart';

/// Customer shell containing the 5 main tabs with the standardized AppBottomNavBar
class CustomerShellView extends GetView<CustomerShellController> {
  const CustomerShellView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final cart = Get.isRegistered<CartController>() ? Get.find<CartController>() : null;
      final cartCount = cart?.itemCount ?? 0;

      return Scaffold(
        backgroundColor: AppColors.surfaceWhite,
        body: IndexedStack(
          index: controller.currentIndex.value,
          children: const [
            HomeView(),
            SearchView(), // Explore
            CartView(),
            OrdersView(),
            ProfileView(),
          ],
        ),
        floatingActionButton: const AppAssistantFab(),
        floatingActionButtonLocation: AppAssistantFabLocation(
          hasPinnedBottomBar: controller.currentIndex.value == 2 && cartCount > 0,
        ),
        // Standardized AppBottomNavBar matching Section 6.8 and Section 5
        bottomNavigationBar: AppBottomNavBar(
          currentIndex: controller.currentIndex.value,
          onTap: controller.changeTab,
          items: [
            const AppNavItem(
              outlineIcon: AppIcon.home,
              filledIcon: AppIcon.homeFilled,
              label: 'Home',
            ),
            const AppNavItem(
              outlineIcon: AppIcon.explore,
              filledIcon: AppIcon.exploreFilled,
              label: 'Explore',
            ),
            AppNavItem(
              outlineIcon: AppIcon.cart,
              filledIcon: AppIcon.cartFilled,
              label: 'Cart',
              badgeCount: cartCount,
            ),
            const AppNavItem(
              outlineIcon: Icons.receipt_long_outlined,
              filledIcon: Icons.receipt_long,
              label: 'Orders',
            ),
            const AppNavItem(
              outlineIcon: AppIcon.profile,
              filledIcon: AppIcon.profileFilled,
              label: 'Profile',
            ),
          ],
        ),
      );
    });
  }
}
