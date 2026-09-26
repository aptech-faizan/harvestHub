import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/constants/app_constants.dart';
import 'package:harvest_hub/app/core/utils/helpers.dart';
import 'package:harvest_hub/app/core/widgets/state_view.dart';
import 'package:harvest_hub/app/modules/farmer/orders/controllers/farmer_orders_controller.dart';
import 'package:harvest_hub/app/modules/farmer/utils/farmer_order_status.dart';

class FarmerOrdersView extends GetView<FarmerOrdersController> {
  const FarmerOrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        actions: [IconButton(onPressed: controller.load, icon: const Icon(Icons.refresh))],
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Obx(() {
            final options = ['All', ...OrderStatus.all];
            return DropdownButton<String>(
              isExpanded: true,
              value: options.contains(controller.statusFilter.value)
                  ? controller.statusFilter.value
                  : 'All',
              items: options
                  .map((s) => DropdownMenuItem(
                        value: s,
                        child: Text(s == 'All' ? 'All statuses' : orderStatusLabel(s)),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v != null) controller.statusFilter.value = v;
              },
            );
          }),
        ),
        Expanded(
          child: Obx(() {
            final list = controller.filtered;
            return StateView(
              isLoading: controller.isLoading.value,
              error: controller.error.value,
              isEmpty: list.isEmpty,
              emptyText: 'No orders yet.',
              onRetry: controller.load,
              child: ListView.separated(
                itemCount: list.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final o = list[i];
                  return ListTile(
                    title: Text('${controller.customerName(o.customerId)}  •  ${money(o.totalPrice)}'),
                    subtitle: Text(
                      '${orderStatusLabel(o.status)}\n${formatDate(o.createdAt)}  •  ${o.pickupSlotTime}',
                    ),
                    isThreeLine: true,
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => controller.openDetails(o),
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
