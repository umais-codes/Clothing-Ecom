import 'dart:ui' as ui;
import 'package:ecom_app/app/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';
import 'custom_button.dart';

class CustomPermissionDialog extends StatelessWidget {
  final IconData? icon;
  final String title;
  final dynamic description;
  final Widget? content;
  final VoidCallback onGrant;
  final VoidCallback? onDeny;
  final String grantText;
  final String denyText;
  final Color? iconColor;
  final Color? iconBgColor;
  final Color? grantButtonColor;

  const CustomPermissionDialog({
    super.key,
    this.icon,
    required this.title,
    this.description,
    this.content,
    required this.onGrant,
    this.onDeny,
    this.grantText = 'Allow Access',
    this.denyText = 'Cancel',
    this.iconColor,
    this.iconBgColor,
    this.grantButtonColor,
  });

  /// Displays the premium backdrop-blurred luxury dialog.
  static Future<void> show({
    required BuildContext context,
    IconData? icon,
    required String title,
    dynamic description,
    Widget? content,
    required VoidCallback onGrant,
    VoidCallback? onDeny,
    String grantText = 'Confirm',
    String denyText = 'Cancel',
    Color? iconColor,
    Color? iconBgColor,
    Color? grantButtonColor,
  }) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Luxury Dialog',
      barrierColor: AppColors.scrimDark,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, anim1, anim2) {
        return CustomPermissionDialog(
          icon: icon,
          title: title,
          description: description,
          content: content,
          onGrant: onGrant,
          onDeny: onDeny,
          grantText: grantText,
          denyText: denyText,
          iconColor: iconColor,
          iconBgColor: iconBgColor,
          grantButtonColor: grantButtonColor,
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
    final effectiveIconColor = iconColor ?? AppColors.camel;
    final effectiveIconBgColor =
        iconBgColor ??
        (iconColor != null
            ? iconColor!.withValues(alpha: 0.12)
            : AppColors.camelLight);

    return BackdropFilter(
      filter: ui.ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: EdgeInsets.symmetric(horizontal: context.wp(6)),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: context.wp(5),
            vertical: context.hp(2.5),
          ),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.98),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.greyLight.withValues(alpha: 0.8),
              width: 1.5,
            ),
            boxShadow: AppColors.cardShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Optional Premium Icon Box
              if (icon != null) ...[
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: effectiveIconBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: effectiveIconColor, size: 26),
                ),
                SizedBox(height: context.hp(1.2)),
              ],

              // Title Text
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: context.sp(17),
                  fontWeight: FontWeight.w800,
                  color: AppColors.charcoal,
                  letterSpacing: -0.2,
                ),
                textAlign: TextAlign.center,
              ),

              if (description != null) ...[
                SizedBox(height: context.hp(1)),
                description is Widget
                    ? description
                    : Text(
                        description.toString(),
                        style: GoogleFonts.outfit(
                          fontSize: context.sp(12.5),
                          color: AppColors.grey,
                          height: 1.45,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
              ],

              if (content != null) ...[
                SizedBox(height: context.hp(1.5)),
                content!,
              ],

              SizedBox(height: context.hp(2.2)),

              // Action Buttons Row using luxury CustomButton
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: denyText,
                      variant: ButtonVariant.outlined,
                      height: 42,
                      fontSize: context.sp(12),
                      textColor: AppColors.grey,
                      onPressed: () {
                        Get.back();
                        if (onDeny != null) {
                          onDeny!();
                        }
                      },
                    ),
                  ),
                  SizedBox(width: context.wp(2.5)),
                  Expanded(
                    child: CustomButton(
                      text: grantText,
                      variant: ButtonVariant.primary,
                      height: 42,
                      fontSize: context.sp(12),
                      buttonColor: grantButtonColor ?? AppColors.camel,
                      textColor: AppColors.white,
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
