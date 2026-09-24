import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/utils/helpers.dart';
import 'package:harvest_hub/app/core/widgets/info_row.dart';
import 'package:harvest_hub/app/modules/admin/farmers/controllers/farmers_controller.dart';

class FarmerDetailsView extends GetView<FarmersController> {
  const FarmerDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Farmer details')),
      body: Obx(() {
        final f = controller.selected.value;
        if (f == null) return const Center(child: Text('Farmer not found'));
        return ListView(padding: const EdgeInsets.all(16), children: [
          InfoRow('Business', f.businessName),
          InfoRow('Owner', f.ownerName),
          InfoRow('Email', f.email),
          InfoRow('Phone', f.phone),
          InfoRow('Market', controller.marketNames[f.marketId] ?? 'No market'),
          InfoRow('Rating', f.rating.toStringAsFixed(1)),
          InfoRow('Description', f.description),
          InfoRow('Status', f.isActive ? 'Active' : 'Deactivated'),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: [
            ElevatedButton.icon(
                onPressed: () => controller.edit(f),
                icon: const Icon(Icons.edit),
                label: const Text('Edit')),
            OutlinedButton.icon(
                onPressed: () => controller.toggleActive(f),
                icon: Icon(f.isActive ? Icons.block : Icons.check_circle),
                label: Text(f.isActive ? 'Deactivate' : 'Activate')),
            OutlinedButton.icon(
              onPressed: () async {
                if (await controller.delete(f)) Get.back();
              },
              icon: const Icon(Icons.delete, color: Colors.red),
              label: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ]),
          const Divider(height: 32),
          const Text('Products', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          if (controller.isLoadingProducts.value)
            const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator()))
          else if (controller.farmerProducts.isEmpty)
            const Padding(padding: EdgeInsets.all(8), child: Text('This farmer has no products'))
          else
            for (final p in controller.farmerProducts)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(p.itemName),
                subtitle: Text('${p.category}  •  Stock: ${p.stockQty}'),
                trailing: Text(money(p.pricePerUnit)),
              ),
        ]);
      }),
    );
  }
}
