import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/app/widgets/custom_button.dart';
import 'package:ecom_app/app/widgets/custom_text_field.dart';
import 'package:ecom_app/app/utils/responsive.dart';
import '../../controllers/auth_controller.dart';

class ShopperAuthView extends StatelessWidget {
  final AuthController controller;

  const ShopperAuthView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final w = context.screenWidth;
    final h = context.screenHeight;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: h * 0.02),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Premium Graphic Anchor
          Center(
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.greyLight, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.charcoal.withValues(alpha: 0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Image.asset(
                'assets/logo/logo.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.shopping_bag_outlined,
                    color: AppColors.camel,
                    size: 28,
                  );
                },
              ),
            ),
          ),
          SizedBox(height: w * 0.04),

          // Rich Typography (Matches Admin styling)
          Text(
            'Welcome to Velvet Maison',
            style: GoogleFonts.playfairDisplay(
              fontSize: w * 0.06,
              fontWeight: FontWeight.w700,
              color: AppColors.charcoal,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Sign in to access exclusive collections.',
            style: GoogleFonts.outfit(
              fontSize: 12.5,
              color: AppColors.grey,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: w * 0.06),

          // Single Elegant Card (Matches Admin card style)
          Container(
            padding: EdgeInsets.all(w * 0.04),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(w * 0.05),
              border: Border.all(color: AppColors.greyLight, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Social logins inside card
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
                SizedBox(height: w * 0.045),

                // Divider inside card
                Row(
                  children: [
                    const Expanded(
                      child: Divider(color: AppColors.greyLight, thickness: 1),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: w * 0.025),
                      child: Text(
                        'or use your email',
                        style: GoogleFonts.outfit(
                          color: AppColors.grey,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Divider(color: AppColors.greyLight, thickness: 1),
                    ),
                  ],
                ),
                SizedBox(height: w * 0.045),

                // Input and Action button
                Obx(
                  () => AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    child: controller.isShopperLogin.value
                        ? _buildLoginView(context, w, h)
                        : _buildSignupView(context, w, h),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: h * 0.03),

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

  Widget _buildLoginView(BuildContext context, double w, double h) {
    final theme = Theme.of(context);
    return Column(
      key: const ValueKey('shopper_login'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomTextField(
          controller: controller.shopperEmailController,
          label: 'Email Address',
          hinttext: 'you@domain.com',
          keyboardType: TextInputType.emailAddress,
          icon: Icons.email_outlined,
        ),
        CustomTextField(
          controller: controller.shopperPasswordController,
          label: 'Password',
          hinttext: 'Enter your password',
          obscureText: true,
          icon: Icons.lock_outline,
        ),
        SizedBox(height: w * 0.015),
        Obx(
          () => CustomButton(
            icon: Icons.login_rounded,
            text: 'Sign In',
            onPressed: controller.status.value == AuthStatus.loading
                ? null
                : controller.signInShopper,
            isLoading: controller.status.value == AuthStatus.loading,
          ),
        ),
        SizedBox(height: w * 0.03),
        Center(
          child: GestureDetector(
            onTap: () => controller.isShopperLogin.value = false,
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: w * 0.035,
                  color: AppColors.charcoal,
                ),
                children: const [
                  TextSpan(text: 'New shopper? '),
                  TextSpan(
                    text: 'Create Account',
                    style: TextStyle(
                      color: AppColors.camel,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignupView(BuildContext context, double w, double h) {
    final theme = Theme.of(context);
    return Column(
      key: const ValueKey('shopper_signup'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomTextField(
          controller: controller.shopperNameController,
          label: 'Full Name',
          hinttext: 'Enter your full name',
          icon: Icons.person_outline,
        ),
        CustomTextField(
          controller: controller.shopperEmailController,
          label: 'Email Address',
          hinttext: 'you@domain.com',
          keyboardType: TextInputType.emailAddress,
          icon: Icons.email_outlined,
        ),
        CustomTextField(
          controller: controller.shopperPasswordController,
          label: 'Password',
          hinttext: 'Create a password',
          obscureText: true,
          icon: Icons.lock_outline,
        ),
        SizedBox(height: w * 0.015),
        Obx(
          () => CustomButton(
            icon: Icons.person_add_alt_1_rounded,
            text: 'Create Account',
            onPressed: controller.status.value == AuthStatus.loading
                ? null
                : controller.signUpShopper,
            isLoading: controller.status.value == AuthStatus.loading,
          ),
        ),
        SizedBox(height: w * 0.03),
        Center(
          child: GestureDetector(
            onTap: () => controller.isShopperLogin.value = true,
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: w * 0.035,
                  color: AppColors.charcoal,
                ),
                children: const [
                  TextSpan(text: 'Already have an account? '),
                  TextSpan(
                    text: 'Sign In',
                    style: TextStyle(
                      color: AppColors.camel,
                      fontWeight: FontWeight.w700,
                    ),
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
