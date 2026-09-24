import 'package:get/get.dart';
import '../controllers/product_search_controller.dart';

// Ye ProductSearchController ko memory mein inject karta hai
class SearchBinding extends Bindings {
  @override
  void dependencies() {
    // Lazily load product search controller
    Get.lazyPut<ProductSearchController>(() => ProductSearchController());
  }
}
