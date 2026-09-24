import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/widgets/search_box.dart';
import 'package:harvest_hub/app/core/widgets/state_view.dart';
import 'package:harvest_hub/app/modules/admin/farmers/controllers/farmers_controller.dart';
import 'package:harvest_hub/app/modules/admin/widgets/admin_drawer.dart';

class FarmersView extends GetView<FarmersController> {
  const FarmersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farmers'),
        actions: [IconButton(onPressed: controller.load, icon: const Icon(Icons.refresh))],
      ),
      drawer: const AdminDrawer(),
      body: Column(children: [
        SearchBox(hint: 'Search by business, owner or email', onChanged: (v) => controller.search.value = v),
        Expanded(
          child: Obx(() {
            final list = controller.filtered;
            return StateView(
              isLoading: controller.isLoading.value,
              error: controller.error.value,
              isEmpty: list.isEmpty,
              emptyText: 'No farmers found',
              onRetry: controller.load,
              child: ListView.builder(
                itemCount: list.length,
                itemBuilder: (_, i) {
                  final f = list[i];
                  return ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.agriculture)),
                    title: Text(f.businessName),
                    subtitle: Text('${f.ownerName}  •  ${controller.marketNames[f.marketId] ?? 'No market'}'),
                    trailing: f.isActive
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : const Icon(Icons.block, color: Colors.red),
                    onTap: () => controller.openDetails(f),
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
