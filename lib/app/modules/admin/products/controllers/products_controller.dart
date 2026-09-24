import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/utils/helpers.dart';
import 'package:harvest_hub/app/core/widgets/edit_dialog.dart';
import 'package:harvest_hub/app/modules/admin/models/category_model.dart';
import 'package:harvest_hub/app/modules/admin/models/product_model.dart';
import 'package:harvest_hub/app/modules/admin/repositories/admin_repository.dart';
import 'package:harvest_hub/app/routes/app_routes.dart';

class ProductsController extends GetxController {
  final repo = AdminRepository();

  final isLoading = false.obs;
  final error = ''.obs;
  final search = ''.obs;
  final categoryFilter = 'All'.obs;
  final products = <ProductModel>[].obs;
  final categories = <CategoryModel>[].obs;
  final farmerNames = <String, String>{}.obs;
  final selected = Rxn<ProductModel>();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  String farmerName(String farmerId) => farmerNames[farmerId] ?? 'Unknown farmer';

  List<ProductModel> get filtered {
    final q = search.value.trim().toLowerCase();
    return products.where((p) {
      final matchesCategory = categoryFilter.value == 'All' || p.category == categoryFilter.value;
      final matchesSearch = q.isEmpty ||
          p.itemName.toLowerCase().contains(q) ||
          farmerName(p.farmerId).toLowerCase().contains(q);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  Future<void> load() async {
    isLoading.value = true;
    error.value = '';
    try {
      products.assignAll(await repo.getProducts());
      categories.assignAll(await repo.getCategories());
      farmerNames.assignAll(await repo.getFarmerNames());
      if (categoryFilter.value != 'All' &&
          !categories.any((c) => c.name == categoryFilter.value)) {
        categoryFilter.value = 'All';
      }
    } catch (e) {
      error.value = 'Could not load products: ${errorText(e)}';
    } finally {
      isLoading.value = false;
    }
  }

  void openDetails(ProductModel p) {
    selected.value = p;
    Get.toNamed(Routes.productDetails);
  }

  // Updates product with all customer and admin compatible keys
  Future<void> edit(ProductModel p) async {
    final categoryOptions = {for (final c in categories) c.name: c.name};
    if (p.category.isNotEmpty) categoryOptions.putIfAbsent(p.category, () => p.category);

    final r = await showEditDialog('Edit product', [
      FieldDef('itemName', 'Product name', initial: p.itemName),
      FieldDef('category', 'Category', initial: p.category, options: categoryOptions),
      FieldDef('description', 'Description', initial: p.description, required: false, lines: 3),
      FieldDef('price', 'Price per unit', initial: '${p.pricePerUnit}', numeric: true),
      FieldDef('stock', 'Stock quantity', initial: '${p.stockQty}', numeric: true),
      FieldDef('imageUrl', 'Image URL', initial: p.imageUrl, required: false),
    ]);
    if (r == null) return;

    final price = double.parse(r['price']!);
    final stock = double.parse(r['stock']!).toInt();
    if (price < 0 || stock < 0) {
      showError('Price and stock cannot be negative');
      return;
    }

    final cat = categories.firstWhereOrNull((c) => c.name == r['category']);
    final fDoc = await FirebaseFirestore.instance.collection('farmers').doc(p.farmerId).get();
    final fData = fDoc.data() ?? {};
    final fName = (fData['businessName'] ?? farmerName(p.farmerId)).toString();
    final mId = (fData['marketId'] ?? '').toString();
    String mName = '';
    double mLat = 0.0;
    double mLng = 0.0;
    if (mId.isNotEmpty) {
      final mDoc = await FirebaseFirestore.instance.collection('markets').doc(mId).get();
      final mData = mDoc.data() ?? {};
      mName = (mData['marketName'] ?? '').toString();
      mLat = readDouble(mData['lat'] ?? mData['latitude']);
      mLng = readDouble(mData['lng'] ?? mData['longitude']);
    }

    try {
      await repo.updateProduct(p.id, {
        'farmerId': p.farmerId,
        'farmerName': fName,
        'itemName': r['itemName'],
        'itemNameLower': r['itemName']!.toLowerCase(),
        'description': r['description'] ?? '',
        'categoryId': cat?.id ?? '',
        'categoryName': r['category'] ?? '',
        'category': r['category'] ?? '',
        'marketId': mId,
        'marketName': mName,
        'pricePerUnit': price,
        'unit': 'kg',
        'stockQty': stock,
        'imageUrl': r['imageUrl'] ?? '',
        'lat': mLat,
        'lng': mLng,
        'isActive': true,
      });
      showSuccess('Product updated');
      await load();
      selected.value = findOrNull(products, (x) => x.id == p.id);
    } catch (e) {
      showError('Update failed: ${errorText(e)}');
    }
  }

  // Returns true if the product was deleted.
  Future<bool> delete(ProductModel p) async {
    final ok = await confirmDialog('Delete product', 'Delete "${p.itemName}"?');
    if (!ok) return false;
    try {
      await repo.deleteProduct(p.id);
      products.removeWhere((x) => x.id == p.id);
      selected.value = null;
      showSuccess('Product deleted');
      return true;
    } catch (e) {
      showError('Delete failed: ${errorText(e)}');
      return false;
    }
  }
}
