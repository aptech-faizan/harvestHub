// TODO(ui): design baad mein
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/customer_auth_controller.dart';

// Ye customer register screen ki placeholder UI hai
class CustomerRegisterView extends GetView<CustomerAuthController> {
  const CustomerRegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customer Register')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Name field
            TextField(
              controller: controller.nameCtrl,
              decoration: const InputDecoration(labelText: 'Full Name'),
            ),
            const SizedBox(height: 12),
            // Email field
            TextField(
              controller: controller.emailCtrl,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            // Phone field
            TextField(
              controller: controller.phoneCtrl,
              decoration: const InputDecoration(labelText: 'Phone Number'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            // Address field
            TextField(
              controller: controller.addressCtrl,
              decoration: const InputDecoration(labelText: 'Address'),
            ),
            const SizedBox(height: 12),
            // Password field with show/hide toggle
            Obx(() => TextField(
              controller: controller.passwordCtrl,
              obscureText: controller.hidePassword.value,
              decoration: InputDecoration(
                labelText: 'Password (min 6 chars)',
                suffixIcon: IconButton(
                  icon: Icon(controller.hidePassword.value
                      ? Icons.visibility_off
                      : Icons.visibility),
                  onPressed: () => controller.togglePasswordVisibility(),
                ),
              ),
            )),
            const SizedBox(height: 24),
            // Register button (loading mein disable hota hai)
            Obx(() => SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : () => controller.register(
                          controller.nameCtrl.text,
                          controller.emailCtrl.text,
                          controller.phoneCtrl.text,
                          controller.passwordCtrl.text,
                          controller.addressCtrl.text,
                        ),
                child: controller.isLoading.value
                    ? const CircularProgressIndicator()
                    : const Text('Register'),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
