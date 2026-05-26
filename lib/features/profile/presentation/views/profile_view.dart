import 'package:ecom_app/app/utils/responsive.dart';
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
import '../widgets/perspective_switcher.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<ProfileController>()) {
      Get.put(ProfileController());
    }

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(
          'My Account',
          style: GoogleFonts.outfit(
            fontSize: context.wp(5),
            fontWeight: FontWeight.w600,
            color: AppColors.charcoal,
          ),
        ),
        backgroundColor: AppColors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: context.wp(4),
          vertical: context.hp(2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const ProfileHeader(),
            SizedBox(height: context.hp(2)),
            const FitProfileCard(),
            SizedBox(height: context.hp(2)),
            const QuickActionGrid(),
            SizedBox(height: context.hp(2)),
            const AccountMenuSection(),
            SizedBox(height: context.hp(2)),
            const PerspectiveSwitcher(),
            SizedBox(height: context.hp(2)),
            CustomButton(
              variant: ButtonVariant.secondary,
              text: 'Log Out',
              onPressed: controller.logout,
              width: double.infinity,
              icon: Icons.logout_rounded,
              buttonColor: AppColors.error.withValues(alpha: 0.9),
              textColor: AppColors.white,
            ),
            SizedBox(height: context.hp(12)),
          ],
        ),
      ),
    );
  }
}
