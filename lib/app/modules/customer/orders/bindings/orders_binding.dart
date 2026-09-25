import 'package:get/get.dart';
import '../controllers/orders_controller.dart';

// Ye OrdersController ko memory mein inject karta hai
class OrdersBinding extends Bindings {
  @override
  void dependencies() {
    // OrdersController inject karna
    Get.lazyPut<OrdersController>(() => OrdersController());
  }
}
