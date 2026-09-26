import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/utils/helpers.dart';
import 'package:harvest_hub/app/data/models/farmer_model.dart';
import 'package:harvest_hub/app/data/models/product_model.dart';
import 'package:harvest_hub/app/data/repositories/farmer_repository.dart';
import 'package:harvest_hub/app/data/repositories/product_repository.dart';
import 'package:harvest_hub/app/data/services/auth_service.dart';

class FarmerInventoryController extends GetxController {
  final AuthService authService = Get.find<AuthService>();
  final _productRepo = ProductRepository();
  final _farmerRepo = FarmerRepository();

  final isLoading = false.obs;
  final error = ''.obs;
  final products = <ProductModel>[].obs;
  final farmer = Rxn<FarmerModel>();

  String get uid => authService.currentUser?.uid ?? '';

  int get threshold => farmer.value?.lowStockThreshold ?? 5;

  List<ProductModel> get zeroStock => products.where((p) => p.stockQty <= 0).toList();
  List<ProductModel> get lowStock =>
      products.where((p) => p.stockQty > 0 && p.stockQty <= threshold).toList();

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
      products.assignAll(await _productRepo.getProductsByFarmer(uid));
    } catch (e) {
      error.value = 'Could not load inventory: ${errorText(e)}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> setStock(ProductModel p, int qty) async {
    if (qty < 0) {
      showError('Stock cannot be negative.');
      return;
    }
    try {
      await _productRepo.updateStock(p.id, qty);
      // Placeholder: skip FCM restock / low-stock alerts.
      await load();
      if (qty == 0) {
        showSuccess('${p.itemName} is now out of stock (cannot be ordered).');
      } else {
        showSuccess('Stock updated');
      }
    } catch (e) {
      showError(errorText(e));
    }
  }

  Future<void> promptStock(ProductModel p) async {
    final c = TextEditingController(text: '${p.stockQty}');
    final result = await Get.dialog<int>(AlertDialog(
      title: Text('Update stock — ${p.itemName}'),
      content: TextField(
        controller: c,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(labelText: 'Quantity', border: OutlineInputBorder()),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        TextButton(
          onPressed: () => Get.back(result: int.tryParse(c.text.trim())),
          child: const Text('Save'),
        ),
      ],
    ));
    c.dispose();
    if (result == null) return;
    await setStock(p, result);
  }
}
