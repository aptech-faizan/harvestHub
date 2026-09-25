import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:firebase_auth/firebase_auth.dart';

import '../../../../data/models/farmer_order_model.dart';
import '../../farmer_theme.dart';
import '../../farmer_entry.dart';
import '../../widgets/farmer_widgets.dart';
import '../controllers/profile_controller.dart';
import '../../orders/controllers/orders_controller.dart';
import '../../products/controllers/products_controller.dart';
import '../../slots/views/slots_view.dart';
import '../../slots/bindings/slots_binding.dart';
import '../../inventory/views/inventory_view.dart';
import '../../inventory/bindings/inventory_binding.dart';

/// Modern Farmer Profile view displaying authentic account data,
/// real order/product metrics, and organized operational tiles.
class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FarmerColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Farmer Profile',
          style: TextStyle(
            color: FarmerColors.text,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: FarmerColors.border, height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        child: Column(
          children: [
            // ── 1. Avatar & Farm Identity Header ────────────────────────
            StaggeredFadeSlide(
              index: 0,
              child: _FarmerProfileHeader(controller: controller),
            ),
            const SizedBox(height: 18),

            // ── 2. Real Metrics Row (Total Orders, Completed, Products) ─
            const StaggeredFadeSlide(
              index: 1,
              child: _RealFarmerStatsRow(),
            ),
            const SizedBox(height: 20),

            // ── 3. Farm Operations Group ────────────────────────────────
            StaggeredFadeSlide(
              index: 2,
              child: _SettingsGroup(
                title: 'Farm Operations',
                tiles: [
                  _SettingsTile(
                    icon: Icons.storefront_outlined,
                    title: 'Pickup Windows & Slots',
                    subtitle: 'Schedule customer farm collection hours',
                    showChevron: true,
                    onTap: () {
                      Get.to(
                        () => const SlotsView(),
                        binding: SlotsBinding(),
                        transition: Transition.rightToLeft,
                      );
                    },
                  ),
                  _SettingsTile(
                    icon: Icons.inventory_2_outlined,
                    title: 'Inventory & Stock Alerts',
                    subtitle: 'Daily batch counters and stock warnings',
                    showChevron: true,
                    onTap: () {
                      Get.to(
                        () => const InventoryView(),
                        binding: InventoryBinding(),
                        transition: Transition.rightToLeft,
                      );
                    },
                  ),
                  _SettingsTile(
                    icon: Icons.location_on_outlined,
                    title: 'Farm Location',
                    subtitle: controller.location.value,
                    showChevron: false,
                    onTap: null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── 4. Contact & Account Details Group ──────────────────────
            StaggeredFadeSlide(
              index: 3,
              child: _SettingsGroup(
                title: 'Contact Details',
                tiles: [
                  _SettingsTile(
                    icon: Icons.email_outlined,
                    title: 'Email Address',
                    subtitle: controller.email.value,
                    showChevron: false,
                    onTap: null,
                  ),
                  _SettingsTile(
                    icon: Icons.phone_outlined,
                    title: 'Phone Number',
                    subtitle: controller.phone.value,
                    showChevron: false,
                    onTap: null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── 5. App Information Group ────────────────────────────────
            StaggeredFadeSlide(
              index: 4,
              child: _SettingsGroup(
                title: 'About App',
                tiles: const [
                  _SettingsTile(
                    icon: Icons.info_outline_rounded,
                    title: 'App Version',
                    subtitle: 'v1.0.0',
                    showChevron: false,
                    onTap: null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── 6. Log Out Button ───────────────────────────────────────
            StaggeredFadeSlide(
              index: 5,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  // Reset back to farmer module entry.
                  // (When SplashView is committed by the team, navigate to SplashView)
                  FarmerEntry.open();
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  side: BorderSide(
                      color: FarmerColors.error.withValues(alpha: 0.4)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  backgroundColor: Colors.white,
                ),
                icon: const Icon(Icons.logout_rounded,
                    color: FarmerColors.error, size: 20),
                label: const Text(
                  'Log Out',
                  style: TextStyle(
                    color: FarmerColors.error,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Profile Header ────────────────────────────────────────────────────────────

class _FarmerProfileHeader extends StatelessWidget {
  final ProfileController controller;
  const _FarmerProfileHeader({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 86,
            height: 86,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: FarmerColors.heroGradient,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: FarmerColors.primaryGlow,
            ),
            child: const Center(
              child: Icon(Icons.person_rounded, size: 50, color: Colors.white),
            ),
          ),
          const SizedBox(height: 14),

          // Name
          Obx(() => Text(
                controller.name.value,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: FarmerColors.text,
                ),
              )),
          const SizedBox(height: 3),

          // Farm Name
          Obx(() => Text(
                controller.farmName.value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: FarmerColors.muted,
                ),
              )),
        ],
      ),
    );
  }
}

// ── Real Metrics Row ──────────────────────────────────────────────────────────

class _RealFarmerStatsRow extends StatelessWidget {
  const _RealFarmerStatsRow();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      child: Obx(() {
        int totalOrders = 0;
        int completedOrders = 0;
        int totalProducts = 0;

        if (Get.isRegistered<OrdersController>()) {
          final ordersCtrl = Get.find<OrdersController>();
          totalOrders = ordersCtrl.orders.length;
          completedOrders = ordersCtrl.orders
              .where((o) => o.status == OrderStatus.completed)
              .length;
        }

        if (Get.isRegistered<ProductsController>()) {
          totalProducts = Get.find<ProductsController>().products.length;
        }

        return Row(
          children: [
            Expanded(
              child: _StatColumn(
                value: '$totalOrders',
                label: 'Total Orders',
                color: FarmerColors.statusConfirmed,
              ),
            ),
            const _VerticalDivider(),
            Expanded(
              child: _StatColumn(
                value: '$completedOrders',
                label: 'Completed',
                color: FarmerColors.primaryDark,
              ),
            ),
            const _VerticalDivider(),
            Expanded(
              child: _StatColumn(
                value: '$totalProducts',
                label: 'Products',
                color: FarmerColors.primary,
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _StatColumn({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: FarmerColors.muted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      color: FarmerColors.divider,
    );
  }
}

// ── Settings Group & Tiles ────────────────────────────────────────────────────

class _SettingsGroup extends StatelessWidget {
  final String title;
  final List<Widget> tiles;

  const _SettingsGroup({
    required this.title,
    required this.tiles,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: FarmerColors.muted,
              letterSpacing: 0.3,
            ),
          ),
        ),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: List.generate(tiles.length, (index) {
              return Column(
                children: [
                  tiles[index],
                  if (index < tiles.length - 1)
                    const Divider(height: 1, indent: 52),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool showChevron;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    final isClickable = onTap != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: FarmerColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: FarmerColors.primary, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: FarmerColors.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: FarmerTextStyles.caption.copyWith(
                        color: FarmerColors.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (showChevron && isClickable)
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: FarmerColors.muted,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
