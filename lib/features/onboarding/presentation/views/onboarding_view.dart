import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/features/onboarding/presentation/controllers/onboarding_controller.dart';
import 'package:ecom_app/features/auth/presentation/screens/auth_gateway_screen.dart';
import 'package:ecom_app/features/onboarding/presentation/widgets/carousel_screen.dart';
import 'package:ecom_app/features/onboarding/presentation/widgets/personalization_screen.dart';
import 'package:ecom_app/features/onboarding/presentation/widgets/role_selection_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      resizeToAvoidBottomInset: true,
      body: PageView(
        controller: controller.pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: controller.onPageChanged,
        children: const [
          CarouselScreen(),
          RoleSelectionScreen(),
          PersonalizationScreen(),
          AuthGatewayScreen(),
        ],
      ),
    );
  }
}
