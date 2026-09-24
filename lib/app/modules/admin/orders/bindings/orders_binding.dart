import 'package:get/get.dart';
import 'package:harvest_hub/app/modules/admin/orders/controllers/orders_controller.dart';

class OrdersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrdersController>(() => OrdersController(), fenix: true);
  }
}
