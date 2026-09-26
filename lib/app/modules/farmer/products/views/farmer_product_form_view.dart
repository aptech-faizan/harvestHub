import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/modules/farmer/products/controllers/farmer_product_form_controller.dart';

class FarmerProductFormView extends GetView<FarmerProductFormController> {
  const FarmerProductFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(controller.isEdit ? 'Edit product' : 'Add product')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Obx(() {
                final url = controller.imageUrl.value;
                return Column(
                  children: [
                    Container(
                      height: 180,
                      width: double.infinity,
                      color: Colors.grey.shade300,
                      child: url.isEmpty
                          ? const Icon(Icons.image, size: 72, color: Colors.grey)
                          : Image.network(url, fit: BoxFit.cover),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: controller.isUploading.value ? null : controller.pickAndUpload,
                      icon: controller.isUploading.value
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.cloud_upload),
                      label: Text(controller.isUploading.value ? 'Uploading...' : 'Upload image (Cloudinary)'),
                    ),
                  ],
                );
              }),
              const SizedBox(height: 16),
              TextField(
                controller: controller.nameC,
                decoration: const InputDecoration(labelText: 'Product name', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              Obx(() {
                final ids = controller.categories.map((c) => c.id).toList();
                final value = ids.contains(controller.selectedCategoryId.value)
                    ? controller.selectedCategoryId.value
                    : null;
                return InputDecorator(
                  decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: value,
                      hint: const Text('Select category'),
                      items: controller.categories
                          .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) controller.selectedCategoryId.value = v;
                      },
                    ),
                  ),
                );
              }),
              const SizedBox(height: 12),
              TextField(
                controller: controller.descC,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller.priceC,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Price per unit', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller.unitC,
                decoration: const InputDecoration(labelText: 'Unit (kg, dozen, ...)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller.stockC,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Stock quantity (0 = cannot be ordered)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: controller.isSaving.value ? null : controller.save,
                child: Text(controller.isEdit ? 'Update product' : 'Save product'),
              ),
            ],
          ),
        );
      }),
    );
  }
}
