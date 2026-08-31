import 'package:ecom_app/features/auth/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthGuard extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    if (!Get.isRegistered<AuthController>()) {
      return const RouteSettings(name: '/onboarding');
    }
    final authCtrl = Get.find<AuthController>();
    if (authCtrl.currentUser == null) {
      return const RouteSettings(name: '/onboarding');
    }
    return null;
  }
}
