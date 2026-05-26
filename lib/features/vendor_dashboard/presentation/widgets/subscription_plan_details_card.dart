import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/app/widgets/custom_button.dart';
import 'package:ecom_app/app/utils/responsive.dart';

class SubscriptionPlanDetailsCard extends StatelessWidget {
  final String planName;
  final String planFee;
  final String commissionRate;
  final int currentProducts;
  final int maxProducts;
  final String nextBillingDate;
  final String billingStatus;
  final VoidCallback onUpgradePressed;

  const SubscriptionPlanDetailsCard({
    super.key,
    required this.planName,
    required this.planFee,
    required this.commissionRate,
    required this.currentProducts,
    required this.maxProducts,
    required this.nextBillingDate,
    required this.billingStatus,
    required this.onUpgradePressed,
  });

  @override
  Widget build(BuildContext context) {
    final double sw = context.screenWidth;
    final isPastDue = billingStatus.toLowerCase() == 'past due';
    final isCanceled = billingStatus.toLowerCase() == 'canceled';

    Color statusBgColor = AppColors.success.withValues(alpha: 0.1);
    Color statusTextColor = AppColors.success;

    if (isPastDue) {
      statusBgColor = AppColors.warning.withValues(alpha: 0.1);
      statusTextColor = AppColors.warning;
    } else if (isCanceled) {
      statusBgColor = AppColors.error.withValues(alpha: 0.1);
      statusTextColor = AppColors.error;
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: sw * 0.04, vertical: sw * 0.02),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(sw * 0.04),
        border: Border.all(
          color: AppColors.greyLight.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Subscription Plan",
                style: GoogleFonts.outfit(
                  fontSize: sw * 0.04,
                  fontWeight: FontWeight.bold,
                  color: AppColors.charcoal,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: sw * 0.02,
                  vertical: sw * 0.005,
                ),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(sw * 0.015),
                ),
                child: Text(
                  billingStatus.toUpperCase(),
                  style: GoogleFonts.outfit(
                    color: statusTextColor,
                    fontSize: sw * 0.022,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: sw * 0.015),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Current Plan",
                    style: GoogleFonts.outfit(
                      fontSize: sw * 0.03,
                      color: AppColors.grey,
                    ),
                  ),
                  Text(
                    planName,
                    style: GoogleFonts.outfit(
                      fontSize: sw * 0.035,
                      fontWeight: FontWeight.bold,
                      color: AppColors.charcoal,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "Cost",
                    style: GoogleFonts.outfit(
                      fontSize: sw * 0.03,
                      color: AppColors.grey,
                    ),
                  ),
                  Text(
                    planFee,
                    style: GoogleFonts.outfit(
                      fontSize: sw * 0.04,
                      fontWeight: FontWeight.bold,
                      color: AppColors.charcoal,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Divider(color: AppColors.greyLight.withValues(alpha: 0.5)),
          SizedBox(height: sw * 0.01),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.percent_rounded,
                    color: AppColors.camel,
                    size: sw * 0.035,
                  ),
                  SizedBox(width: sw * 0.01),
                  Text(
                    "Sales Commission Fee",
                    style: GoogleFonts.outfit(
                      fontSize: sw * 0.03,
                      color: AppColors.charcoal,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Text(
                commissionRate,
                style: GoogleFonts.outfit(
                  fontSize: sw * 0.03,
                  fontWeight: FontWeight.bold,
                  color: AppColors.camel,
                ),
              ),
            ],
          ),
          SizedBox(height: sw * 0.015),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Product Catalog Limit",
                    style: GoogleFonts.outfit(
                      fontSize: sw * 0.03,
                      color: AppColors.grey,
                    ),
                  ),
                  Text(
                    "$currentProducts / $maxProducts Products",
                    style: GoogleFonts.outfit(
                      fontSize: sw * 0.03,
                      fontWeight: FontWeight.bold,
                      color: AppColors.charcoal,
                    ),
                  ),
                ],
              ),
              SizedBox(height: sw * 0.015),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (currentProducts / maxProducts).clamp(0.0, 1.0),
                  backgroundColor: AppColors.greyLight.withValues(alpha: 0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.camel,
                  ),
                  minHeight: 6,
                ),
              ),
            ],
          ),
          SizedBox(height: sw * 0.01),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isPastDue ? "Past Due Since" : "Next Renewal Date",
                    style: GoogleFonts.outfit(
                      fontSize: sw * 0.025,
                      color: AppColors.grey,
                    ),
                  ),
                  Text(
                    nextBillingDate,
                    style: GoogleFonts.outfit(
                      fontSize: sw * 0.032,
                      fontWeight: FontWeight.w600,
                      color: isPastDue ? AppColors.error : AppColors.charcoal,
                    ),
                  ),
                ],
              ),
              CustomButton(
                text: isPastDue ? "Resolve Billing" : "Upgrade Plan",
                onPressed: () {
                  Get.toNamed('/subscription_plans');
                },
                variant: ButtonVariant.ghost,
                textColor: AppColors.camel,
                fontSize: sw * 0.03,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
