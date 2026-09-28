import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/theme/app_colors.dart';
import 'package:harvest_hub/app/core/theme/app_radius.dart';
import 'package:harvest_hub/app/core/theme/app_spacing.dart';
import 'package:harvest_hub/app/core/theme/app_text_styles.dart';
import 'package:harvest_hub/app/core/utils/helpers.dart';
import 'package:harvest_hub/app/core/widgets/app_shimmer.dart';
import 'package:harvest_hub/app/core/widgets/app_widgets.dart';
import 'package:harvest_hub/app/modules/admin/customers/controllers/customers_controller.dart';
import 'package:harvest_hub/app/modules/admin/models/user_model.dart';
import 'package:harvest_hub/app/modules/admin/widgets/admin_drawer.dart';

/// Admin Customers Management screen conforming to the HarvestHub Design System:
/// - AppAppBar with drawer toggle & refresh action
/// - AppSearchBar for filtering customers by name, email, or phone
/// - List of AppCard.list customer rows showing:
///   - Customer name, initial avatar, active/deactivated status badge
///   - Email & phone
///   - Order count
///   - Join date
///   - AppTextButton "View" opening order-history detail (reusing the Orders list-row pattern)
///   - Profile details action navigating to full customer profile
class CustomersView extends GetView<CustomersController> {
  const CustomersView({super.key});

