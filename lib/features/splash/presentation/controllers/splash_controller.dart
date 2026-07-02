import 'dart:async';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:ecom_app/features/auth/domain/repositories/auth_repository.dart';
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
      final authRepo = Get.find<AuthRepository>();
      final user = authRepo.currentUser;
      if (user != null) {
        final box = Hive.box('settings');
        final loginTimeMs = box.get('login_time') as int?;
        bool isSessionValid = true;

        if (loginTimeMs != null) {
          final loginTime = DateTime.fromMillisecondsSinceEpoch(loginTimeMs);
          final diff = DateTime.now().difference(loginTime).inDays;
          if (diff >= 7) {
            isSessionValid = false;
          }
        } else {
          // Initialize for existing active sessions to prevent abrupt logout
          box.put('login_time', DateTime.now().millisecondsSinceEpoch);
        }

        if (isSessionValid) {
          final data = await authRepo.getProfile(user.id);
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
        } else {
          // Session expired (7 days or more)
          await authRepo.signOut();
          box.delete('login_time');
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
