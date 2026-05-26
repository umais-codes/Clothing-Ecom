import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/app/widgets/custom_button.dart';
import 'package:ecom_app/app/widgets/custom_network_image.dart';
import 'package:ecom_app/features/onboarding/presentation/controllers/onboarding_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecom_app/app/utils/responsive.dart';

class CarouselScreen extends GetView<OnboardingController> {
  const CarouselScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final w = context.screenWidth;
    final h = context.screenHeight;

    return Scaffold(
      backgroundColor: AppColors.charcoal,
      body: Stack(
        children: [
          // ── Full-bleed image carousel ──────────────────────────────────
          PageView.builder(
            itemCount: controller.carouselSlides.length,
            onPageChanged: controller.onCarouselPageChanged,
            itemBuilder: (_, index) {
              final slide = controller.carouselSlides[index];
              return CustomNetworkImage(
                imageUrl: slide['image']!,
                fit: .cover,
                width: .infinity,
                height: .infinity,
              );
            },
          ),

          // ── Bottom-up dark gradient scrim ──────────────────────────────
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: .topCenter,
                  end: .bottomCenter,
                  stops: const [0.35, 0.7, 1.0],
                  colors: [
                    Colors.transparent,
                    AppColors.charcoal.withValues(alpha: 0.65),
                    AppColors.charcoal.withValues(alpha: 0.97),
                  ],
                ),
              ),
            ),
          ),

          // ── Top: Skip button ───────────────────────────────────────────
          Positioned(
            top: h * 0.06,
            right: w * 0.05,
            child: SafeArea(
              child: GestureDetector(
                onTap: controller.skipOnboarding,
                child: Container(
                  padding: .symmetric(
                    horizontal: w * 0.035,
                    vertical: h * 0.007,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: .circular(30),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Text(
                    'Skip',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontSize: w * 0.03,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Bottom Content ─────────────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: .fromLTRB(w * 0.07, 0, w * 0.07, h * 0.04),
                child: Obx(() {
                  final slide =
                      controller.carouselSlides[controller.carouselPage.value];
                  return Column(
                    crossAxisAlignment: .start,
                    mainAxisSize: .min,
                    children: [
                      // Badge
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Container(
                          key: ValueKey(slide['badge']),
                          padding: .symmetric(
                            horizontal: w * 0.035,
                            vertical: h * 0.007,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.camel.withValues(alpha: 0.9),
                            borderRadius: .circular(4),
                          ),
                          child: Text(
                            slide['badge']!,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: Colors.white,
                              fontSize: w * 0.028,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: h * 0.01),

                      // Headline
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 350),
                        child: Text(
                          slide['title']!,
                          key: ValueKey(slide['title']),
                          style: theme.textTheme.displayLarge?.copyWith(
                            color: Colors.white,
                            fontSize: w * 0.11,
                          ),
                        ),
                      ),

                      SizedBox(height: h * 0.01),

                      // Subtitle
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          slide['subtitle']!,
                          key: ValueKey(slide['subtitle']),
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withValues(alpha: 0.72),
                            fontSize: w * 0.032,
                          ),
                        ),
                      ),

                      SizedBox(height: h * 0.02),

                      // Dot indicators
                      Row(
                        children: List.generate(
                          controller.carouselSlides.length,
                          (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: EdgeInsets.only(right: w * 0.018),
                            width: controller.carouselPage.value == i
                                ? w * 0.06
                                : w * 0.02,
                            height: h * 0.007,
                            decoration: BoxDecoration(
                              color: controller.carouselPage.value == i
                                  ? AppColors.camel
                                  : Colors.white.withValues(alpha: 0.35),
                              borderRadius: .circular(4),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: h * 0.02),

                      // Get Started Button
                      CustomButton(
                        text: 'Get Started',
                        onPressed: controller.nextPage,
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
