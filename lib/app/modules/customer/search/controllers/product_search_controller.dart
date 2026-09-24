import 'package:get/get.dart';
import '../../../../data/models/category_model.dart';
import '../../../../data/models/market_model.dart';
import '../../../../data/models/product_model.dart';
import '../../../../data/repositories/category_repository.dart';
import '../../../../data/repositories/market_repository.dart';
import '../../../../data/repositories/product_repository.dart';
import '../../cart/controllers/cart_controller.dart';

// Ye search aur filter ki tamaam state aur logic handle karta hai
class ProductSearchController extends GetxController {
  final ProductRepository _productRepo = ProductRepository();
  final CategoryRepository _categoryRepo = CategoryRepository();
  final MarketRepository _marketRepo = MarketRepository();

  // Input filters ke reactive variables
  final RxString query = ''.obs;
  final RxString selectedCategoryId = ''.obs;
  final RxString selectedMarketId = ''.obs;
  final RxString farmerQuery = ''.obs;
  final RxBool isLoading = false.obs;

  // Sab products (filter ke liye)
  final List<ProductModel> allProducts = [];

  // Filtered results ki reactive list
  final RxList<ProductModel> results = <ProductModel>[].obs;

  // Categories aur markets dropdowns ke liye
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxList<MarketModel> markets = <MarketModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadData();

    // Text typing par 300ms debounce taake har keystroke par filter na chale
    debounce(query, (_) => applyFilters(), time: const Duration(milliseconds: 300));
    debounce(farmerQuery, (_) => applyFilters(), time: const Duration(milliseconds: 300));
  }

  // Firestore se products, categories aur markets load karne ka method
  Future<void> loadData() async {
    isLoading.value = true;
    try {
      final productList = await _productRepo.getActiveProducts();
      final categoryList = await _categoryRepo.getActiveCategories();
      final marketList = await _marketRepo.getActiveMarkets();
      allProducts.clear();
      allProducts.addAll(productList);
      categories.assignAll(categoryList);
      markets.assignAll(marketList);
      applyFilters();
    } catch (e) {
      print(e);
      Get.snackbar('Error', 'Data load nahi hua: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Sab active filters ek saath apply karne ka method
  void applyFilters() {
    // TODO: distance filter, geolocator baad mein
    final q = query.value.trim().toLowerCase();
    final fq = farmerQuery.value.trim().toLowerCase();
    final cat = selectedCategoryId.value;
    final mkt = selectedMarketId.value;

    results.value = allProducts.where((p) {
      final matchesQuery = q.isEmpty || p.itemName.toLowerCase().contains(q);
      final matchesFarmer = fq.isEmpty || p.farmerName.toLowerCase().contains(fq);
      final matchesCat = cat.isEmpty || p.categoryId == cat;
      final matchesMkt = mkt.isEmpty || p.marketId == mkt;
      return matchesQuery && matchesFarmer && matchesCat && matchesMkt;
    }).toList();
  }

  // Tamaam filters reset karne ka method
  void clearFilters() {
    query.value = '';
    farmerQuery.value = '';
    selectedCategoryId.value = '';
    selectedMarketId.value = '';
    applyFilters();
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
