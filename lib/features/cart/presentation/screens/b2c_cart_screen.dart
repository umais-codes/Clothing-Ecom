import 'package:ecom_app/app/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../app/theme/app_colors.dart';
import '../controllers/b2c_cart_controller.dart';
import '../widgets/retail_cart_view.dart';

class B2CCartScreen extends StatelessWidget {
  const B2CCartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final B2CCartController controller = Get.find<B2CCartController>();
    final double sw = MediaQuery.sizeOf(context).width;

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          "Shopping Cart",
          style: GoogleFonts.outfit(
            fontSize: sw * 0.05,
            fontWeight: .w600,
            color: AppColors.charcoal,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => controller.clearCart(),
            icon: Icon(Icons.delete_forever, color: AppColors.charcoal),
          ),
        ],
      ),
      body: RetailCartView(controller: controller),
      bottomNavigationBar: _buildBottomBar(sw, controller),
    );
  }

  Widget _buildBottomBar(double sw, B2CCartController controller) {
    return Container(
      padding: .symmetric(horizontal: sw * 0.04, vertical: sw * 0.02),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: .vertical(top: .circular(sw * 0.04)),
        boxShadow: [
          BoxShadow(
            color: AppColors.charcoal.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: .min,
          children: [
            Obx(
              () => _buildSummaryRow(
                "Subtotal",
                "\$${controller.subtotal.toStringAsFixed(2)}",
                sw,
              ),
            ),
            SizedBox(height: sw * 0.01),
            _buildSummaryRow(
              "Delivery Fee",
              "\$${controller.deliveryFee.toStringAsFixed(2)}",
              sw,
            ),
            const Divider(color: AppColors.greyLight, thickness: 1),
            Row(
              mainAxisAlignment: .spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: .start,
                  children: [
                    Text(
                      "Total Amount",
                      style: GoogleFonts.outfit(
                        fontSize: sw * 0.035,
                        color: AppColors.grey,
                      ),
                    ),
                    Obx(
                      () => Text(
                        "\$${controller.total.toStringAsFixed(2)}",
                        style: GoogleFonts.outfit(
                          fontSize: sw * 0.05,
                          fontWeight: .w700,
                          color: AppColors.charcoal,
                        ),
                      ),
                    ),
                  ],
                ),
                CustomButton(
                  text: "Checkout",
                  width: sw * 0.3,
                  height: sw * 0.11,
                  onPressed: () {},
                  textColor: AppColors.white,
                  buttonColor: AppColors.camel,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, double sw) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: sw * 0.035,
            color: AppColors.grey,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: sw * 0.035,
            fontWeight: FontWeight.w600,
            color: AppColors.charcoal,
          ),
        ),
      ],
    );
  }
}
