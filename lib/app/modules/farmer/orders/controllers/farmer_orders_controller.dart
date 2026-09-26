import 'package:get/get.dart';
import 'package:harvest_hub/app/core/utils/helpers.dart';
import 'package:harvest_hub/app/data/models/order_model.dart';
import 'package:harvest_hub/app/data/repositories/order_repository.dart';
import 'package:harvest_hub/app/data/repositories/user_repository.dart';
import 'package:harvest_hub/app/data/services/auth_service.dart';
import 'package:harvest_hub/app/modules/farmer/dashboard/controllers/farmer_dashboard_controller.dart';
import 'package:harvest_hub/app/modules/farmer/utils/farmer_order_status.dart';
import 'package:harvest_hub/app/routes/app_routes.dart';

class FarmerOrdersController extends GetxController {
  final AuthService authService = Get.find<AuthService>();
  final _orderRepo = OrderRepository();
  final _userRepo = UserRepository();

  final isLoading = false.obs;
  final error = ''.obs;
  final statusFilter = 'All'.obs;
  final orders = <OrderModel>[].obs;
  final customerNames = <String, String>{}.obs;
  final selected = Rxn<OrderModel>();

  String get uid => authService.currentUser?.uid ?? '';

  List<OrderModel> get filtered {
    if (statusFilter.value == 'All') return orders.toList();
    return orders.where((o) => o.status == statusFilter.value).toList();
  }

  @override
  void onInit() {
    super.onInit();
    load();
  }

  String customerName(String id) => customerNames[id] ?? 'Customer';

  Future<void> load() async {
    if (uid.isEmpty) return;
    isLoading.value = true;
    error.value = '';
    try {
      orders.assignAll(await _orderRepo.getOrdersByFarmer(uid));
      final names = <String, String>{};
      for (final o in orders) {
        if (names.containsKey(o.customerId)) continue;
        final user = await _userRepo.getUser(o.customerId);
        names[o.customerId] = user?.name ?? o.customerId;
      }
      customerNames.assignAll(names);
      if (selected.value != null) {
        selected.value = findOrNull(orders, (x) => x.id == selected.value!.id);
      }
    } catch (e) {
      error.value = 'Could not load orders: ${errorText(e)}';
    } finally {
      isLoading.value = false;
    }
  }

  void openDetails(OrderModel o) {
    selected.value = o;
    Get.toNamed(Routes.farmerOrderDetails);
  }

  Future<void> updateStatus(OrderModel o, String status) async {
    final allowed = nextFarmerStatuses(o.status);
    if (!allowed.contains(status) && status != o.status) {
      showError('Invalid status change.');
      return;
    }
    try {
      await _orderRepo.updateStatus(o, status);
      showSuccess('Order marked as ${orderStatusLabel(status)}');
      await load();
      if (Get.isRegistered<FarmerDashboardController>()) {
        await Get.find<FarmerDashboardController>().loadFarmerData();
      }
    } catch (e) {
      showError(errorText(e));
    }
  }
}
