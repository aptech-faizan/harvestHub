import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../farmer_theme.dart';
import '../controllers/products_controller.dart';

/// Add / Edit product form.
/// The controller decides whether we're adding or editing via [isEditing].
class ProductFormView extends GetView<ProductsController> {
  const ProductFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FarmerColors.background,
      appBar: AppBar(
        backgroundColor: FarmerColors.primary,
        foregroundColor: Colors.white,
        title: Obx(() => Text(
              controller.isEditing ? 'Edit Product' : 'Add Product',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            )),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Image picker ───────────────────────────────────────────
              _ImagePickerSection(controller: controller),
              const SizedBox(height: 20),

              // ── Product name ───────────────────────────────────────────
              _FormLabel('Product Name'),
              TextFormField(
                controller: controller.nameCtrl,
                validator: controller.validateName,
                textCapitalization: TextCapitalization.words,
                decoration: _inputDecoration(
                    hint: 'e.g. Fresh Tomatoes', icon: Icons.eco),
              ),
              const SizedBox(height: 16),

              // ── Category ───────────────────────────────────────────────
              _FormLabel('Category'),
              Obx(() => DropdownButtonFormField<String>(
                    value: controller.selectedCategory.value,
                    decoration: _inputDecoration(
                        hint: 'Select category', icon: Icons.category),
                    items: controller.categories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) =>
                        controller.selectedCategory.value = v ?? '',
                  )),
              const SizedBox(height: 16),

              // ── Price & Unit ───────────────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FormLabel('Price (PKR)'),
                        TextFormField(
                          controller: controller.priceCtrl,
                          validator: controller.validatePrice,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: _inputDecoration(
                              hint: '0.00', icon: Icons.attach_money),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FormLabel('Unit'),
                        Obx(() => DropdownButtonFormField<String>(
                              value: controller.selectedUnit.value,
                              decoration: _inputDecoration(
                                  hint: 'Unit', icon: Icons.scale),
                              items: controller.units
                                  .map((u) =>
                                      DropdownMenuItem(value: u, child: Text(u)))
                                  .toList(),
                              onChanged: (v) =>
                                  controller.selectedUnit.value = v ?? 'kg',
                            )),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Stock quantity ─────────────────────────────────────────
              _FormLabel('Stock Quantity'),
              TextFormField(
                controller: controller.stockCtrl,
                validator: controller.validateStock,
                keyboardType: TextInputType.number,
                decoration:
                    _inputDecoration(hint: '0', icon: Icons.inventory_2),
              ),
              const SizedBox(height: 16),

              // ── Description ────────────────────────────────────────────
              _FormLabel('Description'),
              TextFormField(
                controller: controller.descCtrl,
                validator: controller.validateDescription,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: _inputDecoration(
                    hint: 'Brief description of the product…',
                    icon: Icons.description),
              ),
              const SizedBox(height: 32),

              // ── Submit button ──────────────────────────────────────────
              Obx(() => SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: controller.isSubmitting.value
                          ? null
                          : controller.saveProduct,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: FarmerColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: controller.isSubmitting.value
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              controller.isEditing
                                  ? 'Update Product'
                                  : 'Add Product',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                    ),
                  )),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
      {required String hint, required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: FarmerColors.primary),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: FarmerColors.secondary),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: FarmerColors.secondary.withValues(alpha: 0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: FarmerColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: FarmerColors.error),
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _FormLabel extends StatelessWidget {
  const _FormLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text,
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: FarmerColors.primary)),
    );
  }
}

class _ImagePickerSection extends StatelessWidget {
  const _ImagePickerSection({required this.controller});
  final ProductsController controller;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Obx(() {
        final file = controller.pickedImage.value;
        return GestureDetector(
          onTap: controller.pickImage,
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: FarmerColors.secondary, width: 2, style: BorderStyle.solid),
            ),
            child: file != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(file.path, fit: BoxFit.cover),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.add_photo_alternate,
                          size: 40, color: FarmerColors.secondary),
                      SizedBox(height: 8),
                      Text('Add Photo',
                          style: TextStyle(
                              color: FarmerColors.primary,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
          ),
        );
      }),
    );
  }
}
