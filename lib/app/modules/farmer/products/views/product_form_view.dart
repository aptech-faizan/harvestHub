import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../farmer_theme.dart';
import '../../widgets/farmer_widgets.dart';
import '../controllers/products_controller.dart';

/// Modern Add / Edit Product screen featuring grouped section cards,
/// dashed-border image uploader, floating-label inputs, and sticky bottom CTA.
class ProductFormView extends GetView<ProductsController> {
  const ProductFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FarmerColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: Semantics(
          button: true,
          label: 'Back',
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 20, color: FarmerColors.text),
            onPressed: () => Get.back(),
          ),
        ),
        title: Obx(() => Text(
              controller.isEditing ? 'Edit Product' : 'Add New Product',
              style: const TextStyle(
                color: FarmerColors.text,
                fontSize: 19,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            )),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: FarmerColors.border, height: 1),
        ),
      ),
      // Sticky bottom bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(
            top: BorderSide(color: FarmerColors.border, width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1F2A1F).withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Obx(() => PrimaryButton(
                  label: controller.isEditing ? 'Update Product' : 'Save & Publish Product',
                  icon: controller.isEditing ? Icons.check_circle_outline_rounded : Icons.add_circle_outline_rounded,
                  isLoading: controller.isSubmitting.value,
                  onPressed: controller.isSubmitting.value ? null : controller.saveProduct,
                  height: 52,
                )),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Section 1: Product Visuals ──────────────────────────────
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionTitle(
                      title: 'Product Photo',
                      subtitle: 'Upload a clear, appetizing photo of your harvest',
                      icon: Icons.photo_camera_outlined,
                    ),
                    const SizedBox(height: 14),
                    _DashedImagePickerArea(controller: controller),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Section 2: Basic Information ────────────────────────────
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionTitle(
                      title: 'General Details',
                      subtitle: 'Name and classification of the product',
                      icon: Icons.info_outline_rounded,
                    ),
                    const SizedBox(height: 16),

                    // Product Name field
                    TextFormField(
                      controller: controller.nameCtrl,
                      validator: controller.validateName,
                      textCapitalization: TextCapitalization.words,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: FarmerColors.text,
                      ),
                      decoration: _fieldDecoration(
                        labelText: 'Product Name',
                        hintText: 'e.g. Organic Farm Fresh Tomatoes',
                        prefixIcon: Icons.eco_rounded,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Category dropdown
                    Obx(() => DropdownButtonFormField<String>(
                          initialValue: controller.selectedCategory.value.isEmpty
                              ? controller.categories.first
                              : controller.selectedCategory.value,
                          isExpanded: true,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: FarmerColors.text,
                          ),
                          decoration: _fieldDecoration(
                            labelText: 'Produce Category',
                            hintText: 'Select category',
                            prefixIcon: Icons.category_rounded,
                          ),
                          items: controller.categories
                              .map((c) => DropdownMenuItem(
                                    value: c,
                                    child: Row(
                                      children: [
                                        Text(_getCategoryEmoji(c)),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            c,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: FarmerColors.text,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) {
                              controller.selectedCategory.value = v;
                            }
                          },
                        )),
                    const SizedBox(height: 16),

                    // Description field
                    TextFormField(
                      controller: controller.descCtrl,
                      validator: controller.validateDescription,
                      maxLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: FarmerColors.text,
                      ),
                      decoration: _fieldDecoration(
                        labelText: 'Description',
                        hintText: 'Describe freshness, farming method, taste, etc.',
                        prefixIcon: Icons.description_outlined,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Section 3: Pricing & Inventory ──────────────────────────
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionTitle(
                      title: 'Pricing & Inventory',
                      subtitle: 'Set unit rate and available batch quantity',
                      icon: Icons.payments_outlined,
                    ),
                    const SizedBox(height: 16),

                    // Price & Unit Responsive Row (Fixed for all widths!)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Price field
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            controller: controller.priceCtrl,
                            validator: controller.validatePrice,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: FarmerColors.primaryDark,
                            ),
                            decoration: _fieldDecoration(
                              labelText: 'Price (PKR)',
                              hintText: '0.00',
                              prefixIcon: Icons.attach_money_rounded,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Unit dropdown (isExpanded: true to prevent any overflow)
                        Expanded(
                          flex: 2,
                          child: Obx(() => DropdownButtonFormField<String>(
                                initialValue: controller.selectedUnit.value.isEmpty
                                    ? controller.units.first
                                    : controller.selectedUnit.value,
                                isExpanded: true,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: FarmerColors.text,
                                ),
                                decoration: _fieldDecoration(
                                  labelText: 'Unit',
                                  hintText: 'Unit',
                                  prefixIcon: Icons.scale_rounded,
                                ),
                                items: controller.units
                                    .map((u) => DropdownMenuItem(
                                          value: u,
                                          child: Text(
                                            u,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ))
                                    .toList(),
                                onChanged: (v) {
                                  if (v != null) {
                                    controller.selectedUnit.value = v;
                                  }
                                },
                              )),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Stock Quantity field
                    TextFormField(
                      controller: controller.stockCtrl,
                      validator: controller.validateStock,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: FarmerColors.text,
                      ),
                      decoration: _fieldDecoration(
                        labelText: 'Available Stock Quantity',
                        hintText: 'e.g. 50',
                        prefixIcon: Icons.inventory_2_rounded,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  static String _getCategoryEmoji(String category) {
    switch (category.toLowerCase()) {
      case 'vegetables':
        return '🥬';
      case 'fruits':
        return '🍎';
      case 'grains':
        return '🌾';
      case 'poultry':
        return '🥚';
      case 'honey & dairy':
        return '🍯';
      case 'herbs & spices':
        return '🌿';
      default:
        return '📦';
    }
  }

  static InputDecoration _fieldDecoration({
    required String labelText,
    required String hintText,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      labelStyle: const TextStyle(
        color: FarmerColors.muted,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      floatingLabelStyle: const TextStyle(
        color: FarmerColors.primary,
        fontSize: 13,
        fontWeight: FontWeight.w700,
      ),
      hintStyle: const TextStyle(
        color: Color(0xFFA5B2A4),
        fontSize: 13,
      ),
      prefixIcon: Icon(prefixIcon, color: FarmerColors.primary, size: 20),
      prefixIconConstraints: const BoxConstraints(minWidth: 42, minHeight: 42),
      filled: true,
      fillColor: const Color(0xFFFAFCF9),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: FarmerColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: FarmerColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: FarmerColors.primary, width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: FarmerColors.error, width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: FarmerColors.error, width: 1.8),
      ),
      errorStyle: const TextStyle(
        color: FarmerColors.error,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

// ── Section Title Header inside Cards ─────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _SectionTitle({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: FarmerColors.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: FarmerColors.primary, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: FarmerColors.text,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: FarmerTextStyles.caption.copyWith(
                  color: FarmerColors.muted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Big Rounded Image Picker Area with Dashed Border ──────────────────────────

class _DashedImagePickerArea extends StatelessWidget {
  final ProductsController controller;
  const _DashedImagePickerArea({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final picked = controller.pickedImage.value;
      final existingUrl = controller.editingProduct.value?.imageUrl;
      final hasImage = picked != null || (existingUrl != null && existingUrl.isNotEmpty);

      return Semantics(
        button: true,
        label: hasImage ? 'Change product photo' : 'Select product photo',
        child: InkWell(
          onTap: controller.pickImage,
          borderRadius: BorderRadius.circular(18),
          child: CustomPaint(
            painter: _DashedRectPainter(
              color: hasImage ? FarmerColors.primary : FarmerColors.secondary,
              strokeWidth: 1.5,
              gap: 4.0,
              dash: 6.0,
              radius: 18.0,
            ),
            child: Container(
              width: double.infinity,
              height: 160,
              decoration: BoxDecoration(
                color: hasImage ? Colors.black.withValues(alpha: 0.02) : const Color(0xFFF9FDF7),
                borderRadius: BorderRadius.circular(18),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (picked != null)
                      Image.network(
                        picked.path,
                        width: double.infinity,
                        height: 160,
                        fit: BoxFit.cover,
                      )
                    else if (existingUrl != null && existingUrl.isNotEmpty)
                      Hero(
                        tag: 'product-img-${controller.editingProduct.value?.id}',
                        child: Image.network(
                          existingUrl,
                          width: double.infinity,
                          height: 160,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _EmptyPickerPlaceholder(),
                        ),
                      )
                    else
                      const _EmptyPickerPlaceholder(),

                    // Overlay change button if image already exists
                    if (hasImage)
                      Positioned(
                        bottom: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.camera_alt_outlined,
                                  color: Colors.white, size: 14),
                              SizedBox(width: 6),
                              Text(
                                'Change Photo',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

class _EmptyPickerPlaceholder extends StatelessWidget {
  const _EmptyPickerPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: FarmerColors.primary.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.add_photo_alternate_outlined,
            size: 28,
            color: FarmerColors.primary,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Tap to Upload Produce Photo',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: FarmerColors.text,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Supports JPG, PNG • High quality recommended',
          style: FarmerTextStyles.caption.copyWith(
            color: FarmerColors.muted,
          ),
        ),
      ],
    );
  }
}

// ── Custom Painter for Dashed Rounded Rectangle Border ────────────────────────

class _DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  final double dash;
  final double radius;

  _DashedRectPainter({
    required this.color,
    this.strokeWidth = 1.5,
    this.gap = 4.0,
    this.dash = 6.0,
    this.radius = 16.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final Path path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(
          strokeWidth / 2,
          strokeWidth / 2,
          size.width - strokeWidth,
          size.height - strokeWidth,
        ),
        Radius.circular(radius),
      ));

    final Path dashedPath = _createDashedPath(path, dash, gap);
    canvas.drawPath(dashedPath, paint);
  }

  Path _createDashedPath(Path source, double dashLength, double gapLength) {
    final Path dest = Path();
    for (final metric in source.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final double len = min(dashLength, metric.length - distance);
        dest.addPath(metric.extractPath(distance, distance + len), Offset.zero);
        distance += dashLength + gapLength;
      }
    }
    return dest;
  }

  @override
  bool shouldRepaint(covariant _DashedRectPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.gap != gap ||
        oldDelegate.dash != dash ||
        oldDelegate.radius != radius;
  }
}
