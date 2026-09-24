import 'package:get/get.dart';
import '../../../../data/models/category_model.dart';
import '../../../../data/models/product_model.dart';
import '../../../../data/repositories/category_repository.dart';
import '../../../../data/repositories/product_repository.dart';
import '../../cart/controllers/cart_controller.dart';

// Ye Customer Home screen ka controller hai jo products aur categories manage karta hai
class HomeController extends GetxController {
  final ProductRepository _productRepo = ProductRepository();
  final CategoryRepository _categoryRepo = CategoryRepository();

  // Products ki reactive list
  final RxList<ProductModel> products = <ProductModel>[].obs;

  // Categories ki reactive list
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;

  // Selected category ki ID (khali string ka matlab 'All' hai)
  final RxString selectedCategoryId = ''.obs;

  // Loading state track karne ke liye
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  // Firestore repositories se active products aur categories load karne ka method
  Future<void> loadData() async {
    isLoading.value = true;
    try {
      final productList = await _productRepo.getActiveProducts();
      final categoryList = await _categoryRepo.getActiveCategories();
      products.assignAll(productList);
      categories.assignAll(categoryList);
    } catch (e) {
      print(e);
      Get.snackbar('Error', 'Data load karne mein masla hua: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Category select karne ka method
  void selectCategory(String id) {
    selectedCategoryId.value = id;
  }

  // Selected category ID ke mutabiq filtered products nikalne ka getter
  List<ProductModel> get filteredProducts {
    if (selectedCategoryId.value.isEmpty) {
      return products;
    }
    return products
        .where((p) => p.categoryId == selectedCategoryId.value)
        .toList();
  }

  // Product ko cart mein add karne ka method
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
