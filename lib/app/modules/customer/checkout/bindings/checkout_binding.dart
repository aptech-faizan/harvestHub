import 'package:get/get.dart';
import '../controllers/checkout_controller.dart';

// Ye CheckoutController ko memory mein inject karta hai
class CheckoutBinding extends Bindings {
  @override
  void dependencies() {
    // Lazily CheckoutController inject karna
    Get.lazyPut<CheckoutController>(() => CheckoutController());
  }
}
