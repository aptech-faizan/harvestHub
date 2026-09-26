import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/modules/farmer/profile/controllers/farmer_profile_controller.dart';

class FarmerProfileView extends GetView<FarmerProfileController> {
  const FarmerProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Farmer Profile')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                initialValue: controller.email.value,
                key: ValueKey(controller.email.value),
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Email (readonly)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller.nameC,
                decoration: const InputDecoration(
                  labelText: 'Owner name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller.phoneC,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller.addressC,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller.businessC,
                decoration: const InputDecoration(
                  labelText: 'Business name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller.descriptionC,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Farm description',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Obx(() {
                final ids = controller.markets.map((m) => m.id).toList();
                final value = ids.contains(controller.selectedMarketId.value)
                    ? controller.selectedMarketId.value
                    : null;
                return InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Farmers market',
                    border: OutlineInputBorder(),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: value,
                      hint: const Text('Select market'),
                      items: controller.markets
                          .map(
                            (m) => DropdownMenuItem(
                              value: m.id,
                              child: Text('${m.marketName} — ${m.address}'),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) controller.selectedMarketId.value = v;
                      },
                    ),
                  ),
                );
              }),
              const SizedBox(height: 8),
              Obx(() => Text(
                    'Rating: ${controller.rating.value.toStringAsFixed(1)}',
                    style: const TextStyle(color: Colors.grey),
                  )),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: controller.isSaving.value ? null : controller.save,
                child: const Text('Save profile'),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 12),
              const Text('Change password', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Obx(() => TextField(
                    controller: controller.currentPassC,
                    obscureText: controller.hideCurrent.value,
                    decoration: InputDecoration(
                      labelText: 'Current password',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(controller.hideCurrent.value ? Icons.visibility : Icons.visibility_off),
                        onPressed: controller.hideCurrent.toggle,
                      ),
                    ),
                  )),
              const SizedBox(height: 12),
              Obx(() => TextField(
                    controller: controller.newPassC,
                    obscureText: controller.hideNew.value,
                    decoration: InputDecoration(
                      labelText: 'New password',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(controller.hideNew.value ? Icons.visibility : Icons.visibility_off),
                        onPressed: controller.hideNew.toggle,
                      ),
                    ),
                  )),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: controller.isSaving.value ? null : controller.changePassword,
                child: const Text('Change password'),
              ),
            ],
          ),
        );
      }),
    );
  }
}
