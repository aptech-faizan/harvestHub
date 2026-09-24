import 'package:get/get.dart';

import '../../../../data/repositories/farmer_repo_factory.dart';
import '../controllers/products_controller.dart';

/// Binding for the products section.
class ProductsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProductsController>(
      () => ProductsController(FarmerRepoFactory.create()),
    );
  }
}
