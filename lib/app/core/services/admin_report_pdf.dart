import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:harvest_hub/app/core/constants/app_constants.dart';
import 'package:harvest_hub/app/core/services/pdf_kit.dart';
import 'package:harvest_hub/app/modules/admin/models/order_model.dart';

/// Builds and shares the admin platform report as a PDF.
///
/// Covers the figures the SRS asks an administrator for: total orders, a
/// revenue summary across markets, and the most active farmers -- for the
/// selected Daily / Weekly / Monthly / All period.
///
/// Every figure is passed in already computed by `ReportsController`, so the
/// PDF and the on-screen report can never disagree.
class AdminReportPdf {
  static final _date = DateFormat('dd MMM yyyy');
  static final _dateTime = DateFormat('dd MMM yyyy, hh:mm a');

  static Future<bool> share({
    required String periodLabel,
    required String rangeLabel,
    required List<OrderModel> orders,
    required Map<String, int> byStatus,
    required Map<String, double> revenueByMarket,
    required List<MapEntry<String, int>> topFarmers,
    required double revenue,
  }) async {
    final bytes = await build(
      periodLabel: periodLabel,
      rangeLabel: rangeLabel,
      orders: orders,
      byStatus: byStatus,
      revenueByMarket: revenueByMarket,
      topFarmers: topFarmers,
      revenue: revenue,
    );
    return Printing.sharePdf(
      bytes: bytes,
      filename: 'harvesthub_platform_report_${periodLabel.toLowerCase()}_'
          '${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
    );
  }

  static Future<Uint8List> build({
    required String periodLabel,
    required String rangeLabel,
    required List<OrderModel> orders,
    required Map<String, int> byStatus,
    required Map<String, double> revenueByMarket,
    required List<MapEntry<String, int>> topFarmers,
    required double revenue,
  }) async {
    final doc = pw.Document();
    final valid =
        orders.where((o) => o.status != OrderStatus.cancelled).toList();
    final cancelled = orders.length - valid.length;
    final avgOrder = valid.isEmpty ? 0.0 : revenue / valid.length;

    // Highest revenue first so the headline market sits at the top.
    final markets = revenueByMarket.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (_) => PdfKit.brandHeader('Platform Report'),
        footer: PdfKit.pageFooter,
        build: (_) => [
          PdfKit.titleBlock('Platform Report - $periodLabel', [
            'Period: $rangeLabel',
            'Markets with revenue: ${markets.length}',
            'Generated: ${_dateTime.format(DateTime.now())}',
          ]),
          pw.SizedBox(height: 16),
          ...PdfKit.summaryRows([
            (label: 'TOTAL REVENUE', value: 'Rs ${revenue.toStringAsFixed(2)}'),
            (label: 'VALID ORDERS', value: '${valid.length}'),
            (label: 'CANCELLED', value: '$cancelled'),
            (label: 'AVG ORDER', value: 'Rs ${avgOrder.toStringAsFixed(2)}'),
          ]),

          PdfKit.sectionTitle('Revenue by market'),
          if (markets.isEmpty)
            PdfKit.emptyNote('No revenue recorded in this period.')
          else
            PdfKit.table(
              headers: const ['Market', 'Revenue', 'Share'],
              data: [
                for (final e in markets)
                  [
                    e.key,
                    'Rs ${e.value.toStringAsFixed(2)}',
                    revenue <= 0
                        ? '-'
                        : '${((e.value / revenue) * 100).toStringAsFixed(1)}%',
                  ],
              ],
              rightAligned: [1, 2],
            ),

          pw.SizedBox(height: 14),
          PdfKit.sectionTitle('Most active farmers'),
          if (topFarmers.isEmpty)
            PdfKit.emptyNote('No farmer orders in this period.')
          else
            PdfKit.table(
              headers: const ['#', 'Farmer', 'Orders'],
              data: [
                for (var i = 0; i < topFarmers.length; i++)
                  ['${i + 1}', topFarmers[i].key, '${topFarmers[i].value}'],
              ],
              rightAligned: [0, 2],
            ),

          pw.SizedBox(height: 14),
          PdfKit.sectionTitle('Orders by status'),
          PdfKit.table(
            headers: const ['Status', 'Orders'],
            data: [
              for (final s in OrderStatus.all)
                [OrderStatus.label(s), '${byStatus[s] ?? 0}'],
            ],
            rightAligned: [1],
          ),

          pw.SizedBox(height: 14),
          PdfKit.sectionTitle('Order details (${orders.length})'),
          if (orders.isEmpty)
            PdfKit.emptyNote('No orders in this period.')
          else
            _ordersTable(orders),
        ],
      ),
    );

    return doc.save();
  }

  static pw.Widget _ordersTable(List<OrderModel> orders) {
    return PdfKit.table(
      headers: const ['Order ID', 'Date', 'Farmer', 'Total', 'Status'],
      data: [
        for (final o in orders)
          [
            PdfKit.shortId(o.id),
            _date.format(o.createdAt ?? DateTime.now()),
            o.farmerName.isEmpty ? '-' : o.farmerName,
            'Rs ${o.totalPrice.toStringAsFixed(2)}',
            OrderStatus.label(o.status),
          ],
      ],
      rightAligned: [3],
    );
  }
}
