import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:attaqwa_finance/models/transaction.dart';
import 'package:attaqwa_finance/models/financial_summary.dart';
import 'package:attaqwa_finance/utils/currency_utils.dart' as currency_utils;

class SimplePDFGenerator {
  static Future<String> generateSimpleReport({
    required List<Transaction> transactions,
    required FinancialSummary summary,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // Request storage permission
      await _requestStoragePermission();
      
      final pdf = pw.Document();

      // Group transactions by type
      final pemasukan = transactions.where((t) => t.type == 'Pemasukan').toList();
      final pengeluaran = transactions.where((t) => t.type == 'Pengeluaran').toList();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return [
              // Header
              pw.Text(
                'LAPORAN KEUANGAN',
                style: const pw.TextStyle(fontSize: 24),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'DKM Masjid Attaqwa',
                style: const pw.TextStyle(fontSize: 18),
              ),
              pw.SizedBox(height: 10),
              pw.Text('Periode: ${_formatDate(startDate)} - ${_formatDate(endDate)}'),
              pw.Divider(),
              pw.SizedBox(height: 20),
              
              // Summary
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(width: 1),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('RINGKASAN KEUANGAN', style: const pw.TextStyle(fontSize: 16)),
                    pw.SizedBox(height: 10),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Total Pemasukan:'),
                        pw.Text(currency_utils.CurrencyUtils.format(summary.totalPemasukan)),
                      ],
                    ),
                    pw.SizedBox(height: 5),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Total Pengeluaran:'),
                        pw.Text(currency_utils.CurrencyUtils.format(summary.totalPengeluaran)),
                      ],
                    ),
                    pw.Divider(),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Saldo Akhir:'),
                        pw.Text(
                          currency_utils.CurrencyUtils.format(summary.saldoAkhir),
                          style: const pw.TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              
              // Pemasukan Section
              if (pemasukan.isNotEmpty) ...[
                pw.Text('PEMASUKAN', style: const pw.TextStyle(fontSize: 16)),
                pw.SizedBox(height: 10),
                pw.Table(
                  border: pw.TableBorder.all(width: 1),
                  children: [
                    // Header
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                      children: [
                        _buildTableCell('Tanggal'),
                        _buildTableCell('Kategori'),
                        _buildTableCell('Deskripsi'),
                        _buildTableCell('Jumlah'),
                      ],
                    ),
                    // Data rows
                    ...pemasukan.map(
                      (transaction) => pw.TableRow(
                        children: [
                          _buildTableCell(_formatDate(transaction.date)),
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
              
              // Pengeluaran Section
              if (pengeluaran.isNotEmpty) ...[
                pw.Text('PENGELUARAN', style: const pw.TextStyle(fontSize: 16)),
                pw.SizedBox(height: 10),
                pw.Table(
                  border: pw.TableBorder.all(width: 1),
                  children: [
                    // Header
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                      children: [
                        _buildTableCell('Tanggal'),
                        _buildTableCell('Kategori'),
                        _buildTableCell('Deskripsi'),
                        _buildTableCell('Jumlah'),
                      ],
                    ),
                    // Data rows
                    ...pengeluaran.map(
                      (transaction) => pw.TableRow(
                        children: [
                          _buildTableCell(_formatDate(transaction.date)),
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
              
              // Footer
              pw.SizedBox(height: 30),
              pw.Text(
                'Laporan dibuat pada: ${_formatDate(DateTime.now())}',
                style: const pw.TextStyle(fontSize: 10),
              ),
              pw.Text(
                'Total ${transactions.length} transaksi',
                style: const pw.TextStyle(fontSize: 10),
              ),
            ];
          },
        ),
      );

      // Save to Downloads directory
      final fileName = 'Laporan_Keuangan_${_formatDateForFile(startDate)}_${_formatDateForFile(endDate)}.pdf';
      final file = await _saveToDownloads(await pdf.save(), fileName);

      return file.path;
    } catch (e) {
      throw Exception('Gagal membuat PDF: $e');
    }
  }

  static Future<void> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      await Permission.storage.request();
      await Permission.manageExternalStorage.request();
    }
  }

  static Future<File> _saveToDownloads(List<int> bytes, String fileName) async {
    late Directory directory;
    
    if (Platform.isAndroid) {
      // For Android, try to save to Downloads folder
      directory = Directory('/storage/emulated/0/Download');
      if (!await directory.exists()) {
        // Fallback to external storage
        directory = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
      }
    } else {
      // For iOS or other platforms
      directory = await getApplicationDocumentsDirectory();
    }

    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(bytes);
    return file;
  }

  static pw.Widget _buildTableCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: const pw.TextStyle(fontSize: 10),
      ),
    );
  }

  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  static String _formatDateForFile(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}_${date.month.toString().padLeft(2, '0')}_${date.year}';
  }
}
