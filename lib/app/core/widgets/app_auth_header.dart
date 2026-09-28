import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'app_text.dart';

/// Reusable auth screen header (stacked logo + title + subtitle)
/// conforming to the HarvestHub Design System.
class AppAuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final double logoWidth;

  const AppAuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.logoWidth = 160.0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          'assets/images/logo_stacked.png',
          width: logoWidth,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => const AppText.displayLogo(
            'HarvestHub',
            color: AppColors.primaryDark,
          ),
        ),
        const SizedBox(height: 16.0),
        AppText.screenTitle(
          title,
          color: AppColors.primaryDark,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6.0),
        AppText.body(
          subtitle,
          color: AppColors.textSecondary,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
