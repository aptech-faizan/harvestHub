import 'package:get/get.dart';
import '../controllers/product_details_controller.dart';

// Ye ProductDetailsController ko memory mein inject karta hai
class ProductDetailsBinding extends Bindings {
  @override
  void dependencies() {
    // Lazily load product details controller
    Get.lazyPut<ProductDetailsController>(() => ProductDetailsController());
  }
}
