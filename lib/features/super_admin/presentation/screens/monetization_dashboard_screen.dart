import 'package:ecom_app/features/super_admin/presentation/widgets/monetization/commission_rules_engine.dart';
import 'package:ecom_app/features/super_admin/presentation/widgets/monetization/vendor_billing_oversight.dart';
import 'package:ecom_app/features/super_admin/presentation/widgets/screen_header.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecom_app/app/utils/responsive.dart';
import '../../../../app/theme/app_colors.dart';
import 'package:ecom_app/app/widgets/custom_button.dart';
import '../controllers/monetization_controller.dart';

class MonetizationDashboardScreen extends StatelessWidget {
  const MonetizationDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final controller = Get.put(MonetizationController());

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ScreenHeader(
            title: 'Monetization & Subscription',
            subtitle:
                'Configure platform subscription tiers, commission overrides, and billing oversight',
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
                  mobile: w * 0.02,
                  tablet: w * 0.02,
                  desktop: w * 0.02,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                    context,
                    'SaaS Subscription Pricing',
                    'Manage active pricing tiers, limits, and feature flags.',
                    w,
                  ),
                  _SubscriptionPricingCard(controller: controller),
                  SizedBox(
                    height: context.responsive(
                      mobile: w * 0.05,
                      tablet: w * 0.05,
                      desktop: w * 0.05,
                    ),
                  ),
                  _buildSectionHeader(
                    context,
                    'Commission & Transaction Rules Engine',
                    'Manage global, category, and vendor specific commission overrides.',
                    w,
                  ),
                  const CommissionRulesEngine(),
                  SizedBox(
                    height: context.responsive(
                      mobile: w * 0.05,
                      tablet: w * 0.05,
                      desktop: w * 0.05,
                    ),
                  ),
                  _buildSectionHeader(
                    context,
                    'Vendor Billing Oversight',
                    'Monitor and manage active vendor subscriptions.',
                    w,
                  ),
                  const VendorBillingOversight(),
                  SizedBox(
                    height: context.responsive(
                      mobile: w * 0.05,
                      tablet: w * 0.05,
                      desktop: w * 0.05,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    String subtitle,
    double w,
  ) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: context.responsive(
          mobile: w * 0.03,
          tablet: w * 0.05,
          desktop: w * 0.06,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.playfairDisplay(
              fontSize: context.responsive(
                mobile: w * 0.045,
                tablet: w * 0.055,
                desktop: w * 0.06,
              ),
              fontWeight: FontWeight.w800,
              color: AppColors.charcoal,
            ),
          ),
          SizedBox(
            height: context.responsive(
              mobile: w * 0.01,
              tablet: w * 0.01,
              desktop: w * 0.01,
            ),
          ),
          Text(
            subtitle,
            style: GoogleFonts.outfit(
              fontSize: context.responsive(
                mobile: w * 0.028,
                tablet: w * 0.032,
                desktop: w * 0.035,
              ),
              color: AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Subscription Pricing Card ────────────────────────────────────────────────

class _SubscriptionPricingCard extends StatelessWidget {
  const _SubscriptionPricingCard({required this.controller});
  final MonetizationController controller;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.greyLight, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.charcoal.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Card Header ───────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.responsive(
                mobile: 12.0,
                tablet: 16.0,
                desktop: 20.0,
              ),
              vertical: context.responsive(
                mobile: 10.0,
                tablet: 12.0,
                desktop: 16.0,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(
                    context.responsive(mobile: 8.0, tablet: 9.0, desktop: 10.0),
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.camel.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.card_membership_rounded,
                    color: AppColors.camel,
                    size: context.responsive(
                      mobile: 16.0,
                      tablet: 18.0,
                      desktop: 20.0,
                    ),
                  ),
                ),
                SizedBox(
                  width: context.responsive(
                    mobile: 10.0,
                    tablet: 12.0,
                    desktop: 14.0,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(
                        () => Text(
                          '${controller.plans.length} Active Subscription Tiers',
                          style: GoogleFonts.outfit(
                            fontSize: context.responsive(
                              mobile: 13.0,
                              tablet: 14.0,
                              desktop: 15.0,
                            ),
                            fontWeight: FontWeight.w700,
                            color: AppColors.charcoal,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                      Text(
                        'Monthly & yearly pricing · product limits · feature gates',
                        style: GoogleFonts.outfit(
                          fontSize: context.responsive(
                            mobile: 10.5,
                            tablet: 11.5,
                            desktop: 12.5,
                          ),
                          color: AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                CustomButton(
                  text: 'Configure',
                  icon: Icons.settings_outlined,
                  onPressed: () => Get.toNamed('/admin-subscription-builder'),
                  variant: ButtonVariant.ghost,
                  buttonColor: AppColors.camel.withValues(alpha: 0.08),
                  textColor: AppColors.camel,
                  borderRadius: 8,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 32,
                ),
              ],
            ),
          ),

          // ── Summary Stats Strip ───────────────────────────────────────────
          Obx(() {
            final totalMrr = controller.plans.fold<double>(
              0,
              (sum, p) => sum + p.mrr,
            );
            final paidTiers = controller.plans
                .where((p) => p.priceMonthly > 0)
                .length;
            final hasFreeTier = controller.plans.any(
              (p) => p.priceMonthly == 0,
            );

            return Container(
              margin: EdgeInsets.symmetric(
                horizontal: context.responsive(
                  mobile: w * 0.001,
                  tablet: w * 0.015,
                  desktop: w * 0.02,
                ),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: context.responsive(
                  mobile: w * 0.02,
                  tablet: w * 0.025,
                  desktop: w * 0.03,
                ),
                vertical: context.responsive(
                  mobile: w * 0.02,
                  tablet: w * 0.025,
                  desktop: w * 0.03,
                ),
              ),
              decoration: BoxDecoration(
                color: AppColors.offWhite,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.greySubtle),
              ),
              child: Row(
                children: [
                  _StatPill(
                    label: 'Total MRR',
                    value: '\$${(totalMrr / 1000).toStringAsFixed(1)}k',
                    icon: Icons.trending_up_rounded,
                    color: AppColors.success,
                  ),
                  Container(
                    width: 1,
                    height: 28,
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    color: AppColors.greyLight,
                  ),
                  _StatPill(
                    label: 'Paid Tiers',
                    value: '$paidTiers',
                    icon: Icons.layers_rounded,
                    color: AppColors.camel,
                  ),
                  Container(
                    width: 1,
                    height: 28,
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    color: AppColors.greyLight,
                  ),
                  _StatPill(
                    label: 'Free Tier',
                    value: hasFreeTier ? 'Active' : 'None',
                    icon: Icons.card_giftcard_rounded,
                    color: AppColors.ink,
                  ),
                ],
              ),
            );
          }),

          SizedBox(height: w * 0.01),

          // ── Plan Tiles ────────────────────────────────────────────────────
          Obx(
            () => Column(
              children: controller.plans
                  .map((plan) => _PlanTile(plan: plan))
                  .toList(),
            ),
          ),
          SizedBox(height: w * 0.005),
        ],
      ),
    );
  }
}

// ─── Summary Stat Pill ────────────────────────────────────────────────────────

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Expanded(
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.responsive(
                mobile: w * 0.02,
                tablet: w * 0.025,
                desktop: w * 0.03,
              ),
              vertical: context.responsive(
                mobile: w * 0.02,
                tablet: w * 0.025,
                desktop: w * 0.03,
              ),
            ),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 12, color: color),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.outfit(
                    fontSize: context.responsive(
                      mobile: w * 0.03,
                      tablet: w * 0.035,
                      desktop: w * 0.04,
                    ),
                    fontWeight: FontWeight.w700,
                    color: AppColors.charcoal,
                    height: 1,
                  ),
                ),
                Text(
                  label,
                  style: GoogleFonts.outfit(
                    fontSize: context.responsive(
                      mobile: w * 0.022,
                      tablet: w * 0.028,
                      desktop: w * 0.032,
                    ),
                    color: AppColors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Individual Plan Tile ─────────────────────────────────────────────────────

class _PlanTile extends StatelessWidget {
  const _PlanTile({required this.plan});
  final dynamic plan;

  @override
  Widget build(BuildContext context) {
    final isFree = (plan.priceMonthly as num) == 0;
    final isEnterprise = plan.name == 'Enterprise';

    final Color accentColor;
    if (isFree) {
      accentColor = AppColors.grey;
    } else if (isEnterprise) {
      accentColor = AppColors.camel;
    } else {
      accentColor = AppColors.success;
    }

    final maxProducts = plan.maxProducts as int;
    final maxStaff = plan.maxStaffAccounts as int;

    final features = <String>[
      '${maxProducts >= 999999 ? 'Unlimited' : maxProducts} products',
      '$maxStaff staff account${maxStaff != 1 ? 's' : ''}',
      if (plan.enableAiSizePredictor as bool) 'AI Size Predictor',
      if (plan.enableB2bBulkQuoting as bool) 'B2B Bulk Quoting',
      if (plan.enableCustomStorefront as bool) 'Custom Storefront',
    ];
    final w = MediaQuery.of(context).size.width;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: context.responsive(
          mobile: w * 0.01,
          tablet: w * 0.015,
          desktop: w * 0.02,
        ),
        vertical: context.responsive(
          mobile: w * 0.005,
          tablet: w * 0.025,
          desktop: w * 0.03,
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: context.responsive(
          mobile: w * 0.02,
          tablet: w * 0.025,
          desktop: w * 0.03,
        ),
        vertical: context.responsive(
          mobile: w * 0.02,
          tablet: w * 0.025,
          desktop: w * 0.03,
        ),
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.greyLight.withValues(alpha: 0.7)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Plan avatar badge ─────────────────────────────────────────────
          Container(
            width: w * 0.09,
            height: w * 0.09,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              (plan.name as String)[0],
              style: GoogleFonts.outfit(
                fontSize: context.responsive(
                  mobile: w * 0.03,
                  tablet: w * 0.035,
                  desktop: w * 0.04,
                ),
                fontWeight: FontWeight.w800,
                color: accentColor,
              ),
            ),
          ),
          SizedBox(width: w * 0.02),

          // ── Plan name + feature chips ─────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      plan.name as String,
                      style: GoogleFonts.outfit(
                        fontSize: context.responsive(
                          mobile: w * 0.03,
                          tablet: w * 0.035,
                          desktop: w * 0.04,
                        ),
                        fontWeight: FontWeight.w700,
                        color: AppColors.charcoal,
                      ),
                    ),
                    if (!isFree) ...[
                      SizedBox(width: w * 0.05),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: w * 0.01,
                          vertical: w * 0.005,
                        ),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: accentColor.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Text(
                          'MRR \$${((plan.mrr as double) / 1000).toStringAsFixed(1)}k',
                          style: GoogleFonts.outfit(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: accentColor,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: w * 0.01),
                Wrap(
                  spacing: w * 0.01,
                  runSpacing: w * 0.005,
                  children: features
                      .map(
                        (f) => Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: w * 0.02,
                            vertical: w * 0.01,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.greySubtle,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            f,
                            style: GoogleFonts.outfit(
                              fontSize: w * 0.023,
                              color: AppColors.ink,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
          SizedBox(width: w * 0.02),

          // ── Pricing column ────────────────────────────────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                isFree
                    ? 'Free'
                    : '\$${(plan.priceMonthly as double).toStringAsFixed(0)}',
                style: GoogleFonts.outfit(
                  fontSize: w * 0.035,
                  fontWeight: FontWeight.w700,
                  color: AppColors.charcoal,
                  height: 1,
                ),
              ),
              if (!isFree)
                Text(
                  '/mo',
                  style: GoogleFonts.outfit(
                    fontSize: w * 0.023,
                    color: AppColors.grey,
                  ),
                ),
              if (!isFree) SizedBox(height: w * 0.005),
              if (!isFree)
                Text(
                  '\$${(plan.priceYearly as double).toStringAsFixed(0)}/yr',
                  style: GoogleFonts.outfit(
                    fontSize: w * 0.03,
                    color: AppColors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
