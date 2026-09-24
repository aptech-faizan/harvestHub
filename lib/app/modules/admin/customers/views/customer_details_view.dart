import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/utils/helpers.dart';
import 'package:harvest_hub/app/core/widgets/info_row.dart';
import 'package:harvest_hub/app/modules/admin/customers/controllers/customers_controller.dart';

class CustomerDetailsView extends GetView<CustomersController> {
  const CustomerDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customer details')),
      body: Obx(() {
        final u = controller.selected.value;
        if (u == null) return const Center(child: Text('Customer not found'));
        return ListView(padding: const EdgeInsets.all(16), children: [
          InfoRow('Name', u.name),
          InfoRow('Email', u.email),
          InfoRow('Phone', u.phone),
          InfoRow('Address', u.address),
          InfoRow('Status', u.isActive ? 'Active' : 'Deactivated'),
          InfoRow('Joined', formatDate(u.createdAt)),
          const SizedBox(height: 16),
          Wrap(spacing: 8, runSpacing: 8, children: [
            ElevatedButton.icon(
                onPressed: () => controller.edit(u),
                icon: const Icon(Icons.edit),
                label: const Text('Edit')),
            OutlinedButton.icon(
                onPressed: () => controller.toggleActive(u),
                icon: Icon(u.isActive ? Icons.block : Icons.check_circle),
                label: Text(u.isActive ? 'Deactivate' : 'Activate')),
            OutlinedButton.icon(
              onPressed: () async {
                if (await controller.delete(u)) Get.back();
              },
              icon: const Icon(Icons.delete, color: Colors.red),
              label: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ]),
        ]);
      }),
    );
  }
}
