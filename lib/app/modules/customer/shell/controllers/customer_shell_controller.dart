import 'package:get/get.dart';
import 'package:harvest_hub/app/modules/customer/orders/controllers/orders_controller.dart';

// Ye customer main shell ke tabs aur screen navigation ko control karta hai
class CustomerShellController extends GetxController {
  // Active bottom navigation tab index
  final RxInt currentIndex = 0.obs;

  // Selected tab index update karta hai aur orders refresh karta hai
  void changeTab(int i) {
    currentIndex.value = i;
    if (i == 3 && Get.isRegistered<OrdersController>()) {
      Get.find<OrdersController>().loadOrders();
    }
  }
}
