import 'dart:ui' as ui;
import 'package:ecom_app/app/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';
import 'custom_button.dart';

class CustomPermissionDialog extends StatelessWidget {
  final IconData icon;
  final String title;
  final dynamic description;
  final VoidCallback onGrant;
  final VoidCallback? onDeny;
  final String grantText;
  final String denyText;

  const CustomPermissionDialog({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.onGrant,
    this.onDeny,
    this.grantText = 'Allow Access',
    this.denyText = 'Not Now',
  });

  /// Displays the premium backdrop-blurred permissions dialog.
  static Future<void> show({
    required BuildContext context,
    required IconData icon,
    required String title,
    required dynamic description,
    required VoidCallback onGrant,
    VoidCallback? onDeny,
    String grantText = 'Allow Access',
    String denyText = 'Not Now',
  }) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Permission Dialog',
      barrierColor: AppColors.charcoal.withValues(alpha: 0.4),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return CustomPermissionDialog(
          icon: icon,
          title: title,
          description: description,
          onGrant: onGrant,
          onDeny: onDeny,
          grantText: grantText,
          denyText: denyText,
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: anim1, curve: Curves.easeOut),
          child: ScaleTransition(
            scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ui.ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: EdgeInsets.symmetric(horizontal: context.wp(6)),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: context.wp(4),
            vertical: context.hp(2),
          ),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.greyLight.withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Premium Permission Icon Box
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.camel.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.camel, size: 32),
              ),
              SizedBox(height: context.hp(1)),

              // Title Text
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: context.sp(20),
                  fontWeight: FontWeight.w700,
                  color: AppColors.charcoal,
                  letterSpacing: -0.3,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: context.hp(1.5)),

              // Description Text
              description is Widget
                  ? description
                  : Text(
                      description,
                      style: GoogleFonts.outfit(
                        fontSize: context.sp(14),
                        color: AppColors.grey,
                        height: 1.5,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
              SizedBox(height: context.hp(2)),

              // Action Buttons Row
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: denyText,
                      variant: ButtonVariant.outlined,
                      height: 48,
                      fontSize: context.sp(14),
                      textColor: AppColors.grey,
                      onPressed: () {
                        Get.back();
                        if (onDeny != null) {
                          onDeny!();
                        }
                      },
                    ),
                  ),
                  SizedBox(width: context.wp(3)),
                  Expanded(
                    child: CustomButton(
                      text: grantText,
                      variant: ButtonVariant.primary,
                      height: 48,
                      fontSize: context.sp(14),
                      buttonColor: AppColors.camel,
                      onPressed: () {
                        Get.back();
                        onGrant();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
