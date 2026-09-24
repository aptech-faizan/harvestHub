// TODO(ui): design baad mein
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';

// Ye customer profile ki simple placeholder UI screen hai
class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: Obx(() {
        if (controller.isLoading.value && controller.user.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final email = controller.user.value?.email ?? '';

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Personal details section
              TextFormField(
                initialValue: email,
                key: ValueKey(email),
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Email (Readonly)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller.nameC,
                decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller.phoneC,
                decoration: const InputDecoration(labelText: 'Phone', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller.addressC,
                decoration: const InputDecoration(labelText: 'Address', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: controller.isLoading.value ? null : () => controller.saveProfile(),
                child: const Text('Save Profile'),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 12),
              // Change password section
              const Text('Change Password', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                controller: controller.currentPassC,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Current Password', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller.newPassC,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'New Password', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : () => controller.changePassword(controller.currentPassC.text, controller.newPassC.text),
                child: const Text('Change Password'),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 12),
              // Logout button
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700, foregroundColor: Colors.white),
                onPressed: () => controller.logout(),
                child: const Text('Logout'),
              ),
            ],
          ),
        );
      }),
    );
  }
}
