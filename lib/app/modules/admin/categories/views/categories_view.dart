import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/widgets/search_box.dart';
import 'package:harvest_hub/app/core/widgets/state_view.dart';
import 'package:harvest_hub/app/modules/admin/categories/controllers/categories_controller.dart';
import 'package:harvest_hub/app/modules/admin/widgets/admin_drawer.dart';


class CategoriesView extends GetView<CategoriesController> {
  const CategoriesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        actions: [IconButton(onPressed: controller.load, icon: const Icon(Icons.refresh))],
      ),
      drawer: const AdminDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => controller.save(),
        child: const Icon(Icons.add),
      ),
      body: Column(children: [
        SearchBox(hint: 'Search categories', onChanged: (v) => controller.search.value = v),
        Expanded(
          child: Obx(() {
            final list = controller.filtered;
            return StateView(
              isLoading: controller.isLoading.value,
              error: controller.error.value,
              isEmpty: list.isEmpty,
              emptyText: 'No categories yet. Tap + to add one.',
              onRetry: controller.load,
              child: ListView.builder(
                itemCount: list.length,
                itemBuilder: (_, i) {
                  final c = list[i];
                  return ListTile(
                    leading: const Icon(Icons.category),
                    title: Text(c.name),
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                      IconButton(icon: const Icon(Icons.edit), onPressed: () => controller.save(c)),
                      IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => controller.delete(c)),
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
