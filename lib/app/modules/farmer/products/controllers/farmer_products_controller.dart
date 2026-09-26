import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/utils/helpers.dart';
import 'package:harvest_hub/app/data/models/category_model.dart';
import 'package:harvest_hub/app/data/models/farmer_model.dart';
import 'package:harvest_hub/app/data/models/product_model.dart';
import 'package:harvest_hub/app/data/repositories/category_repository.dart';
import 'package:harvest_hub/app/data/repositories/farmer_repository.dart';
import 'package:harvest_hub/app/data/repositories/product_repository.dart';
import 'package:harvest_hub/app/data/services/auth_service.dart';
import 'package:harvest_hub/app/modules/farmer/dashboard/controllers/farmer_dashboard_controller.dart';
import 'package:harvest_hub/app/routes/app_routes.dart';

class FarmerProductsController extends GetxController {
  final AuthService authService = Get.find<AuthService>();
  final _productRepo = ProductRepository();
  final _farmerRepo = FarmerRepository();
  final _categoryRepo = CategoryRepository();

  final isLoading = false.obs;
  final error = ''.obs;
  final search = ''.obs;
  final products = <ProductModel>[].obs;
  final categories = <CategoryModel>[].obs;
  final farmer = Rxn<FarmerModel>();

  String get uid => authService.currentUser?.uid ?? '';

  List<ProductModel> get filtered {
    final q = search.value.trim().toLowerCase();
    if (q.isEmpty) return products.toList();
    return products
        .where((p) =>
            p.itemName.toLowerCase().contains(q) ||
            p.categoryName.toLowerCase().contains(q))
        .toList();
  }

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    if (uid.isEmpty) return;
    isLoading.value = true;
    error.value = '';
    try {
      farmer.value = await _farmerRepo.getFarmerById(uid);
      categories.assignAll(await _categoryRepo.getActiveCategories());
      products.assignAll(await _productRepo.getProductsByFarmer(uid));
    } catch (e) {
      error.value = 'Could not load products: ${errorText(e)}';
    } finally {
      isLoading.value = false;
    }
  }

  void openForm([ProductModel? product]) {
    Get.toNamed(Routes.farmerProductForm, arguments: product);
  }

  Future<void> delete(ProductModel p) async {
    final ok = await confirmDialog('Delete product', 'Delete "${p.itemName}"?');
    if (!ok) return;
    try {
      await _productRepo.deleteProduct(p.id);
      products.removeWhere((x) => x.id == p.id);
      if (Get.isRegistered<FarmerDashboardController>()) {
        await Get.find<FarmerDashboardController>().loadFarmerData();
      }
      showSuccess('Product deleted');
    } catch (e) {
      showError('Delete failed: ${errorText(e)}');
    }
  }
}
