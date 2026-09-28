import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../../../data/models/order_model.dart';
import '../../../../data/models/pickup_slot_model.dart';
import '../../../../data/repositories/order_repository.dart';
import '../../../../data/repositories/pickup_slot_repository.dart';
import '../../home/controllers/home_controller.dart';
import '../../search/controllers/product_search_controller.dart';
import '../../../../core/widgets/app_snackbar.dart';

// Ye customer orders ki list, cancellation aur slot change manage karta hai
class OrdersController extends GetxController {
  final OrderRepository _orderRepo = OrderRepository();
  final PickupSlotRepository _slotRepo = PickupSlotRepository();

  final RxList<OrderModel> orders = <OrderModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxList<PickupSlotModel> availableSlots = <PickupSlotModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadOrders();
  }

  // Customer ke tamaam orders Firestore se load karta hai
  Future<void> loadOrders() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    isLoading.value = true;
    try {
      final list = await _orderRepo.getOrdersByCustomer(uid);
      orders.assignAll(list);
    } catch (e) {
      AppSnackbar.error('Could not load orders: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Order cancel karne ke liye repository method call karta hai
  Future<void> cancelOrder(OrderModel order) async {
    try {
      await _orderRepo.cancelOrder(order);
      await loadOrders();
      if (Get.isRegistered<HomeController>()) Get.find<HomeController>().loadData();
      if (Get.isRegistered<ProductSearchController>()) Get.find<ProductSearchController>().loadData();
      AppSnackbar.success('Order cancelled successfully');
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      AppSnackbar.error(msg);
    }
  }

  // Specific order ke farmer ke future slots load karta hai (current chhod kar)
  Future<void> loadSlotsFor(OrderModel order) async {
    try {
      final now = DateTime.now();
      final slots = await _slotRepo.getSlotsByFarmer(order.farmerId);
      final filtered = slots
          .where((s) => s.startTime.isAfter(now) && s.id != order.pickupSlotId)
          .toList();
      availableSlots.assignAll(filtered);
    } catch (e) {
      AppSnackbar.error('Could not load pickup slots: $e');
    }
  }

  // Order ka pickup slot tabdeel karne ke liye repository call karta hai
  Future<void> changeSlot(OrderModel order, PickupSlotModel newSlot) async {
    try {
      await _orderRepo.changeSlot(order, newSlot);
      if (Get.isBottomSheetOpen ?? false) Get.back();
      await loadOrders();
      AppSnackbar.success('Pickup slot changed successfully');
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      AppSnackbar.error(msg);
    }
  }
}
