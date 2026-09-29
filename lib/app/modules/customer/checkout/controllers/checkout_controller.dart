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
import '../../../../core/widgets/app_snackbar.dart';

// Ye checkout process, slot selection aur order placement handle karta hai
class CheckoutController extends GetxController {
  /// Returns the first farmer in [farmerIds] that has no usable pickup slot, or
  /// null when every farmer has one.
  ///
  /// A slot counts as usable only if the farmer has an actual entry selected
  /// *and* that entry still exists in [farmerSlots]. Both halves matter:
  ///
  ///  * Requiring a non-empty id alone would still let a stale selection through
  ///    after the slot list is reloaded or a slot is withdrawn - and such an id
  ///    resolves to nothing further down, producing an order with an empty
  ///    pickupSlotId.
  ///  * Requiring a slot only where [farmerSlots] is non-empty was the bug this
  ///    replaces: a farmer whose slots have not loaded, failed to load, or all
  ///    lie in the past would silently get an order with no pickup slot at all.
  ///
  /// Static and side-effect free so the rule is testable without Firebase.
  static String? farmerMissingPickupSlot({
    required Iterable<String> farmerIds,
    required Map<String, List<PickupSlotModel>> farmerSlots,
    required Map<String, String> selectedSlotId,
  }) {
    for (final farmerId in farmerIds) {
      final slotId = selectedSlotId[farmerId] ?? '';
      if (slotId.isEmpty) return farmerId;
      final isKnownSlot =
          (farmerSlots[farmerId] ?? const <PickupSlotModel>[])
              .any((s) => s.id == slotId);
      if (!isKnownSlot) return farmerId;
    }
    return null;
  }

  final CartController cartController = Get.find<CartController>();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController instructionsController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool isPlacing = false.obs;
  final RxMap<String, List<PickupSlotModel>> farmerSlots = <String, List<PickupSlotModel>>{}.obs;
  final RxMap<String, String> selectedSlotId = <String, String>{}.obs;

  final RxString customerName = ''.obs;
  // A valid Pakistani placeholder. The previous '+91 98765 43210' was an
  // Indian number and would be rejected by the shipping form's validation
  // before the user had a chance to correct it.
  final RxString customerPhone = ''.obs;
  final RxString appliedCoupon = 'FARM20'.obs;
  final RxDouble couponDiscount = 20.0.obs;
  final RxDouble deliveryFee = 40.0.obs;
  final RxString customerAddress = ''.obs;
  final RxBool orderPlaced = false.obs;

 @override
void onInit() {
  super.onInit();
  addressController.addListener(() {
    customerAddress.value = addressController.text;
  });
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
    orderPlaced.value = false;
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
    // Every farmer's part of the order needs a real pickup slot.
    //
    // This is deliberately NOT conditional on the farmer having slots
    // available. Previously the requirement was skipped whenever
    // `farmerSlots[farmerId]` came back empty, which happens when the fetch is
    // still in flight, when it failed, or when every slot has already passed
    // (loadFarmerSlots filters on startTime.isAfter(now)). The order was then
    // still created - with an empty pickupSlotId and a misleading
    // "Standard Delivery" label, on an order that is meant to be collected.
    //
    // Runs before isPlacing and before any write, so a failure here leaves the
    // cart, the database and the existing slot selections untouched.
    final grouped = cartController.groupedByFarmer;
    final farmerMissingSlot = farmerMissingPickupSlot(
      farmerIds: grouped.keys,
      farmerSlots: farmerSlots,
      selectedSlotId: selectedSlotId,
    );
    if (farmerMissingSlot != null) {
      AppSnackbar.warning(
        'This farmer currently has no upcoming pickup slots.',
        title: 'Slot Missing',
      );
      return;
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

// Flag pehle set karo taake cart clear hone par empty-state na dikhe
orderPlaced.value = true;
cartController.clear();

if (Get.isRegistered<HomeController>()) Get.find<HomeController>().loadData();
if (Get.isRegistered<ProductSearchController>()) Get.find<ProductSearchController>().loadData();

// Pehle checkout se bahar niklo, phir tab badlo, snackbar sab se aakhir mein
Get.back();
if (Get.isRegistered<CustomerShellController>()) {
  Get.find<CustomerShellController>().changeTab(3);
}
AppSnackbar.success('Your order was successfully placed!', title: 'Order Placed');
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      AppSnackbar.error(msg, title: 'Order Failed');
    } finally {
      isPlacing.value = false;
    }
  }
}
