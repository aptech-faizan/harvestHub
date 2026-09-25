import 'package:get/get.dart';
import '../../home/controllers/home_controller.dart';
import '../../orders/controllers/orders_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../search/controllers/product_search_controller.dart';
import '../controllers/customer_shell_controller.dart';

// Ye customer shell aur uske mukhtalif tabs ke controllers inject karta hai
class CustomerShellBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CustomerShellController>(() => CustomerShellController());
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<ProductSearchController>(() => ProductSearchController());
    Get.lazyPut<OrdersController>(() => OrdersController());
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}
