import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/modules/auth/controllers/admin_login_controller.dart';

class AdminLoginView extends GetView<AdminLoginController> {
  const AdminLoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: controller.formKey,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.admin_panel_settings, size: 64, color: Colors.green),
                const SizedBox(height: 8),
                const Text('HarvestHub Admin',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                TextFormField(
                  controller: controller.emailC,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                      labelText: 'Email', border: OutlineInputBorder()),
                  validator: (v) {
                    final t = (v ?? '').trim();
                    if (t.isEmpty) return 'Email is required';
                    if (!GetUtils.isEmail(t)) return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Obx(() => TextFormField(
                      controller: controller.passC,
                      obscureText: controller.hidePassword.value,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(controller.hidePassword.value
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () => controller.hidePassword.toggle(),
                        ),
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Password is required' : null,
                    )),
                const SizedBox(height: 20),
                Obx(() => SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: controller.isLoading.value ? null : controller.login,
                        child: controller.isLoading.value
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2))
                            : const Text('Login'),
                      ),
                    )),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
