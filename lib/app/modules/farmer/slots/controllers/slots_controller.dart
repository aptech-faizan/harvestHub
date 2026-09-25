import 'dart:async';

import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../data/models/farmer_slot_model.dart';
import '../../../../data/repositories/farmer_account_repository.dart';

/// Controller for the Pickup Slots screen.
/// Drives the real-time slot list from [FarmerAccountRepository.watchSlots].
class SlotsController extends GetxController {
  final FarmerAccountRepository _repo;
  SlotsController(this._repo);

  String get currentFarmerId => FirebaseAuth.instance.currentUser?.uid ?? '';

  final RxList<PickupSlot> slots = <PickupSlot>[].obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  StreamSubscription<List<PickupSlot>>? _slotsSub;

  @override
  void onInit() {
    super.onInit();
    _slotsSub = _repo.watchSlots(currentFarmerId).listen(
      (list) {
        slots.assignAll(list);
        isLoading.value = false;
        errorMessage.value = '';
      },
      onError: (Object e) {
        final msg = e.toString().replaceFirst('Exception: ', '');
        errorMessage.value = msg.contains('log in')
            ? 'Please log in again.'
            : msg;
        isLoading.value = false;
      },
    );
  }

  @override
  void onClose() {
    _slotsSub?.cancel();
    super.onClose();
  }

  /// Creates a new slot. bookedCount is always 0 at creation (repo enforces).
  Future<void> addSlot(PickupSlot slot) async {
    try {
      await _repo.addSlot(slot);
      Get.snackbar(
        'Slot Added',
        'Pickup window saved successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primary,
        colorText: Get.theme.colorScheme.onPrimary,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Updates an existing slot.
  /// Business rules are enforced by the repository.
  Future<void> updateSlot(PickupSlot updated) async {
    try {
      await _repo.updateSlot(updated);
      Get.snackbar(
        'Slot Updated',
        'Pickup window updated.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primary,
        colorText: Get.theme.colorScheme.onPrimary,
      );
    } catch (e) {
      Get.snackbar(
        'Cannot Update',
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
    }
  }

  /// Deletes a slot after checking bookedCount.
  Future<void> deleteSlot(PickupSlot slot) async {
    try {
      await _repo.deleteSlot(slot.id, slot.bookedCount);
      Get.snackbar(
        'Deleted',
        'Pickup slot removed.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Cannot Delete',
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
    }
  }
}
