import 'package:get/get.dart';
import '../controllers/cart_controller.dart';

// Ye CartController ko memory mein inject karne ke liye hai
class CartBinding extends Bindings {
  @override
  void dependencies() {
    // Controller ko lazily initialize karta hai
    Get.lazyPut<CartController>(() => CartController());
  }
}
