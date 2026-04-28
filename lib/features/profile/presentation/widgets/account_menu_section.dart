import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import '../controllers/profile_controller.dart';

class AccountMenuSection extends GetView<ProfileController> {
  const AccountMenuSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: .start,
      children: [
        Text('Account Settings', style: theme.textTheme.titleLarge),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: .circular(12),
            border: .all(color: AppColors.greyLight, width: 1),
          ),
          child: Column(
            children: [
              const ProfileMenuItem(
                icon: Icons.location_on_outlined,
                title: 'Shipping Addresses',
              ),
              const Divider(
                height: 1,
                color: AppColors.greyLight,
                indent: 16,
                endIndent: 16,
              ),
              const ProfileMenuItem(
                icon: Icons.credit_card_outlined,
                title: 'Payment Methods',
              ),
              const Divider(
                height: 1,
                color: AppColors.greyLight,
                indent: 16,
                endIndent: 16,
              ),
              Obx(
                () => ListTile(
                  leading: const Icon(
                    Icons.notifications_none_rounded,
                    color: AppColors.charcoal,
                  ),
                  title: Text(
                    'Push Notifications',
                    style: theme.textTheme.bodyLarge,
                  ),
                  trailing: Switch.adaptive(
                    value: controller.notificationsEnabled.value,
                    onChanged: controller.toggleNotifications,
                    activeColor: AppColors.camel,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                ),
              ),
              const Divider(
                height: 1,
                color: AppColors.greyLight,
                indent: 16,
                endIndent: 16,
              ),
              const ProfileMenuItem(
                icon: Icons.help_outline_rounded,
                title: 'Help & Support',
              ),
              const Divider(
                height: 1,
                color: AppColors.greyLight,
                indent: 16,
                endIndent: 16,
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

class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final w = MediaQuery.sizeOf(context).width;
    return ListTile(
      leading: Icon(icon, color: AppColors.charcoal),
      title: Text(title, style: theme.textTheme.bodyLarge),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.grey),
      contentPadding: .symmetric(horizontal: w * 0.05, vertical: w * 0.02),
      onTap: onTap,
    );
  }
}
