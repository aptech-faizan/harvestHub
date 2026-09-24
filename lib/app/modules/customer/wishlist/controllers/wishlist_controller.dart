import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../../../data/models/product_model.dart';
import '../../../../data/repositories/product_repository.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../cart/controllers/cart_controller.dart';

// Ye customer wishlist ki tamaam state aur Firestore sync manage karta hai
class WishlistController extends GetxController {
  // Current logged in user ID
  String? get uid => FirebaseAuth.instance.currentUser?.uid;

  // Wishlisted products ki reactive list
  final RxList<ProductModel> items = <ProductModel>[].obs;

  // Firestore se logged in user ki wishlist items load karta hai
  Future<void> loadWishlist() async {
    final currentUid = uid;
    if (currentUid == null) return;
    try {
      final productIds = await UserRepository().getWishlist(currentUid);
      final List<ProductModel> loaded = [];
      for (final id in productIds) {
        final product = await ProductRepository().getProductById(id);
        if (product != null && product.isActive) {
          loaded.add(product);
        }
      }
      items.assignAll(loaded);
    } catch (e) {
      print('Wishlist load error: $e');
    }
  }

  // Product wishlist mein maujood hai ya nahi check karta hai
  bool isWishlisted(String productId) {
    return items.any((p) => p.id == productId);
  }

  // Wishlist mein item ko add ya remove (toggle) karta hai
  Future<void> toggle(ProductModel product) async {
    final alreadyWishlisted = isWishlisted(product.id);
    final currentUid = uid;

    if (alreadyWishlisted) {
      items.removeWhere((p) => p.id == product.id);
      if (currentUid != null) {
        try {
          await UserRepository().removeFromWishlist(currentUid, product.id);
        } catch (e) {
          items.add(product);
          Get.snackbar('Error', 'Wishlist update nahi ho saki');
        }
      }
    } else {
      items.add(product);
      Get.snackbar('Wishlist', '${product.itemName} wishlist mein add ho gaya');
      if (currentUid != null) {
        try {
          await UserRepository().addToWishlist(currentUid, product.id);
        } catch (e) {
          items.removeWhere((p) => p.id == product.id);
          Get.snackbar('Error', 'Wishlist update nahi ho saki');
        }
      }
    }
  }

  // Item ko memory aur Firestore dono se hatane ke liye
  Future<void> remove(String productId) async {
    items.removeWhere((p) => p.id == productId);
    final currentUid = uid;
    if (currentUid != null) {
      try {
        await UserRepository().removeFromWishlist(currentUid, productId);
      } catch (e) {
        print('Wishlist remove error: $e');
      }
    }
  }

  // Logout ke waqt items list saaf karne ke liye
  void clearAll() {
    items.clear();
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
