import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import '../controllers/profile_controller.dart';
import '../views/edit_profile_view.dart';

class ProfileHeader extends GetView<ProfileController> {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final theme = Theme.of(context);

    return Column(
      children: [
        Stack(
          children: [
            Obx(() {
              final imagePath = controller.profileImagePath.value;
              return Container(
                width: size.width * 0.22,
                height: size.width * 0.22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.offWhite,
                  border: Border.all(
                    color: AppColors.camel.withValues(alpha: 0.5),
                    width: 2,
                  ),
                  image: imagePath.isNotEmpty
                      ? DecorationImage(
                          image: FileImage(File(imagePath)),
                          fit: BoxFit.cover,
                        )
                      : const DecorationImage(
                          image: NetworkImage('https://i.pravatar.cc/150?img=47'),
                          fit: BoxFit.cover,
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
                    size: size.width * 0.05,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: size.height * 0.02),
        Obx(
          () => Text(
            controller.userName.value,
            style: theme.textTheme.displayMedium?.copyWith(fontSize: 28),
          ),
        ),
        const SizedBox(height: 4),
        Obx(
          () => Text(
            controller.userEmail.value,
            style: theme.textTheme.bodyMedium,
          ),
        ),
        SizedBox(height: size.height * 0.015),
        Obx(
          () => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.camelLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              controller.roleBadgeText,
              style: theme.textTheme.labelLarge?.copyWith(
                color: AppColors.charcoal,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
