import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/widgets/custom_button.dart';
import 'package:ecom_app/app/utils/responsive.dart';
import '../../controllers/monetization_controller.dart';
import '../admin_card.dart';
import '../admin_widgets.dart';
import '../admin_form_widgets.dart';

class CommissionRulesEngine extends GetView<MonetizationController> {
  const CommissionRulesEngine({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _GlobalCommissionCard(controller: controller),
        SizedBox(height: w * 0.04),
        _OverridesCard(controller: controller),
      ],
    );
  }
}

// ─── Global Commission Card ───────────────────────────────────────────────────

class _GlobalCommissionCard extends StatelessWidget {
  const _GlobalCommissionCard({required this.controller});
  final MonetizationController controller;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return AdminCard(
      padding: .symmetric(
        horizontal: context.responsive(
          mobile: w * 0.02,
          tablet: w * 0.025,
          desktop: w * 0.03,
        ),
        vertical: context.responsive(
          mobile: w * 0.01,
          tablet: w * 0.015,
          desktop: w * 0.02,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AdminFormCardHeader(
                  icon: Icons.percent_rounded,
                  title: 'Global Platform Commission',
                  subtitle:
                      'Applied to all vendor sales unless overridden below',
                ),
              ],
            ),
          ),
          SizedBox(
            width: context.responsive(
              mobile: w * 0.01,
              tablet: w * 0.02,
              desktop: w * 0.03,
            ),
          ),
          Obx(
            () => GestureDetector(
              onTap: () => _showEditDialog(context, controller),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.responsive(
                    mobile: w * 0.04,
                    tablet: w * 0.05,
                    desktop: w * 0.06,
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
                  border: Border.all(
                    color: AppColors.camel.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${controller.globalCommission.value.toStringAsFixed(1)}%',
                      style: GoogleFonts.outfit(
                        fontSize: context.responsive(
                          mobile: w * 0.04,
                          tablet: w * 0.05,
                          desktop: w * 0.06,
                        ),
                        fontWeight: FontWeight.w800,
                        color: AppColors.camel,
                        height: 1,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.edit_rounded,
                      color: AppColors.grey,
                      size: context.responsive(
                        mobile: w * 0.04,
                        tablet: w * 0.05,
                        desktop: w * 0.06,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    MonetizationController controller,
  ) {
    final TextEditingController tc = TextEditingController(
      text: controller.globalCommission.value.toStringAsFixed(1),
    );
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Set Global Commission',
          style: GoogleFonts.outfit(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.charcoal,
          ),
        ),
        content: TextField(
          controller: tc,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: 'e.g., 5.0',
            suffixText: '%',
            filled: true,
            fillColor: AppColors.offWhite,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.greyLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.camel, width: 1.8),
            ),
          ),
          style: GoogleFonts.outfit(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.charcoal,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: GoogleFonts.outfit(color: AppColors.grey),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.camel,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              final val = double.tryParse(tc.text);
              if (val != null) controller.updateGlobalCommission(val);
              Get.back();
            },
            child: Text(
              'Save',
              style: GoogleFonts.outfit(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Overrides Card ───────────────────────────────────────────────────────────

class _OverridesCard extends StatelessWidget {
  const _OverridesCard({required this.controller});
  final MonetizationController controller;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return AdminCard(
      padding: EdgeInsets.all(w * 0.015),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: AdminFormCardHeader(
                  icon: Icons.tune_rounded,
                  title: 'Category & Vendor Overrides',
                  subtitle: 'Targeted commission rates',
                ),
              ),
              CustomButton(
                text: 'Add',
                icon: Icons.add_rounded,
                width: w * 0.22,
                height: w * 0.09,
                variant: ButtonVariant.primary,
                fontSize: context.responsive(
                  mobile: w * 0.03,
                  tablet: w * 0.04,
                  desktop: w * 0.05,
                ),
                onPressed: () {},
              ),
            ],
          ),
          SizedBox(height: w * 0.01),

          // Override rows
          Obx(() {
            if (controller.commissionRules.isEmpty) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: w * 0.03),
                child: AdminEmptyState(
                  message: 'No overrides configured yet.',
                  icon: Icons.rule_rounded,
                ),
              );
            }
            return Column(
              children: controller.commissionRules
                  .map((rule) => _OverrideRow(rule: rule))
                  .toList(),
            );
          }),
        ],
      ),
    );
  }
}

class _OverrideRow extends StatelessWidget {
  const _OverrideRow({required this.rule});
  final dynamic rule;

  @override
  Widget build(BuildContext context) {
    final isVendor = rule.type == 'Vendor';
    final Color typeColor = isVendor ? AppColors.camel : AppColors.ink;
    final Color typeBg = isVendor ? AppColors.camelLight : AppColors.greySubtle;
    final w = MediaQuery.of(context).size.width;

    return Container(
      margin: EdgeInsets.only(top: w * 0.01),
      padding: EdgeInsets.symmetric(horizontal: w * 0.02, vertical: w * 0.01),
      decoration: BoxDecoration(
        color: AppColors.offWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.greySubtle),
      ),
      child: Row(
        children: [
          // Type chip
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: w * 0.01,
              vertical: w * 0.01,
            ),
            decoration: BoxDecoration(
              color: typeBg,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: typeColor.withValues(alpha: 0.2)),
            ),
            child: Text(
              rule.type as String,
              style: GoogleFonts.outfit(
                fontSize: w * 0.025,
                fontWeight: FontWeight.w500,
                color: typeColor,
              ),
            ),
          ),
          SizedBox(width: w * 0.02),

          // Target name
          Expanded(
            child: Text(
              rule.targetName as String,
              style: GoogleFonts.outfit(
                fontSize: w * 0.03,
                fontWeight: FontWeight.w600,
                color: AppColors.charcoal,
              ),
            ),
          ),

          // Commission badge
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: w * 0.02,
              vertical: w * 0.01,
            ),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: AppColors.success.withValues(alpha: 0.2),
              ),
            ),
            child: Text(
              '${rule.percentage}%',
              style: GoogleFonts.outfit(
                fontSize: w * 0.03,
                fontWeight: FontWeight.w600,
                color: AppColors.success,
              ),
            ),
          ),
          SizedBox(width: w * 0.03),

          // Actions
          InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(6),
            child: Icon(Icons.edit_rounded, size: 16, color: AppColors.camel),
          ),
          SizedBox(width: w * 0.02),
          InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(6),
            child: Icon(Icons.delete_forever, size: 16, color: AppColors.error),
          ),
        ],
      ),
    );
  }
}
