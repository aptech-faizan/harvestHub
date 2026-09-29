import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/theme/app_colors.dart';
import '../controllers/about_controller.dart';

// View displaying HarvestHub mission, story, and values
class AboutView extends GetView<AboutController> {
  const AboutView({super.key});

  // Builds the static About Us presentation UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Matches every other pushed Customer Module screen (profile, personal
      // info, change password, followed farmers) - they sit on surfaceMuted so
      // the white cards read as raised surfaces.
      backgroundColor: AppColors.surfaceMuted,
      appBar: AppBar(
        title: const Text('About Us'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  // primaryDark, not Colors.green: this is the brand mark and
                  // matches the green used by AppLogo / displayLogo.
                  const Icon(Icons.eco, size: 64, color: AppColors.primaryDark),
                  const SizedBox(height: 12),
                  const Text(
                    'HarvestHub',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Fresh from Farms, Direct to You',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Our Purpose & Objective',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'HarvestHub is designed to directly bridge the gap between local hardworking farmers and conscious consumers. Our mission is to eliminate middlemen, ensuring fair returns for producers while providing families with 100% fresh, locally grown farm produce.',
              style: TextStyle(fontSize: 14, height: 1.5, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 14),
            const Text(
              'By facilitating direct connections, schedule-based pickup slots, and transparent pricing, we strengthen local agricultural communities and foster sustainable farm-to-table access for everyone.',
              style: TextStyle(fontSize: 14, height: 1.5, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            Card(
              // White fill + hairline divider, matching AppCard's surface
              // treatment. Default elevation 0 so the border, not a shadow,
              // defines the card edge.
              color: AppColors.surfaceWhite,
              elevation: 0,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.divider),
              ),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Why HarvestHub?',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• Direct farmer-to-consumer relationship',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '• Freshness guaranteed without long storage',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '• Support local farmers and local economy',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
