import 'package:flutter/material.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/app/widgets/custom_button.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:google_fonts/google_fonts.dart';

class PendingApprovalScreen extends StatelessWidget {
  const PendingApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: .symmetric(horizontal: w * 0.08),
          child: Column(
            mainAxisAlignment: .center,
            children: [
              const Spacer(),
              Container(
                width: w * 0.3,
                height: w * 0.3,
                decoration: BoxDecoration(
                  color: AppColors.camel.withValues(alpha: 0.12),
                  shape: .circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.hourglass_top_rounded,
                    size: w * 0.15,
                    color: AppColors.camel,
                  ),
                ),
              ),
              SizedBox(height: w * 0.01),

              Text(
                'Application Received',
                style: GoogleFonts.outfit(
                  fontSize: w * 0.05,
                  fontWeight: .w600,
                  color: AppColors.charcoal,
                  letterSpacing: 0.2,
                ),
                textAlign: .center,
              ),
              SizedBox(height: h * 0.01),

              Text(
                'Thank you for applying to be an Aura Partner. Our team will review your KYC documents and get back to you within 24-48 hours.',
                style: GoogleFonts.outfit(
                  fontSize: w * 0.032,
                  color: AppColors.grey,
                  fontWeight: .w400,
                  height: 1.3,
                ),
                textAlign: .center,
              ),

              const Spacer(),
              CustomButton(
                text: 'Return to Home',
                onPressed: () {
                  Get.offAllNamed('/home');
                },
                icon: Icons.house,
              ),
              SizedBox(height: h * 0.04),
            ],
          ),
        ),
      ),
    );
  }
}
