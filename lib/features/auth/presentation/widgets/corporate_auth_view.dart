import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/app/widgets/custom_button.dart';
import 'package:ecom_app/app/widgets/custom_text_field.dart';
import 'package:ecom_app/app/widgets/custom_dropdown_field.dart';
import '../../controllers/auth_controller.dart';

class CorporateAuthView extends StatelessWidget {
  final AuthController controller;

  const CorporateAuthView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final w = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      padding: .symmetric(horizontal: w * 0.06, vertical: w * 0.02),
      child: Column(
        crossAxisAlignment: .stretch,
        children: [
          // Premium Graphic Anchor
          Center(
            child: Container(
              padding: .all(w * 0.02),
              decoration: BoxDecoration(
                color: AppColors.camelLight.withValues(alpha: 0.1),
                shape: .circle,
              ),
              child: Container(
                padding: .all(w * 0.02),
                decoration: BoxDecoration(
                  color: AppColors.camelLight.withValues(alpha: 0.2),
                  shape: .circle,
                ),
                child: Container(
                  padding: .all(w * 0.035),
                  decoration: const BoxDecoration(
                    color: AppColors.camel,
                    shape: .circle,
                  ),
                  child: Icon(
                    Icons.business_outlined,
                    size: w * 0.08,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: w * 0.01),

          // Rich Typography
          Obx(
            () => Text(
              controller.isCorporateLogin.value
                  ? 'Corporate Access'
                  : 'Corporate Solutions',
              style: theme.textTheme.displayMedium?.copyWith(
                color: AppColors.charcoal,
                fontWeight: .w700,
              ),
              textAlign: .center,
            ),
          ),
          SizedBox(height: w * 0.005),
          Obx(
            () => Text(
              controller.isCorporateLogin.value
                  ? 'Log in to manage bulk orders.'
                  : 'Premium uniforms and bulk ordering.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppColors.grey,
                height: 1.2,
                fontSize: w * 0.03,
                fontWeight: .w500,
              ),
              textAlign: .center,
            ),
          ),
          SizedBox(height: w * 0.04),

          // Elevated Content Area (Grouped Card)
          Container(
            padding: .symmetric(horizontal: w * 0.05, vertical: w * 0.03),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: .circular(w * 0.04),
              border: .all(color: AppColors.greyLight.withValues(alpha: 0.5)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.charcoal.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Obx(
              () => AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: controller.isCorporateLogin.value
                    ? _buildLoginView(context, theme, w)
                    : _buildSignupView(context, theme, w),
              ),
            ),
          ),

          SizedBox(height: w * 0.06),
          _buildPrivacyTerms(theme, w),
          SizedBox(height: w * 0.04),
        ],
      ),
    );
  }

  Widget _buildPrivacyTerms(ThemeData theme, double w) {
    return Center(
      child: Padding(
        padding: .symmetric(horizontal: w * 0.04),
        child: RichText(
          textAlign: .center,
          text: TextSpan(
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.grey,
              fontSize: w * 0.028,
              height: 1.5,
            ),
            children: [
              const TextSpan(text: 'By continuing, you agree to our '),
              TextSpan(
                text: 'Terms of Service',
                style: TextStyle(
                  color: AppColors.camel,
                  fontWeight: .w600,
                  decoration: .underline,
                  decorationColor: AppColors.charcoal.withValues(alpha: 0.3),
                ),
              ),
              const TextSpan(text: '\nand '),
              TextSpan(
                text: 'Privacy Policy',
                style: TextStyle(
                  color: AppColors.camel,
                  fontWeight: .w600,
                  decoration: .underline,
                  decorationColor: AppColors.charcoal.withValues(alpha: 0.3),
                ),
              ),
              const TextSpan(text: '.'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginView(BuildContext context, ThemeData theme, double w) {
    return Column(
      key: const ValueKey('corporate_login'),
      crossAxisAlignment: .stretch,
      children: [
        CustomTextField(
          controller: controller.corporateEmailController,
          label: 'Corporate Email',
          hinttext: 'procurement@company.com',
          keyboardType: TextInputType.emailAddress,
          icon: Icons.email_outlined,
        ),
        CustomTextField(
          controller: controller.corporatePasswordController,
          label: 'Password',
          hinttext: 'Enter your password',
          obscureText: true,
          icon: Icons.lock_outline,
        ),
        SizedBox(height: w * 0.04),
        Obx(
          () => CustomButton(
            text: 'Access Dashboard',
            onPressed: controller.status.value == AuthStatus.loading
                ? null
                : controller.signInCorporate,
            isLoading: controller.status.value == AuthStatus.loading,
          ),
        ),
        SizedBox(height: w * 0.03),
        Center(
          child: GestureDetector(
            onTap: () => controller.isCorporateLogin.value = false,
            child: RichText(
              textAlign: .center,
              text: TextSpan(
                style: theme.textTheme.bodySmall?.copyWith(fontSize: w * 0.035),
                children: const [
                  TextSpan(text: 'New corporate client? '),
                  TextSpan(
                    text: 'Request Access',
                    style: TextStyle(color: AppColors.camel, fontWeight: .w700),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignupView(BuildContext context, ThemeData theme, double w) {
    return Column(
      key: const ValueKey('corporate_signup'),
      crossAxisAlignment: .stretch,
      children: [
        CustomTextField(
          controller: controller.companyNameController,
          label: 'Company Name',
          hinttext: 'Enter registered company name',
          icon: Icons.business_outlined,
        ),
        CustomTextField(
          controller: controller.ntnController,
          label: 'National Tax Number (NTN)',
          hinttext: 'XXXXXXX-X',
          keyboardType: TextInputType.number,
          icon: Icons.receipt_long_outlined,
        ),
        CustomTextField(
          controller: controller.corporateEmailController,
          label: 'Corporate Email',
          hinttext: 'procurement@company.com',
          keyboardType: TextInputType.emailAddress,
          icon: Icons.email_outlined,
        ),
        CustomTextField(
          controller: controller.corporatePasswordController,
          label: 'Password',
          hinttext: 'Create a strong password',
          obscureText: true,
          icon: Icons.lock_outline,
        ),
        SizedBox(height: w * 0.015),
        Obx(
          () => CustomDropdownField(
            label: 'Estimated Volume',
            icon: Icons.pie_chart_outline,
            value: controller.selectedVolume.value,
            items: controller.volumeOptions,
            onChanged: (newValue) {
              if (newValue != null) {
                controller.selectedVolume.value = newValue;
              }
            },
            margin: EdgeInsets.only(bottom: w * 0.04),
          ),
        ),
        SizedBox(height: w * 0.04),
        Obx(
          () => CustomButton(
            text: 'Request Access',
            onPressed: controller.status.value == AuthStatus.loading
                ? null
                : controller.registerCorporate,
            isLoading: controller.status.value == AuthStatus.loading,
          ),
        ),
        SizedBox(height: w * 0.03),
        Center(
          child: GestureDetector(
            onTap: () => controller.isCorporateLogin.value = true,
            child: RichText(
              textAlign: .center,
              text: TextSpan(
                style: theme.textTheme.bodySmall?.copyWith(fontSize: w * 0.035),
                children: const [
                  TextSpan(text: 'Existing client? '),
                  TextSpan(
                    text: 'Sign In',
                    style: TextStyle(color: AppColors.camel, fontWeight: .w700),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
