import 'package:ecom_app/features/profile/presentation/widgets/profile_menu_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/features/auth/presentation/controllers/auth_controller.dart';

class PerspectiveSwitcher extends StatelessWidget {
  const PerspectiveSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final sw = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            'Switch Perspective',
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.grey,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.offWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.greyLight, width: 1),
          ),
          child: Column(
            children: [
              ProfileMenuItem(
                icon: Icons.shopping_bag_outlined,
                title: 'Consumer Mode',
                onTap: () {
                  authController.setRole(AuthRole.shopper);
                },
              ),
              ProfileMenuItem(
                icon: Icons.storefront_outlined,
                title: 'Vendor Portal',
                onTap: () {
                  authController.setRole(AuthRole.vendor);
                },
              ),
              ProfileMenuItem(
                icon: Icons.business_outlined,
                title: 'Corporate Sourcing',
                onTap: () {
                  authController.setRole(AuthRole.corporate);
                },
              ),
              ProfileMenuItem(
                icon: Icons.admin_panel_settings_outlined,
                title: 'Super Admin Control',
                onTap: () {
                  Get.toNamed('/admin-login');
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
