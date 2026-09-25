// TODO(ui): design baad mein
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/models/farmer_model.dart';
import '../../../../routes/app_routes.dart';
import '../controllers/farmers_controller.dart';

// Ye farmers ki list dikhane ki placeholder screen hai
class FarmersView extends GetView<FarmersController> {
  const FarmersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Farmers')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.farmers.isEmpty) {
          return const Center(child: Text('Koi farmer nahi mila'));
        }
        return ListView.builder(
          itemCount: controller.farmers.length,
          itemBuilder: (context, index) {
            final farmer = controller.farmers[index];
            return _FarmerTile(farmer: farmer);
          },
        );
      }),
    );
  }
}

// Farmer list tile widget
class _FarmerTile extends StatelessWidget {
  final FarmerModel farmer;
  const _FarmerTile({required this.farmer});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.person),
      title: Text(farmer.businessName),
      subtitle: farmer.description.isNotEmpty ? Text(farmer.description) : null,
      trailing: farmer.rating > 0
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, size: 16, color: Colors.amber),
                Text(farmer.rating.toStringAsFixed(1)),
              ],
            )
          : null,
      onTap: () => Get.toNamed(
        Routes.customerFarmerDetails,
        arguments: farmer,
      ),
    );
  }
}
