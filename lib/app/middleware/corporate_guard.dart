import 'package:ecom_app/features/auth/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CorporateGuard extends GetMiddleware {
  @override
  int? get priority => 2;

  @override
  RouteSettings? redirect(String? route) {
    if (!Get.isRegistered<AuthController>()) {
      return const RouteSettings(name: '/onboarding');
    }
    final authCtrl = Get.find<AuthController>();
    if (authCtrl.currentUser == null) {
      return const RouteSettings(name: '/onboarding');
    }
    if (authCtrl.selectedRole.value != AuthRole.corporate &&
        authCtrl.selectedRole.value != AuthRole.admin) {
      Get.snackbar(
        'Access Restricted',
        'Corporate client authorization required to access this portal.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFAF9F6),
        colorText: const Color(0xFF1A1A1A),
      );
      return const RouteSettings(name: '/main-navigation');
    }
    return null;
  }
}
