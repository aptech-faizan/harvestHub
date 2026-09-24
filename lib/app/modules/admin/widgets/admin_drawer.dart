import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/utils/helpers.dart';
import 'package:harvest_hub/app/data/services/auth_service.dart';
import 'package:harvest_hub/app/routes/app_routes.dart';

class AdminDrawer extends StatelessWidget {
  const AdminDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      ['Dashboard', Icons.dashboard, Routes.adminDashboard],
      ['Customers', Icons.people, Routes.customers],
      ['Farmers', Icons.agriculture, Routes.farmers],
      ['Categories', Icons.category, Routes.categories],
      ['Markets', Icons.store, Routes.markets],
      ['Products', Icons.inventory_2, Routes.products],
      ['Orders', Icons.receipt_long, Routes.orders],
      ['Reports', Icons.bar_chart, Routes.reports],
    ];

    return Drawer(
      child: ListView(children: [
        const DrawerHeader(
          decoration: BoxDecoration(color: Colors.green),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Text('HarvestHub Admin',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          ),
        ),
        for (final i in items)
          ListTile(
            leading: Icon(i[1] as IconData),
            title: Text(i[0] as String),
            selected: Get.currentRoute == i[2],
            onTap: () => Get.offNamed(i[2] as String),
          ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text('Logout'),
          onTap: () async {
            if (!await confirmDialog('Logout', 'Do you want to log out?')) return;
            await Get.find<AuthService>().logout();
            Get.offAllNamed(Routes.adminLogin);
          },
        ),
      ]),
    );
  }
}
