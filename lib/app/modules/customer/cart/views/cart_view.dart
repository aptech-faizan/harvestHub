import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/theme/app_colors.dart';
import 'package:harvest_hub/app/core/theme/app_spacing.dart';
import 'package:harvest_hub/app/core/theme/app_text_styles.dart';
import 'package:harvest_hub/app/core/widgets/app_widgets.dart';
import 'package:harvest_hub/app/routes/app_routes.dart';
import '../../shell/controllers/customer_shell_controller.dart';
import '../controllers/cart_controller.dart';

/// Customer Cart screen conforming to the HarvestHub Design System:
/// - AppAppBar with title and action controls
/// - Vertical list of AppCard.list item rows (thumbnail, name, price, AppStepper, AppIconButton remove)
/// - Visual divider separator
/// - AppCard.list summary block (subtotal & fees matching Invoice pattern)
/// - AppButton.primary "Proceed to Checkout" pinned at the bottom
class CartView extends GetView<CartController> {
  const CartView({super.key});

  Widget _invoiceRow({
    required String label,
    required String value,
    required TextStyle valueStyle,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyText),
        Text(value, style: valueStyle),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceWhite,
      appBar: AppAppBar(
        automaticallyImplyLeading: false,
        titleText: 'Shopping Cart',
        actions: [
          Obx(() {
            final count = controller.itemCount;
            if (count == 0) return const SizedBox.shrink();
            return Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.chipHerbsBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: AppText.caption(
                  '$count ${count == 1 ? "item" : "items"}',
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }),
          Obx(() {
            if (controller.items.isEmpty) return const SizedBox.shrink();
            return TextButton(
              onPressed: () => controller.clear(),
              child: const AppText.link(
                'Clear',
                color: AppColors.accentRed,
              ),
            );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.items.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceMuted,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.shopping_basket_outlined,
                      size: 44,
                      color: AppColors.textDisabled,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.l),
                  const AppText.sectionHeading(
                    'Your Cart is Empty',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.s),
                  const AppText.body(
                    'Explore fresh vegetables, fruits & herbs directly from local farmers.',
                    textAlign: TextAlign.center,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 280),
                    child: AppButton.primary(
                      label: 'Start Shopping',
                      icon: Icons.search_rounded,
                      width: double.infinity,
                      onPressed: () {
                        if (Get.isRegistered<CustomerShellController>()) {
                          Get.find<CustomerShellController>().changeTab(1);
                        } else {
                          Get.offAllNamed(Routes.customerShell);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontalPadding,
                  vertical: AppSpacing.l,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Vertical list of AppCard.list item rows
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.items.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.m),
                      itemBuilder: (context, index) {
                        final item = controller.items[index];
                        final p = item.product;

                        return AppCard.list(
                          padding: const EdgeInsets.all(AppSpacing.m),
                          onTap: () => Get.toNamed(
                            Routes.customerProductDetails,
                            arguments: p,
                          ),
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Thumbnail
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    width: 56,
                                    height: 56,
                                    color: AppColors.surfaceMuted,
                                    child: p.imageUrl.isNotEmpty
                                        ? Image.network(
                                            p.imageUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                const Center(
                                              child: Icon(
                                                Icons.eco_outlined,
                                                size: 24,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                          )
                                        : const Center(
                                            child: Icon(
                                              Icons.eco_outlined,
                                              size: 24,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.m),

                                // Name, price & total
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        p.itemName,
                                        style: AppTextStyles.cardTitle,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '₹${p.pricePerUnit.toStringAsFixed(0)} / ${p.unit}',
                                        style: AppTextStyles.bodyText.copyWith(
                                          color: AppColors.textSecondary,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Total: ₹${item.total.toStringAsFixed(0)}',
                                        style: AppTextStyles.caption.copyWith(
                                          color: AppColors.primaryDark,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.s),

                                // AppStepper for quantity
                                AppStepper(
                                  value: item.qty,
                                  min: 1,
                                  onChanged: (newQty) {
                                    if (newQty <= 0) {
                                      controller.remove(p.id);
                                    } else {
                                      controller.setQty(p.id, newQty);
                                    }
                                  },
                                ),
                                const SizedBox(width: AppSpacing.s),

                                // Remove action via AppIconButton
                                AppIconButton(
                                  icon: Icons.delete_outline_rounded,
                                  size: 36,
                                  iconSize: 18,
                                  backgroundColor: AppColors.surfaceMuted,
                                  iconColor: AppColors.accentRed,
                                  tooltip: 'Remove',
                                  onTap: () => controller.remove(p.id),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: AppSpacing.l),
                    const Divider(color: AppColors.divider, height: 1),
                    const SizedBox(height: AppSpacing.l),

                    // AppCard.list summary block (Invoice pattern)
                    AppCard.list(
                      title: 'Order Summary',
                      children: [
                        _invoiceRow(
                          label: 'Items Subtotal',
                          value: '₹${controller.subtotal.toStringAsFixed(0)}',
                          valueStyle: AppTextStyles.priceText,
                        ),
                        const SizedBox(height: AppSpacing.s),
                        _invoiceRow(
                          label: 'Estimated Delivery',
                          value: '+₹40',
                          valueStyle: AppTextStyles.priceText.copyWith(
                            color: AppColors.accentOrange,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s),
                        const Divider(color: AppColors.divider, height: 16),
                        const SizedBox(height: AppSpacing.xs),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Estimated Total',
                              style: AppTextStyles.sectionHeading.copyWith(
                                color: AppColors.primaryDark,
                              ),
                            ),
                            Text(
                              '₹${(controller.subtotal + 40).toStringAsFixed(0)}',
                              style: AppTextStyles.totalPriceText,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Pinned bottom action bar
            Container(
              padding: const EdgeInsets.all(AppSpacing.l),
              decoration: const BoxDecoration(
                color: AppColors.surfaceWhite,
                border: Border(
                  top: BorderSide(color: AppColors.divider, width: 1.0),
                ),
              ),
              child: SafeArea(
                top: false,
                child: AppButton.primary(
                  label: 'Proceed to Checkout',
                  onPressed: () => Get.toNamed(Routes.customerCheckout),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
