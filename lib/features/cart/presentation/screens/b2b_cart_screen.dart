import 'package:ecom_app/app/widgets/custom_button.dart';
import 'package:ecom_app/app/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../app/theme/app_colors.dart';
import '../controllers/b2b_cart_controller.dart';

class B2BCartScreen extends StatelessWidget {
  const B2BCartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final B2BCartController controller = Get.find<B2BCartController>();
    final double sw = MediaQuery.sizeOf(context).width;

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          "Corporate Procurement",
          style: GoogleFonts.outfit(
            fontSize: sw * 0.05,
            fontWeight: .w600,
            color: AppColors.charcoal,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => controller.uploadCsv(),
            icon: Icon(
              Icons.upload_file,
              size: sw * 0.05,
              color: AppColors.camel,
            ),
            label: Text(
              "Import CSV",
              style: GoogleFonts.outfit(
                fontSize: sw * 0.035,
                color: AppColors.camel,
                fontWeight: .w600,
              ),
            ),
          ),
          SizedBox(width: sw * 0.01),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: .start,
          children: [
            _buildPricingBanner(sw),
            _buildMatrixHeader(sw),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 2,
              itemBuilder: (context, index) {
                return _buildMatrixRow(
                  index == 0 ? "Premium Cotton Polo" : "Executive Oxford Shirt",
                  index == 0 ? "Navy Blue" : "Classic White",
                  sw,
                  controller,
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildB2BBottomBar(sw, controller),
    );
  }

  Widget _buildPricingBanner(double sw) {
    return Container(
      width: .infinity,
      margin: .symmetric(horizontal: sw * 0.04, vertical: sw * 0.01),
      padding: .symmetric(horizontal: sw * 0.03, vertical: sw * 0.015),
      decoration: BoxDecoration(
        color: AppColors.camel.withValues(alpha: 0.1),
        borderRadius: .circular(sw * 0.02),
        border: .all(color: AppColors.camel.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.camel, size: sw * 0.05),
          SizedBox(width: sw * 0.03),
          Expanded(
            child: Text(
              "Bulk Tier Active: 15% discount applied on orders over 100 units per style.",
              style: GoogleFonts.outfit(
                fontSize: sw * 0.03,
                color: AppColors.charcoal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatrixHeader(double sw) {
    return Padding(
      padding: .symmetric(horizontal: sw * 0.04, vertical: sw * 0.01),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text("PRODUCT / COLOR", style: _headerStyle(sw)),
          ),
          Expanded(
            child: Center(child: Text("S", style: _headerStyle(sw))),
          ),
          Expanded(
            child: Center(child: Text("M", style: _headerStyle(sw))),
          ),
          Expanded(
            child: Center(child: Text("L", style: _headerStyle(sw))),
          ),
          Expanded(
            child: Center(child: Text("XL", style: _headerStyle(sw))),
          ),
          Expanded(
            flex: 2,
            child: Text("SUBTOTAL", textAlign: .right, style: _headerStyle(sw)),
          ),
        ],
      ),
    );
  }

  TextStyle _headerStyle(double sw) => GoogleFonts.outfit(
    fontSize: sw * 0.028,
    fontWeight: FontWeight.w700,
    color: AppColors.grey,
    letterSpacing: 1.0,
  );

  Widget _buildMatrixRow(
    String name,
    String color,
    double sw,
    B2BCartController controller,
  ) {
    return Container(
      margin: .symmetric(horizontal: sw * 0.04, vertical: sw * 0.01),
      padding: .symmetric(vertical: sw * 0.03),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.greyLight.withValues(alpha: 0.5)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.outfit(
                    fontSize: sw * 0.035,
                    fontWeight: .w600,
                  ),
                ),
                Text(
                  color,
                  style: GoogleFonts.outfit(
                    fontSize: sw * 0.03,
                    color: AppColors.grey,
                  ),
                ),
              ],
            ),
          ),
          _buildMatrixCell("S", sw),
          _buildMatrixCell("M", sw),
          _buildMatrixCell("L", sw),
          _buildMatrixCell("XL", sw),
          Expanded(
            flex: 2,
            child: Text(
              "\$1,250.00",
              textAlign: .right,
              style: GoogleFonts.outfit(
                fontSize: sw * 0.035,
                fontWeight: .w700,
                color: AppColors.camel,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatrixCell(String size, double sw) {
    return Expanded(
      child: Center(
        child: SizedBox(
          width: sw * 0.09,
          child: CustomTextField(
            controller: TextEditingController(),
            textAlign: .center,
            keyboardType: .number,
            margin: .zero,
            contentPadding: .zero,
            borderRadius: sw * 0.01,
            fillColor: AppColors.offWhite,
            style: GoogleFonts.outfit(
              fontSize: sw * 0.03,
              fontWeight: .w600,
              color: AppColors.charcoal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildB2BBottomBar(double sw, B2BCartController controller) {
    return Container(
      padding: .symmetric(horizontal: sw * 0.04, vertical: sw * 0.02),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.charcoal.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: .min,
          children: [
            Row(
              mainAxisAlignment: .spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: .start,
                  children: [
                    Text(
                      "Total Units",
                      style: GoogleFonts.outfit(
                        fontSize: sw * 0.03,
                        color: AppColors.grey,
                      ),
                    ),
                    Obx(
                      () => Text(
                        "${controller.totalQuantity} PCS",
                        style: GoogleFonts.outfit(
                          fontSize: sw * 0.04,
                          fontWeight: .w700,
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: .end,
                  children: [
                    Text(
                      "Est. Bulk Total",
                      style: GoogleFonts.outfit(
                        fontSize: sw * 0.03,
                        color: AppColors.grey,
                      ),
                    ),
                    Obx(
                      () => Text(
                        "\$${controller.subtotal.toStringAsFixed(2)}",
                        style: GoogleFonts.outfit(
                          fontSize: sw * 0.05,
                          fontWeight: .w800,
                          color: AppColors.charcoal,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: sw * 0.02),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: "Request Quote",
                    variant: ButtonVariant.outlined,
                    onPressed: () => controller.requestQuote(),
                  ),
                ),
                SizedBox(width: sw * 0.03),
                Expanded(
                  child: CustomButton(
                    text: "Submit PO",
                    variant: ButtonVariant.primary,
                    onPressed: () => controller.submitPurchaseOrder(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
