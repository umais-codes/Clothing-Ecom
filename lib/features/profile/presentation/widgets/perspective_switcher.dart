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
          padding: EdgeInsets.only(left: sw * 0.01),
          child: Text(
            'Switch Perspective',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        SizedBox(height: sw * 0.03),
        Container(
          padding: .symmetric(horizontal: sw * 0.02, vertical: sw * 0.01),
          decoration: BoxDecoration(
            color: AppColors.offWhite,
            borderRadius: .circular(sw * 0.04),
            border: .all(color: AppColors.greyLight, width: 1),
          ),
          child: Column(
            children: [
              _buildRoleTile(
                context,
                'Consumer Mode',
                Icons.shopping_bag_outlined,
                AuthRole.shopper,
                authController,
              ),
              const Divider(height: 1, indent: 40),
              _buildRoleTile(
                context,
                'Vendor Portal',
                Icons.storefront_outlined,
                AuthRole.vendor,
                authController,
              ),
              const Divider(height: 1, indent: 40),
              _buildRoleTile(
                context,
                'Corporate Sourcing',
                Icons.business_outlined,
                AuthRole.corporate,
                authController,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRoleTile(
    BuildContext context,
    String title,
    IconData icon,
    AuthRole role,
    AuthController controller,
  ) {
    return Obx(() {
      final isSelected = controller.selectedRole.value == role;
      return ListTile(
        leading: Icon(
          icon,
          color: isSelected ? AppColors.camel : AppColors.charcoal,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? .w700 : .w500,
            color: isSelected ? AppColors.camel : AppColors.charcoal,
          ),
        ),
        trailing: isSelected
            ? const Icon(Icons.check_circle, color: AppColors.camel)
            : const Icon(Icons.chevron_right, color: AppColors.grey),
        onTap: () => controller.setRole(role),
      );
    });
  }
}
