import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/app/widgets/custom_snackbar.dart';

class BulkUploadSheet extends StatelessWidget {
  final double sw;
  BulkUploadSheet({super.key, required this.sw});

  final RxBool isUploading = false.obs;
  final RxDouble progress = 0.0.obs;

  void simulateUpload() async {
    isUploading.value = true;

    for (int i = 0; i <= 100; i += 10) {
      await Future.delayed(const Duration(milliseconds: 200));
      progress.value = i / 100;
    }

    isUploading.value = false;
    Get.back();
    AppSnackbar.success(
      title: 'Upload Complete',
      message: 'Bulk inventory CSV data imported successfully.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: sw * 0.04,
        vertical: sw * 0.02,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: sw * 0.15,
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.greyLight,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          SizedBox(height: sw * 0.03),
          Text(
            'Bulk Upload CSV',
            style: GoogleFonts.outfit(
              fontSize: sw * 0.05,
              fontWeight: FontWeight.w600,
              color: AppColors.charcoal,
            ),
          ),
          SizedBox(height: sw * 0.04),
          Obx(
            () => GestureDetector(
              onTap: isUploading.value ? null : simulateUpload,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: sw * 0.1),
                decoration: BoxDecoration(
                  color: AppColors.offWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.camel,
                    style: BorderStyle.solid,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.cloud_upload_outlined,
                      size: sw * 0.12,
                      color: AppColors.camel,
                    ),
                    SizedBox(height: sw * 0.02),
                    Text(
                      'Tap to select CSV file',
                      style: GoogleFonts.outfit(
                        color: AppColors.charcoal,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Obx(() {
            if (!isUploading.value) return const SizedBox.shrink();
            return Column(
              children: [
                SizedBox(height: sw * 0.06),
                LinearProgressIndicator(
                  value: progress.value,
                  backgroundColor: AppColors.camelLight,
                  color: AppColors.camel,
                ),
                SizedBox(height: sw * 0.02),
                Text(
                  '${(progress.value * 100).toInt()}% uploaded',
                  style: GoogleFonts.outfit(color: AppColors.grey),
                ),
              ],
            );
          }),
          SizedBox(height: sw * 0.06),
        ],
      ),
    );
  }
}
