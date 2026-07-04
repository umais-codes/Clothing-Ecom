import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecom_app/features/auth/controllers/auth_controller.dart';
import '../controllers/profile_controller.dart';
import 'shopper_profile_view.dart';
import 'vendor_profile_view.dart';
import 'corporate_profile_view.dart';
import 'admin_profile_view.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<ProfileController>()) {
      Get.put(ProfileController());
    }

    return Obx(() {
      final role = controller.currentRole;
      switch (role) {
        case AuthRole.shopper:
          return const ShopperProfileView();
        case AuthRole.vendor:
          return const VendorProfileView();
        case AuthRole.corporate:
          return const CorporateProfileView();
        case AuthRole.admin:
          return const AdminProfileView();
      }
    });
  }
}
