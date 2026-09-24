import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../farmer_theme.dart';
import '../controllers/profile_controller.dart';

/// Farmer profile screen (placeholder – wires to auth once available).
class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FarmerColors.background,
      appBar: AppBar(
        backgroundColor: FarmerColors.primary,
        title: const Text('My Profile',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ── Avatar ──────────────────────────────────────────────────
            const SizedBox(height: 8),
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: FarmerColors.secondary.withValues(alpha: 0.3),
                border: Border.all(color: FarmerColors.primary, width: 3),
              ),
              child: const Icon(Icons.person,
                  size: 56, color: FarmerColors.primary),
            ),
            const SizedBox(height: 12),
            Obx(() => Text(controller.name.value,
                style: FarmerTextStyles.heading)),
            Obx(() => Text(controller.farmName.value,
                style: FarmerTextStyles.caption
                    .copyWith(fontSize: 14, fontWeight: FontWeight.w500))),
            const SizedBox(height: 24),

            // ── Profile details card ─────────────────────────────────────
            _ProfileCard(children: [
              Obx(() => _ProfileRow(
                  Icons.email_outlined, 'Email', controller.email.value)),
              Obx(() => _ProfileRow(
                  Icons.phone_outlined, 'Phone', controller.phone.value)),
              Obx(() => _ProfileRow(Icons.location_on_outlined, 'Location',
                  controller.location.value)),
            ]),
            const SizedBox(height: 16),

            // ── Notice about auth integration ────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: FarmerColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: FarmerColors.accent.withValues(alpha: 0.4)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: FarmerColors.accent),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Profile editing will be wired to the Auth team\'s user model in the next iteration.',
                      style: TextStyle(
                          fontSize: 13, color: Color(0xFF7A5200)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow(this.icon, this.label, this.value);
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 22, color: FarmerColors.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: FarmerTextStyles.caption),
                const SizedBox(height: 2),
                Text(value, style: FarmerTextStyles.body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
