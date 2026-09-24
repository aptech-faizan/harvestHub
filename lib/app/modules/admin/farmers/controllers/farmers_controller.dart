import 'package:get/get.dart';
import 'package:harvest_hub/app/core/utils/helpers.dart';
import 'package:harvest_hub/app/core/widgets/edit_dialog.dart';
import 'package:harvest_hub/app/modules/admin/models/farmer_model.dart';
import 'package:harvest_hub/app/modules/admin/models/product_model.dart';
import 'package:harvest_hub/app/modules/admin/repositories/admin_repository.dart';
import 'package:harvest_hub/app/routes/app_routes.dart';


class FarmersController extends GetxController {
  final repo = AdminRepository();

  final isLoading = false.obs;
  final error = ''.obs;
  final search = ''.obs;
  final farmers = <FarmerModel>[].obs;
  final marketNames = <String, String>{}.obs; // marketId -> name
  final selected = Rxn<FarmerModel>();
  final farmerProducts = <ProductModel>[].obs;
  final isLoadingProducts = false.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  List<FarmerModel> get filtered {
    final q = search.value.trim().toLowerCase();
    if (q.isEmpty) return farmers.toList();
    return farmers
        .where((f) =>
            f.businessName.toLowerCase().contains(q) ||
            f.ownerName.toLowerCase().contains(q) ||
            f.email.toLowerCase().contains(q))
        .toList();
  }

  Future<void> load() async {
    isLoading.value = true;
    error.value = '';
    try {
      farmers.assignAll(await repo.getFarmers());
      final markets = await repo.getMarkets();
      marketNames.assignAll({for (final m in markets) m.id: m.marketName});
    } catch (e) {
      error.value = 'Could not load farmers: ${errorText(e)}';
    } finally {
      isLoading.value = false;
    }
  }

  void openDetails(FarmerModel f) {
    selected.value = f;
    loadProducts(f);
    Get.toNamed(Routes.farmerDetails);
  }

  Future<void> loadProducts(FarmerModel f) async {
    isLoadingProducts.value = true;
    try {
      farmerProducts.assignAll(await repo.getProductsByFarmer(f.id));
    } catch (e) {
      farmerProducts.clear();
      showError('Could not load products: ${errorText(e)}');
    } finally {
      isLoadingProducts.value = false;
    }
  }

  Future<void> edit(FarmerModel f) async {
    final r = await showEditDialog('Edit farmer', [
      FieldDef('name', 'Owner name', initial: f.ownerName),
      FieldDef('phone', 'Phone', initial: f.phone, required: false),
      FieldDef('businessName', 'Business name', initial: f.businessName),
      FieldDef('description', 'Description', initial: f.description, required: false, lines: 3),
      FieldDef('marketId', 'Market',
          initial: f.marketId, required: false, options: Map<String, String>.of(marketNames)),
    ]);
    if (r == null) return;
    try {
      await repo.updateFarmer(
        f,
        {
          'businessName': r['businessName'],
          'description': r['description'],
          'marketId': r['marketId'],
        },
        {'name': r['name'], 'phone': r['phone']},
      );
      showSuccess('Farmer updated');
      await load();
      selected.value = findOrNull(farmers, (x) => x.id == f.id);
    } catch (e) {
      showError('Update failed: ${errorText(e)}');
    }
  }

  Future<void> toggleActive(FarmerModel f) async {
    final newValue = !f.isActive;
    final ok = await confirmDialog(
        newValue ? 'Activate farmer' : 'Deactivate farmer',
        '${newValue ? 'Activate' : 'Deactivate'} ${f.businessName}?');
    if (!ok) return;
    try {
      await repo.updateUser(f.userId, {'isActive': newValue});
      showSuccess(newValue ? 'Farmer activated' : 'Farmer deactivated');
      await load();
      selected.value = findOrNull(farmers, (x) => x.id == f.id);
    } catch (e) {
      showError('Could not change status: ${errorText(e)}');
    }
  }

  // Returns true if the farmer was deleted.
  Future<bool> delete(FarmerModel f) async {
    final ok = await confirmDialog('Delete farmer',
        'Delete ${f.businessName}, their profile and ALL their products? This cannot be undone.');
    if (!ok) return false;
    try {
      await repo.deleteFarmer(f);
      farmers.removeWhere((x) => x.id == f.id);
      selected.value = null;
      showSuccess('Farmer deleted');
      return true;
    } catch (e) {
      showError('Delete failed: ${errorText(e)}');
      return false;
    }
  }
}
