import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../../../core/widgets/app_snackbar.dart';
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

  // fix: onInit mein loadWishlist() call kiya taake screen khulte hi wishlist load ho
  @override
  void onInit() {
    super.onInit();
    loadWishlist();
  }

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
      // silent: snackbar nahi dikhana, sirf load fail
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
          AppSnackbar.error('Could not update wishlist');
        }
      }
    } else {
      items.add(product);
      AppSnackbar.success('${product.itemName} added to wishlist', title: 'Wishlist');
      if (currentUid != null) {
        try {
          await UserRepository().addToWishlist(currentUid, product.id);
        } catch (e) {
          items.removeWhere((p) => p.id == product.id);
          AppSnackbar.error('Could not update wishlist');
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
        // silent: remove fail ho to bhi UI already updated
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
      AppSnackbar.warning('${product.itemName} is out of stock', title: 'Out of Stock');
      return;
    }

    if (Get.isRegistered<CartController>()) {
      Get.find<CartController>().add(product);
    } else {
      Get.put(CartController()).add(product);
    }
  }
}
