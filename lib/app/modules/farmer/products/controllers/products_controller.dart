import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../data/models/farmer_product_model.dart';
import '../../../../data/repositories/farmer_account_repository.dart';

/// Controls product list, add-product form, and edit-product form.
class ProductsController extends GetxController {
  final FarmerAccountRepository _repo;

  ProductsController(this._repo);

  String get currentFarmerId => FirebaseAuth.instance.currentUser?.uid ?? '';

  // ── Reactive state ─────────────────────────────────────────────────────
  final RxList<FarmerProduct> products = <FarmerProduct>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // ── Form state ─────────────────────────────────────────────────────────
  final formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final categoryCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final stockCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final unitCtrl = TextEditingController();

  final RxString selectedCategory = 'Vegetables'.obs;
  final RxString selectedUnit = 'kg'.obs;
  final Rx<XFile?> pickedImage = Rx<XFile?>(null);
  final RxBool isSubmitting = false.obs;

  // Editing mode
  final Rx<FarmerProduct?> editingProduct = Rx<FarmerProduct?>(null);
  bool get isEditing => editingProduct.value != null;

  // ── Category / unit options ─────────────────────────────────────────────
  final List<String> categories = [
    'Vegetables',
    'Fruits',
    'Grains',
    'Poultry',
    'Honey & Dairy',
    'Herbs & Spices',
    'Other',
  ];

  final List<String> units = [
    'kg',
    'gram',
    'litre',
    'dozen',
    'piece',
    'bunch',
    'bag',
  ];

  @override
  void onInit() {
    super.onInit();
    loadProducts();
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    categoryCtrl.dispose();
    priceCtrl.dispose();
    stockCtrl.dispose();
    descCtrl.dispose();
    unitCtrl.dispose();
    super.onClose();
  }

  // ── Data loading ────────────────────────────────────────────────────────

  Future<void> loadProducts() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final list = await _repo.getProducts(currentFarmerId);
      products.assignAll(list);
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      errorMessage.value = msg.contains('log in')
          ? 'Please log in again.'
          : 'Failed to load products. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  // ── Form helpers ────────────────────────────────────────────────────────

  /// Prepares the form for adding a new product.
  void prepareForAdd() {
    editingProduct.value = null;
    _clearForm();
  }

  /// Prepares the form for editing an existing product.
  void prepareForEdit(FarmerProduct p) {
    editingProduct.value = p;
    nameCtrl.text = p.name;
    selectedCategory.value = p.category;
    priceCtrl.text = p.pricePerUnit.toStringAsFixed(2);
    stockCtrl.text = p.stockQty.toString();
    descCtrl.text = p.description;
    selectedUnit.value = p.unit;
    pickedImage.value = null;
  }

  void _clearForm() {
    nameCtrl.clear();
    priceCtrl.clear();
    stockCtrl.clear();
    descCtrl.clear();
    selectedCategory.value = categories.first;
    selectedUnit.value = units.first;
    pickedImage.value = null;
    formKey.currentState?.reset();
  }

  /// Picks an image from the device gallery.
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    pickedImage.value = file;
  }

  // ── Validation ──────────────────────────────────────────────────────────

  String? validateName(String? v) {
    if (v == null || v.trim().isEmpty) return 'Product name is required';
    if (v.trim().length < 2) return 'Name must be at least 2 characters';
    return null;
  }

  String? validatePrice(String? v) {
    if (v == null || v.trim().isEmpty) return 'Price is required';
    final price = double.tryParse(v.trim());
    if (price == null) return 'Enter a valid number';
    if (price < 0) return 'Price cannot be negative';
    return null;
  }

  String? validateStock(String? v) {
    if (v == null || v.trim().isEmpty) return 'Stock quantity is required';
    final qty = int.tryParse(v.trim());
    if (qty == null) return 'Enter a whole number';
    if (qty < 0) return 'Stock cannot be negative';
    return null;
  }

  String? validateDescription(String? v) {
    if (v == null || v.trim().isEmpty) return 'Description is required';
    return null;
  }

  // ── Save (add / update) ─────────────────────────────────────────────────

  Future<void> saveProduct() async {
    if (!formKey.currentState!.validate()) return;

    isSubmitting.value = true;
    try {
      if (isEditing) {
        final updated = editingProduct.value!.copyWith(
          name: nameCtrl.text.trim(),
          category: selectedCategory.value,
          pricePerUnit: double.parse(priceCtrl.text.trim()),
          unit: selectedUnit.value,
          stockQty: int.parse(stockCtrl.text.trim()),
          description: descCtrl.text.trim(),
        );
        final saved = await _repo.updateProduct(updated);
        final idx = products.indexWhere((p) => p.id == saved.id);
        if (idx != -1) products[idx] = saved;
        Get.back();
        Get.snackbar(
          'Success',
          'Product updated successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        final newProduct = FarmerProduct(
          id: '', // mock repo generates the id
          farmerId: currentFarmerId,
          name: nameCtrl.text.trim(),
          category: selectedCategory.value,
          pricePerUnit: double.parse(priceCtrl.text.trim()),
          unit: selectedUnit.value,
          stockQty: int.parse(stockCtrl.text.trim()),
          description: descCtrl.text.trim(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        final saved = await _repo.addProduct(newProduct);
        products.add(saved);
        Get.back();
        Get.snackbar(
          'Success',
          'Product added successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Something went wrong. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  // ── Delete ──────────────────────────────────────────────────────────────

  Future<void> deleteProduct(String productId) async {
    try {
      await _repo.deleteProduct(productId);
      products.removeWhere((p) => p.id == productId);
      Get.snackbar(
        'Deleted',
        'Product removed',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not delete product.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
