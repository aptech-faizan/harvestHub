import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/theme/app_colors.dart';
import 'package:harvest_hub/app/core/theme/app_spacing.dart';
import 'package:harvest_hub/app/core/theme/app_text_styles.dart';
import 'package:harvest_hub/app/core/utils/helpers.dart';
import 'package:harvest_hub/app/core/widgets/app_app_bar.dart';
import 'package:harvest_hub/app/core/widgets/app_button.dart';
import 'package:harvest_hub/app/core/widgets/app_card.dart';
import 'package:harvest_hub/app/core/widgets/app_chip.dart';
import 'package:harvest_hub/app/core/widgets/app_section_header.dart';
import 'package:harvest_hub/app/modules/farmer/orders/controllers/farmer_orders_controller.dart';
import 'package:harvest_hub/app/modules/farmer/utils/farmer_order_status.dart';

class FarmerOrderDetailsView extends GetView<FarmerOrdersController> {
  const FarmerOrderDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceMuted,
      appBar: const AppAppBar(titleText: 'Order Details'),
      body: Obx(() {
        final o = controller.selected.value;
        if (o == null) {
          return const Center(
            child: Text(
              'Order not found.',
              style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: AppColors.textSecondary),
            ),
          );
        }

        final next = nextFarmerStatuses(o.status);
        final shortId =
            o.id.length > 12 ? o.id.substring(0, 12) : o.id;
        final statusColors = AppChip.getStatusColors(o.status);

        return ListView(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.l, vertical: AppSpacing.m),
          children: [
            // ── Order header card ─────────────────────────────────
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: statusColors.bg,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.receipt_long_rounded,
                            size: 22, color: statusColors.text),
                      ),
                      const SizedBox(width: AppSpacing.m),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '#${shortId.toUpperCase()}',
                              style: AppTextStyles.sectionHeading,
                            ),
                            Text(
                              formatDate(o.createdAt),
                              style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      AppChip.status(status: o.status),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.m),
                  const Divider(color: AppColors.divider, height: 1),
                  const SizedBox(height: AppSpacing.m),
                  _InfoRow(
                    icon: Icons.person_rounded,
                    label: 'Customer',
                    value: controller.customerName(o.customerId),
                  ),
                  const SizedBox(height: AppSpacing.s),
                  _InfoRow(
                    icon: Icons.schedule_rounded,
                    label: 'Pickup Slot',
                    value: o.pickupSlotTime.isNotEmpty
                        ? o.pickupSlotTime
                        : '-',
                  ),
                  if (o.deliveryAddress.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.s),
                    _InfoRow(
                      icon: Icons.location_on_rounded,
                      label: 'Address',
                      value: o.deliveryAddress,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.m),
                  const Divider(color: AppColors.divider, height: 1),
                  const SizedBox(height: AppSpacing.m),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Order Total',
                          style: AppTextStyles.bodyText.copyWith(
                              color: AppColors.textSecondary)),
                      Text(
                        money(o.totalPrice),
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.l),

            // ── Update status section ─────────────────────────────
            if (next.isNotEmpty) ...[
              const AppSectionHeader(title: 'Update Order Status'),
              const SizedBox(height: AppSpacing.s),
              Wrap(
                spacing: AppSpacing.s,
                runSpacing: AppSpacing.s,
                children: next.map((s) {
                  final isCancel = s == 'cancelled';
                  return AppButton.small(
                    label: orderStatusLabel(s),
                    icon: isCancel
                        ? Icons.close_rounded
                        : s == 'confirmed'
                            ? Icons.check_circle_rounded
                            : s == 'ready_for_pickup'
                                ? Icons.storefront_rounded
                                : Icons.done_all_rounded,
                    onPressed: () => controller.updateStatus(o, s),
                    backgroundColor: isCancel
                        ? const Color(0xFFFFEBEE)
                        : AppColors.primaryButton,
                    textColor: isCancel ? AppColors.accentRed : Colors.white,
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.l),
            ],

            // ── Order items ───────────────────────────────────────
            AppSectionHeader(
              title: 'Items',
              actionTitle: '${o.items.length} item${o.items.length == 1 ? '' : 's'}',
            ),
            const SizedBox(height: AppSpacing.s),

            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  if (o.items.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(AppSpacing.l),
                      child: Center(
                        child: Text(
                          'No items in this order.',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    )
                  else
                    ...List.generate(o.items.length, (i) {
                      final item = o.items[i];
                      final name = (item['name'] ??
                              item['itemName'] ??
                              'Item')
                          .toString();
                      final qty = (item['qty'] ??
                              item['quantity'] ??
                              0) as num;
                      final price = (item['price'] ??
                              item['pricePerUnit'] ??
                              0) as num;
                      final unit =
                          (item['unit'] ?? '').toString();
                      final lineTotal = qty.toDouble() * price.toDouble();
                      final isLast = i == o.items.length - 1;

                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.m,
                              vertical: AppSpacing.s,
                            ),
                            child: Row(
                              children: [
                                // Item icon avatar
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: AppColors.chipHerbsBg,
                                    borderRadius:
                                        BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.eco_rounded,
                                      size: 18,
                                      color: AppColors.primaryDark),
                                ),
                                const SizedBox(width: AppSpacing.m),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        style: AppTextStyles.cardTitle
                                            .copyWith(fontSize: 13),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        '$qty${unit.isNotEmpty ? ' $unit' : ''} × ${money(price.toDouble())}',
                                        style: AppTextStyles.caption
                                            .copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  money(lineTotal),
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!isLast)
                            const Divider(
                                color: AppColors.divider,
                                height: 1,
                                indent: AppSpacing.m,
                                endIndent: AppSpacing.m),
                        ],
                      );
                    }),

                  // Total row
                  if (o.items.isNotEmpty) ...[
                    const Divider(color: AppColors.divider, height: 1),
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.m),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total',
                            style: AppTextStyles.sectionHeading,
                          ),
                          Text(
                            money(o.totalPrice),
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),
          ],
        );
      }),
    );
  }
}

// ---------------------------------------------------------------------------
// Info row used in the order header card
// ---------------------------------------------------------------------------
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: AppSpacing.s),
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value.isEmpty ? '-' : value,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
