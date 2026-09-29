import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/utils/validators.dart';
import 'package:harvest_hub/app/core/widgets/market_location_picker.dart';
import 'package:harvest_hub/app/modules/admin/markets/controllers/market_form_controller.dart';

/// Dedicated Add/Edit market form for the admin panel.
class MarketFormView extends GetView<MarketFormController> {
  const MarketFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(controller.isEdit ? 'Edit market' : 'Add market'),
      ),
      body: Form(
        key: controller.formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: controller.nameC,
              decoration: const InputDecoration(
                labelText: 'Market name',
                border: OutlineInputBorder(),
              ),
              validator:
                  AppValidators.text(minLength: 3, label: 'Market name'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: controller.addressC,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(),
              ),
              validator: AppValidators.address(),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: controller.hoursC,
              decoration: const InputDecoration(
                labelText: 'Operating hours (e.g. 8am - 6pm)',
                border: OutlineInputBorder(),
              ),
              validator: AppValidators.text(
                  minLength: 3, label: 'Operating hours'),
            ),
            const SizedBox(height: 12),
            Obx(() => SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Active'),
                  subtitle: const Text('Inactive markets are hidden from farmers and customers'),
                  value: controller.isActive.value,
                  onChanged: (v) => controller.isActive.value = v,
                )),
            const Divider(height: 32),
            Row(
              children: [
                const Text('Location', style: TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                Obx(() => TextButton.icon(
                      onPressed: controller.toggleManualCoordinates,
                      icon: Icon(
                        controller.manualCoordinates.value
                            ? Icons.map_outlined
                            : Icons.edit_location_alt_outlined,
                      ),
                      label: Text(
                        controller.manualCoordinates.value
                            ? 'Use map picker'
                            : 'Enter coordinates manually',
                      ),
                    )),
              ],
            ),
            const SizedBox(height: 8),
            Obx(() {
              if (!controller.manualCoordinates.value) {
                return MarketLocationPicker(
                  position: controller.position.value,
                  onPositionChanged: controller.setPosition,
                );
              }
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: controller.latC,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true, signed: true),
                          decoration: const InputDecoration(
                            labelText: 'Latitude',
                            border: OutlineInputBorder(),
                          ),
                          // A coordinate outside the valid range would place the
                          // market pin nowhere useful on the map, so this is
                          // range-checked rather than just being a number.
                          validator: AppValidators.coordinate(
                              label: 'Latitude', min: -90, max: 90),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: controller.lngC,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true, signed: true),
                          decoration: const InputDecoration(
                            labelText: 'Longitude',
                            border: OutlineInputBorder(),
                          ),
                          validator: AppValidators.coordinate(
                              label: 'Longitude', min: -180, max: 180),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Obx(() => Text(
                          controller.position.value == null
                              ? 'No location set yet'
                              : 'Location: ${controller.position.value!.latitude.toStringAsFixed(6)}, '
                                  '${controller.position.value!.longitude.toStringAsFixed(6)}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        )),
                  ),
                ],
              );
            }),
            const SizedBox(height: 24),
            Obx(() => ElevatedButton(
                  onPressed: controller.isSaving.value ? null : controller.save,
                  child: Text(
                    controller.isSaving.value
                        ? 'Saving...'
                        : controller.isEdit
                            ? 'Update market'
                            : 'Save market',
                  ),
                )),
            const SizedBox(height: 8),
            TextButton(
              onPressed: controller.isSaving.value ? null : Get.back,
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}

