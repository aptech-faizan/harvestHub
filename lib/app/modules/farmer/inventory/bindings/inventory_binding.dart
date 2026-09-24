import 'package:get/get.dart';

import '../../../../data/repositories/farmer_repo_factory.dart';
import '../controllers/inventory_controller.dart';

class InventoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InventoryController>(
      () => InventoryController(FarmerRepoFactory.create()),
    );
  }
}
