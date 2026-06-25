import 'dart:async';
import 'package:get/get.dart';
import 'package:ecom_app/core/supabase/supabase_client.dart';
import 'package:ecom_app/features/auth/controllers/auth_controller.dart';

class SplashController extends GetxController {
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    _startInitTimer();
  }

  void _startInitTimer() {
    _timer = Timer(const Duration(milliseconds: 2500), () {
      _navigateToNextScreen();
    });
  }

  Future<void> _navigateToNextScreen() async {
    try {
      final supabase = Get.find<SupabaseService>().client;
      final user = supabase.auth.currentUser;
      if (user != null) {
        final data = await supabase
            .from('profiles')
            .select()
            .eq('id', user.id)
            .maybeSingle();
        if (data != null) {
          final authCtrl = Get.find<AuthController>();
          final roleStr = data['role']?.toString();
          if (roleStr == 'shopper') {
            authCtrl.selectedRole.value = AuthRole.shopper;
            Get.offAllNamed('/main-navigation');
            return;
          } else if (roleStr == 'vendor') {
            authCtrl.selectedRole.value = AuthRole.vendor;
            Get.offAllNamed('/main-navigation');
            return;
          } else if (roleStr == 'corporate') {
            authCtrl.selectedRole.value = AuthRole.corporate;
            Get.offAllNamed('/main-navigation');
            return;
          } else if (roleStr == 'admin') {
            authCtrl.selectedRole.value = AuthRole.admin;
            Get.offAllNamed('/admin-panel');
            return;
          }
        }
      }
    } catch (e) {
      Get.printInfo(info: 'Splash session verification failed: $e');
    }
    Get.offAllNamed('/onboarding');
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
