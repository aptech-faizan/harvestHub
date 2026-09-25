// TODO(ui): design baad mein
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/modules/farmer/farmer_entry.dart';
import '../../routes/app_routes.dart';
import '../customer/auth/bindings/customer_auth_binding.dart';
import '../customer/auth/views/customer_login_view.dart';


// Ye role select screen hai jahan user Customer, Farmer ya Admin chunti hai
class RoleSelectView extends StatelessWidget {
  const RoleSelectView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HarvestHub - Role Select')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Apna role chunein:', style: TextStyle(fontSize: 20)),
              const SizedBox(height: 32),
              // Customer login par navigate karta hai
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.to(
                    () => const CustomerLoginView(),
                    binding: CustomerAuthBinding(),
                  ),
                  child: const Text('Customer'),
                ),
              ),
              const SizedBox(height: 16),
              // TODO: Dev 2 ka login
              SizedBox(
                width: double.infinity,
               child: ElevatedButton(
  onPressed: () => FarmerEntry.open(),
  child: const Text('Farmer'),
),
              ),
              const SizedBox(height: 16),
              // Admin login par navigate karta hai
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.toNamed(Routes.adminLogin),
                  child: const Text('Admin'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
