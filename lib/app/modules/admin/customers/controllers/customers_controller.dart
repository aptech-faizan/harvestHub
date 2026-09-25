import 'package:get/get.dart';
import 'package:harvest_hub/app/core/constants/app_constants.dart';
import 'package:harvest_hub/app/core/utils/helpers.dart';
import 'package:harvest_hub/app/core/widgets/edit_dialog.dart';
import 'package:harvest_hub/app/modules/admin/models/user_model.dart';
import 'package:harvest_hub/app/modules/admin/repositories/admin_repository.dart';
import 'package:harvest_hub/app/routes/app_routes.dart';

class CustomersController extends GetxController {
  final repo = AdminRepository();

  final isLoading = false.obs;
  final error = ''.obs;
  final search = ''.obs;
  final customers = <UserModel>[].obs;
  final selected = Rxn<UserModel>();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  List<UserModel> get filtered {
    final q = search.value.trim().toLowerCase();
    if (q.isEmpty) return customers.toList();
    return customers
        .where((c) =>
            c.name.toLowerCase().contains(q) ||
            c.email.toLowerCase().contains(q) ||
            c.phone.contains(q))
        .toList();
  }

  Future<void> load() async {
    isLoading.value = true;
    error.value = '';
    try {
      customers.assignAll(await repo.getUsersByRole(Roles.customer));
    } catch (e) {
      error.value = 'Could not load customers: ${errorText(e)}';
    } finally {
      isLoading.value = false;
    }
  }

  void openDetails(UserModel c) {
    selected.value = c;
    Get.toNamed(Routes.customerDetails);
  }

  Future<void> edit(UserModel c) async {
    final r = await showEditDialog('Edit customer', [
      FieldDef('name', 'Full name', initial: c.name),
      FieldDef('phone', 'Phone', initial: c.phone),
      FieldDef('address', 'Address', initial: c.address, required: false, lines: 2),
    ]);
    if (r == null) return;
    try {
      await repo.updateUser(c.id, {'name': r['name'], 'phone': r['phone'], 'address': r['address']});
      showSuccess('Customer updated');
      await load();
      selected.value = findOrNull(customers, (x) => x.id == c.id);
    } catch (e) {
      showError('Update failed: ${errorText(e)}');
    }
  }

  Future<void> toggleActive(UserModel c) async {
    final newValue = !c.isActive;
    final ok = await confirmDialog(
        newValue ? 'Activate customer' : 'Deactivate customer',
        '${newValue ? 'Activate' : 'Deactivate'} ${c.name}?');
    if (!ok) return;
    try {
      await repo.updateUser(c.id, {'isActive': newValue});
      showSuccess(newValue ? 'Customer activated' : 'Customer deactivated');
      await load();
      selected.value = findOrNull(customers, (x) => x.id == c.id);
    } catch (e) {
      showError('Could not change status: ${errorText(e)}');
    }
  }

  // Returns true if the customer was deleted.
  Future<bool> delete(UserModel c) async {
    final ok = await confirmDialog('Delete customer',
        'Delete ${c.name}\'s profile? This cannot be undone. (Deactivating is safer.)');
    if (!ok) return false;
    try {
      await repo.deleteUser(c.id);
      customers.removeWhere((x) => x.id == c.id);
      selected.value = null;
      showSuccess('Customer deleted');
      return true;
    } catch (e) {
      showError('Delete failed: ${errorText(e)}');
      return false;
    }
  }
}
