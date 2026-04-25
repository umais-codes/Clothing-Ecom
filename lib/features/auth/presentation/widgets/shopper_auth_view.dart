import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/app/widgets/custom_button.dart';
import 'package:ecom_app/app/widgets/custom_text_field.dart';
import 'package:ecom_app/features/onboarding/presentation/widgets/pin_input_field.dart';
import '../controllers/auth_controller.dart';

class ShopperAuthView extends StatelessWidget {
  final AuthController controller;

  const ShopperAuthView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    return SingleChildScrollView(
      padding: .symmetric(horizontal: w * 0.06, vertical: w * 0.02),
      child: Column(
        crossAxisAlignment: .stretch,
        children: [
          // Premium Graphic Anchor
          Center(
            child: Container(
              padding: .symmetric(horizontal: w * 0.02, vertical: w * 0.02),
              decoration: BoxDecoration(
                color: AppColors.camelLight.withValues(alpha: 0.1),
                shape: .circle,
              ),
              child: Container(
                padding: .symmetric(horizontal: w * 0.02, vertical: w * 0.02),
                decoration: BoxDecoration(
                  color: AppColors.camelLight.withValues(alpha: 0.2),
                  shape: .circle,
                ),
                child: Container(
                  padding: .symmetric(
                    horizontal: w * 0.035,
                    vertical: w * 0.035,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.camel,
                    shape: .circle,
                  ),
                  child: Icon(
                    Icons.shopping_bag_outlined,
                    size: w * 0.08,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: w * 0.02),

          // Rich Typography
          Text(
            'Welcome to Aura',
            style: theme.textTheme.displayMedium?.copyWith(
              color: AppColors.charcoal,
              fontWeight: .w700,
            ),
            textAlign: .center,
          ),
          SizedBox(height: w * 0.005),
          Text(
            'Sign in to access exclusive collections.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: AppColors.grey,
              height: 1.5,
              fontSize: w * 0.035,
            ),
            textAlign: .center,
          ),
          SizedBox(height: w * 0.04),

          // Grouped Social Area (Soft Tint)
          Container(
            padding: .all(w * 0.02),
            decoration: BoxDecoration(
              color: AppColors.offWhite,
              borderRadius: .circular(w * 0.04),
              border: .all(color: AppColors.camelLight.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                _SocialButton(
                  icon: Icons.g_mobiledata_rounded,
                  label: 'Continue with Google',
                  onTap: () => controller.continueWithSocial('Google'),
                  w: w,
                  isGoogle: true,
                ),
                SizedBox(height: h * 0.015),
                _SocialButton(
                  icon: Icons.apple_rounded,
                  label: 'Continue with Apple',
                  onTap: () => controller.continueWithSocial('Apple'),
                  w: w,
                  isGoogle: false,
                ),
              ],
            ),
          ),

          SizedBox(height: w * 0.02),
          Row(
            children: [
              const Expanded(
                child: Divider(color: AppColors.greyLight, thickness: 1),
              ),
              Padding(
                padding: .symmetric(horizontal: w * 0.02),
                child: Text(
                  'or use your mobile',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.grey,
                    fontWeight: .w600,
                  ),
                ),
              ),
              const Expanded(
                child: Divider(color: AppColors.greyLight, thickness: 1),
              ),
            ],
          ),
          SizedBox(height: h * 0.01),

          // Elevated Form Area
          Container(
            padding: .symmetric(horizontal: w * 0.05, vertical: w * 0.02),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: .circular(w * 0.04),
              border: .all(color: AppColors.greyLight),
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
                child: controller.showShopperOtpField.value
                    ? _buildOtpState(context, w, h)
                    : _buildPhoneState(context, w, h),
              ),
            ),
          ),

          SizedBox(height: h * 0.02),

          // Privacy and Terms
          Center(
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
                        decorationColor: AppColors.charcoal.withValues(
                          alpha: 0.3,
                        ),
                      ),
                    ),
                    const TextSpan(text: '\nand '),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: TextStyle(
                        color: AppColors.camel,
                        fontWeight: .w600,
                        decoration: .underline,
                        decorationColor: AppColors.charcoal.withValues(
                          alpha: 0.3,
                        ),
                      ),
                    ),
                    const TextSpan(text: '.'),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: h * 0.02),
        ],
      ),
    );
  }

  Widget _buildPhoneState(BuildContext context, double w, double h) {
    return Column(
      key: const ValueKey('phone_state'),
      crossAxisAlignment: .stretch,
      children: [
        CustomTextField(
          controller: controller.shopperPhoneController,
          label: 'Mobile Number',
          hinttext: '3XX XXXXXXX',
          keyboardType: .phone,
          icon: Icons.phone_outlined,
        ),
        SizedBox(height: w * 0.015),
        Obx(
          () => CustomButton(
            icon: Icons.near_me_rounded,
            text: 'Send Code',
            onPressed: controller.status.value == AuthStatus.loading
                ? null
                : controller.sendShopperOtp,
            isLoading: controller.status.value == AuthStatus.loading,
          ),
        ),
      ],
    );
  }

  Widget _buildOtpState(BuildContext context, double w, double h) {
    final theme = Theme.of(context);
    return Column(
      key: const ValueKey('otp_state'),
      crossAxisAlignment: .stretch,
      children: [
        Row(
          mainAxisAlignment: .spaceBetween,
          children: [
            Text(
              'Verification Code',
              style: theme.textTheme.labelLarge?.copyWith(
                fontSize: w * 0.035,
                color: AppColors.charcoal,
              ),
            ),
            GestureDetector(
              onTap: () => controller.showShopperOtpField.value = false,
              child: Text(
                'Edit Number',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: AppColors.camel,
                  fontSize: w * 0.032,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.camel,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: h * 0.01),
        PinInputField(
          controller: controller.shopperOtpController,
          onCompleted: (v) => controller.verifyShopperOtp(),
        ),
        SizedBox(height: h * 0.015),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Didn't receive code? ",
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: w * 0.035,
                color: AppColors.grey,
              ),
            ),
            GestureDetector(
              onTap: controller.sendShopperOtp,
              child: Text(
                'Resend',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.camel,
                  fontWeight: FontWeight.w700,
                  fontSize: w * 0.035,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: h * 0.015),
        Obx(
          () => CustomButton(
            text: 'Verify & Login',
            onPressed: controller.status.value == AuthStatus.loading
                ? null
                : controller.verifyShopperOtp,
            isLoading: controller.status.value == AuthStatus.loading,
          ),
        ),
      ],
    );
  }
}

class _SocialButton extends StatefulWidget {
  final VoidCallback onTap;
  final IconData icon;
  final String label;
  final double w;
  final bool isGoogle;

  const _SocialButton({
    required this.onTap,
    required this.icon,
    required this.label,
    required this.w,
    this.isGoogle = false,
  });

  @override
  State<_SocialButton> createState() => _SocialButtonState();
}

class _SocialButtonState extends State<_SocialButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        child: Container(
          padding: .symmetric(vertical: widget.w * 0.03),
          decoration: BoxDecoration(
            color: widget.isGoogle
                ? AppColors.camel.withValues(alpha: 0.2)
                : AppColors.charcoal,
            borderRadius: BorderRadius.circular(12),
            border: widget.isGoogle
                ? .all(
                    color: AppColors.camel.withValues(alpha: 0.2),
                    width: 1.0,
                  )
                : null,
            boxShadow: widget.isGoogle
                ? [
                    BoxShadow(
                      color: AppColors.charcoal.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.icon,
                size: widget.w * 0.06,
                color: widget.isGoogle ? AppColors.charcoal : AppColors.white,
              ),
              const SizedBox(width: 12),
              Text(
                widget.label,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: widget.isGoogle ? AppColors.charcoal : AppColors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: widget.w * 0.036,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
