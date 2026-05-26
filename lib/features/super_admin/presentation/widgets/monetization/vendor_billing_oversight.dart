import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:ecom_app/app/utils/responsive.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../controllers/monetization_controller.dart';
import '../../../domain/models/vendor_billing.dart';

class VendorBillingOversight extends GetView<MonetizationController> {
  const VendorBillingOversight({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

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
      padding: EdgeInsets.all(
        context.responsive(
          mobile: w * 0.02,
          tablet: w * 0.03,
          desktop: w * 0.04,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Vendor Billing Oversight',
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
              mobile: w * 0.02,
              tablet: w * 0.03,
              desktop: w * 0.04,
            ),
          ),
          Obx(() {
            if (controller.vendorBillings.isEmpty) {
              return Padding(
                padding: EdgeInsets.symmetric(
                  vertical: context.responsive(
                    mobile: w * 0.02,
                    tablet: w * 0.03,
                    desktop: w * 0.04,
                  ),
                ),
                child: Center(
                  child: Text(
                    'No vendor billings found.',
                    style: GoogleFonts.outfit(color: AppColors.grey),
                  ),
                ),
              );
            }
            if (context.isMobileView) {
              return Column(
                children: controller.vendorBillings.map((billing) {
                  return Container(
                    margin: EdgeInsets.only(
                      bottom: context.responsive(
                        mobile: w * 0.02,
                        tablet: w * 0.03,
                        desktop: w * 0.04,
                      ),
                    ),
                    padding: EdgeInsets.all(
                      context.responsive(
                        mobile: w * 0.02,
                        tablet: w * 0.03,
                        desktop: w * 0.04,
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.offWhite,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.greyLight.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              billing.vendorName,
                              style: GoogleFonts.outfit(
                                fontSize: context.responsive(
                                  mobile: w * 0.03,
                                  tablet: w * 0.035,
                                  desktop: w * 0.04,
                                ),
                                fontWeight: FontWeight.bold,
                                color: AppColors.charcoal,
                              ),
                            ),
                            _buildStatusChip(billing.billingStatus),
                          ],
                        ),
                        SizedBox(
                          height: context.responsive(
                            mobile: w * 0.01,
                            tablet: w * 0.02,
                            desktop: w * 0.03,
                          ),
                        ),
                        Divider(
                          color: AppColors.greySubtle,
                          height: context.responsive(
                            mobile: w * 0.01,
                            tablet: w * 0.02,
                            desktop: w * 0.03,
                          ),
                        ),
                        SizedBox(
                          height: context.responsive(
                            mobile: w * 0.01,
                            tablet: w * 0.02,
                            desktop: w * 0.03,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Active Plan',
                                  style: GoogleFonts.outfit(
                                    fontSize: context.responsive(
                                      mobile: w * 0.025,
                                      tablet: w * 0.03,
                                      desktop: w * 0.035,
                                    ),
                                    color: AppColors.grey,
                                  ),
                                ),
                                SizedBox(
                                  height: context.responsive(
                                    mobile: w * 0.005,
                                    tablet: w * 0.01,
                                    desktop: w * 0.015,
                                  ),
                                ),
                                Text(
                                  billing.activePlanName,
                                  style: GoogleFonts.outfit(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.charcoal,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Next Billing',
                                  style: GoogleFonts.outfit(
                                    fontSize: context.responsive(
                                      mobile: w * 0.025,
                                      tablet: w * 0.03,
                                      desktop: w * 0.035,
                                    ),
                                    color: AppColors.grey,
                                  ),
                                ),
                                SizedBox(
                                  height: context.responsive(
                                    mobile: w * 0.005,
                                    tablet: w * 0.01,
                                    desktop: w * 0.015,
                                  ),
                                ),
                                Text(
                                  DateFormat('MMM dd, yyyy').format(billing.nextBillingDate),
                                  style: GoogleFonts.outfit(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.charcoal,
                                  ),  
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(
                          height: context.responsive(
                            mobile: w * 0.005,
                            tablet: w * 0.01,
                            desktop: w * 0.015,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'Actions',
                              style: GoogleFonts.outfit(
                                fontSize: context.responsive(
                                  mobile: w * 0.025,
                                  tablet: w * 0.03,
                                  desktop: w * 0.035,
                                ),
                                color: AppColors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            _buildActionDropdown(billing),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            }
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
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
                  DataColumn(label: Text('Vendor Name')),
                  DataColumn(label: Text('Active Plan')),
                  DataColumn(label: Text('Billing Status')),
                  DataColumn(label: Text('Next Billing Date')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: controller.vendorBillings.map((billing) {
                  return DataRow(cells: [
                    DataCell(Text(billing.vendorName, style: const TextStyle(fontWeight: FontWeight.w600))),
                    DataCell(Text(billing.activePlanName)),
                    DataCell(_buildStatusChip(billing.billingStatus)),
                    DataCell(Text(DateFormat('MMM dd, yyyy').format(billing.nextBillingDate))),
                    DataCell(_buildActionDropdown(billing)),
                  ]);
                }).toList(),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color bgColor;
    Color textColor;

    switch (status) {
      case 'Active':
        bgColor = AppColors.success.withValues(alpha: 0.1);
        textColor = AppColors.success;
        break;
      case 'Past Due':
        bgColor = AppColors.warning.withValues(alpha: 0.1);
        textColor = AppColors.warning;
        break;
      case 'Canceled':
      default:
        bgColor = AppColors.error.withValues(alpha: 0.1);
        textColor = AppColors.error;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: GoogleFonts.outfit(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildActionDropdown(VendorBilling billing) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: AppColors.grey),
      onSelected: (String result) {
        controller.changeVendorBillingAction(billing.vendorId, result);
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'Upgrade',
          child: Text('Upgrade Plan', style: GoogleFonts.outfit(color: AppColors.charcoal)),
        ),
        PopupMenuItem<String>(
          value: 'Downgrade',
          child: Text('Downgrade Plan', style: GoogleFonts.outfit(color: AppColors.charcoal)),
        ),
        PopupMenuItem<String>(
          value: 'Extend',
          child: Text('Extend Subscription', style: GoogleFonts.outfit(color: AppColors.charcoal)),
        ),
      ],
    );
  }
}
