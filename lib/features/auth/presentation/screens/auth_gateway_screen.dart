import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/features/onboarding/presentation/controllers/onboarding_controller.dart';
import 'package:ecom_app/app/utils/responsive.dart';
import '../../controllers/auth_controller.dart';
import '../widgets/shopper_auth_view.dart';
import '../widgets/vendor_auth_view.dart';
import '../widgets/corporate_auth_view.dart';

class AuthGatewayScreen extends StatelessWidget {
  const AuthGatewayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();
    final theme = Theme.of(context);
    final w = context.screenWidth;
    final h = context.screenHeight;

    bool isRoleLocked = false;
    if (Get.isRegistered<OnboardingController>()) {
      final onboardingRole =
          Get.find<OnboardingController>().selectedRole.value;
      if (onboardingRole != null) {
        isRoleLocked = true;
        if (onboardingRole == UserRole.shopper) {
          controller.setRole(AuthRole.shopper);
        } else if (onboardingRole == UserRole.fashionBrand) {
          controller.setRole(AuthRole.vendor);
        } else if (onboardingRole == UserRole.corporateBuyer) {
          controller.setRole(AuthRole.corporate);
        }
      }
    }

    return DefaultTabController(
      length: 3,
      initialIndex: controller.selectedRole.value.index,
      child: Scaffold(
        backgroundColor: AppColors.offWhite,
        body: SafeArea(
          child: Column(
            children: [
              // Premium Header
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: w * 0.04,
                  vertical: h * 0.015,
                ),
                child: Row(
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        if (Get.isRegistered<OnboardingController>()) {
                          Get.find<OnboardingController>().prevPage();
                        } else {
                          Get.back();
                        }
                      },
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 20,
                      ),
                      color: AppColors.charcoal,
                    ),
                    const Spacer(),
                    Image.asset(
                      'assets/logo/logo.png',
                      height: 38,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Text(
                          'VELVET MAISON',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.charcoal,
                            letterSpacing: 1.5,
                          ),
                        );
                      },
                    ),
                    const Spacer(),
                    const SizedBox(
                      width: 32,
                    ), // Spacer to balance back button width
                  ],
                ),
              ),
              SizedBox(height: h * 0.01),

              // TabBar for Role Selection
              if (!isRoleLocked) ...[
                Container(
                  margin: EdgeInsets.symmetric(horizontal: w * 0.055),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(w * 0.03),
                    border: Border.all(color: AppColors.greyLight, width: 1),
                  ),
                  child: TabBar(
                    onTap: (index) {
                      controller.setRole(AuthRole.values[index]);
                    },
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: BoxDecoration(
                      color: AppColors.camel,
                      borderRadius: BorderRadius.circular(w * 0.03),
                    ),
                    labelColor: AppColors.white,
                    unselectedLabelColor: AppColors.charcoal,
                    labelStyle: theme.textTheme.labelLarge,
                    unselectedLabelStyle: theme.textTheme.labelLarge,
                    dividerColor: Colors.transparent,
                    tabs: const [
                      Tab(text: 'SHOPPER'),
                      Tab(text: 'BRAND'),
                      Tab(text: 'CORPORATE'),
                    ],
                  ),
                ),
                SizedBox(height: w * 0.02),
              ],

              // TabBarView for specific flows
              Expanded(
                child: TabBarView(
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    ShopperAuthView(controller: controller),
                    VendorAuthView(controller: controller),
                    CorporateAuthView(controller: controller),
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
