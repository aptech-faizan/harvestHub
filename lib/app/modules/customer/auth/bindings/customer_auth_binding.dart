import 'package:get/get.dart';
import '../controllers/customer_auth_controller.dart';

// Ye CustomerAuthController ko memory mein inject karta hai
class CustomerAuthBinding extends Bindings {
  @override
  void dependencies() {
    // Lazily load auth controller
    Get.lazyPut<CustomerAuthController>(() => CustomerAuthController());
  }
}
