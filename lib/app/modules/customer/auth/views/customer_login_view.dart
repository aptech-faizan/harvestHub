// TODO(ui): design baad mein
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/customer_auth_controller.dart';
import 'customer_register_view.dart';

// Ye customer login screen ki placeholder UI hai
class CustomerLoginView extends GetView<CustomerAuthController> {
  const CustomerLoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customer Login')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Email field
            TextField(
              controller: controller.emailCtrl,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            // Password field with show/hide toggle
            Obx(() => TextField(
              controller: controller.passwordCtrl,
              obscureText: controller.hidePassword.value,
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: IconButton(
                  icon: Icon(controller.hidePassword.value
                      ? Icons.visibility_off
                      : Icons.visibility),
                  onPressed: () => controller.togglePasswordVisibility(),
                ),
              ),
            )),
            const SizedBox(height: 24),
            // Login button (loading mein disable hota hai)
            Obx(() => SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : () => controller.login(
                          controller.emailCtrl.text,
                          controller.passwordCtrl.text,
                        ),
                child: controller.isLoading.value
                    ? const CircularProgressIndicator()
                    : const Text('Login'),
              ),
            )),
            const SizedBox(height: 16),
            // Register page par jane ka link
            TextButton(
              onPressed: () => Get.to(() => const CustomerRegisterView()),
              child: const Text('Account nahi hai? Register karein'),
            ),
          ],
        ),
      ),
    );
  }
}
