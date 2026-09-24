import 'package:get/get.dart';
import 'package:harvest_hub/app/core/constants/app_constants.dart';
import 'package:harvest_hub/app/core/utils/helpers.dart';
import 'package:harvest_hub/app/modules/admin/models/order_model.dart';
import 'package:harvest_hub/app/modules/admin/repositories/admin_repository.dart';
import 'package:harvest_hub/app/routes/app_routes.dart';

class OrdersController extends GetxController {
  final repo = AdminRepository();

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

  Future<void> updateStatus(OrderModel o, String status) async {
    if (status == o.status || !OrderStatus.all.contains(status)) return;
    try {
      await repo.updateOrderStatus(o.id, status);
      showSuccess('Order marked as $status');
      await load();
      selected.value = findOrNull(orders, (x) => x.id == o.id);
    } catch (e) {
      showError('Could not update status: ${errorText(e)}');
    }
  }
}
