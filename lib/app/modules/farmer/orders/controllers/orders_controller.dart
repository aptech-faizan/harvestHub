import 'package:get/get.dart';

import '../../../../data/models/farmer_order_model.dart';
import '../../../../data/repositories/farmer_repository.dart';

/// Manages the farmer's orders list with filter and status-update logic.
class OrdersController extends GetxController {
  final FarmerRepository _repo;
  OrdersController(this._repo);

  final String currentFarmerId = 'farmer_001';

  final RxList<FarmerOrder> orders = <FarmerOrder>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<OrderStatus?> selectedFilter = Rx<OrderStatus?>(null);

  @override
  void onInit() {
    super.onInit();
    loadOrders();
  }

  Future<void> loadOrders() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final list = await _repo.getOrders(
        currentFarmerId,
        status: selectedFilter.value,
      );
      // Most recent first
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      orders.assignAll(list);
    } catch (e) {
      errorMessage.value = 'Failed to load orders. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  /// Apply a status filter (null = all orders).
  void applyFilter(OrderStatus? status) {
    selectedFilter.value = status;
    loadOrders();
  }

  /// Updates the status of an order and refreshes the list.
  Future<void> updateStatus(FarmerOrder order, OrderStatus newStatus) async {
    try {
      final updated = await _repo.updateOrderStatus(order.id, newStatus);
      final idx = orders.indexWhere((o) => o.id == order.id);
      if (idx != -1) orders[idx] = updated;
      Get.snackbar(
        'Updated',
        'Order #${order.id.substring(0, 6)} → ${newStatus.label}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not update order status.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
