import 'package:get/get.dart';
import '../../../../data/models/product_model.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../wishlist/controllers/wishlist_controller.dart';

// Ye Product Details screen ki logic aur state handle karta hai
class ProductDetailsController extends GetxController {
  // Navigation arguments se product lena
  late final ProductModel product;

  // Selected quantity (default 1)
  final RxInt qty = 1.obs;

  // Wishlist state track karne ke liye reactive bool
  final RxBool isWishlisted = false.obs;

  @override
  void onInit() {
    super.onInit();
    product = Get.arguments as ProductModel;
    _checkWishlistStatus();
  }

  // CartController ko safe tareeqe se dhoondna ya inject karna
  CartController get _cartController {
    if (Get.isRegistered<CartController>()) {
      return Get.find<CartController>();
    }
    return Get.put(CartController(), permanent: true);
  }

  // WishlistController ko safe tareeqe se dhoondna ya inject karna
  WishlistController get _wishlistController {
    if (Get.isRegistered<WishlistController>()) {
      return Get.find<WishlistController>();
    }
    return Get.put(WishlistController(), permanent: true);
  }

  // Wishlist status initial set karna
  void _checkWishlistStatus() {
    isWishlisted.value = _wishlistController.isWishlisted(product.id);
  }

  // Quantity barhana (stock limit tak)
  void increment() {
    if (qty.value < product.stockQty) {
      qty.value++;
    } else {
      Get.snackbar('Stock Limit', 'Available stock se zyada select nahi ho sakta');
    }
  }

  // Quantity ghatana (kam az kam 1 tak)
  void decrement() {
    if (qty.value > 1) {
      qty.value--;
    }
  }

  // Product ko cart mein selected quantity ke sath add karna
  void addToCart() {
    if (product.stockQty <= 0) {
      Get.snackbar('Stock khatam', '${product.itemName} out of stock hai');
      return;
    }

    final cart = _cartController;
    final index = cart.items.indexWhere((i) => i.product.id == product.id);
    if (index >= 0) {
      cart.setQty(product.id, cart.items[index].qty + qty.value);
    } else {
      cart.add(product);
      if (qty.value > 1) {
        cart.setQty(product.id, qty.value);
      }
    }
    Get.snackbar('Cart', '${qty.value} x ${product.itemName} cart mein add ho gaya');
  }

  // Wishlist toggle karna aur heart icon update karna
  void toggleWishlist() {
    _wishlistController.toggle(product);
    isWishlisted.value = _wishlistController.isWishlisted(product.id);
  }
}
