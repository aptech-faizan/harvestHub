import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/utils/helpers.dart';
import 'package:harvest_hub/app/core/widgets/state_view.dart';
import 'package:harvest_hub/app/modules/admin/dashboard/controllers/dashboard_controller.dart';
import 'package:harvest_hub/app/modules/admin/widgets/admin_drawer.dart';
import 'package:harvest_hub/app/routes/app_routes.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  Widget _stat(String title, int value, IconData icon, String route) {
    return SizedBox(
      width: 160,
      child: Card(
        child: InkWell(
          onTap: () => Get.toNamed(route),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(icon, color: Colors.green),
              const SizedBox(height: 8),
              Text('$value', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              Text(title),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _content() {
    final c = controller;
    return ListView(padding: const EdgeInsets.all(12), children: [
      Wrap(children: [
        _stat('Customers', c.customers.value, Icons.people, Routes.customers),
        _stat('Farmers', c.farmers.value, Icons.agriculture, Routes.farmers),
        _stat('Products', c.products.value, Icons.inventory_2, Routes.products),
        _stat('Categories', c.categories.value, Icons.category, Routes.categories),
        _stat('Markets', c.markets.value, Icons.store, Routes.markets),
        _stat('Orders', c.totalOrders.value, Icons.receipt_long, Routes.orders),
      ]),
      Card(
        child: ListTile(
          leading: const Icon(Icons.payments, color: Colors.green),
          title: const Text('Revenue (excluding cancelled orders)'),
          subtitle: Text(money(c.revenue.value),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          trailing: TextButton(
              onPressed: () => Get.toNamed(Routes.reports), child: const Text('Reports')),
        ),
      ),
      const Padding(
        padding: EdgeInsets.fromLTRB(4, 16, 4, 4),
        child: Text('Recent Orders', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      if (c.recentOrders.isEmpty) const Padding(padding: EdgeInsets.all(8), child: Text('No orders yet')),
      for (final o in c.recentOrders)
        Card(
          child: ListTile(
            title: Text(c.userNames[o.customerId] ?? 'Unknown customer'),
            subtitle: Text('${formatDate(o.createdAt)}  •  ${o.status}'),
            trailing: Text(money(o.totalPrice)),
          ),
        ),
      const Padding(
        padding: EdgeInsets.fromLTRB(4, 16, 4, 4),
        child: Text('Most Active Farmers',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      if (c.topFarmers.isEmpty) const Padding(padding: EdgeInsets.all(8), child: Text('No data yet')),
      for (final f in c.topFarmers)
        Card(
          child: ListTile(
            leading: const Icon(Icons.agriculture),
            title: Text(f.key),
            trailing: Text('${f.value} orders'),
          ),
        ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [IconButton(onPressed: controller.load, icon: const Icon(Icons.refresh))],
      ),
      drawer: const AdminDrawer(),
      body: Obx(() => StateView(
            isLoading: controller.isLoading.value,
            error: controller.error.value,
            isEmpty: false,
            onRetry: controller.load,
            child: _content(),
          )),
    );
  }
}
