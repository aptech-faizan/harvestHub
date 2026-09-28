import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/constants/app_constants.dart';
import 'package:harvest_hub/app/core/theme/app_colors.dart';
import 'package:harvest_hub/app/core/theme/app_spacing.dart';
import 'package:harvest_hub/app/core/utils/helpers.dart';
import 'package:harvest_hub/app/core/widgets/app_shimmer.dart';
import 'package:harvest_hub/app/core/widgets/app_widgets.dart';
import 'package:harvest_hub/app/data/models/order_model.dart';
import 'package:harvest_hub/app/modules/farmer/dashboard/controllers/farmer_dashboard_controller.dart';
import 'package:harvest_hub/app/modules/farmer/orders/controllers/farmer_orders_controller.dart';
import 'package:harvest_hub/app/routes/app_routes.dart';

/// Main navigation shell and overview for authenticated Farmer users.
class FarmerDashboardView extends GetView<FarmerDashboardController> {
  const FarmerDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceMuted,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Material(
          color: AppColors.surfaceWhite,
          elevation: 0,
          child: SafeArea(
            bottom: false,
            child: SizedBox(
              height: 56,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.l,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // LEFT: HarvestHub logo
                    const AppLogo(),
                    const Spacer(),
                    // RIGHT: Avatar + dropdown arrow
                    Obx(() {
                      final url = controller.photoUrl.value;
                      final name = controller.businessName.value.isNotEmpty
                          ? controller.businessName.value
                          : (controller.authService.currentUserModel.value?.name ?? 'F');

                      return _AvatarMenu(
                        photoUrl: url.isNotEmpty ? url : null,
                        name: name,
                        onChat: () => Get.toNamed(Routes.chatInbox),
                        onLogout: () async {
                          if (await confirmDialog(
                              'Logout', 'Do you want to log out?')) {
                            await controller.logout();
                          }
                        },
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const ShimmerDetailBlock();
        }

        return RefreshIndicator(
          onRefresh: controller.loadFarmerData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.l,
              vertical: AppSpacing.m,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Greeting block ───────────────────────────────────────
                Obx(() {
                  final name = controller.businessName.value.isNotEmpty
                      ? controller.businessName.value
                      : (controller.authService.currentUserModel.value?.name ??
                          'My Farm');
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                     
                      AppText.sectionHeading(
                        name,
                        color: AppColors.textPrimary,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  );
                }),
                const SizedBox(height: AppSpacing.l),

                // ── Stat Cards Row ──────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: AppStatCard(
                        title: 'My Products',
                        value: '${controller.productCount.value}',
                        icon: Icons.inventory_2_rounded,
                        iconColor: AppColors.primaryDark,
                        iconBgColor: AppColors.chipHerbsBg,
                        onTap: () => Get.toNamed(Routes.farmerProducts),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.m),
                    Expanded(
                      child: AppStatCard(
                        title: 'Active Orders',
                        value: '${controller.orderCount.value}',
                        icon: Icons.receipt_long_rounded,
                        iconColor: AppColors.accentOrange,
                        iconBgColor: const Color(0xFFFFF3E0),
                        onTap: () => Get.toNamed(Routes.farmerOrders),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.l),

                // ── Pending Orders Section ──────────────────────────────
                AppSectionHeader(
                  title: 'Pending Orders',
                  actionTitle: 'View All',
                  onActionTap: () => Get.toNamed(Routes.farmerOrders),
                ),
                const SizedBox(height: AppSpacing.s),

                _PendingOrdersList(),

                const SizedBox(height: AppSpacing.l),

                // ── Quick Links ─────────────────────────────────────────
                const AppSectionHeader(title: 'Farmer Modules'),
                const SizedBox(height: AppSpacing.s),

                _QuickLinksGrid(),

                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        );
      }),
    );
  }
}


// ---------------------------------------------------------------------------
// Pending Orders List (reads from FarmerOrdersController if registered)
// ---------------------------------------------------------------------------
class _PendingOrdersList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Lazily find the orders controller if it is already registered; if not,
    // show a prompt so we don't duplicate Firestore fetches.
    if (!Get.isRegistered<FarmerOrdersController>()) {
      return _EmptyOrdersCard();
    }

    final ordersCtrl = Get.find<FarmerOrdersController>();

    return Obx(() {
      if (ordersCtrl.isLoading.value) {
        return const ShimmerOrderList(count: 3);
      }

      final pending = ordersCtrl.orders
          .where((o) => o.status == OrderStatus.pending)
          .take(5)
          .toList();

      if (pending.isEmpty) {
        return AppCard.list(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
              child: Center(
                child: const Text(
                  'No pending orders – all caught up! 🎉',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        );
      }

      return Column(
        children: [
          for (int i = 0; i < pending.length; i++) ...[
            _PendingOrderRow(
              order: pending[i],
              ordersCtrl: ordersCtrl,
            ),
            if (i < pending.length - 1) const SizedBox(height: AppSpacing.s),
          ],
        ],
      );
    });
  }
}

class _EmptyOrdersCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppCard.list(
      children: [
        Row(
          children: [
            const Icon(Icons.receipt_long_rounded,
                size: 20, color: AppColors.textSecondary),
            const SizedBox(width: AppSpacing.s),
            const Expanded(
              child: Text(
                'Open Orders to see pending items.',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            AppTextButton(
              label: 'View Orders',
              onPressed: () => Get.toNamed(Routes.farmerOrders),
              trailingIcon: Icons.arrow_forward_ios_rounded,
            ),
          ],
        ),
      ],
    );
  }
}

class _PendingOrderRow extends StatelessWidget {
  final OrderModel order;
  final FarmerOrdersController ordersCtrl;

