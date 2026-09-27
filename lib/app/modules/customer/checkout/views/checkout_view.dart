import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/theme/app_colors.dart';
import 'package:harvest_hub/app/core/theme/app_radius.dart';
import 'package:harvest_hub/app/core/theme/app_spacing.dart';
import 'package:harvest_hub/app/core/theme/app_text_styles.dart';
import 'package:harvest_hub/app/core/widgets/app_widgets.dart';
import '../controllers/checkout_controller.dart';

/// Customer Checkout screen conforming to the Farmers App UI Design Specification (Section 7):
/// Item row (with stepper) → Apply Coupon row → Invoice card → Shipping Details card → Add Delivery Instructions → Proceed to Checkout (fixed bottom button)
class CheckoutView extends GetView<CheckoutController> {
  const CheckoutView({super.key});

  void _showCouponDialog(BuildContext context) {
    final couponTextCtrl = TextEditingController(text: controller.appliedCoupon.value);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.l,
          right: AppSpacing.l,
          top: AppSpacing.l,
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + AppSpacing.l,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Apply Coupon', style: AppTextStyles.sectionHeading),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.of(sheetContext).pop(),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.m),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: couponTextCtrl,
                    hintText: 'Enter coupon code (e.g. FARM20)',
                  ),
                ),
                const SizedBox(width: AppSpacing.s),
                AppButton.small(
                  label: 'Apply',
                  onPressed: () {
                    controller.applyCoupon(couponTextCtrl.text);
                    Navigator.of(sheetContext).pop();
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.m),
            Container(
              padding: const EdgeInsets.all(AppSpacing.m),
              decoration: BoxDecoration(
                color: AppColors.chipHerbsBg,
                borderRadius: AppRadius.cardRadius,
              ),
              child: Row(
                children: [
                  const Icon(Icons.local_offer, color: AppColors.primaryDark, size: 20),
                  const SizedBox(width: AppSpacing.s),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('FARM20', style: AppTextStyles.cardTitle.copyWith(fontWeight: FontWeight.w700)),
                        Text('Get ₹20 off on all fresh harvest orders', style: AppTextStyles.caption),
                      ],
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

  void _showEditAddressDialog(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.l,
          right: AppSpacing.l,
          top: AppSpacing.l,
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + AppSpacing.l,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Edit Shipping Details', style: AppTextStyles.sectionHeading),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.of(sheetContext).pop(),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.m),
            Text('Recipient Name', style: AppTextStyles.cardTitle),
            const SizedBox(height: 4),
            AppTextField(
              hintText: 'Full Name',
              controller: TextEditingController(text: controller.customerName.value)
                ..addListener(() {}),
              onChanged: (val) => controller.customerName.value = val,
            ),
            const SizedBox(height: AppSpacing.m),
            Text('Delivery Address', style: AppTextStyles.cardTitle),
            const SizedBox(height: 4),
            AppTextField(
              controller: controller.addressController,
              hintText: 'Street, House No, City',
              maxLines: 2,
            ),
            const SizedBox(height: AppSpacing.m),
            Text('Phone Number', style: AppTextStyles.cardTitle),
            const SizedBox(height: 4),
            AppTextField(
              hintText: '+91 ...',
              controller: TextEditingController(text: controller.customerPhone.value)
                ..addListener(() {}),
              onChanged: (val) => controller.customerPhone.value = val,
            ),
            const SizedBox(height: AppSpacing.l),
            AppButton.primary(
              label: 'Save Address',
              onPressed: () => Navigator.of(sheetContext).pop(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceWhite,
      appBar: const AppAppBar(
        titleText: 'Checkout',
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        final items = controller.cartController.items;
        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.remove_shopping_cart_outlined,
                    size: 64, color: AppColors.textDisabled),
                const SizedBox(height: AppSpacing.m),
                Text('Your cart is empty', style: AppTextStyles.sectionHeading),
                const SizedBox(height: AppSpacing.l),
                AppButton.small(
                  label: 'Add more items',
                  onPressed: () => Get.back(),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontalPadding,
                  vertical: AppSpacing.m,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Item rows (with stepper)
                    Text('Order Items (${items.length})', style: AppTextStyles.sectionHeading),
                    const SizedBox(height: AppSpacing.s),

                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: items.length,
                      separatorBuilder: (_, __) =>
                          const Divider(color: AppColors.divider, height: 16),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final p = item.product;

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Product Image thumbnail (rounded 8px)
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
                                        errorBuilder: (_, __, ___) => const Center(
                                          child: Icon(Icons.eco_outlined,
                                              size: 24, color: AppColors.primary),
                                        ),
                                      )
                                    : const Center(
                                        child: Icon(Icons.eco_outlined,
                                            size: 24, color: AppColors.primary),
                                      ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.m),

                            // Name & unit price
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
                                    'By ${p.farmerName.isNotEmpty ? p.farmerName : 'Local Farmer'}',
                                    style: AppTextStyles.caption,
                                  ),
                                ],
                              ),
                            ),

                            // Item Stepper (Section 6.7: pill-shaped, primaryButton bg, +/- tap targets >=32px)
                            AppStepper(
                              value: item.qty,
                              onChanged: (newQty) {
                                if (newQty <= 0) {
                                  controller.cartController.remove(p.id);
                                } else {
                                  controller.cartController.setQty(p.id, newQty);
                                }
                              },
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // 2. Apply Coupon row (Section 7)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.l,
                        vertical: AppSpacing.m,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceWhite,
                        borderRadius: AppRadius.cardRadius,
                        border: Border.all(color: AppColors.divider),
                        boxShadow: AppRadius.cardElevation,
                      ),
                      child: InkWell(
                        onTap: () => _showCouponDialog(context),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.local_offer_outlined,
                                  color: AppColors.primaryDark,
                                  size: 20,
                                ),
                                const SizedBox(width: AppSpacing.s),
                                Text(
                                  controller.couponDiscount.value > 0
                                      ? 'Coupon Applied: ${controller.appliedCoupon.value}'
                                      : 'Apply Coupon',
                                  style: AppTextStyles.linkText,
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                if (controller.couponDiscount.value > 0) ...[
                                  Text(
                                    '-₹${controller.couponDiscount.value.toStringAsFixed(0)}',
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.success,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                ],
                                const Icon(
                                  Icons.chevron_right,
                                  size: 18,
                                  color: AppColors.primaryDark,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // 3. Invoice card (Section 6.6 & Section 7)
                    AppListCard(
                      title: 'Invoice',
                      children: [
                        // Subtotal row
                        _invoiceRow(
                          label: 'Items Subtotal',
                          value: '₹${controller.grandTotal.toStringAsFixed(0)}',
                          valueStyle: AppTextStyles.priceText,
                        ),
                        const SizedBox(height: AppSpacing.s),

                        // Delivery Fee row (+40 styled in accentOrange #FB8C00 as in Section 1)
                        _invoiceRow(
                          label: 'Delivery Fee',
                          value: '+₹${controller.deliveryFee.value.toStringAsFixed(0)}',
                          valueStyle: AppTextStyles.priceText.copyWith(
                            color: AppColors.accentOrange,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s),

                        // Discount row (-20 styled in success #2E7D32 as in Section 1)
                        if (controller.couponDiscount.value > 0) ...[
                          _invoiceRow(
                            label: 'Harvest Discount',
                            value: '-₹${controller.couponDiscount.value.toStringAsFixed(0)}',
                            valueStyle: AppTextStyles.priceText.copyWith(
                              color: AppColors.success,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.s),
                        ],

                        const Divider(color: AppColors.divider, height: 16),
                        const SizedBox(height: AppSpacing.xs),

                        // Total Row (totalPriceText 18px Bold in success #2E7D32)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Amount',
                              style: AppTextStyles.sectionHeading.copyWith(
                                color: AppColors.primaryDark,
                              ),
                            ),
                            Text(
                              '₹${controller.finalTotal.toStringAsFixed(0)}',
                              style: AppTextStyles.totalPriceText,
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // 4. Shipping Details card (Section 6.6 & Section 7)
                    AppListCard(
                      title: 'Shipping Details',
                      trailingTitle: InkWell(
                        onTap: () => _showEditAddressDialog(context),
                        child: Text('Edit', style: AppTextStyles.linkText),
                      ),
                      children: [
                        // Recipient Name
                        Obx(() => Text(
                              controller.customerName.value,
                              style: AppTextStyles.cardTitle,
                            )),
                        const SizedBox(height: 4),

                        // Address lines
                        Obx(() => Text(
                              controller.addressController.text.isNotEmpty
                                  ? controller.addressController.text
                                  : 'No address set',
                              style: AppTextStyles.bodyText,
                            )),
                        const SizedBox(height: 4),

                        // Phone
                        Obx(() => Text(
                              controller.customerPhone.value,
                              style: AppTextStyles.bodyText,
                            )),

                        // Farmer Pickup Slots if available
                        ...controller.cartController.groupedByFarmer.entries.map((entry) {
                          final farmerId = entry.key;
                          final items = entry.value;
                          final farmerName = items.isNotEmpty
                              ? items.first.product.farmerName
                              : 'Farmer';
                          final slots = controller.farmerSlots[farmerId] ?? [];

                          if (slots.isEmpty) return const SizedBox.shrink();

                          return Padding(
                            padding: const EdgeInsets.only(top: AppSpacing.m),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Delivery Slot ($farmerName):',
                                  style: AppTextStyles.caption.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 8.0,
                                  runSpacing: 6.0,
                                  children: slots.map((slot) {
                                    if (slot.isFull) {
                                      return ChoiceChip(
                                        label: Text('${slot.label} (Full)'),
                                        selected: false,
                                        onSelected: null,
                                      );
                                    }
                                    final isSelected =
                                        controller.selectedSlotId[farmerId] == slot.id;
                                    return ChoiceChip(
                                      label: Text(slot.label),
                                      selected: isSelected,
                                      selectedColor: AppColors.chipHerbsBg,
                                      onSelected: (_) =>
                                          controller.selectSlot(farmerId, slot),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // 5. Add Delivery Instructions (Section 6.2 & Section 7)
                    Text('Delivery Instructions', style: AppTextStyles.sectionHeading),
                    const SizedBox(height: AppSpacing.s),
                    AppTextField.outlined(
                      controller: controller.instructionsController,
                      hintText: 'Add Delivery Instructions (e.g. Leave with gatekeeper)',
                      maxLines: 2,
                    ),

                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ),

            // 6. Fixed Bottom Bar with "Proceed to Checkout" (Section 6.7 & Section 7)
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
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Grand Total', style: AppTextStyles.caption),
                          Text(
                            '₹${controller.finalTotal.toStringAsFixed(0)}',
                            style: AppTextStyles.totalPriceText,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 6,
                      child: AppButton.primary(
                        label: 'Proceed to Checkout',
                        isLoading: controller.isPlacing.value,
                        onPressed: () => controller.placeOrder(),
                      ),
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
}
