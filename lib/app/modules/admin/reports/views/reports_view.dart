import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/utils/helpers.dart';
import 'package:harvest_hub/app/core/widgets/state_view.dart';
import 'package:harvest_hub/app/modules/admin/reports/controllers/reports_controller.dart';
import 'package:harvest_hub/app/modules/admin/widgets/admin_drawer.dart';

class ReportsView extends GetView<ReportsController> {
  const ReportsView({super.key});

  Widget _title(String text) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 20, 4, 6),
        child: Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      );

  Widget _content() {
    final c = controller;
    final orders = c.periodOrders; // read once, reused below
    final byStatus = c.ordersByStatus(orders);
    final byMarket = c.revenueByMarket(orders);
    final farmers = c.topFarmers(orders);

    return ListView(padding: const EdgeInsets.all(12), children: [
      Wrap(spacing: 8, children: [
        for (final p in ReportsController.periods)
          ChoiceChip(
            label: Text(p == 'All' ? 'All time' : p),
            selected: c.period.value == p,
            onSelected: (_) => c.period.value = p,
          ),
      ]),
      const SizedBox(height: 4),
      const Text('Daily = today, Weekly = last 7 days, Monthly = last 30 days',
          style: TextStyle(fontSize: 12, color: Colors.grey)),
      Obx(() => Text('Showing: ${c.rangeLabel}',
          style: const TextStyle(fontSize: 12, color: Colors.grey))),
      const SizedBox(height: 10),
      Obx(() => SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: c.isExporting.value ? null : c.exportPdf,
              icon: c.isExporting.value
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.picture_as_pdf_outlined),
              label: Text(c.isExporting.value
                  ? 'Preparing PDF...'
                  : 'Export this report as PDF'),
            ),
          )),
      _title('Summary'),
      Card(child: ListTile(title: const Text('Total orders'), trailing: Text('${c.validOrdersCount(orders)}'))),
      Card(
        child: ListTile(
          title: const Text('Total revenue (excluding cancelled)'),
          trailing: Text(money(c.revenueOf(orders))),
        ),
      ),
      _title('Orders by status'),
      for (final e in byStatus.entries)
        Card(child: ListTile(title: Text(e.key), trailing: Text('${e.value}'))),
      _title('Revenue by market'),
      if (byMarket.isEmpty) const Padding(padding: EdgeInsets.all(8), child: Text('No revenue yet')),
      for (final e in byMarket.entries)
        Card(child: ListTile(title: Text(e.key), trailing: Text(money(e.value)))),
      _title('Most active farmers'),
      if (farmers.isEmpty) const Padding(padding: EdgeInsets.all(8), child: Text('No orders yet')),
      for (final e in farmers)
        Card(
          child: ListTile(
            leading: const Icon(Icons.agriculture),
            title: Text(e.key),
            trailing: Text('${e.value} orders'),
          ),
        ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        actions: [
          Obx(() => IconButton(
                tooltip: 'Export report as PDF',
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
      drawer: const AdminDrawer(),
      body: Obx(() => StateView(
            isLoading: controller.isLoading.value,
            error: controller.error.value,
            isEmpty: false,
            onRetry: controller.load,
            child: _content(),
          )),
    );
  }
}
