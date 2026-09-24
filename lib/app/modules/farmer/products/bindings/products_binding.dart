import 'package:get/get.dart';

import '../../../../data/repositories/farmer_mock_repository.dart';
import '../controllers/products_controller.dart';

/// Binding for the products section.
/// Swap FarmerMockRepository with FarmerFirestoreRepository when ready.
class ProductsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProductsController>(
      () => ProductsController(FarmerMockRepository()),
    );
  }
}
