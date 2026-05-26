import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/app/utils/responsive.dart';
import 'package:ecom_app/features/super_admin/presentation/widgets/monetization/subscription_plan_builder.dart';
import 'package:ecom_app/features/super_admin/presentation/widgets/screen_header.dart';

class SubscriptionPlanBuilderScreen extends StatelessWidget {
  const SubscriptionPlanBuilderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ScreenHeader(
              title: 'SaaS Plan Builder',
              subtitle:
                  'Create and configure platform subscription tiers and pricing',
              leading: GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: w * 0.01,
                    horizontal: w * 0.02,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.offWhite,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.greyLight, width: 1),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 14,
                    color: AppColors.charcoal,
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: context.responsive(
                    mobile: w * 0.03,
                    tablet: w * 0.03,
                    desktop: w * 0.03,
                  ),
                  vertical: context.responsive(
                    mobile: w * 0.04,
                    tablet: w * 0.04,
                    desktop: w * 0.04,
                  ),
                ),
                child: const SubscriptionPlanBuilder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
