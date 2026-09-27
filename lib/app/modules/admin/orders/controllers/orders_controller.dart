import 'package:get/get.dart';
import 'package:harvest_hub/app/core/constants/app_constants.dart';
import 'package:harvest_hub/app/core/utils/helpers.dart';
import 'package:harvest_hub/app/data/repositories/order_repository.dart';
import 'package:harvest_hub/app/modules/admin/models/order_model.dart';
import 'package:harvest_hub/app/modules/admin/repositories/admin_repository.dart';
import 'package:harvest_hub/app/routes/app_routes.dart';

class OrdersController extends GetxController {
  final repo = AdminRepository();
  // Status changes must go through OrderRepository so the state machine is
  // enforced and stock is restored on cancel. AdminRepository.updateOrderStatus
  // is a blind write and is deliberately no longer used here.
  final _orderRepo = OrderRepository();

  final isLoading = false.obs;
  final error = ''.obs;
  final search = ''.obs;
  final statusFilter = 'All'.obs;
  final orders = <OrderModel>[].obs;
  final customerNames = <String, String>{}.obs;
  final farmerNames = <String, String>{}.obs;
  final selected = Rxn<OrderModel>();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  String customerName(String id) => customerNames[id] ?? 'Unknown customer';
  String farmerName(String id) => farmerNames[id] ?? 'Unknown farmer';

  List<OrderModel> get filtered {
    final q = search.value.trim().toLowerCase();
    return orders.where((o) {
      final matchesStatus = statusFilter.value == 'All' || o.status == statusFilter.value;
      final matchesSearch = q.isEmpty ||
          o.id.toLowerCase().contains(q) ||
          customerName(o.customerId).toLowerCase().contains(q) ||
          farmerName(o.farmerId).toLowerCase().contains(q);
      return matchesStatus && matchesSearch;
    }).toList();
  }

  Future<void> load() async {
    isLoading.value = true;
    error.value = '';
    try {
      orders.assignAll(await repo.getOrders());
      customerNames.assignAll(await repo.getUserNames());
      farmerNames.assignAll(await repo.getFarmerNames());
    } catch (e) {
      error.value = 'Could not load orders: ${errorText(e)}';
    } finally {
      isLoading.value = false;
    }
  }

  void openDetails(OrderModel o) {
    selected.value = o;
    Get.toNamed(Routes.orderDetails);
  }

  /// Statuses the admin may legally move this order to. Terminal orders
  /// (completed/cancelled) return an empty list, which the view renders as a
  /// read-only badge instead of a dropdown.
  List<String> nextStatuses(OrderModel o) => OrderStatus.next(o.status);

  Future<void> updateStatus(OrderModel o, String status) async {
    if (status == o.status) return;
    if (!OrderStatus.all.contains(status)) return;
    if (!OrderStatus.canTransition(o.status, status)) {
      showError('Cannot change an order from ${o.status} to $status.');
      return;
    }
    try {
      await _orderRepo.changeOrderStatus(
        orderId: o.id,
        currentStatus: o.status,
        nextStatus: status,
      );
      showSuccess('Order marked as $status');
      await load();
      selected.value = findOrNull(orders, (x) => x.id == o.id);
    } catch (e) {
      showError('Could not update status: ${errorText(e)}');
    }
  }
}
