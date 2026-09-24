import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import '../../../../data/models/category_model.dart';
import '../../../../data/models/market_model.dart';
import '../../../../data/models/product_model.dart';
import '../../../../data/repositories/category_repository.dart';
import '../../../../data/repositories/market_repository.dart';
import '../../../../data/repositories/product_repository.dart';
import '../../cart/controllers/cart_controller.dart';
import '../location_helper.dart';

// Ye search aur filter ki tamaam state aur logic handle karta hai
class ProductSearchController extends GetxController {
  final ProductRepository _productRepo = ProductRepository();
  final CategoryRepository _categoryRepo = CategoryRepository();
  final MarketRepository _marketRepo = MarketRepository();

  final RxString query = ''.obs;
  final RxString selectedCategoryId = ''.obs;
  final RxString selectedMarketId = ''.obs;
  final RxString farmerQuery = ''.obs;
  final RxBool isLoading = false.obs;

  // Distance filter ke reactive variables
  final RxDouble maxDistanceKm = 0.0.obs;
  final Rxn<Position> userPos = Rxn<Position>();

  final List<ProductModel> allProducts = [];
  final RxList<ProductModel> results = <ProductModel>[].obs;
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxList<MarketModel> markets = <MarketModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
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
      Get.snackbar('Error', 'Data load nahi hua: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Distance filter set karta hai; km > 0 hone par location fetch karta hai
  Future<void> selectDistance(double km) async {
    if (km > 0) {
      final pos = await LocationHelper.getCurrentPosition();
      if (pos == null) {
        Get.snackbar('Location Error', 'Location nahi mil saki, distance filter reset ho gaya');
        maxDistanceKm.value = 0;
        applyFilters();
        return;
      }
      userPos.value = pos;
    }
    maxDistanceKm.value = km;
    applyFilters();
  }

  // Sab active filters ek saath apply karne ka method
  void applyFilters() {
    final q = query.value.trim().toLowerCase();
    final fq = farmerQuery.value.trim().toLowerCase();
    final cat = selectedCategoryId.value;
    final mkt = selectedMarketId.value;
    final maxDist = maxDistanceKm.value;
    final pos = userPos.value;

    results.value = allProducts.where((p) {
      final matchesQuery = q.isEmpty || p.itemName.toLowerCase().contains(q);
      final matchesFarmer = fq.isEmpty || p.farmerName.toLowerCase().contains(fq);
      final matchesCat = cat.isEmpty || p.categoryId == cat;
      final matchesMkt = mkt.isEmpty || p.marketId == mkt;

      // Distance filter: lat/lng dono 0 wale products skip karo
      bool matchesDist = true;
      if (maxDist > 0 && pos != null) {
        if (p.lat == 0.0 && p.lng == 0.0) {
          matchesDist = false;
        } else {
          final distM = Geolocator.distanceBetween(pos.latitude, pos.longitude, p.lat, p.lng);
          matchesDist = (distM / 1000) <= maxDist;
        }
      }

      return matchesQuery && matchesFarmer && matchesCat && matchesMkt && matchesDist;
    }).toList();
  }

  // Product se user ki distance km mein string format mein deta hai
  String distanceKmOf(ProductModel p) {
    final pos = userPos.value;
    if (pos == null || (p.lat == 0.0 && p.lng == 0.0)) return '';
    final distM = Geolocator.distanceBetween(pos.latitude, pos.longitude, p.lat, p.lng);
    return '${(distM / 1000).toStringAsFixed(1)} km';
  }

  // Tamaam filters (distance samait) reset karne ka method
  void clearFilters() {
    query.value = '';
    farmerQuery.value = '';
    selectedCategoryId.value = '';
    selectedMarketId.value = '';
    maxDistanceKm.value = 0;
    userPos.value = null;
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
