import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/app/widgets/custom_button.dart';
import 'package:ecom_app/app/widgets/custom_text_field.dart';
import 'package:ecom_app/app/widgets/custom_dropdown_field.dart';
import 'package:ecom_app/app/utils/constants.dart';
import '../../controllers/auth_controller.dart';
import 'document_picker_box.dart';

class VendorAuthView extends StatelessWidget {
  final AuthController controller;

  const VendorAuthView({super.key, required this.controller});

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
                    Icons.storefront_outlined,
                    size: w * 0.08,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: w * 0.02),

          // Rich Typography
          Obx(
            () => Text(
              controller.isVendorLogin.value
                  ? 'Partner Access'
                  : 'Partner with Us',
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
              controller.isVendorLogin.value
                  ? 'Log in to manage your brand portal.'
                  : 'Reach millions of shoppers with Aura.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppColors.grey,
                height: 1.5,
                fontSize: w * 0.035,
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
                child: controller.isVendorLogin.value
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
      key: const ValueKey('vendor_login'),
      crossAxisAlignment: .stretch,
      children: [
        CustomTextField(
          controller: controller.vendorEmailController,
          label: 'Business Email',
          hinttext: 'brand@domain.com',
          keyboardType: TextInputType.emailAddress,
          icon: Icons.email_outlined,
        ),
        CustomTextField(
          controller: controller.vendorPasswordController,
          label: 'Password',
          hinttext: 'Enter your password',
          obscureText: true,
          icon: Icons.lock_outline,
        ),
        SizedBox(height: w * 0.04),
        Obx(
          () => CustomButton(
            text: 'Log In to Brand Portal',
            onPressed: controller.status.value == AuthStatus.loading
                ? null
                : controller.signInVendor,
            isLoading: controller.status.value == AuthStatus.loading,
          ),
        ),
        SizedBox(height: w * 0.03),
        Center(
          child: GestureDetector(
            onTap: () => controller.isVendorLogin.value = false,
            child: RichText(
              textAlign: .center,
              text: TextSpan(
                style: theme.textTheme.bodySmall?.copyWith(fontSize: w * 0.035),
                children: const [
                  TextSpan(text: 'New partner? '),
                  TextSpan(
                    text: 'Apply Here',
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
      key: const ValueKey('vendor_signup'),
      crossAxisAlignment: .stretch,
      children: [
        CustomTextField(
          controller: controller.brandNameController,
          label: 'Brand Name',
          hinttext: 'Enter your fashion brand name',
          icon: Icons.storefront_outlined,
        ),
        CustomTextField(
          controller: controller.contactPersonController,
          label: 'Contact Person',
          hinttext: 'Enter full name',
          icon: Icons.person_outline,
        ),
        CustomTextField(
          controller: controller.vendorEmailController,
          label: 'Business Email',
          hinttext: 'brand@domain.com',
          keyboardType: TextInputType.emailAddress,
          icon: Icons.email_outlined,
        ),
        CustomTextField(
          controller: controller.vendorPasswordController,
          label: 'Password',
          hinttext: 'Create a strong password',
          obscureText: true,
          icon: Icons.lock_outline,
        ),
        SizedBox(height: w * 0.02),
        Obx(
          () => CustomDropdownField(
            label: 'Business Category',
            icon: Icons.category_outlined,
            value: controller.selectedVendorCategory.value,
            items: AppConstants.categories,
            onChanged: (value) {
              if (value != null) {
                controller.selectedVendorCategory.value = value;
              }
            },
          ),
        ),
        SizedBox(height: w * 0.03),
        Padding(
          padding: .symmetric(horizontal: w * 0.018),
          child: Row(
            children: [
              Icon(
                Icons.file_present_outlined,
                size: w * 0.045,
                color: AppColors.camel,
              ),
              SizedBox(width: w * 0.02),
              Text(
                'KYC Verification',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontSize: w * 0.032,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: w * 0.015),
        Obx(
          () => DocumentPickerBox(
            title: 'CNIC / National ID',
            subtitle: 'Front and back scan only (PDF, JPG)',
            isUploaded: controller.hasCnicUploaded.value,
            fileName: controller.cnicFileName.value,
            onTap: controller.pickCnicDocument,
          ),
        ),
        SizedBox(height: w * 0.015),
        Obx(
          () => DocumentPickerBox(
            title: 'SECP Registration',
            subtitle: 'Business incorporation certificate only (PDF, JPG)',
            isUploaded: controller.hasSecpUploaded.value,
            fileName: controller.secpFileName.value,
            onTap: controller.pickSecpDocument,
          ),
        ),
        SizedBox(height: w * 0.04),
        Obx(
          () => CustomButton(
            text: 'Submit Application',
            onPressed: controller.status.value == AuthStatus.loading
                ? null
                : controller.registerVendor,
            isLoading: controller.status.value == AuthStatus.loading,
          ),
        ),
        SizedBox(height: w * 0.03),
        Center(
          child: GestureDetector(
            onTap: () => controller.isVendorLogin.value = true,
            child: RichText(
              textAlign: .center,
              text: TextSpan(
                style: theme.textTheme.bodySmall?.copyWith(fontSize: w * 0.035),
                children: const [
                  TextSpan(text: 'Already a partner? '),
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
