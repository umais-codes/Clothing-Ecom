import 'package:ecom_app/features/auth/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecom_app/app/widgets/custom_snackbar.dart';

class VendorGuard extends GetMiddleware {
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
    if (authCtrl.selectedRole.value != AuthRole.vendor) {
      AppSnackbar.warning(
        title: 'Access Restricted',
        message: 'Vendor authorization required to access this portal.',
      );
      return const RouteSettings(name: '/main-navigation');
    }
    return null;
  }
}