  void _showOrderHistorySheet(BuildContext context, UserModel customer) {
    final customerOrders = controller.ordersForCustomer(customer.id);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.card)),
        ),
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.m),

            // Sheet Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order History',
                        style: AppTextStyles.sectionHeading,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${customer.name} • ${customerOrders.length} ${customerOrders.length == 1 ? "order" : "orders"}',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                AppIconButton(
                  icon: Icons.close,
                  size: 28,
                  iconSize: 18,
                  backgroundColor: AppColors.surfaceMuted,
                  iconColor: AppColors.textSecondary,
                  onTap: () => Navigator.of(ctx).pop(),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.m),
            const Divider(color: AppColors.divider, height: 1),
            const SizedBox(height: AppSpacing.m),

            // Orders list or empty state
            Expanded(
              child: customerOrders.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: const BoxDecoration(
                                color: AppColors.chipHerbsBg,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.receipt_long_outlined,
                                size: 32,
                                color: AppColors.primaryDark,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.m),
                            Text(
                              'No Orders Found',
                              style: AppTextStyles.sectionHeading,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              'This customer has not placed any orders yet.',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      itemCount: customerOrders.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.m),
                      itemBuilder: (context, index) {
                        final order = customerOrders[index];
                        final shortId = order.id.length > 8
                            ? order.id.substring(0, 8).toUpperCase()
                            : order.id.toUpperCase();
                        final dateStr = order.createdAt != null
                            ? formatDate(order.createdAt)
                            : 'Date not available';

                        // Reuse the Orders list-row pattern
                        return AppCard.list(
                          padding: const EdgeInsets.all(AppSpacing.m),
                          children: [
                            // Order ID & Status AppChip
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.receipt_outlined,
                                          size: 15,
                                          color: AppColors.primaryDark,
                                        ),
                                        const SizedBox(width: AppSpacing.xs),
                                        Text(
                                          'Order #$shortId',
                                          style: AppTextStyles.cardTitle
                                              .copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      dateStr,
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                AppChip.status(status: order.status),
                              ],
                            ),

                            const SizedBox(height: AppSpacing.s),
                            const Divider(
                              color: AppColors.divider,
                              height: 1,
                            ),
                            const SizedBox(height: AppSpacing.s),

                            // Farmer Name
                            Row(
                              children: [
                                const Icon(
                                  Icons.storefront_outlined,
                                  size: 15,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                Text(
                                  'Farmer: ',
                                  style: AppTextStyles.caption.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    order.farmerName.isNotEmpty
                                        ? order.farmerName
                                        : controller.farmerName(order.farmerId),
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),

                            // Items preview
                            if (order.items.isNotEmpty) ...[
                              const SizedBox(height: 3),
                              Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.shopping_bag_outlined,
                                    size: 15,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: AppSpacing.xs),
                                  Text(
                                    'Items: ',
                                    style: AppTextStyles.caption.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      order.items
                                          .map((item) =>
                                              '${item.itemName} x${item.quantity}')
                                          .join(', '),
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.textPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],

                            // Pickup slot
                            if (order.pickupSlot.isNotEmpty) ...[
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.schedule_outlined,
                                    size: 15,
                                    color: AppColors.primaryDark,
                                  ),
                                  const SizedBox(width: AppSpacing.xs),
                                  Text(
                                    'Slot: ${order.pickupSlot}',
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.primaryDark,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],

                            const SizedBox(height: AppSpacing.s),
                            const Divider(
                              color: AppColors.divider,
                              height: 1,
                            ),
                            const SizedBox(height: AppSpacing.xs),

                            // Total
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total',
                                  style: AppTextStyles.caption,
                                ),
                                Text(
                                  money(order.totalPrice),
                                  style: AppTextStyles.priceText,
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceMuted,
      appBar: AppAppBar(
        titleText: 'Customers Management',
        leading: Builder(
          builder: (ctx) => AppIconButton(
            icon: Icons.menu,
            iconSize: 22,
            backgroundColor: Colors.transparent,
            iconColor: AppColors.textPrimary,
            isCircle: false,
            onTap: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        actions: [
          AppIconButton(
            icon: Icons.refresh_rounded,
            iconSize: 20,
            backgroundColor: AppColors.surfaceMuted,
            iconColor: AppColors.primaryDark,
            tooltip: 'Refresh',
            onTap: controller.load,
          ),
        ],
      ),
      drawer: const AdminDrawer(),
      body: Column(
        children: [
          // ── Search Bar ─────────────────────────────────────────────────────
          Container(
            color: AppColors.surfaceWhite,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.l,
              AppSpacing.s,
              AppSpacing.l,
              AppSpacing.m,
            ),
            child: AppSearchBar(
              hintText: 'Search by name, email or phone...',
              onChanged: (v) => controller.search.value = v,
            ),
          ),

          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: AppSpacing.s),

          // ── Customer List ───────────────────────────────────────────────────
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const ShimmerListSkeleton();
              }

              if (controller.error.value.isNotEmpty) {
                return _buildErrorState();
              }

              final list = controller.filtered;
              if (list.isEmpty) {
                return _buildEmptyState();
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.l,
                  0,
                  AppSpacing.l,
                  AppSpacing.xl,
                ),
                itemCount: list.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.m),
                itemBuilder: (_, i) {
                  final customer = list[i];
                  final orderCount = controller.orderCount(customer.id);
                  return _CustomerManagementRow(
                    customer: customer,
                    orderCount: orderCount,
                    onViewOrders: () =>
                        _showOrderHistorySheet(context, customer),
                    onViewProfile: () => controller.openDetails(customer),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  // ── Empty State ─────────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.chipHerbsBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.people_outline_rounded,
                size: 40,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            Text(
              'No customers found',
              style: AppTextStyles.sectionHeading,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.s),
            Text(
              'Try adjusting your search query.',
              style: AppTextStyles.bodyText.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.l),
            AppButton.small(
              label: 'Reset Search',
              icon: Icons.refresh_rounded,
              onPressed: () => controller.search.value = '',
            ),
          ],
        ),
      ),
    );
  }

  // ── Error State ─────────────────────────────────────────────────────────────
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              size: 48,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.m),
            Text(
              controller.error.value,
              style: AppTextStyles.bodyText.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.l),
            AppButton.small(
              label: 'Retry',
              icon: Icons.refresh,
              onPressed: controller.load,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Customer Management Row Component ─────────────────────────────────────────
class _CustomerManagementRow extends StatelessWidget {
  final UserModel customer;
  final int orderCount;
  final VoidCallback onViewOrders;
  final VoidCallback onViewProfile;

  const _CustomerManagementRow({
    required this.customer,
    required this.orderCount,
    required this.onViewOrders,
    required this.onViewProfile,
  });

  @override
  Widget build(BuildContext context) {
    final initial = customer.name.isNotEmpty
        ? customer.name[0].toUpperCase()
        : '?';

    final joinDateStr = customer.createdAt != null
        ? '${customer.createdAt!.day.toString().padLeft(2, "0")}/${customer.createdAt!.month.toString().padLeft(2, "0")}/${customer.createdAt!.year}'
        : 'Sep 2026';

    return AppCard.list(
      onTap: onViewProfile,
      padding: const EdgeInsets.all(AppSpacing.l),
      children: [
        // ── Top Row: Initial Avatar + Name + Status Chip ─────────────────────
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.chipHerbsBg,
              child: Text(
                initial,
                style: AppTextStyles.cardTitle.copyWith(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.m),

            // Customer Name & Sub-details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customer.name.isNotEmpty ? customer.name : 'Unnamed Customer',
                    style: AppTextStyles.cardTitle.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.receipt_long_outlined,
                        size: 14,
                        color: AppColors.primaryDark,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$orderCount ${orderCount == 1 ? "order" : "orders"} placed',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: AppSpacing.s),

            // Status Badge
            AppChip.pill(
              label: customer.isActive ? 'Active' : 'Deactivated',
              iconData: customer.isActive
                  ? Icons.check_circle_outline_rounded
                  : Icons.block_rounded,
              backgroundColor: customer.isActive
                  ? AppColors.chipHerbsBg
                  : const Color(0xFFFFEBEE),
              textColor: customer.isActive
                  ? AppColors.primaryDark
                  : AppColors.accentRed,
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.m),
        const Divider(color: AppColors.divider, height: 1),
        const SizedBox(height: AppSpacing.m),

        // ── Contact Details: Email & Phone ───────────────────────────────────
        if (customer.email.isNotEmpty) ...[
          Row(
            children: [
              const Icon(
                Icons.email_outlined,
                size: 15,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  customer.email,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
        ],

        if (customer.phone.isNotEmpty) ...[
          Row(
            children: [
              const Icon(
                Icons.phone_outlined,
                size: 15,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  customer.phone,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
        ],

        // Join Date
        Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: 15,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              'Joined: ',
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              joinDateStr,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.m),
        const Divider(color: AppColors.divider, height: 1),
        const SizedBox(height: AppSpacing.s),

        // ── Action Buttons Row ───────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // View Orders action (specified in user request)
            AppTextButton(
              label: 'View Orders ($orderCount)',
              leadingIcon: Icons.history_rounded,
              color: AppColors.primaryDark,
              onPressed: onViewOrders,
            ),
            const SizedBox(width: AppSpacing.s),

            // Profile action
            AppTextButton(
              label: 'Profile',
              leadingIcon: Icons.open_in_new_rounded,
              color: AppColors.textSecondary,
              onPressed: onViewProfile,
            ),
          ],
        ),
      ],
    );
  }
}
