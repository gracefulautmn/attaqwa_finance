import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/services/supabase_service.dart';
import '../../routes/app_routes.dart';

class LoginController extends GetxController {
  final emailC = TextEditingController();
  final passC = TextEditingController();
  final loading = false.obs;

  final _svc = SupabaseService();

  Future<void> login() async {
    if (emailC.text.isEmpty || passC.text.isEmpty) {
      Get.snackbar('Error', 'Semua kolom wajib diisi');
      return;
    }
    try {
      loading.value = true;
      await _svc.signInWithEmail(emailC.text.trim(), passC.text);
      Get.offAllNamed(AppRoutes.DASHBOARD);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      loading.value = false;
    }
  }

  @override
  void onClose() {
    emailC.dispose();
    passC.dispose();
    super.onClose();
  }
}
