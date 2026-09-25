import 'package:get/get.dart';
import 'package:harvest_hub/app/modules/admin/products/controllers/products_controller.dart';

class ProductsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProductsController>(() => ProductsController(), fenix: true);
  }
}
