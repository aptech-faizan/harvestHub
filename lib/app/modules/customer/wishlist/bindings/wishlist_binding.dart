import 'package:get/get.dart';
import '../controllers/wishlist_controller.dart';

// Ye WishlistController ko memory mein inject karta hai
class WishlistBinding extends Bindings {
  @override
  void dependencies() {
    // Lazily load wishlist controller
    Get.lazyPut<WishlistController>(() => WishlistController());
  }
}
