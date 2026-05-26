import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/app/utils/responsive.dart';
import 'package:ecom_app/app/widgets/custom_button.dart';
import 'package:ecom_app/features/super_admin/domain/models/subscription_plan.dart';
import '../controllers/vendor_dashboard_controller.dart';

class SubscriptionPlansView extends GetView<VendorDashboardController> {
  const SubscriptionPlansView({super.key});

  @override
  Widget build(BuildContext context) {
    final double sw = context.screenWidth;
    final double sh = context.screenHeight;

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: Text(
          'Choose Selling Plan',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w600,
            fontSize: sw * 0.055,
            color: AppColors.charcoal,
          ),
        ),
        backgroundColor: AppColors.white,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded),
          iconSize: sw * 0.06,
          onPressed: () => Get.back(),
          color: AppColors.charcoal,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(sw * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Subscribed to grow your business',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: sw * 0.05,
                  fontWeight: FontWeight.bold,
                  color: AppColors.charcoal,
                ),
              ),
              SizedBox(height: sh * 0.01),
              Text(
                'Choose the plan that fits your volume and business size. Switch or cancel anytime.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: sw * 0.03,
                  color: AppColors.grey,
                ),
              ),
              SizedBox(height: sh * 0.03),

              // Monthly/Yearly toggle
              Center(
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.greyLight.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Obx(() {
                    final isYearly = controller.isYearlyBilling.value;
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildToggleButton(
                          label: 'Monthly',
                          isSelected: !isYearly,
                          onTap: () => controller.isYearlyBilling.value = false,
                        ),
                        _buildToggleButton(
                          label: 'Yearly (Save 20%)',
                          isSelected: isYearly,
                          onTap: () => controller.isYearlyBilling.value = true,
                        ),
                      ],
                    );
                  }),
                ),
              ),
              SizedBox(height: sh * 0.035),

              // Plans cards
              Obx(() {
                final isYearly = controller.isYearlyBilling.value;
                final currentPlan = controller.activePlanName.value;

                return Column(
                  children: controller.availablePlans.map((plan) {
                    final isCurrent =
                        currentPlan.toLowerCase() == plan.name.toLowerCase();
                    final price = isYearly
                        ? plan.priceYearly
                        : plan.priceMonthly;
                    final period = isYearly ? '/ yr' : '/ mo';

                    return _buildPlanCard(
                      context: context,
                      sw: sw,
                      plan: plan,
                      priceText:
                          '\$${price.toStringAsFixed(price == 0 ? 0 : 2)}$period',
                      isCurrent: isCurrent,
                    );
                  }).toList(),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.charcoal.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? AppColors.charcoal : AppColors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard({
    required BuildContext context,
    required double sw,
    required SubscriptionPlan plan,
    required String priceText,
    required bool isCurrent,
  }) {
    final isPro = plan.name.toLowerCase() == 'pro';
    final cardBorderColor = isPro
        ? AppColors.camel
        : AppColors.greyLight.withValues(alpha: 0.3);

    return Container(
      margin: EdgeInsets.only(bottom: sw * 0.04),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorderColor, width: isPro ? 2 : 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.charcoal.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(sw * 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      plan.name,
                      style: GoogleFonts.outfit(
                        fontSize: sw * 0.05,
                        fontWeight: FontWeight.bold,
                        color: AppColors.charcoal,
                      ),
                    ),
                    if (isPro)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.camel.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'RECOMMENDED',
                          style: GoogleFonts.outfit(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: AppColors.camel,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: sw * 0.02),
                Text(
                  priceText,
                  style: GoogleFonts.outfit(
                    fontSize: sw * 0.075,
                    fontWeight: FontWeight.w800,
                    color: AppColors.charcoal,
                  ),
                ),
                SizedBox(height: sw * 0.04),
                Divider(color: AppColors.greyLight.withValues(alpha: 0.5)),
                SizedBox(height: sw * 0.03),

                // Features list
                _buildFeatureRow(
                  sw,
                  plan.maxProducts == 999999
                      ? 'Unlimited Products'
                      : 'Up to ${plan.maxProducts} Products',
                  true,
                ),
                _buildFeatureRow(
                  sw,
                  '${plan.maxStaffAccounts} Staff Account(s)',
                  true,
                ),
                _buildFeatureRow(
                  sw,
                  'AI Size Predictor Tools',
                  plan.enableAiSizePredictor,
                ),
                _buildFeatureRow(
                  sw,
                  'B2B Bulk Purchase Quoting',
                  plan.enableB2bBulkQuoting,
                ),
                _buildFeatureRow(
                  sw,
                  'Custom Brand Storefront',
                  plan.enableCustomStorefront,
                ),

                SizedBox(height: sw * 0.05),

                CustomButton(
                  text: isCurrent ? 'Active Plan' : 'Select Plan',
                  onPressed: isCurrent
                      ? () {}
                      : () => controller.selectNewPlan(plan),
                  variant: isCurrent
                      ? ButtonVariant.secondary
                      : (isPro
                            ? ButtonVariant.primary
                            : ButtonVariant.secondary),
                  width: double.infinity,
                  height: 44,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(double sw, String label, bool isAvailable) {
    return Padding(
      padding: EdgeInsets.only(bottom: sw * 0.02),
      child: Row(
        children: [
          Icon(
            isAvailable ? Icons.check_circle : Icons.cancel,
            color: isAvailable
                ? AppColors.success
                : AppColors.grey.withValues(alpha: 0.5),
            size: sw * 0.04,
          ),
          SizedBox(width: sw * 0.025),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: sw * 0.032,
              color: isAvailable
                  ? AppColors.charcoal
                  : AppColors.grey.withValues(alpha: 0.6),
              decoration: isAvailable ? null : TextDecoration.lineThrough,
            ),
          ),
        ],
      ),
    );
  }
}
