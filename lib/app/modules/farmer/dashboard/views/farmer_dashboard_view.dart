import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/utils/helpers.dart';
import 'package:harvest_hub/app/modules/farmer/dashboard/controllers/farmer_dashboard_controller.dart';

/// Main navigation shell and overview for authenticated Farmer users.
class FarmerDashboardView extends GetView<FarmerDashboardController> {
  const FarmerDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farmer Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              if (await confirmDialog('Logout', 'Do you want to log out?')) {
                await controller.logout();
              }
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: controller.loadFarmerData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Farmer Business Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.green,
                          child: Icon(Icons.agriculture, color: Colors.white, size: 30),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                controller.businessName.value.isNotEmpty
                                    ? controller.businessName.value
                                    : 'Farmer Account',
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.star, size: 16, color: Colors.amber),
                                  const SizedBox(width: 4),
                                  Text(
                                    controller.rating.value.toStringAsFixed(1),
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text('• Verified Farmer',
                                      style: TextStyle(color: Colors.green, fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Overview',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                // Overview metrics
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.inventory_2, color: Colors.green),
                              const SizedBox(height: 8),
                              const Text('My Products', style: TextStyle(color: Colors.grey)),
                              const SizedBox(height: 4),
                              Text(
                                '${controller.productCount.value}',
                                style: const TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.receipt_long, color: Colors.orange),
                              const SizedBox(height: 8),
                              const Text('Active Orders', style: TextStyle(color: Colors.grey)),
                              const SizedBox(height: 4),
                              Text(
                                '${controller.orderCount.value}',
                                style: const TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Farmer Modules',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                // Farmer section tiles matching existing directory placeholders
                ListTile(
                  leading: const Icon(Icons.inventory_2_outlined),
                  title: const Text('Manage Products'),
                  subtitle: const Text('View and edit inventory'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => showSuccess('Products management module ready for UI'),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.receipt_long_outlined),
                  title: const Text('Orders'),
                  subtitle: const Text('Track and update order status'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => showSuccess('Orders module ready for UI'),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.schedule_outlined),
                  title: const Text('Pickup Slots'),
                  subtitle: const Text('Manage pickup time slots'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => showSuccess('Pickup slots module ready for UI'),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.bar_chart_outlined),
                  title: const Text('Reports & Analytics'),
                  subtitle: const Text('Sales summaries and performance'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => showSuccess('Reports module ready for UI'),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text('Farmer Profile'),
                  subtitle: const Text('Update farm details and contacts'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => showSuccess('Profile module ready for UI'),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
