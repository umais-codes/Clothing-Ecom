import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/app/widgets/custom_text_field.dart';
import 'package:ecom_app/app/widgets/custom_button.dart';
import '../controllers/profile_controller.dart';

class EditProfileView extends GetView<ProfileController> {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

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
      appBar: AppBar(
        title: Text(
          "Edit Profile",
          style: GoogleFonts.outfit(
            fontSize: size.width * 0.05,
            fontWeight: FontWeight.w600,
            color: AppColors.charcoal,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: size.width * 0.05,
            color: AppColors.charcoal,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.05,
          vertical: size.height * 0.02,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildAvatarEdit(context, size),
            SizedBox(height: size.height * 0.05),
            CustomTextField(
              label: 'Full Name',
              controller: nameController,
              icon: Icons.person_outline_rounded,
            ),
            SizedBox(height: size.height * 0.015),
            CustomTextField(
              label: 'Email Address',
              controller: emailController,
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: size.height * 0.015),
            CustomTextField(
              label: 'Phone Number',
              controller: phoneController,
              icon: Icons.phone_android_rounded,
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: size.height * 0.06),
            CustomButton(
              text: 'Save Changes',
              onPressed: () {
                controller.userName.value = nameController.text;
                controller.userEmail.value = emailController.text;
                controller.userPhone.value = phoneController.text;
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
              },
              icon: Icons.check_circle_outline_rounded,
            ),
            SizedBox(height: size.height * 0.05),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarEdit(BuildContext context, Size size) {
    return GestureDetector(
      onTap: () => _showImagePicker(context),
      child: Stack(
        children: [
          Obx(() {
            final imagePath = controller.profileImagePath.value;
            return Container(
              width: size.width * 0.3,
              height: size.width * 0.3,
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
                size: size.width * 0.05,
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
