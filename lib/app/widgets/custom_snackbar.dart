import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecom_app/app/theme/app_colors.dart';

enum SnackbarVariant { success, error, warning, info }

class AppSnackbar {
  AppSnackbar._();

  /// Shows a luxury success toast from the top
  static void success({
    String title = 'Success',
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      title: title,
      message: message,
      variant: SnackbarVariant.success,
      duration: duration,
    );
  }

  /// Shows a luxury error toast from the top
  static void error({
    String title = 'Error',
    required String message,
    Duration duration = const Duration(seconds: 4),
  }) {
    show(
      title: title,
      message: message,
      variant: SnackbarVariant.error,
      duration: duration,
    );
  }

  /// Shows a luxury warning toast from the top
  static void warning({
    String title = 'Warning',
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      title: title,
      message: message,
      variant: SnackbarVariant.warning,
      duration: duration,
    );
  }

  /// Shows a luxury info toast from the top
  static void info({
    String title = 'Information',
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      title: title,
      message: message,
      variant: SnackbarVariant.info,
      duration: duration,
    );
  }

  /// Generic customizable luxury toast from the top
  static void show({
    required String title,
    required String message,
    SnackbarVariant variant = SnackbarVariant.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    Color accentColor;
    Color iconBgColor;
    IconData iconData;

    switch (variant) {
      case SnackbarVariant.success:
        accentColor = AppColors.success;
        iconBgColor = AppColors.successBg;
        iconData = Icons.check_circle_rounded;
        break;
      case SnackbarVariant.error:
        accentColor = AppColors.error;
        iconBgColor = AppColors.errorBg;
        iconData = Icons.error_outline_rounded;
        break;
      case SnackbarVariant.warning:
        accentColor = AppColors.warning;
        iconBgColor = AppColors.warningBg;
        iconData = Icons.warning_amber_rounded;
        break;
      case SnackbarVariant.info:
        accentColor = AppColors.camel;
        iconBgColor = AppColors.camelLight;
        iconData = Icons.info_outline_rounded;
        break;
    }

    if (Get.isSnackbarOpen == true) {
      Get.closeCurrentSnackbar();
    }

    Get.rawSnackbar(
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.transparent,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: EdgeInsets.zero,
      duration: duration,
      animationDuration: const Duration(milliseconds: 320),
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.easeInCubic,
      isDismissible: true,
      messageText: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.98),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: accentColor.withValues(alpha: 0.35),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.charcoal.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: accentColor.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left Accent Bar + Icon Badge
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(iconData, color: accentColor, size: 20),
            ),
            const SizedBox(width: 12),

            // Content Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (title.isNotEmpty) ...[
                    Text(
                      title,
                      style: GoogleFonts.outfit(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.charcoal,
                        letterSpacing: -0.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                  ],
                  Text(
                    message,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.ink,
                      height: 1.35,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 6),

            // Dismiss Button
            InkWell(
              onTap: () {
                if (Get.isSnackbarOpen == true) {
                  Get.closeCurrentSnackbar();
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: AppColors.grey.withValues(alpha: 0.7),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
