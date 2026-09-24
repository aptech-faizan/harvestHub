import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/constants/app_constants.dart';
import 'package:harvest_hub/app/core/utils/helpers.dart';
import 'package:harvest_hub/app/core/widgets/search_box.dart';
import 'package:harvest_hub/app/core/widgets/state_view.dart';
import 'package:harvest_hub/app/modules/admin/orders/controllers/orders_controller.dart';
import 'package:harvest_hub/app/modules/admin/widgets/admin_drawer.dart';

class OrdersView extends GetView<OrdersController> {
  const OrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        actions: [IconButton(onPressed: controller.load, icon: const Icon(Icons.refresh))],
      ),
      drawer: const AdminDrawer(),
      body: Column(children: [
        SearchBox(
            hint: 'Search by order ID, customer or farmer',
            onChanged: (v) => controller.search.value = v),
        SizedBox(
          height: 44,
          child: Obx(() => ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                children: [
                  for (final s in ['All', ...OrderStatus.all])
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(s),
                        selected: controller.statusFilter.value == s,
                        onSelected: (_) => controller.statusFilter.value = s,
                      ),
                    ),
                ],
              )),
        ),
        Expanded(
          child: Obx(() {
            final list = controller.filtered;
            return StateView(
              isLoading: controller.isLoading.value,
              error: controller.error.value,
              isEmpty: list.isEmpty,
              emptyText: 'No orders found',
              onRetry: controller.load,
              child: ListView.builder(
                itemCount: list.length,
                itemBuilder: (_, i) {
                  final o = list[i];
                  return ListTile(
                    title: Text('${controller.customerName(o.customerId)}  →  ${controller.farmerName(o.farmerId)}'),
                    subtitle: Text('#${o.id.length > 8 ? o.id.substring(0, 8) : o.id}  •  ${formatDate(o.createdAt)}\n${o.status}'),
                    isThreeLine: true,
                    trailing: Text(money(o.totalPrice)),
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
