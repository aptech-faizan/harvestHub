// simulated order, koi payment nahi
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/models/order_model.dart';
import '../../../../data/models/pickup_slot_model.dart';
import '../../../../data/repositories/order_repository.dart';
import '../../../../data/repositories/pickup_slot_repository.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../home/controllers/home_controller.dart';
import '../../search/controllers/product_search_controller.dart';
import '../../shell/controllers/customer_shell_controller.dart';

// Ye checkout process, slot selection aur order placement handle karta hai
class CheckoutController extends GetxController {
  final CartController cartController = Get.find<CartController>();
  final TextEditingController addressController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool isPlacing = false.obs;
  final RxMap<String, List<PickupSlotModel>> farmerSlots = <String, List<PickupSlotModel>>{}.obs;
  final RxMap<String, String> selectedSlotId = <String, String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadCheckoutData();
  }

  @override
  void onClose() {
    addressController.dispose();
    super.onClose();
  }

  // Grand total bill getter
  double get grandTotal => cartController.subtotal;

  // Har farmer ke slots aur user address load karta hai
  Future<void> loadCheckoutData() async {
    isLoading.value = true;
    try {
      final now = DateTime.now();
      for (final farmerId in cartController.groupedByFarmer.keys) {
        final slots = await PickupSlotRepository().getSlotsByFarmer(farmerId);
        farmerSlots[farmerId] = slots.where((s) => s.startTime.isAfter(now)).toList();
      }
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final user = await UserRepository().getUser(uid);
        if (user != null && user.address.isNotEmpty) addressController.text = user.address;
      }
    } catch (e) {
      Get.snackbar('Error', 'Data load nahi ho saka: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Farmer ke liye pickup slot select karta hai
  void selectSlot(String farmerId, PickupSlotModel slot) {
    if (slot.isFull) {
      Get.snackbar('Slot Full', 'Ye slot full hai, doosra slot select karein');
      return;
    }
    selectedSlotId[farmerId] = slot.id;
  }

  // Validations check karke orders place karta hai
  Future<void> placeOrder() async {
    if (isPlacing.value) return;
    if (cartController.items.isEmpty) {
      Get.snackbar('Cart Khali', 'Cart mein koi product nahi hai');
      return;
    }
    final address = addressController.text.trim();
    if (address.isEmpty) {
      Get.snackbar('Address Missing', 'Delivery address likhna zaroori hai');
      return;
    }
    final grouped = cartController.groupedByFarmer;
    for (final farmerId in grouped.keys) {
      if (!selectedSlotId.containsKey(farmerId) || selectedSlotId[farmerId]!.isEmpty) {
        Get.snackbar('Slot Missing', 'Har farmer ka pickup slot select karein');
        return;
      }
    }
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      Get.snackbar('Auth Error', 'Pehle login karein');
      return;
    }

    isPlacing.value = true;
    try {
      final List<OrderModel> ordersToPlace = [];
      for (final entry in grouped.entries) {
        final farmerId = entry.key;
        final cartItems = entry.value;
        final farmerName = cartItems.isNotEmpty ? cartItems.first.product.farmerName : '';
        final slotId = selectedSlotId[farmerId]!;
        final slot = (farmerSlots[farmerId] ?? []).firstWhere((s) => s.id == slotId);

        final orderItems = cartItems.map((ci) => {
          'productId': ci.product.id,
          'name': ci.product.itemName,
          'price': ci.product.pricePerUnit,
          'qty': ci.qty,
          'unit': ci.product.unit,
        }).toList();

        final farmerTotal = cartItems.fold<double>(0.0, (sum, ci) => sum + ci.total);
        ordersToPlace.add(OrderModel(
          id: '',
          customerId: uid,
          farmerId: farmerId,
          farmerName: farmerName,
          items: orderItems,
          totalPrice: farmerTotal,
          deliveryAddress: address,
          pickupSlotId: slot.id,
          pickupSlotTime: slot.label,
          status: 'pending',
          createdAt: DateTime.now(),
        ));
      }

      await OrderRepository().placeOrders(ordersToPlace);
      cartController.clear();
      if (Get.isRegistered<HomeController>()) Get.find<HomeController>().loadData();
      if (Get.isRegistered<ProductSearchController>()) Get.find<ProductSearchController>().loadData();
      Get.snackbar('Kamyabi', 'Aap ka order kamyabi se place ho gaya!');
      Get.back();
      if (Get.isRegistered<CustomerShellController>()) {
        Get.find<CustomerShellController>().changeTab(3);
      }
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      Get.snackbar('Order Fail', msg);
    } finally {
      isPlacing.value = false;
    }
  }
}
