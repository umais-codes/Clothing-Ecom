import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/widgets/custom_button.dart';
import '../../../../../app/widgets/custom_text_field.dart';
import '../../controllers/monetization_controller.dart';
import '../../../domain/models/subscription_plan.dart';
import 'package:ecom_app/app/utils/responsive.dart';

class SubscriptionPlanBuilder extends GetView<MonetizationController> {
  const SubscriptionPlanBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    // Responsive layout: stacked on mobile/tablet portrait, side-by-side on wide tablet/desktop
    final isDesktop = context.isDesktopView;

    return isDesktop
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 1, child: _buildPlanList(context)),
              const SizedBox(width: 24),
              Expanded(flex: 2, child: _buildPlanForm(context)),
            ],
          )
        : Column(
            children: [
              _buildPlanList(context),
              const SizedBox(height: 24),
              _buildPlanForm(context),
            ],
          );
  }

  Widget _buildPlanList(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.charcoal.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Active Plans',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.charcoal,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle, color: AppColors.camel),
                onPressed: controller.createNewPlan,
                tooltip: 'Create New Plan',
              )
            ],
          ),
          const SizedBox(height: 16),
          Obx(() {
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.plans.length,
              separatorBuilder: (context, index) => const Divider(color: AppColors.greySubtle),
              itemBuilder: (context, index) {
                final plan = controller.plans[index];
                return _buildPlanListItem(plan);
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPlanListItem(SubscriptionPlan plan) {
    return Obx(() {
      final isSelected = controller.selectedPlan.value?.id == plan.id;
      return InkWell(
        onTap: () => controller.selectPlan(plan),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.camelLight : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppColors.camel : Colors.transparent,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan.name,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.charcoal,
                    ),
                  ),
                  Text(
                    '\$${plan.priceMonthly}/mo',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'MRR',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.grey,
                    ),
                  ),
                  Text(
                    '\$${plan.mrr.toStringAsFixed(0)}',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
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

  Widget _buildPlanForm(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.charcoal.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() {
            final isEditing = controller.selectedPlan.value != null;
            return Text(
              isEditing ? 'Edit Plan' : 'Create New Plan',
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.charcoal,
              ),
            );
          }),
          const SizedBox(height: 24),
          
          // Form Fields
          CustomTextField(
            label: 'Plan Name',
            controller: controller.planNameController,
            hinttext: 'e.g., Professional',
          ),
          const SizedBox(height: 16),
          
          if (context.isMobileView) ...[
            CustomTextField(
              label: 'Monthly Price (\$)',
              controller: controller.priceMonthlyController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Yearly Price (\$)',
              controller: controller.priceYearlyController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    label: 'Monthly Price (\$)',
                    controller: controller.priceMonthlyController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomTextField(
                    label: 'Yearly Price (\$)',
                    controller: controller.priceYearlyController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          if (context.isMobileView) ...[
            CustomTextField(
              label: 'Max Products',
              controller: controller.maxProductsController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Max Staff Accounts',
              controller: controller.maxStaffController,
              keyboardType: TextInputType.number,
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    label: 'Max Products',
                    controller: controller.maxProductsController,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomTextField(
                    label: 'Max Staff Accounts',
                    controller: controller.maxStaffController,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
          ],
          
          const SizedBox(height: 24),
          Text(
            'Premium Features',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 12),
          
          _buildFeatureToggle(
            'Enable AI Size Predictor', 
            controller.enableAiSizePredictor,
          ),
          _buildFeatureToggle(
            'Enable B2B Bulk Quoting', 
            controller.enableB2bBulkQuoting,
          ),
          _buildFeatureToggle(
            'Enable Custom Storefront', 
            controller.enableCustomStorefront,
          ),
          
          const SizedBox(height: 32),
          Align(
            alignment: Alignment.centerRight,
            child: CustomButton(
              text: 'Save Plan',
              width: 150,
              height: 45,
              variant: ButtonVariant.primary,
              onPressed: controller.savePlan,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureToggle(String label, RxBool value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 15,
              color: AppColors.charcoal,
              fontWeight: FontWeight.w500,
            ),
          ),
          Obx(() => Switch(
            value: value.value,
            onChanged: (val) => value.value = val,
            activeThumbColor: AppColors.white,
            activeTrackColor: AppColors.camel,
            inactiveThumbColor: AppColors.greyLight,
            inactiveTrackColor: AppColors.greySubtle,
          )),
        ],
      ),
    );
  }
}
