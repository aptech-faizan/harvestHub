import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/utils/helpers.dart';
import 'package:harvest_hub/app/data/models/pickup_slot_model.dart';
import 'package:harvest_hub/app/data/repositories/pickup_slot_repository.dart';
import 'package:harvest_hub/app/data/services/auth_service.dart';

class FarmerSlotsController extends GetxController {
  final AuthService authService = Get.find<AuthService>();
  final _repo = PickupSlotRepository();

  final isLoading = false.obs;
  final error = ''.obs;
  final slots = <PickupSlotModel>[].obs;

  String get uid => authService.currentUser?.uid ?? '';

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    if (uid.isEmpty) return;
    isLoading.value = true;
    error.value = '';
    try {
      slots.assignAll(await _repo.getSlotsByFarmer(uid));
    } catch (e) {
      error.value = 'Could not load slots: ${errorText(e)}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createOrEdit([PickupSlotModel? existing]) async {
    DateTime date = existing?.startTime ?? DateTime.now().add(const Duration(days: 1));
    TimeOfDay start = TimeOfDay(hour: existing?.startTime.hour ?? 9, minute: existing?.startTime.minute ?? 0);
    TimeOfDay end = TimeOfDay(hour: existing?.endTime.hour ?? 10, minute: existing?.endTime.minute ?? 0);
    final capC = TextEditingController(text: '${existing?.capacity ?? 5}');

    final saved = await Get.dialog<bool>(
      StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          title: Text(existing == null ? 'New pickup slot' : 'Edit pickup slot'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text('${date.day}/${date.month}/${date.year}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: date,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 90)),
                    );
                    if (picked != null) setState(() => date = picked);
                  },
                ),
                ListTile(
                  title: Text('Start: ${start.format(context)}'),
                  onTap: () async {
                    final picked = await showTimePicker(context: context, initialTime: start);
                    if (picked != null) setState(() => start = picked);
                  },
                ),
                ListTile(
                  title: Text('End: ${end.format(context)}'),
                  onTap: () async {
                    final picked = await showTimePicker(context: context, initialTime: end);
                    if (picked != null) setState(() => end = picked);
                  },
                ),
                TextField(
                  controller: capC,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Capacity', border: OutlineInputBorder()),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
            TextButton(onPressed: () => Get.back(result: true), child: const Text('Save')),
          ],
        );
      }),
    );

    if (saved != true) {
      capC.dispose();
      return;
    }

    final capacity = int.tryParse(capC.text.trim()) ?? 0;
    capC.dispose();
    final startDt = DateTime(date.year, date.month, date.day, start.hour, start.minute);
    final endDt = DateTime(date.year, date.month, date.day, end.hour, end.minute);
    if (!endDt.isAfter(startDt)) {
      showError('End time must be after start time.');
      return;
    }
    if (capacity < 1) {
      showError('Capacity must be at least 1.');
      return;
    }
    if (existing != null && capacity < existing.bookedCount) {
      showError('Capacity cannot be below current bookings (${existing.bookedCount}).');
      return;
    }

    try {
      final slot = PickupSlotModel(
        id: existing?.id ?? '',
        farmerId: uid,
        startTime: startDt,
        endTime: endDt,
        capacity: capacity,
        bookedCount: existing?.bookedCount ?? 0,
      );
      if (existing == null) {
        await _repo.addSlot(slot);
      } else {
        await _repo.updateSlot(slot);
      }
      showSuccess(existing == null ? 'Slot created' : 'Slot updated');
      await load();
    } catch (e) {
      showError(errorText(e));
    }
  }

  Future<void> delete(PickupSlotModel slot) async {
    final ok = await confirmDialog('Delete slot', 'Delete ${slot.label}?');
    if (!ok) return;
    try {
      await _repo.deleteSlot(slot);
      showSuccess('Slot deleted');
      await load();
    } catch (e) {
      showError(errorText(e));
    }
  }
}
