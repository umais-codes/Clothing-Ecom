import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/widgets/custom_button.dart';
import '../../../../../app/widgets/custom_text_field.dart';
import '../../controllers/monetization_controller.dart';
import '../../../domain/models/subscription_plan.dart';
import 'package:ecom_app/app/utils/responsive.dart';
import '../admin_card.dart';
import '../admin_widgets.dart';
import '../admin_form_widgets.dart';

class SubscriptionPlanBuilder extends GetView<MonetizationController> {
  const SubscriptionPlanBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktopView;
    final w = MediaQuery.of(context).size.width;

    return isDesktop
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 1, child: _PlanListCard(controller: controller)),
              SizedBox(width: w * 0.02),
              Expanded(flex: 2, child: _PlanFormCard(controller: controller)),
            ],
          )
        : Column(
            children: [
              _PlanListCard(controller: controller),
              SizedBox(height: w * 0.04),
              _PlanFormCard(controller: controller),
            ],
          );
  }
}

// ─── Active Plans List Card ───────────────────────────────────────────────────

class _PlanListCard extends StatelessWidget {
  const _PlanListCard({required this.controller});
  final MonetizationController controller;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return AdminCard(
      padding: EdgeInsets.symmetric(horizontal: w * 0.03, vertical: w * 0.015),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Expanded(
                child: AdminFormCardHeader(
                  icon: Icons.layers_rounded,
                  title: 'Active Plans',
                  subtitle: 'Tap a plan to edit',
                ),
              ),
              SizedBox(width: w * 0.02),
              GestureDetector(
                onTap: controller.createNewPlan,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: w * 0.04,
                    vertical: w * 0.02,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.camel,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: AppColors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: w * 0.03),
          Container(height: 1, color: AppColors.greySubtle),
          SizedBox(height: w * 0.02),

          // Plan tiles
          Obx(
            () => Column(
              children: controller.plans
                  .map(
                    (plan) => _PlanListItem(plan: plan, controller: controller),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanListItem extends StatelessWidget {
  const _PlanListItem({required this.plan, required this.controller});
  final SubscriptionPlan plan;
  final MonetizationController controller;

  @override
  Widget build(BuildContext context) {
    final isFree = plan.priceMonthly == 0;
    final isEnterprise = plan.name == 'Enterprise';
    final w = MediaQuery.of(context).size.width;

    final Color accentColor;
    if (isFree) {
      accentColor = AppColors.grey;
    } else if (isEnterprise) {
      accentColor = AppColors.camel;
    } else {
      accentColor = AppColors.success;
    }

    return Obx(() {
      final isSelected = controller.selectedPlan.value?.id == plan.id;
      return GestureDetector(
        onTap: () => controller.selectPlan(plan),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: EdgeInsets.only(bottom: w * 0.02),
          padding: EdgeInsets.symmetric(
            horizontal: w * 0.03,
            vertical: w * 0.02,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? accentColor.withValues(alpha: 0.07)
                : AppColors.offWhite,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? accentColor.withValues(alpha: 0.4)
                  : AppColors.greySubtle,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  plan.name[0],
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: accentColor,
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Name + price
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.name,
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.charcoal,
                      ),
                    ),
                    Text(
                      isFree
                          ? 'Free forever'
                          : '\$${plan.priceMonthly.toStringAsFixed(2)}/mo',
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              // MRR
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'MRR',
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppColors.grey,
                    ),
                  ),
                  Text(
                    isFree
                        ? '\$0'
                        : '\$${(plan.mrr / 1000).toStringAsFixed(1)}k',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}

// ─── Plan Form Card ───────────────────────────────────────────────────────────

class _PlanFormCard extends StatelessWidget {
  const _PlanFormCard({required this.controller});
  final MonetizationController controller;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isMobile = context.isMobileView;

    return AdminCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header
          Obx(() {
            final isEditing = controller.selectedPlan.value != null;
            return AdminFormCardHeader(
              icon: isEditing ? Icons.edit_rounded : Icons.add_rounded,
              title: isEditing
                  ? 'Edit "${controller.selectedPlan.value!.name}" Plan'
                  : 'Create New Plan',
              subtitle: isEditing
                  ? 'Modify pricing, limits, and feature flags'
                  : 'Define a new subscription tier for vendors',
            );
          }),
          const SizedBox(height: 14),
          Container(height: 1, color: AppColors.greySubtle),
          const SizedBox(height: 16),

          // Plan Name
          CustomTextField(
            label: 'Plan Name',
            icon: Icons.badge_outlined,
            controller: controller.planNameController,
            hinttext: 'e.g., Professional',
            isRequired: true,
          ),

          // Pricing row
          if (isMobile) ...[
            CustomTextField(
              label: 'Monthly Price (\$)',
              icon: Icons.calendar_view_month_rounded,
              controller: controller.priceMonthlyController,
              hinttext: '0.00',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              prefixText: '\$',
            ),
            CustomTextField(
              label: 'Yearly Price (\$)',
              icon: Icons.calendar_today_rounded,
              controller: controller.priceYearlyController,
              hinttext: '0.00',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              prefixText: '\$',
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    label: 'Monthly Price (\$)',
                    icon: Icons.calendar_view_month_rounded,
                    controller: controller.priceMonthlyController,
                    hinttext: '0.00',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    prefixText: '\$',
                  ),
                ),
                SizedBox(width: w * 0.02),
                Expanded(
                  child: CustomTextField(
                    label: 'Yearly Price (\$)',
                    icon: Icons.calendar_today_rounded,
                    controller: controller.priceYearlyController,
                    hinttext: '0.00',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    prefixText: '\$',
                  ),
                ),
              ],
            ),
          ],

          // Limits row
          if (isMobile) ...[
            CustomTextField(
              label: 'Max Products',
              icon: Icons.inventory_2_outlined,
              controller: controller.maxProductsController,
              hinttext: 'e.g., 500',
              keyboardType: TextInputType.number,
            ),
            CustomTextField(
              label: 'Max Staff Accounts',
              icon: Icons.group_outlined,
              controller: controller.maxStaffController,
              hinttext: 'e.g., 5',
              keyboardType: TextInputType.number,
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    label: 'Max Products',
                    icon: Icons.inventory_2_outlined,
                    controller: controller.maxProductsController,
                    hinttext: 'e.g., 500',
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: w * 0.02),
                Expanded(
                  child: CustomTextField(
                    label: 'Max Staff Accounts',
                    icon: Icons.group_outlined,
                    controller: controller.maxStaffController,
                    hinttext: 'e.g., 5',
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 8),

          // Premium Features section
          AdminSectionHeader(title: 'Premium Features'),
          const SizedBox(height: 12),

          _FeatureToggleRow(
            icon: Icons.auto_awesome_rounded,
            label: 'AI Size Predictor',
            subtitle: 'Smart sizing recommendations for buyers',
            value: controller.enableAiSizePredictor,
          ),
          _FeatureToggleRow(
            icon: Icons.request_quote_rounded,
            label: 'B2B Bulk Quoting',
            subtitle: 'Enable wholesale pricing & RFQ flows',
            value: controller.enableB2bBulkQuoting,
          ),
          _FeatureToggleRow(
            icon: Icons.storefront_rounded,
            label: 'Custom Storefront',
            subtitle: 'Branded subdomain & theme customization',
            value: controller.enableCustomStorefront,
          ),

          const SizedBox(height: 20),

          // Save button
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Obx(() {
                final isEditing = controller.selectedPlan.value != null;
                if (isEditing) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: CustomButton(
                      text: 'Cancel',
                      width: 100,
                      height: 42,
                      variant: ButtonVariant.outlined,
                      onPressed: controller.createNewPlan,
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
              CustomButton(
                text: 'Save Plan',
                icon: Icons.check_rounded,
                width: 130,
                height: 42,
                variant: ButtonVariant.primary,
                onPressed: controller.savePlan,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Feature Toggle Row ───────────────────────────────────────────────────────

class _FeatureToggleRow extends StatelessWidget {
  const _FeatureToggleRow({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final RxBool value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.offWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.greySubtle),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: AppColors.camelLight,
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(icon, size: 14, color: AppColors.camel),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.charcoal,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.outfit(
                    fontSize: 10.5,
                    color: AppColors.grey,
                  ),
                ),
              ],
            ),
          ),
          Obx(
            () => Switch(
              value: value.value,
              onChanged: (val) => value.value = val,
              activeThumbColor: AppColors.white,
              activeTrackColor: AppColors.camel,
              inactiveThumbColor: AppColors.greyLight,
              inactiveTrackColor: AppColors.greySubtle,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }
}
