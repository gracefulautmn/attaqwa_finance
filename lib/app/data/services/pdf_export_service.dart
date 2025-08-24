import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfExportService {
  Future<File> createGeneralJournalPdf(List<Map<String, dynamic>> rows) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        build: (ctx) => [
          pw.Text('Jurnal Umum', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Table.fromTextArray(
            headers: ['Tanggal', 'Deskripsi', 'Akun', 'Debet', 'Kredit'],
            data: rows.map((r) {
              final tDate = (r['transactions']?['transaction_date'] ?? '').toString();
              final desc = (r['transactions']?['description'] ?? '').toString();
              final acc = '${r['accounts']?['account_code']} - ${r['accounts']?['account_name']}';
              final debit = r['debit'].toString();
              final credit = r['credit'].toString();
              return [tDate, desc, acc, debit, credit];
            }).toList(),
          ),
        ],
      ),
    );
    final out = await _save(pdf, 'jurnal-umum');
    return out;
  }

  Future<File> createGeneralLedgerPdf(Map<String, dynamic> account, List<Map<String, dynamic>> rows) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        build: (ctx) => [
          pw.Text('Buku Besar - ${account['account_code']} ${account['account_name']}',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Table.fromTextArray(
            headers: ['Tanggal', 'Deskripsi', 'Debet', 'Kredit', 'Saldo'],
            data: rows.map((r) => [
              r['transaction_date'].toString(),
              r['description'].toString(),
              r['debit'].toString(),
              r['credit'].toString(),
              r['running_balance'].toString(),
            ]).toList(),
          ),
        ],
      ),
    );
    final out = await _save(pdf, 'buku-besar-${account['account_code']}');
    return out;
  }

  Future<File> createActivityStatementPdf(Map<String, dynamic> data) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        build: (ctx) => [
          pw.Text('Laporan Aktivitas', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 12),
          pw.Table.fromTextArray(
            headers: ['Item', 'Jumlah'],
            data: [
              ['Pendapatan', data['total_income'].toString()],
              ['Beban', data['total_expense'].toString()],
              ['Surplus / Defisit', data['surplus_deficit'].toString()],
            ],
          ),
        ],
      ),
    );
    final out = await _save(pdf, 'laporan-aktivitas');
    return out;
  }

  Future<File> _save(pw.Document doc, String baseName) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$baseName.pdf');
    await file.writeAsBytes(await doc.save());
    return file;
  }
}
