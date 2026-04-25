import 'package:flutter/material.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/app/widgets/custom_button.dart';

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
                  color: AppColors.camelLight.withValues(alpha: 0.3),
                  shape: .circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.hourglass_empty_rounded,
                    size: 48,
                    color: AppColors.camel,
                  ),
                ),
              ),
              SizedBox(height: h * 0.025),

              Text(
                'Application Received',
                style: theme.textTheme.displaySmall?.copyWith(
                  color: AppColors.charcoal,
                ),
                textAlign: .center,
              ),
              SizedBox(height: h * 0.01),

              Text(
                'Thank you for applying to be an Aura Partner. Our team will review your KYC documents and get back to you within 24-48 hours.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.grey,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              CustomButton(
                text: 'Return to Home',
                onPressed: () {
                  // Get.offAllNamed('/home');
                },
              ),
              SizedBox(height: h * 0.04),
            ],
          ),
        ),
      ),
    );
  }
}
