import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/widgets/search_box.dart';
import 'package:harvest_hub/app/core/widgets/state_view.dart';
import 'package:harvest_hub/app/modules/admin/markets/controllers/markets_controller.dart';
import 'package:harvest_hub/app/modules/admin/widgets/admin_drawer.dart';

class MarketsView extends GetView<MarketsController> {
  const MarketsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Markets'),
        actions: [IconButton(onPressed: controller.load, icon: const Icon(Icons.refresh))],
      ),
      drawer: const AdminDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => controller.openForm(),
        child: const Icon(Icons.add),
      ),
      body: Column(children: [
        SearchBox(hint: 'Search by name or address', onChanged: (v) => controller.search.value = v),
        Expanded(
          child: Obx(() {
            final list = controller.filtered;
            return StateView(
              isLoading: controller.isLoading.value,
              error: controller.error.value,
              isEmpty: list.isEmpty,
              emptyText: 'No markets yet. Tap + to add one.',
              onRetry: controller.load,
              child: ListView.builder(
                itemCount: list.length,
                itemBuilder: (_, i) {
                  final m = list[i];
                  return ListTile(
                    leading: Icon(
                      m.activeStatus ? Icons.store : Icons.storefront_outlined,
                      color: m.activeStatus ? null : Colors.grey,
                    ),
                    title: Text(m.marketName),
                    subtitle: Text(
                      '${m.address}\n${m.operatingHours}  •  ${m.hasCoordinates ? 'GPS: ${m.latitude.toStringAsFixed(4)}, ${m.longitude.toStringAsFixed(4)}' : 'No location set'}',
                    ),
                    isThreeLine: true,
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                      Switch(value: m.activeStatus, onChanged: (v) => controller.setActive(m, v)),
                      IconButton(icon: const Icon(Icons.edit), onPressed: () => controller.openForm(m)),
                      IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => controller.delete(m)),
                    ]),
                  );
                },
              ),
            );
          }),
        ),
      ]),
    );
  }
}
