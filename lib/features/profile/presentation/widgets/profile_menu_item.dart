import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:ecom_app/app/utils/responsive.dart';

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
    final w = context.screenWidth;
    return Material(
      color: Colors.transparent,
      child: ListTile(
        leading: Icon(icon, color: AppColors.charcoal, size: w * 0.055),
        title: Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(
            letterSpacing: 0.4,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: AppColors.grey,
          size: w * 0.06,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        onTap: onTap,
      ),
    );
  }
}
