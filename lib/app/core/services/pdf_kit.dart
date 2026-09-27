import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Shared building blocks for the PDF reports.
///
/// Both the farmer sales report and the admin platform report render the same
/// chrome (branding header, page footer, summary tiles, data tables). Keeping
/// that in one place means a layout change lands in every report at once.
abstract class PdfKit {
  /// Branding row repeated at the top of every page.
  static pw.Widget brandHeader(String documentTitle) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(width: 1)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('HarvestHub',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.Text(documentTitle,
              style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
        ],
      ),
    );
  }

  /// "Page n of m" footer.
  static pw.Widget pageFooter(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 8),
      child: pw.Text('Page ${context.pageNumber} of ${context.pagesCount}',
          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
    );
  }

  /// Report title followed by free-form detail lines.
  static pw.Widget titleBlock(String title, List<String> details) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title,
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 6),
        for (final line in details) pw.Text(line),
      ],
    );
  }

  /// A single value in the summary strip.
  static pw.Widget summaryTile(String label, String value) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(10),
        margin: const pw.EdgeInsets.only(right: 8),
        decoration: pw.BoxDecoration(
          color: PdfColors.grey100,
          borderRadius: pw.BorderRadius.circular(4),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(label,
                style:
                    const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
            pw.SizedBox(height: 4),
            pw.Text(value,
                style: pw.TextStyle(
                    fontSize: 14, fontWeight: pw.FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  /// Row of summary tiles. Tiles are laid out in rows of [perRow].
  static List<pw.Widget> summaryRows(
    List<({String label, String value})> tiles, {
    int perRow = 4,
  }) {
    final rows = <pw.Widget>[];
    for (var i = 0; i < tiles.length; i += perRow) {
      final chunk = tiles.skip(i).take(perRow).toList();
      rows.add(pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          for (final t in chunk) summaryTile(t.label, t.value),
        ],
      ));
      rows.add(pw.SizedBox(height: 8));
    }
    return rows;
  }

  static pw.Widget sectionTitle(String text) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 6, top: 4),
      child: pw.Text(text,
          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
    );
  }

  /// Styled two-or-more column table.
  ///
  /// [rightAligned] lists column indexes that hold numbers.
  static pw.Widget table({
    required List<String> headers,
    required List<List<String>> data,
    List<int> rightAligned = const [],
  }) {
    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
      headerStyle: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
      cellStyle: const pw.TextStyle(fontSize: 10),
      border: const pw.TableBorder(
        horizontalInside: pw.BorderSide(width: 0.5, color: PdfColors.grey400),
        bottom: pw.BorderSide(width: 0.5, color: PdfColors.grey400),
      ),
      cellAlignments: {
        for (final i in rightAligned) i: pw.Alignment.centerRight,
      },
    );
  }

  /// Shown in place of a table when there is nothing to list.
  static pw.Widget emptyNote(String text) =>
      pw.Text(text, style: const pw.TextStyle(color: PdfColors.grey700));

  /// Firestore auto-ids are long; a short prefix identifies a row.
  static String shortId(String id) =>
      id.length <= 8 ? id : id.substring(0, 8).toUpperCase();
}
