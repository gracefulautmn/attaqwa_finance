import 'package:get/get.dart';
import '../../data/services/supabase_service.dart';
import '../../routes/app_routes.dart';

class SplashController extends GetxController {
  final SupabaseService _svc = SupabaseService();

  final isLoading = true.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  @override
  void onReady() {
    super.onReady();
    _checkConnectionAndNavigate();
  }

  Future<void> _checkConnectionAndNavigate() async {
    try {
      await _svc.checkConnection();
      await Future.delayed(const Duration(seconds: 2));
      Get.offAllNamed(AppRoutes.LOGIN);
    } catch (e) {
      isLoading.value = false;
      hasError.value = true;
      errorMessage.value = 'Gagal terhubung ke server. Periksa koneksi internet Anda.';
    }
  }

  Future<void> retryConnection() async {
    isLoading.value = true;
    hasError.value = false;
    await _checkConnectionAndNavigate();
  }
}
