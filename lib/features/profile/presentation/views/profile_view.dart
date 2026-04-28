import 'package:ecom_app/app/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/profile_controller.dart';
import '../widgets/fit_profile_card.dart';
import '../widgets/profile_header.dart';
import '../widgets/quick_action_grid.dart';
import '../widgets/account_menu_section.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<ProfileController>()) {
      Get.put(ProfileController());
    }

    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(
          'My Account',
          style: GoogleFonts.outfit(
            fontSize: size.width * 0.05,
            fontWeight: .w600,
            color: AppColors.charcoal,
          ),
        ),
        backgroundColor: AppColors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: .symmetric(
          horizontal: size.width * 0.04,
          vertical: size.height * 0.02,
        ),
        child: Column(
          crossAxisAlignment: .center,
          children: [
            const ProfileHeader(),
            SizedBox(height: size.height * 0.02),
            const FitProfileCard(),
            SizedBox(height: size.height * 0.02),
            const QuickActionGrid(),
            SizedBox(height: size.height * 0.02),
            const AccountMenuSection(),
            SizedBox(height: size.height * 0.02),
            CustomButton(
              text: 'Log Out',
              onPressed: controller.logout,
              icon: Icons.logout_rounded,
              buttonColor: AppColors.error.withOpacity(0.1),
              textColor: AppColors.error,
            ),
            SizedBox(height: size.height * 0.1),
          ],
        ),
      ),
    );
  }
}
