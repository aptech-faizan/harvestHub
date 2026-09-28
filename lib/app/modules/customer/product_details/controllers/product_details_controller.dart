import 'package:get/get.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../data/models/farmer_model.dart';
import '../../../../data/models/product_model.dart';
import '../../../../data/repositories/farmer_repository.dart';
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

  // Real farmer profile, used for the rating instead of a hardcoded value.
  final Rxn<FarmerModel> farmer = Rxn<FarmerModel>();
  final RxBool isLoadingFarmer = false.obs;

  @override
  void onInit() {
    super.onInit();
    // fix: safe cast prevents crash when arguments are null or wrong type
    final args = Get.arguments;
    if (args is! ProductModel) {
      Get.back();
      return;
    }
    product = args;
    _checkWishlistStatus();
    loadFarmer();
  }

  /// Looks the farmer up so the details page can show a real rating.
  ///
  /// `products.farmerId` is written from the farmer document id, but older
  /// documents stored the auth uid instead, so both are tried before giving up.
  Future<void> loadFarmer() async {
    final id = product.farmerId;
    if (id.isEmpty) return;
    isLoadingFarmer.value = true;
    try {
      final repo = FarmerRepository();
      var found = await repo.getFarmerById(id);
      found ??= await repo.getFarmerByUserId(id);
      farmer.value = found;
    } catch (_) {
      // A missing farmer profile must not break the page; the rating row hides.
      farmer.value = null;
    } finally {
      isLoadingFarmer.value = false;
    }
  }

  /// Rating to display, or null when the farmer has no rating yet.
  double? get farmerRating {
    final r = farmer.value?.rating ?? 0.0;
    return r > 0 ? r : null;
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
      AppSnackbar.warning('Cannot select more than available stock', title: 'Stock Limit');
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
      AppSnackbar.warning('${product.itemName} is out of stock', title: 'Out of Stock');
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
    AppSnackbar.success('${qty.value} × ${product.itemName} added to cart', title: 'Item Added');
  }

  // Wishlist toggle karna aur heart icon update karna
  void toggleWishlist() {
    _wishlistController.toggle(product);
    isWishlisted.value = _wishlistController.isWishlisted(product.id);
  }
}
