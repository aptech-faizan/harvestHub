import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:harvest_hub/app/core/constants/app_constants.dart';
import 'package:harvest_hub/app/core/services/pdf_kit.dart';
import 'package:harvest_hub/app/data/models/order_model.dart';

/// Builds and shares the farmer sales report as a PDF.
///
/// The caller passes the *already filtered* figures from
/// `FarmerReportsController`, so the document can never disagree with what the
/// farmer sees on screen. This service only formats and renders.
class SalesReportPdf {
  static final _date = DateFormat('dd MMM yyyy');
  static final _dateTime = DateFormat('dd MMM yyyy, hh:mm a');

  /// Renders the report and opens the platform share sheet.
  ///
  /// Returns false when the platform provides no share/print support (some
  /// desktop targets), so the caller can surface a message rather than silently
  /// doing nothing.
  static Future<bool> share({
    required String farmerName,
    required String periodLabel,
    required String rangeLabel,
    required List<OrderModel> orders,
    required Map<String, int> byStatus,
    required Map<String, int> qtyByProduct,
    required double revenue,
  }) async {
    final bytes = await build(
      farmerName: farmerName,
      periodLabel: periodLabel,
      rangeLabel: rangeLabel,
      orders: orders,
      byStatus: byStatus,
      qtyByProduct: qtyByProduct,
      revenue: revenue,
    );
    return Printing.sharePdf(
      bytes: bytes,
      filename: 'harvesthub_sales_${periodLabel.toLowerCase()}_'
          '${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
    );
  }

  /// Renders the report to raw PDF bytes.
  static Future<Uint8List> build({
    required String farmerName,
    required String periodLabel,
    required String rangeLabel,
    required List<OrderModel> orders,
    required Map<String, int> byStatus,
    required Map<String, int> qtyByProduct,
    required double revenue,
  }) async {
    final doc = pw.Document();
    final valid =
        orders.where((o) => o.status != OrderStatus.cancelled).toList();
    final cancelled = orders.length - valid.length;
    final avgOrder = valid.isEmpty ? 0.0 : revenue / valid.length;

    // Best movers first, which reads better in a report than insertion order.
    final sold = qtyByProduct.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (_) => PdfKit.brandHeader('Sales Report'),
        footer: PdfKit.pageFooter,
        build: (_) => [
          PdfKit.titleBlock('Sales Report - $periodLabel', [
            'Farmer: $farmerName',
            'Period: $rangeLabel',
            'Generated: ${_dateTime.format(DateTime.now())}',
          ]),
          pw.SizedBox(height: 16),
          ...PdfKit.summaryRows([
            (label: 'REVENUE', value: 'Rs ${revenue.toStringAsFixed(2)}'),
            (label: 'VALID ORDERS', value: '${valid.length}'),
            (label: 'CANCELLED', value: '$cancelled'),
            (label: 'AVG ORDER', value: 'Rs ${avgOrder.toStringAsFixed(2)}'),
          ]),
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
          PdfKit.sectionTitle('Items sold'),
          if (sold.isEmpty)
            PdfKit.emptyNote('No items sold in this period.')
          else
            PdfKit.table(
              headers: const ['Product', 'Quantity sold'],
              data: [for (final e in sold) [e.key, '${e.value}']],
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
      headers: const ['Order ID', 'Date', 'Items', 'Total', 'Status'],
      data: [
        for (final o in orders)
          [
            PdfKit.shortId(o.id),
            _date.format(o.canModify ? o.createdAt ?? DateTime.now() : o.createdAt ?? DateTime.now()  ),
            '${o.items.length}',
            'Rs ${o.totalPrice.toStringAsFixed(2)}',
            OrderStatus.label(o.status),
          ],
      ],
      rightAligned: [2, 3],
    );
  }
}
