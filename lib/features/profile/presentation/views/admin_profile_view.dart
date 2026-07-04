import 'package:ecom_app/app/utils/responsive.dart';
import 'package:ecom_app/app/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/app/widgets/custom_app_bar.dart';
import '../controllers/profile_controller.dart';
import '../widgets/profile_header.dart';
import '../widgets/account_menu_section.dart';
import '../widgets/perspective_switcher.dart';

class AdminProfileView extends GetView<ProfileController> {
  const AdminProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final h = context.screenHeight;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: const CustomAppBar(
        title: 'Super Admin Dashboard',
        showBackButton: false,
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
            SizedBox(height: h * 0.025),

            // Admin Status Overview
            _buildAdminStatsGrid(context),
            SizedBox(height: h * 0.025),

            // System Admin Operations
            _buildAdminControls(context),
            SizedBox(height: h * 0.025),

            const AccountMenuSection(),
            SizedBox(height: h * 0.025),

            const PerspectiveSwitcher(),
            SizedBox(height: h * 0.025),

            CustomButton(
              variant: ButtonVariant.secondary,
              text: 'Log Out',
              onPressed: controller.logout,
              width: double.infinity,
              icon: Icons.logout_rounded,
              buttonColor: AppColors.error.withValues(alpha: 0.9),
              textColor: AppColors.white,
            ),
            SizedBox(height: h * 0.1),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminStatsGrid(BuildContext context) {
    final w = context.screenWidth;
    final cardWidth = (w * 0.92 - 16) / 3;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatCard(context, cardWidth, '148', 'Total Users', Colors.deepPurple.shade700),
        _buildStatCard(context, cardWidth, '3', 'Active KYC Queues', Colors.amber.shade800),
        _buildStatCard(context, cardWidth, '99.9%', 'System Uptime', AppColors.success),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, double width, String value, String label, Color accentColor) {
    return Container(
      width: width,
      padding: EdgeInsets.symmetric(vertical: context.hp(1.4), horizontal: context.wp(0.8)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.greyLight, width: 1),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: context.sp(20),
              fontWeight: FontWeight.w800,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: context.sp(10),
              fontWeight: FontWeight.bold,
              color: AppColors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAdminControls(BuildContext context) {
    final w = context.screenWidth;
    final cardWidth = (w * 0.92 - 16) / 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Administrative Controls',
          style: GoogleFonts.outfit(
            fontSize: context.sp(15),
            fontWeight: FontWeight.bold,
            color: AppColors.charcoal,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildOpCard(
              context,
              cardWidth,
              Icons.admin_panel_settings_rounded,
              'Approve KYC Vendors',
              'Review vendor applications',
              () => Get.toNamed('/admin-panel'),
            ),
            _buildOpCard(
              context,
              cardWidth,
              Icons.analytics_outlined,
              'System Diagnostics',
              'Inspect logs and health stats',
              () {
                Get.snackbar(
                  'Diagnostics Checked',
                  'All database connection signals are normal.',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppColors.camelLight,
                  colorText: AppColors.camel,
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOpCard(
    BuildContext context,
    double width,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        padding: EdgeInsets.all(context.wp(3.5)),
        decoration: BoxDecoration(
          color: AppColors.offWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.greyLight, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.camel, size: 24),
            SizedBox(height: context.hp(1)),
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: context.sp(13),
                fontWeight: FontWeight.bold,
                color: AppColors.charcoal,
              ),
            ),
            SizedBox(height: context.hp(0.2)),
            Text(
              subtitle,
              style: GoogleFonts.outfit(
                fontSize: context.sp(10),
                color: AppColors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
