import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../data/models/farmer_product_model.dart';
import '../../../../data/repositories/farmer_repository.dart';
import '../../farmer_theme.dart';

/// Manages quick stock-quantity updates for inventory screen.
class InventoryController extends GetxController {
  final FarmerRepository _repo;
  InventoryController(this._repo);

  String get currentFarmerId => FirebaseAuth.instance.currentUser?.uid ?? '';

  final RxList<FarmerProduct> products = <FarmerProduct>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Per-product editing controllers map  (productId → TextEditingController)
  final Map<String, TextEditingController> stockControllers = {};

  @override
  void onInit() {
    super.onInit();
    loadInventory();
  }

  @override
  void onClose() {
    for (final c in stockControllers.values) {
      c.dispose();
    }
    super.onClose();
  }

  Future<void> loadInventory() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final list = await _repo.getProducts(currentFarmerId);
      // Sort: out-of-stock first, then low stock, then in stock
      list.sort((a, b) {
        int rank(FarmerProduct p) {
          if (p.isOutOfStock) return 0;
          if (p.stockQty <= 5) return 1;
          return 2;
        }

        return rank(a).compareTo(rank(b));
      });
      products.assignAll(list);
      // Initialise stock text controllers
      for (final p in list) {
        stockControllers.putIfAbsent(
            p.id, () => TextEditingController(text: p.stockQty.toString()));
      }
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      errorMessage.value = msg.contains('log in')
          ? 'Please log in again.'
          : 'Failed to load inventory. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  /// Validates and persists the new stock value for a product.
  Future<void> updateStock(FarmerProduct product) async {
    final raw = stockControllers[product.id]?.text.trim() ?? '';
    final qty = int.tryParse(raw);
    if (qty == null || qty < 0) {
      Get.snackbar('Invalid', 'Enter a valid non-negative quantity.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    try {
      final updated = product.copyWith(stockQty: qty);
      await _repo.updateProduct(updated);
      final idx = products.indexWhere((p) => p.id == product.id);
      if (idx != -1) products[idx] = updated;
      Get.snackbar('Saved', '${product.name} stock updated to $qty.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: FarmerColors.primary,
          colorText: Colors.white);
    } catch (_) {
      Get.snackbar('Error', 'Could not update stock.',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  /// Quick-increment / decrement helpers
  void increment(FarmerProduct product) {
    final ctrl = stockControllers[product.id];
    if (ctrl == null) return;
    final current = int.tryParse(ctrl.text) ?? 0;
    ctrl.text = (current + 1).toString();
  }

  void decrement(FarmerProduct product) {
    final ctrl = stockControllers[product.id];
    if (ctrl == null) return;
    final current = int.tryParse(ctrl.text) ?? 0;
    if (current <= 0) return;
    ctrl.text = (current - 1).toString();
  }
}
