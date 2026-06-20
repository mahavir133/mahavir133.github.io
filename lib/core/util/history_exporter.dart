import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import '../../domain/entity/history_item.dart';

class HistoryExporter {
  /// Exports calculation history list to a CSV spreadsheet.
  /// Returns the absolute path of the generated file.
  static Future<String> exportToCSV(List<HistoryItem> items) async {
    final csvRows = <List<String>>[
      ['Timestamp', 'Module', 'Expression', 'Result', 'Bookmarked', 'Notes']
    ];

    for (final item in items) {
      csvRows.add([
        item.timestamp.toIso8601String(),
        item.module,
        item.expression,
        item.result,
        item.isBookmarked ? 'Yes' : 'No',
        item.note ?? '',
      ]);
    }

    final csvString = const ListToCsvConverter().convert(csvRows);

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/OmniCalc_History_${DateTime.now().millisecondsSinceEpoch}.csv');
    await file.writeAsString(csvString);

    return file.path;
  }

  /// Exports calculation history list to a styled PDF file.
  /// Returns the absolute path of the generated file.
  static Future<String> exportToPDF(List<HistoryItem> items) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'OmniCalc - Calculations History Report',
                    style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    DateTime.now().toLocal().toString().substring(0, 16),
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 16),
            pw.TableHelper.fromTextArray(
              headers: ['Timestamp', 'Module', 'Expression', 'Result', 'Notes'],
              data: items.map((item) {
                return [
                  item.timestamp.toLocal().toString().substring(0, 16),
                  item.module.toUpperCase(),
                  item.expression,
                  item.result,
                  item.note ?? '',
                ];
              }).toList(),
              border: pw.TableBorder.all(width: 0.5, color: PdfColors.grey),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.deepPurple),
              cellHeight: 30,
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.center,
                2: pw.Alignment.centerLeft,
                3: pw.Alignment.centerRight,
                4: pw.Alignment.centerLeft,
              },
            ),
          ];
        },
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/OmniCalc_Report_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());

    return file.path;
  }
}