  const _PendingOrderRow({
    required this.order,
    required this.ordersCtrl,
  });

  @override
  Widget build(BuildContext context) {
    final customerLabel = ordersCtrl.customerName(order.customerId);

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.m),
      onTap: () => ordersCtrl.openDetails(order),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Order icon avatar
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.shopping_bag_rounded,
              size: 22,
              color: AppColors.accentOrange,
            ),
          ),
          const SizedBox(width: AppSpacing.m),

          // Order info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customerLabel,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      money(order.totalPrice),
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('•',
                        style: TextStyle(color: AppColors.textSecondary)),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        order.pickupSlotTime.isNotEmpty
                            ? order.pickupSlotTime
                            : formatDate(order.createdAt),
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.s),

          // Status chip + Confirm button
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AppChip.status(status: order.status),
              const SizedBox(height: 6),
              AppButton.small(
                label: 'Confirm',
                icon: Icons.check_rounded,
                onPressed: () =>
                    ordersCtrl.updateStatus(order, OrderStatus.confirmed),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Quick Links Grid
// ---------------------------------------------------------------------------
class _QuickLinksGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final links = [
      _QuickLinkItem(
        icon: Icons.inventory_2_rounded,
        label: 'Products',
        bg: AppColors.chipHerbsBg,
        iconColor: AppColors.primaryDark,
        route: Routes.farmerProducts,
      ),
      _QuickLinkItem(
        icon: Icons.warehouse_rounded,
        label: 'Inventory',
        bg: const Color(0xFFF0E4C8),
        iconColor: const Color(0xFF795548),
        route: Routes.farmerInventory,
      ),
      _QuickLinkItem(
        icon: Icons.schedule_rounded,
        label: 'Pickup Slots',
        bg: const Color(0xFFE3F2FD),
        iconColor: const Color(0xFF1565C0),
        route: Routes.farmerSlots,
      ),
      _QuickLinkItem(
        icon: Icons.receipt_long_rounded,
        label: 'Orders',
        bg: const Color(0xFFFFF3E0),
        iconColor: AppColors.accentOrange,
        route: Routes.farmerOrders,
      ),
      _QuickLinkItem(
        icon: Icons.bar_chart_rounded,
        label: 'Reports',
        bg: const Color(0xFFFCE4EC),
        iconColor: const Color(0xFFAD1457),
        route: Routes.farmerReports,
      ),
      _QuickLinkItem(
        icon: Icons.chat_bubble_outline_rounded,
        label: 'Chat',
        bg: const Color(0xFFE8F5E9),
        iconColor: AppColors.primary,
        route: Routes.chatInbox,
      ),
      _QuickLinkItem(
        icon: Icons.person_rounded,
        label: 'Profile',
        bg: const Color(0xFFEDE7F6),
        iconColor: const Color(0xFF4527A0),
        route: Routes.farmerProfile,
      ),
    ];

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppSpacing.m,
      mainAxisSpacing: AppSpacing.m,
      childAspectRatio: 1.0,
      children: links.map((item) => _QuickLinkTile(item: item)).toList(),
    );
  }
}

class _QuickLinkItem {
  final IconData icon;
  final String label;
  final Color bg;
  final Color iconColor;
  final String route;

  const _QuickLinkItem({
    required this.icon,
    required this.label,
    required this.bg,
    required this.iconColor,
    required this.route,
  });
}

class _QuickLinkTile extends StatelessWidget {
  final _QuickLinkItem item;

  const _QuickLinkTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.m),
      onTap: () => Get.toNamed(item.route),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: item.bg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.icon, size: 24, color: item.iconColor),
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            item.label,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Avatar + dropdown menu anchored below the avatar
// ---------------------------------------------------------------------------
class _AvatarMenu extends StatelessWidget {
  final String? photoUrl;
  final String name;
  final VoidCallback onChat;
  final VoidCallback onLogout;

  const _AvatarMenu({
    required this.photoUrl,
    required this.name,
    required this.onChat,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_MenuAction>(
      offset: const Offset(0, 44),
      color: AppColors.surfaceWhite,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      constraints: const BoxConstraints(minWidth: 200, maxWidth: 200),
      onSelected: (action) {
        switch (action) {
          case _MenuAction.chat:
            onChat();
          case _MenuAction.logout:
            onLogout();
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem<_MenuAction>(
          value: _MenuAction.chat,
          child: Row(
            children: const [
              Icon(Icons.chat_bubble_outline_rounded,
                  size: 18, color: AppColors.textPrimary),
              SizedBox(width: 12),
              Text(
                'Chat',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(height: 1),
        PopupMenuItem<_MenuAction>(
          value: _MenuAction.logout,
          child: Row(
            children: const [
              Icon(Icons.logout_rounded, size: 18, color: AppColors.accentRed),
              SizedBox(width: 12),
              Text(
                'Logout',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.accentRed,
                ),
              ),
            ],
          ),
        ),
      ],
      // Custom tap target: AppAvatar + drop-down chevron
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppAvatar(
            imageUrl: photoUrl,
            name: name,
            size: 40,
          ),
          const Icon(
            Icons.arrow_drop_down,
            size: 18,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}

enum _MenuAction { chat, logout }
