import 'package:get/get.dart';
import '../../../../data/models/farmer_model.dart';
import '../../../../data/models/product_model.dart';
import '../../../../data/repositories/farmer_repository.dart';
import '../../../../data/repositories/product_repository.dart';

// Ye farmers list aur unke products load karne ki logic manage karta hai
class FarmersController extends GetxController {
  final RxList<FarmerModel> farmers = <FarmerModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadFarmers();
  }

  // Firestore se farmers load karta hai; khali ho to products se deduplicate karta hai
  Future<void> loadFarmers() async {
    isLoading.value = true;
    try {
      final list = await FarmerRepository().getFarmers();
      if (list.isNotEmpty) {
        farmers.assignAll(list);
      } else {
        // TODO: farmers collection Dev 2 bharega
        final products = await ProductRepository().getActiveProducts();
        final seen = <String>{};
        final derived = <FarmerModel>[];
        for (final p in products) {
          if (!seen.contains(p.farmerId)) {
            seen.add(p.farmerId);
            derived.add(FarmerModel(
              id: p.farmerId,
              userId: p.farmerId,
              businessName: p.farmerName,
            ));
          }
        }
        farmers.assignAll(derived);
      }
    } catch (e) {
      Get.snackbar('Error', 'Farmers load nahi ho sake: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Kisi farmer ke products farmerId ya userId se filter karta hai
  Future<List<ProductModel>> getProductsForFarmer(FarmerModel farmer) async {
    final all = await ProductRepository().getActiveProducts();
    return all
        .where((p) => p.farmerId == farmer.id || p.farmerId == farmer.userId)
        .toList();
  }
}
