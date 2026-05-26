import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/widgets/custom_button.dart';
import 'package:ecom_app/app/utils/responsive.dart';
import '../../controllers/monetization_controller.dart';

class CommissionRulesEngine extends GetView<MonetizationController> {
  const CommissionRulesEngine({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildGlobalSettings(w, context),
        SizedBox(
          height: context.responsive(
            mobile: w * 0.01,
            tablet: w * 0.03,
            desktop: w * 0.05,
          ),
        ),
        _buildOverridesTable(w, context),
      ],
    );
  }

  Widget _buildGlobalSettings(double w, BuildContext context) {
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
      padding: EdgeInsets.symmetric(
        horizontal: context.responsive(
          mobile: w * 0.01,
          tablet: w * 0.03,
          desktop: w * 0.05,
        ),
        vertical: context.responsive(
          mobile: w * 0.01,
          tablet: w * 0.03,
          desktop: w * 0.05,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Global Platform Commission',
                style: GoogleFonts.outfit(
                  fontSize: context.responsive(
                    mobile: w * 0.04,
                    tablet: w * 0.045,
                    desktop: w * 0.05,
                  ),
                  fontWeight: FontWeight.bold,
                  color: AppColors.charcoal,
                ),
              ),
              SizedBox(
                height: context.responsive(
                  mobile: w * 0.01,
                  tablet: w * 0.03,
                  desktop: w * 0.05,
                ),
              ),
              Text(
                'This percentage is applied to all vendor sales unless overridden below.',
                style: GoogleFonts.outfit(
                  fontSize: context.responsive(
                    mobile: w * 0.03,
                    tablet: w * 0.035,
                    desktop: w * 0.04,
                  ),
                  color: AppColors.grey,
                ),
              ),
            ],
          ),
          Obx(
            () => Container(
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
              decoration: BoxDecoration(
                color: AppColors.offWhite,
                border: Border.all(
                  color: AppColors.camel.withValues(alpha: 0.5),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Text(
                    '${controller.globalCommission.value}%',
                    style: GoogleFonts.outfit(
                      fontSize: context.responsive(
                        mobile: w * 0.04,
                        tablet: w * 0.045,
                        desktop: w * 0.05,
                      ),
                      fontWeight: FontWeight.bold,
                      color: AppColors.camel,
                    ),
                  ),
                  SizedBox(
                    width: context.responsive(
                      mobile: w * 0.01,
                      tablet: w * 0.03,
                      desktop: w * 0.05,
                    ),
                  ),
                  Icon(
                    Icons.edit,
                    color: AppColors.grey,
                    size: context.responsive(
                      mobile: w * 0.03,
                      tablet: w * 0.035,
                      desktop: w * 0.04,
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

  Widget _buildOverridesTable(double w, BuildContext context) {
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Category & Vendor Overrides',
                style: GoogleFonts.outfit(
                  fontSize: context.responsive(
                    mobile: w * 0.04,
                    tablet: w * 0.045,
                    desktop: w * 0.05,
                  ),
                  fontWeight: FontWeight.bold,
                  color: AppColors.charcoal,
                ),
              ),
              CustomButton(
                text: 'Add Override',
                icon: Icons.add,
                width: context.responsive(
                  mobile: w * 0.04,
                  tablet: w * 0.045,
                  desktop: w * 0.05,
                ),
                height: context.responsive(
                  mobile: w * 0.03,
                  tablet: w * 0.035,
                  desktop: w * 0.04,
                ),
                fontSize: context.responsive(
                  mobile: w * 0.03,
                  tablet: w * 0.035,
                  desktop: w * 0.04,
                ),
                variant: ButtonVariant.primary,
                onPressed: () {},
              ),
            ],
          ),
          SizedBox(
            height: context.responsive(
              mobile: w * 0.01,
              tablet: w * 0.03,
              desktop: w * 0.05,
            ),
          ),
          Obx(() {
            return DataTable(
              headingTextStyle: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                color: AppColors.charcoal,
              ),
              dataTextStyle: GoogleFonts.outfit(
                color: AppColors.ink,
                fontSize: 14,
              ),
              dividerThickness: 1,
              columns: const [
                DataColumn(label: Text('Type')),
                DataColumn(label: Text('Target Name')),
                DataColumn(label: Text('Commission (%)')),
                DataColumn(label: Text('Actions')),
              ],
              rows: controller.commissionRules.map((rule) {
                return DataRow(
                  cells: [
                    DataCell(_buildTypeChip(rule.type)),
                    DataCell(
                      Text(
                        rule.targetName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    DataCell(
                      Text(
                        '${rule.percentage}%',
                        style: const TextStyle(
                          color: AppColors.success,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    DataCell(
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                              size: 20,
                              color: AppColors.camel,
                            ),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              size: 20,
                              color: AppColors.error,
                            ),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTypeChip(String type) {
    final isVendor = type == 'Vendor';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isVendor ? AppColors.camelLight : AppColors.greySubtle,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        type,
        style: GoogleFonts.outfit(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: isVendor ? AppColors.camel : AppColors.grey,
        ),
      ),
    );
  }
}
