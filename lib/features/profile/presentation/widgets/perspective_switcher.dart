import 'package:ecom_app/features/profile/presentation/widgets/profile_menu_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/features/auth/presentation/controllers/auth_controller.dart';

class PerspectiveSwitcher extends StatelessWidget {
  const PerspectiveSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final sw = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: .start,
      children: [
        Padding(
          padding: .only(left: sw * 0.02),
          child: Text(
            'Switch Perspective',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        SizedBox(height: sw * 0.02),
        Container(
          decoration: BoxDecoration(
            color: AppColors.offWhite,
            borderRadius: .circular(sw * 0.04),
            border: .all(color: AppColors.greyLight, width: 1),
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
            ],
          ),
        ),
      ],
    );
  }
}
