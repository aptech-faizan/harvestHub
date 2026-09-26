import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:harvest_hub/app/core/utils/helpers.dart';
import 'package:harvest_hub/app/data/models/category_model.dart';
import 'package:harvest_hub/app/data/models/farmer_model.dart';
import 'package:harvest_hub/app/data/models/market_model.dart';
import 'package:harvest_hub/app/data/models/product_model.dart';
import 'package:harvest_hub/app/data/repositories/category_repository.dart';
import 'package:harvest_hub/app/data/repositories/farmer_repository.dart';
import 'package:harvest_hub/app/data/repositories/market_repository.dart';
import 'package:harvest_hub/app/data/repositories/product_repository.dart';
import 'package:harvest_hub/app/data/services/auth_service.dart';
import 'package:harvest_hub/app/data/services/cloudinary_service.dart';
import 'package:harvest_hub/app/modules/farmer/dashboard/controllers/farmer_dashboard_controller.dart';
import 'package:harvest_hub/app/modules/farmer/inventory/controllers/farmer_inventory_controller.dart';
import 'package:harvest_hub/app/modules/farmer/products/controllers/farmer_products_controller.dart';

class FarmerProductFormController extends GetxController {
  final AuthService authService = Get.find<AuthService>();
  final _productRepo = ProductRepository();
  final _farmerRepo = FarmerRepository();
  final _marketRepo = MarketRepository();
  final _categoryRepo = CategoryRepository();
  final _cloudinary = CloudinaryService();
  final _picker = ImagePicker();

  ProductModel? editing;

  final isLoading = false.obs;
  final isSaving = false.obs;
  final isUploading = false.obs;
  final categories = <CategoryModel>[].obs;
  final selectedCategoryId = ''.obs;
  final imageUrl = ''.obs;

  final nameC = TextEditingController();
  final descC = TextEditingController();
  final priceC = TextEditingController();
  final stockC = TextEditingController();
  final unitC = TextEditingController(text: 'kg');

  FarmerModel? farmer;
  MarketModel? market;

  String get uid => authService.currentUser?.uid ?? '';
  bool get isEdit => editing != null;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is ProductModel) editing = args;
    load();
  }

  @override
  void onClose() {
    nameC.dispose();
    descC.dispose();
    priceC.dispose();
    stockC.dispose();
    unitC.dispose();
    super.onClose();
  }

  Future<void> load() async {
    isLoading.value = true;
    try {
      farmer = await _farmerRepo.getFarmerById(uid);
      if (farmer != null && farmer!.marketId.isNotEmpty) {
        market = await _marketRepo.getMarketById(farmer!.marketId);
      }
      categories.assignAll(await _categoryRepo.getActiveCategories());
      if (editing != null) {
        nameC.text = editing!.itemName;
        descC.text = editing!.description;
        priceC.text = editing!.pricePerUnit.toString();
        stockC.text = editing!.stockQty.toString();
        unitC.text = editing!.unit.isNotEmpty ? editing!.unit : 'kg';
        imageUrl.value = editing!.imageUrl;
        selectedCategoryId.value = editing!.categoryId;
        if (selectedCategoryId.value.isEmpty) {
          final match = categories.firstWhereOrNull((c) => c.name == editing!.categoryName);
          selectedCategoryId.value = match?.id ?? '';
        }
      } else if (categories.isNotEmpty) {
        selectedCategoryId.value = categories.first.id;
      }
    } catch (e) {
      showError('Could not load form: ${errorText(e)}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickAndUpload() async {
    final file = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (file == null) return;
    isUploading.value = true;
    try {
      imageUrl.value = await _cloudinary.uploadImage(file);
      showSuccess('Image uploaded');
    } catch (e) {
      showError(errorText(e));
    } finally {
      isUploading.value = false;
    }
  }

  Future<void> save() async {
    if (farmer == null) {
      showError('Complete your farmer profile and link a market first.');
      return;
    }
    if (farmer!.marketId.isEmpty) {
      showError('Link a farmers market in your profile before adding products.');
      return;
    }

    final name = nameC.text.trim();
    final price = double.tryParse(priceC.text.trim());
    final stock = int.tryParse(stockC.text.trim());
    final unit = unitC.text.trim().isEmpty ? 'kg' : unitC.text.trim();
    final category = categories.firstWhereOrNull((c) => c.id == selectedCategoryId.value);

    if (name.isEmpty || price == null || stock == null || category == null) {
      showError('Name, price, stock and category are required.');
      return;
    }
    if (price < 0 || stock < 0) {
      showError('Price and stock cannot be negative.');
      return;
    }
    if (imageUrl.value.isEmpty) {
      showError('Upload a product image.');
      return;
    }

    isSaving.value = true;
    try {
      market ??= await _marketRepo.getMarketById(farmer!.marketId);
      final data = _productRepo.buildFarmerProductMap(
        farmer: farmer!,
        market: market,
        category: category,
        itemName: name,
        description: descC.text.trim(),
        pricePerUnit: price,
        unit: unit,
        stockQty: stock,
        imageUrl: imageUrl.value,
      );
      if (isEdit) {
        await _productRepo.updateProduct(editing!.id, data);
      } else {
        await _productRepo.addProduct(data);
      }
      if (Get.isRegistered<FarmerProductsController>()) {
        await Get.find<FarmerProductsController>().load();
      }
      if (Get.isRegistered<FarmerInventoryController>()) {
        await Get.find<FarmerInventoryController>().load();
      }
      if (Get.isRegistered<FarmerDashboardController>()) {
        await Get.find<FarmerDashboardController>().loadFarmerData();
      }
      showSuccess(isEdit ? 'Product updated' : 'Product added');
      Get.back();
    } catch (e) {
      showError('Save failed: ${errorText(e)}');
    } finally {
      isSaving.value = false;
    }
  }
}
