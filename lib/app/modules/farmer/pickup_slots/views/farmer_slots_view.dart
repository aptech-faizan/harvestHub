import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/widgets/state_view.dart';
import 'package:harvest_hub/app/modules/farmer/pickup_slots/controllers/farmer_slots_controller.dart';

class FarmerSlotsView extends GetView<FarmerSlotsController> {
  const FarmerSlotsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pickup Slots'),
        actions: [IconButton(onPressed: controller.load, icon: const Icon(Icons.refresh))],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => controller.createOrEdit(),
        child: const Icon(Icons.add),
      ),
      body: Obx(() {
        final list = controller.slots;
        return StateView(
          isLoading: controller.isLoading.value,
          error: controller.error.value,
          isEmpty: list.isEmpty,
          emptyText: 'No pickup slots yet. Tap + to add one.',
          onRetry: controller.load,
          child: ListView.separated(
            itemCount: list.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final s = list[i];
              return ListTile(
                leading: Icon(s.isFull ? Icons.event_busy : Icons.event_available),
                title: Text(s.label),
                subtitle: Text('Booked ${s.bookedCount} / ${s.capacity}${s.isFull ? '  •  Full' : ''}'),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  IconButton(icon: const Icon(Icons.edit), onPressed: () => controller.createOrEdit(s)),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => controller.delete(s),
                  ),
                ]),
              );
            },
          ),
        );
      }),
    );
  }
}
