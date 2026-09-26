import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/constants/app_constants.dart';
import 'package:harvest_hub/app/modules/auth/controllers/register_controller.dart';
import 'package:harvest_hub/app/routes/app_routes.dart';

/// Single unified registration screen for Customer and Farmer.
/// Admin registration is prohibited publicly.
class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Form(
              key: controller.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Join HarvestHub',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Select your account type and fill in your details',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  // Role Selection: Customer or Farmer
                  const Text(
                    'Register as:',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  const SizedBox(height: 8),
                  Obx(() => SegmentedButton<String>(
                        segments: const [
                          ButtonSegment<String>(
                            value: Roles.customer,
                            label: Text('Customer'),
                            icon: Icon(Icons.person),
                          ),
                          ButtonSegment<String>(
                            value: Roles.farmer,
                            label: Text('Farmer'),
                            icon: Icon(Icons.agriculture),
                          ),
                        ],
                        selected: {controller.selectedRole.value},
                        onSelectionChanged: (newSelection) {
                          if (newSelection.isNotEmpty) {
                            controller.setRole(newSelection.first);
                          }
                        },
                      )),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: controller.nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if ((v ?? '').trim().isEmpty) return 'Full name is required';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: controller.emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      final t = (v ?? '').trim();
                      if (t.isEmpty) return 'Email is required';
                      if (!GetUtils.isEmail(t)) return 'Enter a valid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: controller.phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      prefixIcon: Icon(Icons.phone_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if ((v ?? '').trim().isEmpty) return 'Phone number is required';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: controller.addressController,
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      prefixIcon: Icon(Icons.location_on_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if ((v ?? '').trim().isEmpty) return 'Address is required';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  // Farmer-only: link the account to a market so products,
                  // inventory and orders always have a market to resolve.
                  Obx(() {
                    if (!controller.isFarmer) return const SizedBox.shrink();
                    if (controller.isLoadingMarkets.value) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: LinearProgressIndicator(),
                      );
                    }
                    if (controller.markets.isEmpty) {
                      return const InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Market',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.store),
                        ),
                        child: Text(
                          'No active markets yet. Ask an admin to add one.',
                          style: TextStyle(color: Colors.red, fontSize: 13),
                        ),
                      );
                    }
                    final ids = controller.markets.map((m) => m.id).toList();
                    final value = ids.contains(controller.selectedMarketId.value)
                        ? controller.selectedMarketId.value
                        : null;
                    return DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: value,
                      decoration: const InputDecoration(
                        labelText: 'Market *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.store),
                      ),
                      hint: const Text('Select your market'),
                      items: controller.markets
                          .map((m) => DropdownMenuItem(
                                value: m.id,
                                child: Text(
                                  m.marketName,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ))
                          .toList(),
                      onChanged: controller.setMarket,
                      validator: (_) => controller.selectedMarketId.value.isEmpty
                          ? 'Market is required'
                          : null,
                    );
                  }),
                  const SizedBox(height: 14),
                  Obx(() => TextFormField(
                        controller: controller.passwordController,
                        obscureText: controller.hidePassword.value,
                        decoration: InputDecoration(
                          labelText: 'Password (min 6 characters)',
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(controller.hidePassword.value
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: controller.togglePasswordVisibility,
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      )),
                  const SizedBox(height: 24),
                  Obx(() => SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed:
                              controller.isLoading.value ? null : controller.register,
                          child: controller.isLoading.value
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Register', style: TextStyle(fontSize: 16)),
                        ),
                      )),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Get.toNamed(Routes.login),
                    child: const Text('Already have an account? Login'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
