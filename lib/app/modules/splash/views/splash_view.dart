import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/splash_controller.dart';

// Ye app start hone par initial loading splash screen hai
class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    // Redirection trigger karne ke liye SplashController initialize karna
    Get.put(SplashController());

    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.eco, size: 72, color: Colors.green),
            SizedBox(height: 16),
            Text(
              'HarvestHub',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            SizedBox(height: 24),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
