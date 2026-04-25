import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/app/widgets/custom_button.dart';
import 'package:ecom_app/features/onboarding/presentation/controllers/onboarding_controller.dart';
import 'package:ecom_app/features/onboarding/presentation/widgets/onboarding_progress_bar.dart';
import 'package:ecom_app/features/onboarding/presentation/widgets/pin_input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class AuthScreen extends GetView<OnboardingController> {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Back + Progress ────────────────────────────────────────────
            Padding(
              padding: .fromLTRB(w * 0.03, h * 0.015, w * 0.05, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: controller.prevPage,
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                    color: AppColors.charcoal,
                  ),
                  Expanded(child: OnboardingProgressBar(step: 4, total: 4)),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: .fromLTRB(w * 0.07, h * 0.03, w * 0.07, h * 0.03),
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    // ── Step label ──────────────────────────────────────────
                    Container(
                      padding: .symmetric(
                        horizontal: w * 0.03,
                        vertical: h * 0.006,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.camelLight,
                        borderRadius: .circular(4),
                      ),
                      child: Text(
                        'STEP 3 OF 3',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: AppColors.camel,
                          fontSize: w * 0.028,
                        ),
                      ),
                    ),

                    SizedBox(height: h * 0.02),

                    Text(
                      'Initialize\nAccount',
                      style: theme.textTheme.displayLarge?.copyWith(
                        fontSize: w * 0.1,
                      ),
                    ),

                    SizedBox(height: h * 0.01),

                    Text(
                      'Join our global community of brands and\nshoppers on a unified platform.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontSize: w * 0.035,
                        color: AppColors.grey,
                      ),
                    ),

                    SizedBox(height: h * 0.04),

                    // ── Social Logins ───────────────────────────────────────
                    _GhostSocialButton(
                      onTap: controller.continueWithGoogle,
                      icon: Icons.g_mobiledata_rounded,
                      label: 'Continue with Google',
                      w: w,
                    ),

                    SizedBox(height: h * 0.016),

                    _GhostSocialButton(
                      onTap: controller.continueWithApple,
                      icon: Icons.apple_rounded,
                      label: 'Continue with Apple',
                      w: w,
                    ),

                    SizedBox(height: h * 0.038),

                    // ── Divider ─────────────────────────────────────────────
                    Row(
                      children: [
                        const Expanded(child: Divider(color: AppColors.greyLight)),
                        Padding(
                          padding: .symmetric(horizontal: w * 0.04),
                          child: Text(
                            'OR USE MOBILE',
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontSize: w * 0.025,
                              color: AppColors.grey,
                            ),
                          ),
                        ),
                        const Expanded(child: Divider(color: AppColors.greyLight)),
                      ],
                    ),

                    SizedBox(height: h * 0.035),

                    // ── Interactive Auth Flow ────────────────────────────────
                    Obx(() => AnimatedSwitcher(
                      duration: const Duration(milliseconds: 450),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      child: controller.showOtpField.value 
                        ? _buildOtpState(context, w, h) 
                        : _buildPhoneState(context, w, h),
                    )),

                    SizedBox(height: h * 0.04),

                    // ── Terms ────────────────────────────────────────────────
                    Center(
                      child: Padding(
                        padding: .symmetric(horizontal: w * 0.04),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: w * 0.028,
                              height: 1.6,
                            ),
                            children: [
                              const TextSpan(text: 'By continuing, you agree to our '),
                              TextSpan(
                                text: 'Terms',
                                style: TextStyle(
                                  color: AppColors.camel,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const TextSpan(text: ' and '),
                              TextSpan(
                                text: 'Privacy Policy',
                                style: TextStyle(
                                  color: AppColors.camel,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneState(BuildContext context, double w, double h) {
    final theme = Theme.of(context);
    return Column(
      key: const ValueKey('phone_state'),
      crossAxisAlignment: .start,
      children: [
        Text(
          'MOBILE NUMBER',
          style: theme.textTheme.labelLarge?.copyWith(fontSize: w * 0.028),
        ),
        SizedBox(height: h * 0.012),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: .circular(w * 0.03),
            border: .all(color: AppColors.grey.withValues(alpha: 0.2), width: 1.2),
          ),
          child: Row(
            children: [
              Container(
                padding: .symmetric(horizontal: w * 0.04, vertical: h * 0.018),
                decoration: BoxDecoration(
                  border: Border(right: BorderSide(color: AppColors.grey.withValues(alpha: 0.15))),
                ),
                child: Row(
                  children: [
                    Text('🇵🇰', style: TextStyle(fontSize: w * 0.045)),
                    SizedBox(width: w * 0.015),
                    Text('+92', style: theme.textTheme.titleLarge?.copyWith(fontSize: w * 0.038, fontWeight: .w700)),
                  ],
                ),
              ),
              Expanded(
                child: TextField(
                  controller: controller.phoneController,
                  keyboardType: .phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
                  style: theme.textTheme.bodyLarge?.copyWith(fontWeight: .w600),
                  decoration: const InputDecoration(
                    hintText: '3XX XXXXXXX',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: h * 0.03),
        CustomButton(
          text: 'Send Verification Code',
          onPressed: controller.isLoading.value ? null : controller.sendOtp,
          isLoading: controller.isLoading.value,
        ),
      ],
    );
  }

  Widget _buildOtpState(BuildContext context, double w, double h) {
    final theme = Theme.of(context);
    return Column(
      key: const ValueKey('otp_state'),
      crossAxisAlignment: .start,
      children: [
        Row(
          mainAxisAlignment: .spaceBetween,
          children: [
            Text(
              'VERIFICATION CODE',
              style: theme.textTheme.labelLarge?.copyWith(fontSize: w * 0.028),
            ),
            GestureDetector(
              onTap: () => controller.showOtpField.value = false,
              child: Text(
                'Edit Number',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: AppColors.camel,
                  fontSize: w * 0.028,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: h * 0.012),
        PinInputField(
          controller: controller.otpController,
          onCompleted: (v) => controller.verifyOtp(),
        ),
        SizedBox(height: h * 0.025),
        Row(
          mainAxisAlignment: .center,
          children: [
            Text(
              "Didn't receive code? ",
              style: theme.textTheme.bodySmall?.copyWith(fontSize: w * 0.03),
            ),
            GestureDetector(
              onTap: controller.sendOtp,
              child: Text(
                'Resend',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.camel,
                  fontWeight: .w700,
                  fontSize: w * 0.03,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: h * 0.035),
        CustomButton(
          text: 'Verify & Initialize',
          onPressed: controller.isLoading.value ? null : controller.verifyOtp,
          isLoading: controller.isLoading.value,
        ),
      ],
    );
  }
}

class _GhostSocialButton extends StatefulWidget {
  final VoidCallback onTap;
  final IconData icon;
  final String label;
  final double w;

  const _GhostSocialButton({
    required this.onTap,
    required this.icon,
    required this.label,
    required this.w,
  });

  @override
  State<_GhostSocialButton> createState() => _GhostSocialButtonState();
}

class _GhostSocialButtonState extends State<_GhostSocialButton> {
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
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const .symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: .circular(widget.w * 0.03),
            border: Border.all(color: AppColors.grey.withValues(alpha: 0.15), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: AppColors.charcoal.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: .center,
            children: [
              Icon(widget.icon, size: widget.w * 0.06, color: AppColors.charcoal),
              const SizedBox(width: 12),
              Text(
                widget.label,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: .w600,
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
