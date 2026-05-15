import 'package:ecom_app/features/auth/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminGuard extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    final authCtrl = Get.find<AuthController>();
    if (authCtrl.selectedRole.value != AuthRole.admin) {
      return const RouteSettings(name: '/onboarding');
    }
    return null;
  }
}
