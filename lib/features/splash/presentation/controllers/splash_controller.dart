import 'dart:async';
import 'package:get/get.dart';

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

  void _navigateToNextScreen() {
    Get.offAllNamed('/onboarding');
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
