import 'package:get/get.dart';
import '../../../../data/models/product_model.dart';
import '../../cart/controllers/cart_controller.dart';

// Ye customer wishlist ki tamaam state aur actions manage karta hai
class WishlistController extends GetxController {
  // Wishlisted products ki reactive list
  // TODO: Firestore users/{uid}/wishlist/{productId} se replace karo
  final RxList<ProductModel> items = <ProductModel>[].obs;

  // Product wishlist mein maujood hai ya nahi check karta hai
  bool isWishlisted(String productId) {
    return items.any((p) => p.id == productId);
  }

  // Wishlist mein item ko add ya remove (toggle) karta hai
  void toggle(ProductModel product) {
    if (isWishlisted(product.id)) {
      remove(product.id);
    } else {
      items.add(product);
      Get.snackbar('Wishlist', '${product.itemName} wishlist mein add ho gaya');
    }
  }

  // Item ko wishlist se hatane ke liye
  void remove(String productId) {
    items.removeWhere((p) => p.id == productId);
  }

  // Product ko direct cart mein add karne ke liye
  void addToCart(ProductModel product) {
    if (product.stockQty <= 0) {
      Get.snackbar('Stock khatam', '${product.itemName} out of stock hai');
      return;
    }

    if (Get.isRegistered<CartController>()) {
      Get.find<CartController>().add(product);
    } else {
      Get.put(CartController()).add(product);
    }
  }
}
