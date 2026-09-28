// simulated order, koi payment nahi
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/routes/app_routes.dart';
import '../../../../data/models/order_model.dart';
import '../../../../data/models/pickup_slot_model.dart';
import '../../../../data/repositories/order_repository.dart';
import '../../../../data/repositories/pickup_slot_repository.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../home/controllers/home_controller.dart';
import '../../search/controllers/product_search_controller.dart';
import '../../shell/controllers/customer_shell_controller.dart';
import '../../../../core/widgets/app_snackbar.dart';

// Ye checkout process, slot selection aur order placement handle karta hai
class CheckoutController extends GetxController {
  final CartController cartController = Get.find<CartController>();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController instructionsController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool isPlacing = false.obs;
  final RxMap<String, List<PickupSlotModel>> farmerSlots = <String, List<PickupSlotModel>>{}.obs;
  final RxMap<String, String> selectedSlotId = <String, String>{}.obs;

  final RxString customerName = 'Rajesh Kumar'.obs;
  final RxString customerPhone = '+91 98765 43210'.obs;
  final RxString appliedCoupon = 'FARM20'.obs;
  final RxDouble couponDiscount = 20.0.obs;
  final RxDouble deliveryFee = 40.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadCheckoutData();
  }

  @override
  void onClose() {
    addressController.dispose();
    instructionsController.dispose();
    super.onClose();
  }

  // Grand total bill getter
  double get grandTotal => cartController.subtotal;

  // Final total accounting for delivery fee and coupon discount as in specification
  double get finalTotal =>
      (grandTotal + deliveryFee.value - couponDiscount.value).clamp(0.0, double.infinity);

  void applyCoupon(String code) {
    if (code.trim().toUpperCase() == 'FARM20' || code.trim().toUpperCase() == 'HARVEST') {
      appliedCoupon.value = code.trim().toUpperCase();
      couponDiscount.value = 20.0;
      AppSnackbar.success('₹20 discount applied successfully!', title: 'Coupon Applied');
    } else {
      AppSnackbar.error('Coupon code is not valid', title: 'Invalid Coupon');
    }
  }

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
        if (user != null) {
          if (user.name.isNotEmpty) customerName.value = user.name;
          if (user.phone.isNotEmpty) customerPhone.value = user.phone;
          if (user.address.isNotEmpty) addressController.text = user.address;
        }
      }
      if (addressController.text.isEmpty) {
        addressController.text = '24 Green Avenue, Sector 4, Gujranwala';
      }
    } catch (e) {
      AppSnackbar.error('Failed to load checkout data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Farmer ke liye pickup slot select karta hai
  void selectSlot(String farmerId, PickupSlotModel slot) {
    if (slot.isFull) {
      AppSnackbar.warning('This slot is full. Please select another slot.', title: 'Slot Full');
      return;
    }
    selectedSlotId[farmerId] = slot.id;
  }

  // Validations check karke orders place karta hai
  Future<void> placeOrder() async {
    if (isPlacing.value) return;
    if (cartController.items.isEmpty) {
      AppSnackbar.warning('Your cart is empty', title: 'Empty Cart');
      return;
    }
    final address = addressController.text.trim();
    if (address.isEmpty) {
      AppSnackbar.warning('Delivery address is required', title: 'Address Missing');
      return;
    }
    final grouped = cartController.groupedByFarmer;
    for (final farmerId in grouped.keys) {
      final availableSlots = farmerSlots[farmerId] ?? [];
      // Only require slot if the farmer has slots configured
      if (availableSlots.isNotEmpty &&
          (!selectedSlotId.containsKey(farmerId) || selectedSlotId[farmerId]!.isEmpty)) {
        AppSnackbar.warning('Please select a pickup slot for each farmer', title: 'Slot Missing');
        return;
      }
    }
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      AppSnackbar.error('Please sign in to continue', title: 'Authentication Required');
      return;
    }

    isPlacing.value = true;
    try {
      final List<OrderModel> ordersToPlace = [];
      for (final entry in grouped.entries) {
        final farmerId = entry.key;
        final cartItems = entry.value;
        final farmerName = cartItems.isNotEmpty ? cartItems.first.product.farmerName : '';
        final slotId = selectedSlotId[farmerId];
        final slot = (farmerSlots[farmerId] ?? [])
            .cast<PickupSlotModel?>()
            .firstWhere((s) => s?.id == slotId, orElse: () => null);

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
          pickupSlotId: slot?.id ?? '',
          pickupSlotTime: slot?.label ?? 'Standard Delivery',
          status: 'pending',
          createdAt: DateTime.now(),
        ));
      }

      await OrderRepository().placeOrders(ordersToPlace);
      cartController.clear();
      if (Get.isRegistered<HomeController>()) Get.find<HomeController>().loadData();
      if (Get.isRegistered<ProductSearchController>()) Get.find<ProductSearchController>().loadData();

      // Gather summary values existing in checkout controller before navigating
      final firstOrder = ordersToPlace.isNotEmpty ? ordersToPlace.first : null;
      final totalItemsCount = ordersToPlace.fold<int>(
        0,
        (sum, order) => sum + order.items.fold<int>(0, (iSum, item) => iSum + ((item['qty'] as num?)?.toInt() ?? 0)),
      );
      final uniqueFarmerNames = ordersToPlace
          .map((o) => o.farmerName)
          .where((name) => name.isNotEmpty)
          .toSet()
          .join(', ');
      final pickupSlotLabel = ordersToPlace
          .map((o) => o.pickupSlotTime)
          .where((time) => time.isNotEmpty && time != 'Standard Delivery')
          .toSet()
          .join(', ');

      Get.offNamed(
        Routes.orderSuccess,
        arguments: {
          'orderId': firstOrder?.id.isNotEmpty == true ? firstOrder!.id : '',
          'totalAmount': finalTotal,
          'itemCount': totalItemsCount,
          'pickupSlot': pickupSlotLabel.isNotEmpty ? pickupSlotLabel : firstOrder?.pickupSlotTime,
          'farmerName': uniqueFarmerNames,
        },
      );
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      AppSnackbar.error(msg, title: 'Order Failed');
    } finally {
      isPlacing.value = false;
    }
  }
}
