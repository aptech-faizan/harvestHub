import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import '../../../../core/utils/location_helper.dart';
import '../../../../data/models/category_model.dart';
import '../../../../data/models/market_model.dart';
import '../../../../data/models/product_model.dart';
import '../../../../data/repositories/category_repository.dart';
import '../../../../data/repositories/market_repository.dart';
import '../../../../data/repositories/product_repository.dart';
import '../../cart/controllers/cart_controller.dart';

// Search results are shown either as a list or as a market map.
enum SearchViewMode { list, map }

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

  // List <-> Map toggle
  final viewMode = SearchViewMode.list.obs;

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

  void setViewMode(SearchViewMode mode) {
    viewMode.value = mode;
    // Map view shows distances, so grab the position once the user asks for it.
    if (mode == SearchViewMode.map) ensureUserLocation();
  }

  /// Fetches the position once and caches it, so the map and the distance
  /// filter do not each prompt for permission.
  Future<void> ensureUserLocation() async {
    if (userPos.value != null) return;
    final pos = await LocationHelper.getCurrentPosition();
    if (pos != null) userPos.value = pos;
  }

  /// Markets that have coordinates, narrowed by the active distance range.
  /// Without a range (or without a position) every located market is shown.
  List<MarketModel> get visibleMarkets {
    final located = markets.where((m) => m.hasCoordinates).toList();
    final maxKm = maxDistanceKm.value;
    final pos = userPos.value;
    if (maxKm <= 0 || pos == null) return located;
    return located
        .where((m) =>
            (LocationHelper.distanceKm(
              fromLat: pos.latitude,
              fromLng: pos.longitude,
              toLat: m.lat,
              toLng: m.lng,
            ) ??
                double.infinity) <=
            maxKm)
        .toList();
  }

  /// Distance from the customer to a market, or null when unknown.
  double? distanceToMarket(MarketModel m) {
    final pos = userPos.value;
    if (pos == null) return null;
    return LocationHelper.distanceKm(
      fromLat: pos.latitude,
      fromLng: pos.longitude,
      toLat: m.lat,
      toLng: m.lng,
    );
  }

  String distanceLabelToMarket(MarketModel m) {
    final km = distanceToMarket(m);
    return km == null ? '' : '${km.toStringAsFixed(1)} km away';
  }

  /// "View Products" from the market bottom sheet: jump back to the list,
  /// filtered to that market.
  void filterByMarket(MarketModel m) {
    selectedMarketId.value = m.id;
    viewMode.value = SearchViewMode.list;
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

  // tamaam filters reset, market filter bhi
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
