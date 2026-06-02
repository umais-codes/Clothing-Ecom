import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/app/utils/responsive.dart';
import 'package:ecom_app/features/auth/controllers/auth_controller.dart';
import '../controllers/profile_controller.dart';

class QuickActionGrid extends GetView<ProfileController> {
  const QuickActionGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final w = context.screenWidth;
    final h = context.screenHeight;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions', style: theme.textTheme.titleLarge),
        SizedBox(height: h * 0.02),
        Obx(() {
          final showB2B = controller.showUniformAllowance;
          return Wrap(
            spacing: w * 0.04,
            runSpacing: w * 0.04,
            children: [
              QuickActionCard(
                icon: Icons.local_shipping_outlined,
                label: 'Track Orders',
                onTap: () {
                  final authController = Get.find<AuthController>();
                  if (authController.selectedRole.value == AuthRole.vendor) {
                    Get.toNamed('/vendor-tracking');
                  } else {
                    Get.toNamed('/customer-tracking');
                  }
                },
              ),
              QuickActionCard(
                icon: Icons.favorite_border_rounded,
                label: 'Wishlist',
                onTap: () => Get.toNamed('/wishlist'),
              ),
              QuickActionCard(
                icon: Icons.confirmation_number_outlined,
                label: 'Vouchers',
                onTap: () {
                  Get.snackbar(
                    'Promo Vouchers',
                    'No active vouchers available at the moment.',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: AppColors.camelLight,
                    colorText: AppColors.camel,
                  );
                },
              ),
              if (showB2B)
                QuickActionCard(
                  icon: Icons.cases_outlined,
                  label: 'Uniform Allowance',
                  onTap: () {
                    Get.snackbar(
                      'Allowance Balance',
                      'Your remaining uniform allowance is \$450.00',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: AppColors.camelLight,
                      colorText: AppColors.camel,
                    );
                  },
                ),
            ],
          );
        }),
      ],
    );
  }
}

class QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const QuickActionCard({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final w = context.screenWidth;
    final h = context.screenHeight;
    final theme = Theme.of(context);
    final cardWidth = (w * 0.9 - (w * 0.04)) / 2;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: cardWidth,
        padding: EdgeInsets.symmetric(vertical: h * 0.02),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.greyLight, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.camel, size: 28),
            SizedBox(height: h * 0.01),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
