import 'package:get/get.dart';
import 'package:harvest_hub/app/modules/admin/categories/controllers/categories_controller.dart';

class CategoriesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CategoriesController>(() => CategoriesController(), fenix: true);
  }
}
