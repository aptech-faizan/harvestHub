import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/theme/app_colors.dart';
import 'package:harvest_hub/app/core/theme/app_spacing.dart';
import 'package:harvest_hub/app/core/utils/helpers.dart';
import 'package:harvest_hub/app/core/widgets/app_icon.dart';
import 'package:harvest_hub/app/core/widgets/app_text.dart';
import 'package:harvest_hub/app/data/services/auth_service.dart';
import 'package:harvest_hub/app/routes/app_routes.dart';

/// Restyled admin side-drawer conforming to the HarvestHub Design System.
/// Items, order, routes and logout logic are unchanged from the original.
class AdminDrawer extends StatelessWidget {
  const AdminDrawer({super.key});

  // ── Nav items (order & routes unchanged from original) ──────────────────
  static const List<_NavItem> _items = [
    _NavItem('Dashboard',  Icons.dashboard_rounded,    Routes.adminDashboard),
    _NavItem('Customers',  Icons.people_rounded,       Routes.customers),
    _NavItem('Farmers',    Icons.agriculture_rounded,  Routes.farmers),
    _NavItem('Categories', Icons.category_rounded,     Routes.categories),
    _NavItem('Markets',    Icons.store_rounded,        Routes.markets),
    _NavItem('Products',   Icons.inventory_2_rounded,  Routes.products),
    _NavItem('Orders',     Icons.receipt_long_rounded, Routes.orders),
    _NavItem('Reports',    Icons.bar_chart_rounded,    Routes.reports),
  ];

  @override
  Widget build(BuildContext context) {
    final current = Get.currentRoute;

    return Drawer(
      backgroundColor: AppColors.surfaceWhite,
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.20),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────────
          _DrawerHeader(),

          // ── Nav items ───────────────────────────────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.s,
                horizontal: AppSpacing.s,
              ),
              children: [
                for (final item in _items)
                  _DrawerNavItem(item: item, isActive: current == item.route),
              ],
            ),
          ),

          // ── Divider + Logout ─────────────────────────────────────────────
          const Divider(color: AppColors.divider, height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s,
              vertical: AppSpacing.s,
            ),
            child: _DrawerLogoutItem(),
          ),

          // Bottom safe-area
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

// ── Header ──────────────────────────────────────────────────────────────────

class _DrawerHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Soft primary tint header (light green AppColors.chipHerbsBg)
    final headerBg = AppColors.chipHerbsBg;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.l, // 16px
        vertical: AppSpacing.xl,   // 20px
      ),
      decoration: BoxDecoration(
        color: headerBg,
        borderRadius: const BorderRadius.only(topRight: Radius.circular(16)),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 32,
              fit: BoxFit.contain,
              alignment: Alignment.centerLeft,
              errorBuilder: (context, error, stackTrace) {
                return const AppText.displayLogo(
                  'HarvestHub',
                  color: AppColors.primaryDark,
                );
              },
            ),
            const SizedBox(height: AppSpacing.s),
            const AppText.sectionHeading(
              'HarvestHub Admin',
              color: AppColors.primaryDark,
              fontWeight: FontWeight.w700,
            ),
            const SizedBox(height: 2),
            const AppText.caption(
              'Administrator',
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Nav item ────────────────────────────────────────────────────────────────

class _DrawerNavItem extends StatelessWidget {
  final _NavItem item;
  final bool isActive;

  const _DrawerNavItem({required this.item, required this.isActive});

  @override
  Widget build(BuildContext context) {
    final activeBg  = AppColors.primary.withValues(alpha: 0.12);
    final iconColor = isActive ? AppColors.primaryDark : AppColors.textSecondary;
    final textColor = isActive ? AppColors.primaryDark : AppColors.textPrimary;
    final fontWeight = isActive ? FontWeight.w600 : FontWeight.w400;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s, // 8px horizontal margin per spec
        vertical: 2,
      ),
      child: Material(
        color: isActive ? activeBg : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => Get.offNamed(item.route),
          child: SizedBox(
            height: 48,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
              child: Row(
                children: [
                  AppIcon(item.icon, size: 22, color: iconColor),
                  const SizedBox(width: AppSpacing.m),
                  Expanded(
                    child: AppText(
                      item.label,
                      color: textColor,
                      fontWeight: fontWeight,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
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

// ── Logout item ─────────────────────────────────────────────────────────────

class _DrawerLogoutItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s, vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () async {
            // Logout logic unchanged from original
            if (!await confirmDialog('Logout', 'Do you want to log out?')) return;
            await Get.find<AuthService>().logout();
          },
          child: const SizedBox(
            height: 48,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.m),
              child: Row(
                children: [
                  AppIcon(
                    Icons.logout_rounded,
                    size: 22,
                    color: AppColors.accentRed,
                  ),
                  SizedBox(width: AppSpacing.m),
                  AppText(
                    'Logout',
                    color: AppColors.accentRed,
                    fontWeight: FontWeight.w600,
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

// ── Data class ──────────────────────────────────────────────────────────────

class _NavItem {
  final String label;
  final IconData icon;
  final String route;
  const _NavItem(this.label, this.icon, this.route);
}

