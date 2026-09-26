import 'package:get/get.dart';
import '../../../../data/models/category_model.dart';
import '../../../../data/models/market_model.dart';
import '../../../../data/models/product_model.dart';
import '../../../../data/repositories/category_repository.dart';
import '../../../../data/repositories/market_repository.dart';
import '../../../../data/repositories/product_repository.dart';
import '../../cart/controllers/cart_controller.dart';

// NOTE: Location/Distance filter scope se exclude kiya gaya.
// GPS-based distance calculation is out-of-scope for the current release.
// Assumption/Limitation: Document in README — "Distance filter not implemented;
// location_helper.dart is retained as a stub for future use."

// Ye search aur filter ki tamaam state aur logic handle karta hai
class ProductSearchController extends GetxController {
  final ProductRepository _productRepo = ProductRepository();
  final CategoryRepository _categoryRepo = CategoryRepository();
  final MarketRepository _marketRepo = MarketRepository();

  // Filter state — sab reactive
  final RxString query = ''.obs;
  final RxString selectedCategoryId = ''.obs;
  final RxString selectedMarketId = ''.obs;

  // Farmer filter: ID se match karo (farmerName nahi, farmerId se — reliable match)
  final RxString selectedFarmerId = ''.obs;

  final RxBool isLoading = false.obs;

  // Ek baar fetch, phir sab local filtering
  final List<ProductModel> allProducts = [];
  final RxList<ProductModel> results = <ProductModel>[].obs;
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxList<MarketModel> markets = <MarketModel>[].obs;

  // Unique farmers list — products se derive karo (id -> name)
  final RxList<FarmerEntry> farmers = <FarmerEntry>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
    // Search query par 300ms debounce
    debounce(query, (_) => applyFilters(), time: const Duration(milliseconds: 300));
  }

  // Firestore se products, categories aur markets ek baar load karo
  Future<void> loadData() async {
    isLoading.value = true;
    try {
      final productList = await _productRepo.getActiveProducts();
      final categoryList = await _categoryRepo.getActiveCategories();
      final marketList = await _marketRepo.getActiveMarkets();

      allProducts
        ..clear()
        ..addAll(productList);

      categories.assignAll(categoryList);
      markets.assignAll(marketList);

      // Products se unique farmer entries derive karo
      final seen = <String>{};
      final farmerList = <FarmerEntry>[];
      for (final p in productList) {
        if (p.farmerId.isNotEmpty && seen.add(p.farmerId)) {
          farmerList.add(FarmerEntry(id: p.farmerId, name: p.farmerName));
        }
      }
      farmerList.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      farmers.assignAll(farmerList);

      applyFilters();
    } catch (e) {
      Get.snackbar('Error', 'Data load nahi hua: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Sab active filters AND logic se apply karo — pure Dart, no Firestore query
  void applyFilters() {
    final q = query.value.trim().toLowerCase();
    final cat = selectedCategoryId.value;
    final mkt = selectedMarketId.value;
    final farmer = selectedFarmerId.value;

    results.value = allProducts.where((p) {
      final matchesQuery = q.isEmpty || p.itemName.toLowerCase().contains(q);
      final matchesCat = cat.isEmpty || p.categoryId == cat;
      final matchesMkt = mkt.isEmpty || p.marketId == mkt;
      final matchesFarmer = farmer.isEmpty || p.farmerId == farmer;
      return matchesQuery && matchesCat && matchesMkt && matchesFarmer;
    }).toList();
  }

  // Kitne filters active hain — badge dikhane ke liye
  int get activeFilterCount {
    int count = 0;
    if (selectedCategoryId.value.isNotEmpty) count++;
    if (selectedMarketId.value.isNotEmpty) count++;
    if (selectedFarmerId.value.isNotEmpty) count++;
    return count;
  }

  // Tamaam filters reset karo (search bhi)
  void clearFilters() {
    query.value = '';
    selectedCategoryId.value = '';
    selectedMarketId.value = '';
    selectedFarmerId.value = '';
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

// Farmers dropdown ke liye id+name pair
class FarmerEntry {
  final String id;
  final String name;
  const FarmerEntry({required this.id, required this.name});
}
