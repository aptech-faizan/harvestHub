import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/utils/helpers.dart';
import 'package:harvest_hub/app/core/widgets/state_view.dart';
import 'package:harvest_hub/app/modules/farmer/reports/controllers/farmer_reports_controller.dart';
import 'package:harvest_hub/app/modules/farmer/utils/farmer_order_status.dart';

class FarmerReportsView extends GetView<FarmerReportsController> {
  const FarmerReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales report'),
        actions: [
          Obx(() => IconButton(
                tooltip: 'Export as PDF',
                onPressed: controller.isExporting.value ? null : controller.exportPdf,
                icon: controller.isExporting.value
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.picture_as_pdf_outlined),
              )),
          IconButton(onPressed: controller.load, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: Obx(() => StateView(
            isLoading: controller.isLoading.value,
            error: controller.error.value,
            isEmpty: false,
            onRetry: controller.load,
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                Wrap(
                  spacing: 8,
                  children: [
                    for (final p in FarmerReportsController.periods)
                      ChoiceChip(
                        label: Text(p == 'All' ? 'All time' : p),
                        selected: controller.period.value == p,
                        onSelected: (_) => controller.period.value = p,
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Daily = today, Weekly = last 7 days, Monthly = last 30 days',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Obx(() => Text(
                      'Showing: ${controller.rangeLabel}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    )),
                const SizedBox(height: 12),
                Obx(() => SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: controller.isExporting.value
                            ? null
                            : controller.exportPdf,
                        icon: controller.isExporting.value
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.picture_as_pdf_outlined),
                        label: Text(controller.isExporting.value
                            ? 'Preparing PDF...'
                            : 'Export this report as PDF'),
                      ),
                    )),
                const SizedBox(height: 16),
                const Text('Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Card(
                  child: ListTile(
                    title: const Text('Orders (excluding cancelled)'),
                    trailing: Text('${controller.valid.length}'),
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: ListTile(
                    title: const Text('Revenue (excluding cancelled)'),
                    trailing: Text(money(controller.revenue)),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Orders by status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                for (final e in controller.byStatus.entries)
                  Card(
                    child: ListTile(
                      title: Text(orderStatusLabel(e.key)),
                      trailing: Text('${e.value}'),
                    ),
                  ),
                const SizedBox(height: 16),
                const Text('Items sold', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                if (controller.qtyByProduct.isEmpty)
                  const Padding(padding: EdgeInsets.all(8), child: Text('No sales in this period')),
                for (final e in controller.qtyByProduct.entries)
                  Card(
                    child: ListTile(
                      title: Text(e.key),
                      trailing: Text('${e.value}'),
                    ),
                  ),
              ],
            ),
          )),
    );
  }
}
