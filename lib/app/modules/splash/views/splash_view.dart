import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/theme/app_colors.dart';
import 'package:harvest_hub/app/core/widgets/app_text.dart';
import '../controllers/splash_controller.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    // Startup logic / controller initialization unchanged
    if (!Get.isRegistered<SplashController>()) {
      Get.put(SplashController());
    }

    return Scaffold(
      backgroundColor: AppColors.surfaceWhite,
      body: Stack(
        children: [
          Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.scale(
                    scale: 0.90 + (0.10 * value),
                    child: child,
                  ),
                );
              },
              child: Image.asset(
                'assets/images/logo_stacked.png',
                width: 220,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const AppText.displayLogo(
                  'HarvestHub',
                  color: AppColors.primaryDark,
                ),
              ),
            ),
          ),
          const Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.only(bottom: 24.0),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryButton),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
