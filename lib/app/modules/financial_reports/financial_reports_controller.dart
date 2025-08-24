import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/services/pdf_export_service.dart';
import '../../data/services/supabase_service.dart';

class FinancialReportsController extends GetxController {
  final start = DateTime.now().subtract(const Duration(days: 30)).obs;
  final end = DateTime.now().obs;

  final _svc = SupabaseService();
  final _pdf = PdfExportService();

  final loading = false.obs;

  Future<void> generateGeneralJournal() async {
    try {
      loading.value = true;
      final rows = await _svc.fetchGeneralJournal(start: start.value, end: end.value);
      final file = await _pdf.createGeneralJournalPdf(rows);
      await Share.shareXFiles([XFile(file.path)], text: 'Jurnal Umum');
    } finally {
      loading.value = false;
    }
  }

  Future<void> generateGeneralLedger({required String accountId, required Map<String, dynamic> accountInfo}) async {
    try {
      loading.value = true;
      final rows = await _svc.getGeneralLedger(accountId: accountId, start: start.value, end: end.value);
      final file = await _pdf.createGeneralLedgerPdf(accountInfo, rows);
      await Share.shareXFiles([XFile(file.path)], text: 'Buku Besar');
    } finally {
      loading.value = false;
    }
  }

  Future<void> generateActivityStatement() async {
    try {
      loading.value = true;
      final data = await _svc.getActivityStatement(start: start.value, end: end.value);
      final file = await _pdf.createActivityStatementPdf(data);
      await Share.shareXFiles([XFile(file.path)], text: 'Laporan Aktivitas');
    } finally {
      loading.value = false;
    }
  }
}
