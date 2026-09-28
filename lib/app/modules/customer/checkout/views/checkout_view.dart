import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/theme/app_colors.dart';
import 'package:harvest_hub/app/core/theme/app_radius.dart';
import 'package:harvest_hub/app/core/theme/app_spacing.dart';
import 'package:harvest_hub/app/core/theme/app_text_styles.dart';
import 'package:harvest_hub/app/core/widgets/app_widgets.dart';
import '../controllers/checkout_controller.dart';

/// Customer Checkout screen conforming to the HarvestHub Design System:
/// - Order summary via AppCard.list (collapsed/summarized item rows)
/// - AppSectionHeader "Pickup Slot" + slot-selection UI via AppSlotPicker
/// - Shipping details & delivery instructions
/// - Invoice / summary rows in the AppCard.list pattern
/// - AppButton.primary "Place Order" pinned at the bottom
class CheckoutView extends GetView<CheckoutController> {
  const CheckoutView({super.key});

  void _showCouponDialog(BuildContext context) {
    final couponTextCtrl =
        TextEditingController(text: controller.appliedCoupon.value);
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
                  const Icon(
                    Icons.local_offer,
                    color: AppColors.primaryDark,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.s),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'FARM20',
                          style: AppTextStyles.cardTitle
                              .copyWith(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          'Get ₹20 off on all fresh harvest orders',
                          style: AppTextStyles.caption,
                        ),
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
                Text(
                  'Edit Shipping Details',
                  style: AppTextStyles.sectionHeading,
                ),
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
              controller:
                  TextEditingController(text: controller.customerName.value)
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
              controller:
                  TextEditingController(text: controller.customerPhone.value)
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
      appBar: const AppAppBar(
        titleText: 'Checkout',
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (controller.isPlacing.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        final items = controller.cartController.items;
        if (items.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontalPadding,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.remove_shopping_cart_outlined,
                    size: 64,
                    color: AppColors.textDisabled,
                  ),
                  const SizedBox(height: AppSpacing.m),
                  Text('Your cart is empty', style: AppTextStyles.sectionHeading),
                  const SizedBox(height: AppSpacing.l),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 280),
                    child: AppButton.small(
                      width: double.infinity,
                      label: 'Add more items',
                      onPressed: () => Get.back(),
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
                    // 1. Order summary via AppCard.list (Cart item-row style, collapsed/summarized)
                    AppCard.list(
                      title: 'Order Items (${items.length})',
                      children: items.map((item) {
                        final p = item.product;
                        final isLast = items.last == item;

                        return Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Thumbnail (matching Cart: 56x56 rounded 8px)
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

                                // Name, unit price & farmer name
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
                                      if (p.farmerName.isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          'By ${p.farmerName}',
                                          style: AppTextStyles.caption,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.s),

                                // Collapsed/Summarized Qty badge + item total
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceMuted,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: AppColors.divider,
                                          width: 1.0,
                                        ),
                                      ),
                                      child: Text(
                                        'Qty: ${item.qty}',
                                        style: AppTextStyles.caption.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '₹${item.total.toStringAsFixed(0)}',
                                      style: AppTextStyles.priceText,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            if (!isLast)
                              const Divider(
                                color: AppColors.divider,
                                height: 20,
                              ),
                          ],
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // 2. AppSectionHeader "Pickup Slot" + slot-selection UI via AppSlotPicker
                    const AppSectionHeader(title: 'Pickup Slot'),
                    const SizedBox(height: AppSpacing.xs),
                    ...controller.cartController.groupedByFarmer.entries
                        .map((entry) {
                      final farmerId = entry.key;
                      final farmerItems = entry.value;
                      final farmerName = farmerItems.isNotEmpty
                          ? farmerItems.first.product.farmerName
                          : 'Local Farmer';
                      final slots = controller.farmerSlots[farmerId] ?? [];
                      final selectedId = controller.selectedSlotId[farmerId];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.m),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (controller
                                    .cartController.groupedByFarmer.length >
                                1)
                              Padding(
                                padding:
                                    const EdgeInsets.only(bottom: AppSpacing.s),
                                child: Text(
                                  'For $farmerName:',
                                  style: AppTextStyles.caption.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            AppSlotPicker(
                              slots: slots,
                              selectedSlotId: selectedId,
                              onSlotSelected: (slot) =>
                                  controller.selectSlot(farmerId, slot),
                            ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: AppSpacing.m),

                    // 3. Shipping Details card
                    AppCard.list(
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
                        ValueListenableBuilder<TextEditingValue>(
                          valueListenable: controller.addressController,
                          builder: (context, value, _) => Text(
                            value.text.isNotEmpty
                                ? value.text
                                : 'No address set',
                            style: AppTextStyles.bodyText,
                          ),
                        ),
                        const SizedBox(height: 4),

                        // Phone
                        Obx(() => Text(
                              controller.customerPhone.value,
                              style: AppTextStyles.bodyText,
                            )),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.l),

                    // 4. Coupon Row
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
                                      ? 'Coupon: ${controller.appliedCoupon.value}'
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

                    const SizedBox(height: AppSpacing.l),

                    // 5. Delivery Instructions
                    Text(
                      'Delivery Instructions',
                      style: AppTextStyles.sectionHeading,
                    ),
                    const SizedBox(height: AppSpacing.s),
                    AppTextField.outlined(
                      controller: controller.instructionsController,
                      hintText:
                          'Add Delivery Instructions (e.g. Leave with gatekeeper)',
                      maxLines: 2,
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // 6. Invoice / summary rows in the AppCard.list pattern
                    AppCard.list(
                      title: 'Invoice',
                      children: [
                        // Subtotal row
                        _invoiceRow(
                          label: 'Items Subtotal',
                          value: '₹${controller.grandTotal.toStringAsFixed(0)}',
                          valueStyle: AppTextStyles.priceText,
                        ),
                        const SizedBox(height: AppSpacing.s),

                        // Delivery Fee row
                        _invoiceRow(
                          label: 'Delivery Fee',
                          value:
                              '+₹${controller.deliveryFee.value.toStringAsFixed(0)}',
                          valueStyle: AppTextStyles.priceText.copyWith(
                            color: AppColors.accentOrange,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s),

                        // Discount row
                        if (controller.couponDiscount.value > 0) ...[
                          _invoiceRow(
                            label: 'Harvest Discount',
                            value:
                                '-₹${controller.couponDiscount.value.toStringAsFixed(0)}',
                            valueStyle: AppTextStyles.priceText.copyWith(
                              color: AppColors.success,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.s),
                        ],

                        const Divider(color: AppColors.divider, height: 16),
                        const SizedBox(height: AppSpacing.xs),

                        // Total Row
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

                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ),

            // 7. Pinned Bottom Bar with "Place Order"
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
                        label: 'Place Order',
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
}
