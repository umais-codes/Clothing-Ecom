import 'package:ecom_app/app/utils/responsive.dart';
import 'package:ecom_app/app/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../../../app/theme/app_colors.dart';

class AdminSideDrawer extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback onSave;

  const AdminSideDrawer({
    super.key,
    required this.title,
    required this.child,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final double drawerWidth = context.isMobileView
        ? context.wp(90)
        : (context.isTabletView
              ? context.wp(60)
              : context.wp(35).clamp(400, 500));

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        width: drawerWidth,
        height: context.height,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            bottomLeft: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.charcoal.withValues(alpha: 0.1),
              blurRadius: 30,
              offset: const Offset(-10, 0),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header ─────────────────────────────────────────────────────────
              Container(
                padding: EdgeInsets.fromLTRB(
                  context.wp(4).clamp(16.0, 24.0),
                  context.hp(2.5).clamp(20.0, 32.0),
                  context.wp(2).clamp(8.0, 16.0),
                  context.hp(1.5).clamp(12.0, 20.0),
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.outfit(
                            fontSize: context.sp(18).clamp(18.0, 24.0),
                            fontWeight: FontWeight.w700,
                            color: AppColors.charcoal,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'PRODUCT AUDIT PANEL',
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.camel,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: AppColors.grey,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // ── Body ───────────────────────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.wp(4).clamp(16.0, 24.0),
                    vertical: context.hp(2).clamp(16.0, 24.0),
                  ),
                  child: child,
                ),
              ),

              const Divider(height: 1),

              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.wp(4).clamp(16.0, 24.0),
                  vertical: context.hp(2).clamp(16.0, 20.0),
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  border: Border(
                    top: BorderSide(
                      color: AppColors.greyLight.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: CustomButton(
                        text: 'DISCARD',
                        onPressed: () => Get.back(),
                        variant: ButtonVariant.outlined,
                        height: 44,
                        fontSize: 12,
                        textColor: AppColors.grey,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 3,
                      child: CustomButton(
                        text: 'SAVE CHANGES',
                        onPressed: onSave,
                        buttonColor: AppColors.camel,
                        height: 44,
                        fontSize: 12,
                        icon: Icons.check_circle_outline_rounded,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
