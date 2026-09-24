import 'package:get/get.dart';

import '../../../../data/repositories/farmer_mock_repository.dart';
import '../controllers/orders_controller.dart';

class OrdersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrdersController>(
      () => OrdersController(FarmerMockRepository()),
    );
  }
}
