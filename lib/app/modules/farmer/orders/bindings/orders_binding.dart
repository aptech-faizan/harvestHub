import 'package:get/get.dart';

import '../../../../data/repositories/farmer_repo_factory.dart';
import '../controllers/orders_controller.dart';

class OrdersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrdersController>(
      () => OrdersController(FarmerRepoFactory.create()),
    );
  }
}
