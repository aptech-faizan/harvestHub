import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../routes/app_routes.dart';
import 'package:harvest_hub/app/core/theme/app_colors.dart';
import 'package:harvest_hub/app/core/theme/app_radius.dart';
import 'package:harvest_hub/app/core/theme/app_spacing.dart';
import 'package:harvest_hub/app/core/theme/app_text_styles.dart';
import 'package:harvest_hub/app/core/widgets/app_widgets.dart';
import '../controllers/cart_controller.dart';

class CartView extends GetView<CartController> {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceWhite,
      appBar: AppAppBar(
        automaticallyImplyLeading: false,
        titleText: 'Shopping Cart',
        actions: [
          Obx(() {
            if (controller.items.isEmpty) return const SizedBox.shrink();
            return TextButton(
              onPressed: () => controller.clear(),
              child: Text(
                'Clear',
                style: AppTextStyles.linkText.copyWith(color: AppColors.accentRed),
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
                    width: 90,
                    height: 90,
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceMuted,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.shopping_basket_outlined,
                      size: 46,
                      color: AppColors.textDisabled,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.l),
                  Text('Your cart is empty', style: AppTextStyles.sectionHeading),
                  const SizedBox(height: AppSpacing.s),
                  Text(
                    'Explore fresh vegetables, fruits & herbs directly from local farmers.',
                    style: AppTextStyles.bodyText,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.screenHorizontalPadding),
                itemCount: controller.items.length,
                separatorBuilder: (_, __) =>
                    const Divider(color: AppColors.divider, height: 16),
                itemBuilder: (context, index) {
                  final item = controller.items[index];
                  final p = item.product;

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Thumbnail
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 60,
                          height: 60,
                          color: AppColors.surfaceMuted,
                          child: p.imageUrl.isNotEmpty
                              ? Image.network(
                                  p.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Center(
                                    child: Icon(Icons.eco_outlined,
                                        size: 26, color: AppColors.primary),
                                  ),
                                )
                              : const Center(
                                  child: Icon(Icons.eco_outlined,
                                      size: 26, color: AppColors.primary),
                                ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.m),

                      // Name, Unit & Price
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                              style: AppTextStyles.bodyText,
                            ),
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

                      // Quantity Stepper
                      AppStepper(
                        value: item.qty,
                        onChanged: (newQty) {
                          if (newQty <= 0) {
                            controller.remove(p.id);
                          } else {
                            controller.setQty(p.id, newQty);
                          }
                        },
                      ),
                    ],
                  );
                },
              ),
            ),

            // Bottom Summary & Checkout Button
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Subtotal (${controller.itemCount} items)',
                            style: AppTextStyles.bodyText),
                        Text(
                          '₹${controller.subtotal.toStringAsFixed(0)}',
                          style: AppTextStyles.priceText,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.m),
                    AppButton.primary(
                      label: 'Proceed to Checkout',
                      onPressed: () => Get.toNamed(Routes.customerCheckout),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
