import 'package:ecom_app/app/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../app/theme/app_colors.dart';
import '../controllers/admin_crud_controller.dart';
import '../widgets/admin_data_table.dart';
import '../widgets/admin_side_drawer.dart';

class FinancialRulesScreen extends GetView<AdminCrudController> {
  const FinancialRulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: Padding(
        padding: EdgeInsets.all(context.wp(2.5).clamp(16.0, 32.0)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Financial Rules Engine',
              style: GoogleFonts.outfit(
                fontSize: context.sp(22).clamp(20.0, 28.0),
                fontWeight: FontWeight.w800,
                color: AppColors.charcoal,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Configure global commissions and SaaS subscription parameters.',
              style: GoogleFonts.outfit(fontSize: 14, color: AppColors.grey),
            ),
            const SizedBox(height: 32),

            Expanded(
              child: AdminDataTable<dynamic>(
                title: 'Active Rules & Pricing',
                columnFlex: const [3, 2, 2, 2, 1],
                columns: const ['Rule Title', 'Value', 'Type', 'Category', 'Actions'],
                items: controller.financialRules,
                rowBuilder: (item) {
                  return Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          item.title,
                          style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          item.type == 'Percentage' ? '${item.value}%' : 'PKR ${item.value.toStringAsFixed(0)}',
                          style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.camel),
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
                          style: GoogleFonts.outfit(fontSize: 12, color: AppColors.grey),
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
                              icon: const Icon(Icons.tune_rounded, size: 18, color: AppColors.camel),
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
    Get.bottomSheet(
      AdminSideDrawer(
        title: 'Adjust Financial Rule',
        onSave: () => Get.back(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFieldLabel('Rule Title'),
            Text(rule.title, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 24),
            _buildFieldLabel('Adjustment Value'),
            TextField(
              controller: TextEditingController(text: rule.value.toString()),
              decoration: InputDecoration(
                suffixText: rule.type == 'Percentage' ? '%' : 'PKR',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.grey, letterSpacing: 1.0),
      ),
    );
  }
}
