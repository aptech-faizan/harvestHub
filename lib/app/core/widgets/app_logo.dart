import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'app_text.dart';

/// HarvestHub logo widget — 32px high, BoxFit.contain, left-aligned.
/// Falls back to the display-logo text if the asset cannot be loaded.
class AppLogo extends StatelessWidget {
  final double height;

  const AppLogo({super.key, this.height = 32});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo1.png',
      height: height,
      fit: BoxFit.contain,
      alignment: Alignment.centerLeft,
      errorBuilder: (context, error, stackTrace) {
        return AppText.displayLogo(
          'HarvestHub',
          color: AppColors.primaryDark,
        );
      },
    );
  }
}
