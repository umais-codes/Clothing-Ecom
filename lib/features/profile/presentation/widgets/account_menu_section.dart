import 'package:ecom_app/features/profile/presentation/widgets/profile_menu_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/app/utils/responsive.dart';
import '../controllers/profile_controller.dart';

class AccountMenuSection extends GetView<ProfileController> {
  const AccountMenuSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final w = context.screenWidth;

    return Column(
      crossAxisAlignment: .start,
      children: [
        Text('Account Settings', style: theme.textTheme.titleLarge),
        SizedBox(height: w * 0.02),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: .circular(w * 0.04),
            border: .all(color: AppColors.greyLight, width: 1),
          ),
          child: Column(
            children: [
              const ProfileMenuItem(
                icon: Icons.location_on_outlined,
                title: 'Shipping Addresses',
              ),
              const ProfileMenuItem(
                icon: Icons.credit_card_outlined,
                title: 'Payment Methods',
              ),

              // Obx(
              //   () => ListTile(
              //     leading: Icon(
              //       Icons.notifications_none_rounded,
              //       color: AppColors.charcoal,
              //       size: w * 0.06,
              //     ),
              //     title: Text(
              //       'Push Notifications',
              //       style: theme.textTheme.bodyMedium,
              //     ),
              //     trailing: Switch.adaptive(
              //       value: controller.notificationsEnabled.value,
              //       onChanged: controller.toggleNotifications,
              //       activeColor: AppColors.camel,
              //     ),
              //     contentPadding: .symmetric(
              //       horizontal: w * 0.04,
              //       vertical: w * 0.00,
              //     ),
              //   ),
              // ),
              const ProfileMenuItem(
                icon: Icons.help_outline_rounded,
                title: 'Help & Support',
              ),
              const ProfileMenuItem(
                icon: Icons.lock_outline_rounded,
                title: 'Privacy Settings',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
