import 'package:get/get.dart';
import 'package:harvest_hub/app/core/utils/helpers.dart';
import 'package:harvest_hub/app/core/widgets/edit_dialog.dart';
import 'package:harvest_hub/app/modules/admin/models/category_model.dart';
import 'package:harvest_hub/app/modules/admin/repositories/admin_repository.dart';


class CategoriesController extends GetxController {
  final repo = AdminRepository();

  final isLoading = false.obs;
  final error = ''.obs;
  final search = ''.obs;
  final categories = <CategoryModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  List<CategoryModel> get filtered {
    final q = search.value.trim().toLowerCase();
    if (q.isEmpty) return categories.toList();
    return categories.where((c) => c.name.toLowerCase().contains(q)).toList();
  }

  Future<void> load() async {
    isLoading.value = true;
    error.value = '';
    try {
      categories.assignAll(await repo.getCategories());
    } catch (e) {
      error.value = 'Could not load categories: ${errorText(e)}';
    } finally {
      isLoading.value = false;
    }
  }

  // Add when [c] is null, edit otherwise.
  Future<void> save([CategoryModel? c]) async {
    final r = await showEditDialog(c == null ? 'Add category' : 'Edit category',
        [FieldDef('name', 'Category name', initial: c?.name ?? '')]);
    if (r == null) return;
    final name = r['name']!;
    final duplicate = categories
        .any((x) => x.id != c?.id && x.name.toLowerCase() == name.toLowerCase());
    if (duplicate) {
      showError('This category already exists');
      return;
    }
    try {
      if (c == null) {
        await repo.addCategory(name);
      } else {
        await repo.renameCategory(c.id, c.name, name);
      }
      showSuccess(c == null ? 'Category added' : 'Category updated');
      await load();
    } catch (e) {
      showError('Could not save category: ${errorText(e)}');
    }
  }

  Future<void> delete(CategoryModel c) async {
    final ok = await confirmDialog('Delete category', 'Delete "${c.name}"?');
    if (!ok) return;
    try {
      await repo.deleteCategory(c.id, c.name);
      categories.removeWhere((x) => x.id == c.id);
      showSuccess('Category deleted');
    } catch (e) {
      showError(errorText(e));
    }
  }
}
