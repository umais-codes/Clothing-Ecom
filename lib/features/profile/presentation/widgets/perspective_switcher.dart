import 'package:ecom_app/features/profile/presentation/widgets/profile_menu_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/app/utils/responsive.dart';
import 'package:ecom_app/app/widgets/custom_permission_dialog.dart';
import 'package:ecom_app/features/auth/controllers/auth_controller.dart';

class PerspectiveSwitcher extends StatelessWidget {
  const PerspectiveSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final theme = Theme.of(context);
    final w = context.screenWidth;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text('Switch Perspective', style: theme.textTheme.titleLarge),
        ),
        const SizedBox(height: 12),
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(w * 0.04),
            border: Border.all(color: AppColors.greyLight, width: 1),
          ),
          child: Obx(() {
            final activeRole = authController.selectedRole.value;

            return Column(
              children: [
                ProfileMenuItem(
                  icon: Icons.shopping_bag_outlined,
                  title: 'Consumer Mode',
                  onTap: () {
                    if (activeRole != AuthRole.shopper) {
                      _confirmSwitch(
                        context,
                        'Consumer Mode',
                        () => authController.setRole(AuthRole.shopper),
                      );
                    }
                  },
                  trailing: activeRole == AuthRole.shopper
                      ? Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.camel,
                          size: w * 0.06,
                        )
                      : null,
                ),
                ProfileMenuItem(
                  icon: Icons.storefront_outlined,
                  title: 'Vendor Portal',
                  onTap: () {
                    if (activeRole != AuthRole.vendor) {
                      _confirmSwitch(
                        context,
                        'Vendor Portal',
                        () => authController.setRole(AuthRole.vendor),
                      );
                    }
                  },
                  trailing: activeRole == AuthRole.vendor
                      ? Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.camel,
                          size: w * 0.06,
                        )
                      : null,
                ),
                ProfileMenuItem(
                  icon: Icons.business_outlined,
                  title: 'Corporate Sourcing',
                  onTap: () {
                    if (activeRole != AuthRole.corporate) {
                      _confirmSwitch(
                        context,
                        'Corporate Sourcing',
                        () => authController.setRole(AuthRole.corporate),
                      );
                    }
                  },
                  trailing: activeRole == AuthRole.corporate
                      ? Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.camel,
                          size: w * 0.06,
                        )
                      : null,
                ),
                ProfileMenuItem(
                  icon: Icons.admin_panel_settings_outlined,
                  title: 'Super Admin Control',
                  onTap: () {
                    if (activeRole != AuthRole.admin) {
                      _confirmSwitch(
                        context,
                        'Super Admin Control',
                        () => Get.toNamed('/admin-login'),
                      );
                    }
                  },
                  trailing: activeRole == AuthRole.admin
                      ? Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.camel,
                          size: w * 0.06,
                        )
                      : null,
                ),
              ],
            );
          }),
        ),
      ],
    );
  }

  void _confirmSwitch(
    BuildContext context,
    String name,
    VoidCallback onConfirm,
  ) {
    CustomPermissionDialog.show(
      context: context,
      icon: Icons.swap_horiz_rounded,
      title: 'Switch Perspective?',
      description: 'Are you sure you want to switch to $name?',
      grantText: 'Switch',
      denyText: 'Cancel',
      onGrant: onConfirm,
    );
  }
}
