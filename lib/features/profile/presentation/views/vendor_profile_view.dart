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

class VendorProfileView extends GetView<ProfileController> {
  const VendorProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final h = context.screenHeight;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: const CustomAppBar(
        title: 'Vendor Partner Portal',
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
            SizedBox(height: h * 0.02),

            // Brand Details Card
            Obx(() => _buildBrandCard(context)),
            SizedBox(height: h * 0.02),

            // Quick Stats
            _buildVendorStatsGrid(context),
            SizedBox(height: h * 0.02),

            // Vendor Operations
            _buildVendorOperations(context),
            SizedBox(height: h * 0.02),

            const AccountMenuSection(),
            SizedBox(height: h * 0.02),

            const PerspectiveSwitcher(),
            SizedBox(height: h * 0.02),

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

  Widget _buildBrandCard(BuildContext context) {
    final w = context.screenWidth;
    final h = context.screenHeight;

    final kyc = controller.kycStatus.value.toLowerCase();
    Color statusColor;
    IconData statusIcon;

    if (kyc == 'approved') {
      statusColor = AppColors.success;
      statusIcon = Icons.verified_user_rounded;
    } else if (kyc == 'rejected') {
      statusColor = AppColors.error;
      statusIcon = Icons.gpp_bad_rounded;
    } else {
      statusColor = AppColors.warning;
      statusIcon = Icons.pending_actions_rounded;
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(w * 0.04),
      decoration: BoxDecoration(
        color: AppColors.offWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.greyLight, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Brand Identity',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.charcoal,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, color: statusColor, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      controller.kycStatus.value.toUpperCase(),
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: h * 0.015),
          _buildInfoRow(
            context,
            'Brand Name',
            controller.brandName.value.isNotEmpty
                ? controller.brandName.value
                : 'Not Configured',
          ),
          Divider(height: h * 0.02, color: AppColors.greyLight),
          _buildInfoRow(context, 'Contact Person', controller.userName.value),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final w = context.screenWidth;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: w * 0.035,
            color: AppColors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: w * 0.038,
            color: AppColors.charcoal,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildVendorStatsGrid(BuildContext context) {
    final w = context.screenWidth;
    final cardWidth = (w * 0.92 - 16) / 3;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatCard(
          context,
          cardWidth,
          '18',
          'Active Products',
          AppColors.camel,
        ),
        _buildStatCard(
          context,
          cardWidth,
          '5',
          'Pending Orders',
          AppColors.warning,
        ),
        _buildStatCard(
          context,
          cardWidth,
          '\$1.4k',
          'Monthly Revenue',
          AppColors.success,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    double width,
    String value,
    String label,
    Color accentColor,
  ) {
    return Container(
      width: width,
      padding: EdgeInsets.symmetric(
        vertical: context.hp(1.4),
        horizontal: context.wp(0.8),
      ),
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
              fontSize: context.wp(5),
              fontWeight: FontWeight.w800,
              color: accentColor,
            ),
          ),
          SizedBox(height: context.hp(0.4)),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: context.wp(2.5),
              fontWeight: FontWeight.bold,
              color: AppColors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildVendorOperations(BuildContext context) {
    final w = context.screenWidth;
    final cardWidth = (w * 0.92 - 16) / 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Store Operations',
          style: GoogleFonts.outfit(
            fontSize: context.wp(3.8),
            fontWeight: FontWeight.bold,
            color: AppColors.charcoal,
          ),
        ),
        SizedBox(height: context.hp(1.2)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildOpCard(
              context,
              cardWidth,
              Icons.inventory_2_outlined,
              'Manage Inventory',
              'Update stock & details',
              () => Get.toNamed('/vendor-inventory'),
            ),
            _buildOpCard(
              context,
              cardWidth,
              Icons.local_shipping_outlined,
              'Orders Portal',
              'Dispatch pending orders',
              () => Get.toNamed('/vendor-orders'),
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
        padding: const EdgeInsets.all(14),
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
                fontSize: context.wp(3.3),
                fontWeight: FontWeight.bold,
                color: AppColors.charcoal,
              ),
            ),
            SizedBox(height: context.hp(0.2)),
            Text(
              subtitle,
              style: GoogleFonts.outfit(
                fontSize: context.wp(2.6),
                color: AppColors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
