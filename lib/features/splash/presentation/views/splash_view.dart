import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/features/splash/presentation/controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: SafeArea(
        child: Stack(
          children: [
            // Center Brand Content (Logo + App Name)
            Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 1600),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 40 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Brand Logo
                    Container(
                      height: Get.width * 0.35,
                      width: Get.width * 0.35,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.charcoal.withValues(alpha: 0.04),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Transform.translate(
                          offset: const Offset(0, 27),
                          child: Image.asset(
                            'assets/logo/logo.png',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              // Fallback if logo is missing or fails to load
                              return Container(
                                color: AppColors.charcoal,
                                child: const Icon(
                                  Icons.hourglass_empty_rounded,
                                  color: AppColors.offWhite,
                                  size: 50,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: Get.width * 0.01),

                    // Brand Name
                    Text(
                      'VELVET MAISON',
                      style: GoogleFonts.playfairDisplay(
                        color: AppColors.charcoal,
                        fontSize: Get.width * 0.06,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 6.0,
                        height: 1.2,
                      ),
                    ),

                    SizedBox(height: Get.width * 0.01),

                    // Subtitle / Brand Category
                    Text(
                      'HAUTE APPAREL & LUXURY HUB',
                      style: GoogleFonts.outfit(
                        color: AppColors.camel,
                        fontSize: Get.width * 0.025,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 3.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Premium Subtle Custom Loading Indicator
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: Get.height * 0.09),
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration: const Duration(seconds: 3),
                  curve: Curves.easeInOutSine,
                  builder: (context, progressValue, child) {
                    return TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 1000),
                      curve: Curves.easeIn,
                      builder: (context, opacityValue, child) {
                        return Opacity(
                          opacity: opacityValue,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Elegant, thin, slow progress line
                              Container(
                                width: Get.width * 0.4,
                                height: 2,
                                decoration: BoxDecoration(
                                  color: AppColors.camel.withValues(
                                    alpha: 0.15,
                                  ),
                                  borderRadius: BorderRadius.circular(1),
                                ),
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  width: Get.width * 0.4 * progressValue,
                                  height: 2,
                                  decoration: BoxDecoration(
                                    color: AppColors.camel,
                                    borderRadius: BorderRadius.circular(1),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.camel.withValues(
                                          alpha: 0.3,
                                        ),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: Get.height * 0.015),

                              // Subtle text below progress line
                              Text(
                                'Initializing Seamless Experience',
                                style: GoogleFonts.outfit(
                                  color: AppColors.charcoal.withValues(
                                    alpha: 0.4,
                                  ),
                                  fontSize: Get.width * 0.022,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
