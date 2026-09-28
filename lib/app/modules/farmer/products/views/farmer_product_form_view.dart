import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/theme/app_colors.dart';
import 'package:harvest_hub/app/core/theme/app_radius.dart';
import 'package:harvest_hub/app/core/theme/app_spacing.dart';
import 'package:harvest_hub/app/core/theme/app_text_styles.dart';
import 'package:harvest_hub/app/core/widgets/app_app_bar.dart';
import 'package:harvest_hub/app/core/widgets/app_button.dart';
import 'package:harvest_hub/app/core/widgets/app_chip.dart';
import 'package:harvest_hub/app/core/widgets/app_section_header.dart';
import 'package:harvest_hub/app/core/widgets/app_text_field.dart';
import 'package:harvest_hub/app/modules/farmer/products/controllers/farmer_product_form_controller.dart';

class FarmerProductFormView extends GetView<FarmerProductFormController> {
  const FarmerProductFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceMuted,
      appBar: AppAppBar(
        titleText: controller.isEdit ? 'Edit Product' : 'Add Product',
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.l,
            vertical: AppSpacing.m,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Product Image ───────────────────────────────────────
              _ImagePicker(controller: controller),

              const SizedBox(height: AppSpacing.l),

              // ── Basic Details ───────────────────────────────────────
              const AppSectionHeader(title: 'Product Details'),
              const SizedBox(height: AppSpacing.s),

              _FormCard(
                children: [
                  AppTextField.outlined(
                    controller: controller.nameC,
                    labelText: 'Product Name',
                    hintText: 'e.g. Fresh Tomatoes',
                    prefixIcon: const Icon(Icons.label_outline_rounded,
                        size: 18, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.m),
                  AppTextField.outlined(
                    controller: controller.descC,
                    labelText: 'Description',
                    hintText: 'Describe your product…',
                    maxLines: 3,
                    prefixIcon: const Icon(Icons.notes_rounded,
                        size: 18, color: AppColors.textSecondary),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.l),

              // ── Category ────────────────────────────────────────────
              const AppSectionHeader(title: 'Category'),
              const SizedBox(height: AppSpacing.s),

              _CategorySelector(controller: controller),

              const SizedBox(height: AppSpacing.l),

              // ── Pricing & Stock ─────────────────────────────────────
              const AppSectionHeader(title: 'Pricing & Stock'),
              const SizedBox(height: AppSpacing.s),

              _FormCard(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: AppTextField.outlined(
                          controller: controller.priceC,
                          labelText: 'Price per Unit',
                          hintText: '0.00',
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          prefixIcon: const Icon(Icons.attach_money_rounded,
                              size: 18, color: AppColors.textSecondary),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.m),
                      Expanded(
                        child: AppTextField.outlined(
                          controller: controller.unitC,
                          labelText: 'Unit',
                          hintText: 'kg',
                          prefixIcon: const Icon(Icons.scale_rounded,
                              size: 18, color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.m),
                  AppTextField.outlined(
                    controller: controller.stockC,
                    labelText: 'Stock Quantity',
                    hintText: '0 = out of stock',
                    keyboardType: TextInputType.number,
                    prefixIcon: const Icon(Icons.inventory_2_rounded,
                        size: 18, color: AppColors.textSecondary),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xxl),

              // ── Save button ─────────────────────────────────────────
              Obx(() => AppButton.primary(
                    label: controller.isEdit ? 'Update Product' : 'Save Product',
                    icon: Icons.check_rounded,
                    isLoading: controller.isSaving.value,
                    onPressed:
                        controller.isSaving.value ? null : controller.save,
                  )),

              const SizedBox(height: AppSpacing.l),
            ],
          ),
        );
      }),
    );
  }
}

// ---------------------------------------------------------------------------
// Image picker section
// ---------------------------------------------------------------------------
class _ImagePicker extends StatelessWidget {
  final FarmerProductFormController controller;

  const _ImagePicker({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final url = controller.imageUrl.value;
      final uploading = controller.isUploading.value;

      return Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: AppRadius.cardRadius,
          border: Border.all(color: AppColors.divider),
          boxShadow: AppRadius.cardElevation,
        ),
        child: Column(
          children: [
            // Preview area
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(AppRadius.card)),
              child: Container(
                height: 190,
                width: double.infinity,
                color: AppColors.surfaceMuted,
                child: url.isEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_rounded,
                              size: 48,
                              color: AppColors.primary.withValues(alpha: 0.45)),
                          const SizedBox(height: 8),
                          const Text(
                            'No image uploaded',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      )
                    : Image.network(url,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                              Icons.broken_image_rounded,
                              size: 48,
                              color: AppColors.textDisabled,
                            )),
              ),
            ),

            // Upload button
            Padding(
              padding: const EdgeInsets.all(AppSpacing.m),
              child: AppButton.small(
                label: uploading ? 'Uploading…' : 'Upload Image (Cloudinary)',
                icon: uploading ? null : Icons.cloud_upload_rounded,
                isLoading: uploading,
                onPressed: uploading ? null : controller.pickAndUpload,
                backgroundColor: AppColors.surfaceMuted,
                textColor: AppColors.primaryDark,
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ---------------------------------------------------------------------------
// Category chip selector
// ---------------------------------------------------------------------------
class _CategorySelector extends StatelessWidget {
  final FarmerProductFormController controller;

  const _CategorySelector({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final cats = controller.categories;
      if (cats.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(AppSpacing.m),
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: AppRadius.cardRadius,
            border: Border.all(color: AppColors.divider),
          ),
          child: const Text(
            'No categories available.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        );
      }

      return Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: AppRadius.cardRadius,
          border: Border.all(color: AppColors.divider),
          boxShadow: AppRadius.cardElevation,
        ),
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Wrap(
          spacing: AppSpacing.s,
          runSpacing: AppSpacing.s,
          children: cats.map((cat) {
            final selected = controller.selectedCategoryId.value == cat.id;
            return GestureDetector(
              onTap: () => controller.selectedCategoryId.value = cat.id,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primaryDark
                      : AppChip.getCategoryBgColor(cat.name),
                  borderRadius: AppRadius.chipRadius,
                  border: selected
                      ? null
                      : Border.all(color: AppColors.divider, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      AppChip.getCategoryIcon(cat.name),
                      size: 14,
                      color: selected
                          ? Colors.white
                          : AppColors.primaryDark,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      cat.name,
                      style: AppTextStyles.chipLabel.copyWith(
                        color: selected
                            ? Colors.white
                            : AppColors.textPrimary,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      );
    });
  }
}

// ---------------------------------------------------------------------------
// Reusable white form section card
// ---------------------------------------------------------------------------
class _FormCard extends StatelessWidget {
  final List<Widget> children;

  const _FormCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: AppRadius.cardRadius,
        border: Border.all(color: AppColors.divider),
        boxShadow: AppRadius.cardElevation,
      ),
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}
