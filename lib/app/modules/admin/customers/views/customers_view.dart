import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/widgets/search_box.dart';
import 'package:harvest_hub/app/core/widgets/state_view.dart';
import 'package:harvest_hub/app/modules/admin/customers/controllers/customers_controller.dart';
import 'package:harvest_hub/app/modules/admin/widgets/admin_drawer.dart';

class CustomersView extends GetView<CustomersController> {
  const CustomersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
        actions: [IconButton(onPressed: controller.load, icon: const Icon(Icons.refresh))],
      ),
      drawer: const AdminDrawer(),
      body: Column(children: [
        SearchBox(hint: 'Search by name, email or phone', onChanged: (v) => controller.search.value = v),
        Expanded(
          child: Obx(() {
            final list = controller.filtered;
            return StateView(
              isLoading: controller.isLoading.value,
              error: controller.error.value,
              isEmpty: list.isEmpty,
              emptyText: 'No customers found',
              onRetry: controller.load,
              child: ListView.builder(
                itemCount: list.length,
                itemBuilder: (_, i) {
                  final c = list[i];
                  return ListTile(
                    leading: CircleAvatar(child: Text(c.name.isEmpty ? '?' : c.name[0].toUpperCase())),
                    title: Text(c.name),
                    subtitle: Text('${c.email}\n${c.phone}'),
                    isThreeLine: true,
                    trailing: c.isActive
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : const Icon(Icons.block, color: Colors.red),
                    onTap: () => controller.openDetails(c),
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
