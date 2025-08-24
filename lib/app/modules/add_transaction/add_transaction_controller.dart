import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../data/services/supabase_service.dart';

class AddTransactionController extends GetxController {
  final date = DateTime.now().obs;
  final descC = TextEditingController();
  final amountC = TextEditingController();

  final debitAccountId = RxnString();
  final creditAccountId = RxnString();

  final loading = false.obs;
  final accounts = <Map<String, dynamic>>[].obs;

  final _svc = SupabaseService();

  @override
  void onReady() {
    super.onReady();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    accounts.assignAll(await _svc.getAccountsRaw());
  }

  Future<void> submit() async {
    if (descC.text.isEmpty || amountC.text.isEmpty || debitAccountId.value == null || creditAccountId.value == null) {
      Get.snackbar('Error', 'Semua kolom wajib diisi');
      return;
    }
    final amt = double.tryParse(amountC.text.replaceAll('.', '').replaceAll(',', '.')) ?? 0;
    if (amt <= 0) {
      Get.snackbar('Error', 'Nominal tidak valid');
      return;
    }
    try {
      loading.value = true;
      await _svc.createSimpleDoubleEntry(
        date: date.value,
        description: descC.text.trim(),
        debitAccountId: debitAccountId.value!,
        creditAccountId: creditAccountId.value!,
        amount: amt,
      );
      Get.snackbar('Sukses', 'Transaksi berhasil disimpan');
      descC.clear();
      amountC.clear();
      debitAccountId.value = null;
      creditAccountId.value = null;
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      loading.value = false;
    }
  }

  String formatDate(DateTime d) => DateFormat('dd MMM yyyy').format(d);

  @override
  void onClose() {
    descC.dispose();
    amountC.dispose();
    super.onClose();
  }
}
