import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:attaqwa_finance/models/transaction.dart';
import 'package:attaqwa_finance/models/financial_summary.dart';
import 'package:attaqwa_finance/utils/currency_utils.dart' as currency_utils;

class PDFGenerator {
  static Future<File> generateFinancialReport({
    required List<Transaction> transactions,
    required FinancialSummary summary,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final pdf = pw.Document();
  
    final pemasukan = transactions.where((t) => t.type == 'Pemasukan').toList();
    final pengeluaran = transactions.where((t) => t.type == 'Pengeluaran').toList();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'LAPORAN KEUANGAN',
                    style: const pw.TextStyle(
                      fontSize: 24,
                    ),
                  ),
                  pw.Text(
                    'DKM Masjid Attaqwa',
                    style: const pw.TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    'Periode: ${_formatDateSimple(startDate)} - ${_formatDateSimple(endDate)}',
                    style: const pw.TextStyle(fontSize: 14),
                  ),
                  pw.Divider(),
                ],
              ),
            ),

            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(width: 1),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'RINGKASAN KEUANGAN',
                    style: const pw.TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Total Pemasukan:'),
                      pw.Text(
                        currency_utils.CurrencyUtils.format(summary.totalPemasukan),
                        style: const pw.TextStyle(),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 5),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Total Pengeluaran:'),
                      pw.Text(
                        currency_utils.CurrencyUtils.format(summary.totalPengeluaran),
                        style: const pw.TextStyle(),
                      ),
                    ],
                  ),
                  pw.Divider(),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Saldo Akhir:',
                        style: const pw.TextStyle(),
                      ),
                      pw.Text(
                        currency_utils.CurrencyUtils.format(summary.saldoAkhir),
                        style: const pw.TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            if (pemasukan.isNotEmpty) ...[
              pw.Text(
                'PEMASUKAN',
                style: const pw.TextStyle(
                  fontSize: 16,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Table(
                border: pw.TableBorder.all(width: 1),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey300,
                    ),
                    children: [
                      _buildTableCell('Tanggal', isHeader: true),
                      _buildTableCell('Kategori', isHeader: true),
                      _buildTableCell('Deskripsi', isHeader: true),
                      _buildTableCell('Jumlah', isHeader: true),
                    ],
                  ),
                  ...pemasukan.map(
                    (transaction) => pw.TableRow(
                      children: [
                        _buildTableCell(_formatDateSimple(transaction.date)),
                        _buildTableCell(transaction.categoryName ?? '-'),
                        _buildTableCell(transaction.description ?? '-'),
                        _buildTableCell(currency_utils.CurrencyUtils.format(transaction.amount)),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
            ],

            if (pengeluaran.isNotEmpty) ...[
              pw.Text(
                'PENGELUARAN',
                style: const pw.TextStyle(
                  fontSize: 16,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Table(
                border: pw.TableBorder.all(width: 1),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey300,
                    ),
                    children: [
                      _buildTableCell('Tanggal', isHeader: true),
                      _buildTableCell('Kategori', isHeader: true),
                      _buildTableCell('Deskripsi', isHeader: true),
                      _buildTableCell('Jumlah', isHeader: true),
                    ],
                  ),
                  ...pengeluaran.map(
                    (transaction) => pw.TableRow(
                      children: [
                        _buildTableCell(_formatDateSimple(transaction.date)),
                        _buildTableCell(transaction.categoryName ?? '-'),
                        _buildTableCell(transaction.description ?? '-'),
                        _buildTableCell(currency_utils.CurrencyUtils.format(transaction.amount)),
                      ],
                    ),
                  ),
                ],
              ),
            ],

            pw.SizedBox(height: 30),
            pw.Text(
              'Laporan dibuat pada: ${_formatDateSimple(DateTime.now())}',
              style: const pw.TextStyle(fontSize: 10),
            ),
          ];
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/laporan_keuangan_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  static pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 12 : 10,
        ),
      ),
    );
  }

  static String _formatDateSimple(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  static Future<void> shareReport(File reportFile) async {
    await Share.shareXFiles(
      [XFile(reportFile.path)],
      text: 'Laporan Keuangan DKM Masjid Attaqwa',
    );
  }
}
