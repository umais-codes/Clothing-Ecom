import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/app/utils/responsive.dart';
import '../controllers/profile_controller.dart';
import '../views/edit_profile_view.dart';

class ProfileHeader extends GetView<ProfileController> {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final w = context.screenWidth;
    final theme = Theme.of(context);

    return Column(
      children: [
        Stack(
          children: [
            Obx(() {
              final imagePath = controller.profileImagePath.value;
              final name = controller.userName.value.trim();
              final initial = name.isNotEmpty ? name[0].toUpperCase() : 'S';

              if (imagePath.isNotEmpty) {
                return Container(
                  width: w * 0.22,
                  height: w * 0.22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.offWhite,
                    border: Border.all(
                      color: AppColors.camel.withValues(alpha: 0.5),
                      width: 2,
                    ),
                    image: imagePath.startsWith('http')
                        ? DecorationImage(
                            image: NetworkImage(imagePath),
                            fit: BoxFit.cover,
                          )
                        : DecorationImage(
                            image: FileImage(File(imagePath)),
                            fit: BoxFit.cover,
                          ),
                  ),
                );
              }

              return Container(
                width: w * 0.22,
                height: w * 0.22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.camel,
                  border: Border.all(
                    color: AppColors.camel.withValues(alpha: 0.5),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.camel.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  initial,
                  style: TextStyle(
                    fontSize: w * 0.09,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
              );
            }),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: () => Get.to(() => const EditProfileView()),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.camel,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.edit_rounded,
                    color: AppColors.white,
                    size: w * 0.05,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: context.hp(2)),
        Obx(
          () => Text(
            controller.userName.value,
            style: theme.textTheme.displayMedium?.copyWith(
              fontSize: context.sp(28),
            ),
          ),
        ),
        SizedBox(height: context.hp(0.5)),
        Obx(
          () => Text(
            controller.userEmail.value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: context.sp(14),
            ),
          ),
        ),
        SizedBox(height: context.hp(1.5)),
        Obx(
          () => Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.wp(3.2),
              vertical: context.hp(0.8),
            ),
            decoration: BoxDecoration(
              color: AppColors.camelLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              controller.roleBadgeText,
              style: theme.textTheme.labelLarge?.copyWith(
                color: AppColors.charcoal,
                fontWeight: FontWeight.w600,
                fontSize: context.sp(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
