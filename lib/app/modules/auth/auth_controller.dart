import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../routes/app_routes.dart';

class AuthController extends GetxController {
  final _supabase = Supabase.instance.client;
  
  final isLoading = true.obs;
  final isLoggedIn = false.obs;
  bool _hasCheckedInitialAuth = false;

  @override
  void onInit() {
    super.onInit();
    _setupAuthListener();
    checkAuthStatus();
  }

  void _setupAuthListener() {
    _supabase.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      isLoggedIn.value = session != null;
      
      // Only navigate after initial auth check is complete
      if (_hasCheckedInitialAuth) {
        if (session != null) {
          // User is logged in, redirect to home
          Get.offAllNamed(AppRoutes.HOME);
        } else {
          // User is not logged in, redirect to login
          Get.offAllNamed(AppRoutes.LOGIN);
        }
      }
    });
  }

  Future<void> checkAuthStatus() async {
    try {
      isLoading.value = true;
      final session = _supabase.auth.currentSession;
      isLoggedIn.value = session != null;
      
      // Mark that we've completed the initial auth check
      _hasCheckedInitialAuth = true;
      
      if (session != null) {
        Get.offAllNamed(AppRoutes.HOME);
      } else {
        Get.offAllNamed(AppRoutes.LOGIN);
      }
    } catch (e) {
      print('Error checking auth status: $e');
      _hasCheckedInitialAuth = true;
      Get.offAllNamed(AppRoutes.LOGIN);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      // Don't manually navigate here, let the auth listener handle it
    } catch (e) {
      Get.snackbar('Error', 'Failed to sign out: $e');
    }
  }
}
