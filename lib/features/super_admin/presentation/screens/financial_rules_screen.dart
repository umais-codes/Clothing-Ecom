import 'package:ecom_app/app/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../app/theme/app_colors.dart';
import '../../domain/entities/admin_entities.dart';
import 'package:ecom_app/app/widgets/custom_button.dart';
import 'package:ecom_app/app/widgets/custom_text_field.dart';
import '../controllers/admin_crud_controller.dart';
import '../widgets/admin_data_table.dart';

class FinancialRulesScreen extends GetView<AdminCrudController> {
  const FinancialRulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.responsive(
            mobile: w * 0.03,
            tablet: w * 0.04,
            desktop: w * 0.05,
          ),
          vertical: context.responsive(
            mobile: w * 0.02,
            tablet: w * 0.03,
            desktop: w * 0.04,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Financial Rules Engine',
              style: GoogleFonts.outfit(
                fontSize: context.responsive(
                  mobile: w * 0.055,
                  tablet: w * 0.06,
                  desktop: w * 0.07,
                ),
                fontWeight: FontWeight.w700,
                color: AppColors.charcoal,
              ),
            ),
            SizedBox(
              height: context.responsive(
                mobile: w * 0.002,
                tablet: w * 0.004,
                desktop: w * 0.006,
              ),
            ),
            Text(
              'Configure global commissions and SaaS subscription parameters.',
              style: GoogleFonts.outfit(
                fontSize: context.responsive(
                  mobile: w * 0.035,
                  tablet: w * 0.04,
                  desktop: w * 0.05,
                ),
                color: AppColors.grey,
              ),
            ),
            SizedBox(
              height: context.responsive(
                mobile: w * 0.02,
                tablet: w * 0.03,
                desktop: w * 0.04,
              ),
            ),

            Expanded(
              child: AdminDataTable<dynamic>(
                title: 'Active Rules & Pricing',
                columnFlex: const [3, 2, 2, 2, 1],
                columns: const [
                  'Rule Title',
                  'Value',
                  'Type',
                  'Category',
                  'Actions',
                ],
                items: controller.financialRules,
                rowBuilder: (item) {
                  return Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          item.title,
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          item.type == 'Percentage'
                              ? '${item.value}%'
                              : 'PKR ${item.value.toStringAsFixed(0)}',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            color: AppColors.camel,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          item.type,
                          style: GoogleFonts.outfit(fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          item.category,
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: AppColors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () => _showRuleDrawer(context, item),
                              icon: const Icon(
                                Icons.tune_rounded,
                                size: 18,
                                color: AppColors.camel,
                              ),
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRuleDrawer(BuildContext context, dynamic rule) {
    final valueController = TextEditingController(text: rule.value.toString());
    final w = MediaQuery.sizeOf(context).width;
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          left: w * 0.04,
          right: w * 0.04,
          top: w * 0.04,
          bottom: MediaQuery.of(context).viewInsets.bottom + w * 0.04,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: w * 0.1,
                  height: w * 0.01,
                  margin: EdgeInsets.only(bottom: w * 0.02),
                  decoration: BoxDecoration(
                    color: AppColors.greyLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              // Header
              Text(
                'Adjust Financial Rule',
                style: GoogleFonts.outfit(
                  fontSize: w * 0.05,
                  fontWeight: FontWeight.w700,
                  color: AppColors.charcoal,
                ),
              ),
              SizedBox(height: w * 0.01),
              Text(
                'Update parameter values for platform computations.',
                style: GoogleFonts.outfit(
                  fontSize: w * 0.03,
                  color: AppColors.grey,
                ),
              ),
              SizedBox(height: w * 0.04),

              // Form Content
              _buildFieldLabel('Rule Title', w),
              Text(
                rule.title,
                style: GoogleFonts.outfit(
                  fontSize: w * 0.04,
                  fontWeight: FontWeight.w600,
                  color: AppColors.charcoal,
                ),
              ),
              SizedBox(height: w * 0.04),

              _buildFieldLabel('Adjustment Value', w),
              CustomTextField(
                controller: valueController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                fillColor: AppColors.offWhite,
                margin: EdgeInsets.zero,
                style: GoogleFonts.outfit(
                  fontSize: w * 0.035,
                  fontWeight: FontWeight.w600,
                  color: AppColors.charcoal,
                ),
                suffixIcon: Container(
                  width: w * 0.12,
                  alignment: Alignment.center,
                  child: Text(
                    rule.type == 'Percentage' ? '%' : 'PKR',
                    style: GoogleFonts.outfit(
                      fontSize: w * 0.035,
                      fontWeight: FontWeight.w700,
                      color: AppColors.grey,
                    ),
                  ),
                ),
              ),
              SizedBox(height: w * 0.08),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'DISCARD',
                      variant: ButtonVariant.outlined,
                      textColor: AppColors.grey,
                      height: 44,
                      onPressed: () => Get.back(),
                    ),
                  ),
                  SizedBox(width: w * 0.03),
                  Expanded(
                    child: CustomButton(
                      text: 'SAVE CHANGES',
                      variant: ButtonVariant.primary,
                      height: 44,
                      buttonColor: AppColors.camel,
                      onPressed: () {
                        final val = double.tryParse(valueController.text);
                        if (val != null) {
                          controller.updateFinancialRule(
                            FinancialRuleEntity(
                              id: rule.id,
                              title: rule.title,
                              value: val,
                              type: rule.type,
                              category: rule.category,
                            ),
                          );
                        }
                        Get.back();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildFieldLabel(String label, double w) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.outfit(
          fontSize: w * 0.025,
          fontWeight: FontWeight.w800,
          color: AppColors.grey,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}
