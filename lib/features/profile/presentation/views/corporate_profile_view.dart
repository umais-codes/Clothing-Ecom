import 'package:ecom_app/app/utils/responsive.dart';
import 'package:ecom_app/app/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/app/widgets/custom_app_bar.dart';
import 'package:ecom_app/app/widgets/custom_snackbar.dart';
import '../controllers/profile_controller.dart';
import '../widgets/profile_header.dart';
import '../widgets/account_menu_section.dart';
import '../widgets/perspective_switcher.dart';

class CorporateProfileView extends GetView<ProfileController> {
  const CorporateProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final h = context.screenHeight;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: const CustomAppBar(
        title: 'Corporate Sourcing Hub',
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

            // B2B Identity Card
            Obx(() => _buildCorporateIdentityCard(context)),
            SizedBox(height: h * 0.025),

            // Uniform Allowance Card
            _buildAllowanceCard(context),
            SizedBox(height: h * 0.025),

            // B2B Operations
            _buildCorporateOperations(context),
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

  Widget _buildCorporateIdentityCard(BuildContext context) {
    final h = context.screenHeight;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.wp(4)),
      decoration: BoxDecoration(
        color: AppColors.offWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.greyLight, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Corporate Account Details',
            style: GoogleFonts.outfit(
              fontSize: context.sp(16),
              fontWeight: FontWeight.bold,
              color: AppColors.charcoal,
            ),
          ),
          SizedBox(height: h * 0.015),
          _buildInfoRow(context, 'Company Name', controller.userName.value),
          Divider(height: h * 0.02, color: AppColors.greyLight),
          _buildInfoRow(context, 'NTN Number', controller.companyNtn.value),
          Divider(height: h * 0.02, color: AppColors.greyLight),
          _buildInfoRow(
            context,
            'Volume Tier',
            controller.employeeVolume.value,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: context.sp(13),
            color: AppColors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: context.sp(14),
            color: AppColors.charcoal,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildAllowanceCard(BuildContext context) {
    final h = context.screenHeight;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.wp(4)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.camel, AppColors.camel.withValues(alpha: 0.85)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.camel.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Uniform Allowance Balance',
                style: GoogleFonts.outfit(
                  fontSize: context.sp(14),
                  fontWeight: FontWeight.w600,
                  color: AppColors.white.withValues(alpha: 0.85),
                ),
              ),
              Icon(
                Icons.style_outlined,
                color: AppColors.white.withValues(alpha: 0.9),
                size: 20,
              ),
            ],
          ),
          SizedBox(height: h * 0.01),
          Text(
            '\$450.00',
            style: GoogleFonts.outfit(
              fontSize: context.sp(28),
              fontWeight: FontWeight.w800,
              color: AppColors.white,
            ),
          ),
          SizedBox(height: h * 0.008),
          Text(
            'Valid for seasonal collections order. Expiring Dec 31, 2026.',
            style: GoogleFonts.outfit(
              fontSize: context.sp(11),
              color: AppColors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorporateOperations(BuildContext context) {
    final w = context.screenWidth;
    final cardWidth = (w * 0.92 - 16) / 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Procurement Center',
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
              Icons.request_quote_outlined,
              'Bulk Quotations',
              'Request bulk volume quotes',
              () {
                AppSnackbar.info(
                  title: 'Bulk Quote',
                  message: 'Quotations features can be accessed on B2B product checkout.',
                );
              },
            ),
            _buildOpCard(
              context,
              cardWidth,
              Icons.receipt_long_rounded,
              'Track Deliveries',
              'Sourcing shipment tracking',
              () => Get.toNamed('/customer-tracking'),
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
