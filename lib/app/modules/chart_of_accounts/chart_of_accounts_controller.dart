import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/services/supabase_service.dart';

class ChartOfAccountsController extends GetxController {
  final _svc = SupabaseService();
  final items = <Map<String, dynamic>>[].obs;
  final loading = false.obs;

  @override
  void onReady() {
    super.onReady();
    refreshList();
  }

  Future<void> refreshList() async {
    loading.value = true;
    items.assignAll(await _svc.getAccountsRaw());
    loading.value = false;
  }

  Future<void> createOrEdit({
    String? id,
    required String code,
    required String name,
    required String type,
    required String normalBalance,
  }) async {
    final payload = {
      'account_code': code,
      'account_name': name,
      'account_type': type,
      'normal_balance': normalBalance,
    };
    if (id == null) {
      await _svc.insertAccount(payload);
    } else {
      await _svc.updateAccount(id, payload);
    }
    await refreshList();
    Get.back();
    Get.snackbar('Sukses', 'Data akun tersimpan');
  }

  Future<void> delete(String id) async {
    await _svc.deleteAccount(id);
    await refreshList();
  }
}
