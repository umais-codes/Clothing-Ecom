import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';
import 'custom_button.dart';

class CustomConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
  final Color confirmColor;

  const CustomConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    required this.onConfirm,
    this.confirmColor = AppColors.error,
  });

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.sizeOf(context).width;

    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: .circular(sw * 0.04)),
      child: Padding(
        padding: .symmetric(horizontal: sw * 0.06, vertical: sw * 0.025),
        child: Column(
          mainAxisSize: .min,
          children: [
            Container(
              padding: .symmetric(horizontal: sw * 0.03, vertical: sw * 0.015),
              decoration: BoxDecoration(
                color: confirmColor.withValues(alpha: 0.1),
                shape: .circle,
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                color: confirmColor,
                size: sw * 0.08,
              ),
            ),
            SizedBox(height: sw * 0.04),
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: sw * 0.05,
                fontWeight: .w700,
                color: AppColors.charcoal,
              ),
              textAlign: .center,
            ),
            SizedBox(height: sw * 0.02),
            Text(
              message,
              style: GoogleFonts.outfit(
                fontSize: sw * 0.038,
                color: AppColors.grey,
                height: 1.5,
              ),
              textAlign: .center,
            ),
            SizedBox(height: sw * 0.06),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: cancelText,
                    variant: .outlined,
                    height: sw * 0.11,
                    onPressed: () => Get.back(),
                  ),
                ),
                SizedBox(width: sw * 0.03),
                Expanded(
                  child: CustomButton(
                    text: confirmText,
                    variant: .primary,
                    buttonColor: confirmColor,
                    height: sw * 0.11,
                    onPressed: onConfirm,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
