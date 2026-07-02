import 'dart:io';
import 'package:ecom_app/app/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecom_app/app/widgets/custom_app_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/app/widgets/custom_text_field.dart';
import 'package:ecom_app/app/widgets/custom_button.dart';
import '../controllers/profile_controller.dart';

class EditProfileView extends GetView<ProfileController> {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController(
      text: controller.userName.value,
    );
    final emailController = TextEditingController(
      text: controller.userEmail.value,
    );
    final phoneController = TextEditingController(
      text: controller.userPhone.value,
    );

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: const CustomAppBar(
        title: "Edit Profile",
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: context.wp(5),
          vertical: context.hp(2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildAvatarEdit(context),
            SizedBox(height: context.hp(5)),
            CustomTextField(
              label: 'Full Name',
              controller: nameController,
              icon: Icons.person_outline_rounded,
            ),
            SizedBox(height: context.hp(1.5)),
            CustomTextField(
              label: 'Email Address',
              controller: emailController,
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: context.hp(1.5)),
            CustomTextField(
              label: 'Phone Number',
              controller: phoneController,
              icon: Icons.phone_android_rounded,
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: context.hp(6)),
            Obx(
              () => CustomButton(
                text: 'Save Changes',
                isLoading: controller.isSaving.value,
                onPressed: controller.isSaving.value
                    ? null
                    : () async {
                        try {
                          await controller.saveProfileChanges(
                            name: nameController.text.trim(),
                            email: emailController.text.trim(),
                            phone: phoneController.text.trim(),
                          );
                          Get.back();
                          Get.snackbar(
                            'Success',
                            'Profile updated successfully',
                            snackPosition: SnackPosition.TOP,
                            backgroundColor: AppColors.offWhite,
                            colorText: AppColors.charcoal,
                            margin: const EdgeInsets.all(16),
                            borderRadius: 12,
                          );
                        } catch (e) {
                          Get.snackbar(
                            'Error',
                            'Failed to update profile: $e',
                            snackPosition: SnackPosition.TOP,
                            backgroundColor: AppColors.error,
                            colorText: AppColors.white,
                            margin: const EdgeInsets.all(16),
                            borderRadius: 12,
                          );
                        }
                      },
                icon: Icons.check_circle_outline_rounded,
              ),
            ),
            SizedBox(height: context.hp(5)),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarEdit(BuildContext context) {
    return GestureDetector(
      onTap: () => _showImagePicker(context),
      child: Stack(
        children: [
          Obx(() {
            final imagePath = controller.profileImagePath.value;
            return Container(
              width: context.wp(30),
              height: context.wp(30),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.offWhite,
                border: Border.all(
                  color: AppColors.camel.withValues(alpha: 0.3),
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
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppColors.camel,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.camera_alt_rounded,
                color: AppColors.white,
                size: context.wp(5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showImagePicker(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Image Source',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.charcoal,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: AppColors.camel),
              title: const Text('Gallery'),
              onTap: () {
                Get.back();
                controller.pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined, color: AppColors.camel),
              title: const Text('Camera'),
              onTap: () {
                Get.back();
                controller.pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }
}
