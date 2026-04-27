import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/widgets/custom_button.dart';
import '../controllers/cart_controller.dart';

class OrderSummaryBottomBar extends StatelessWidget {
  const OrderSummaryBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    final CartController controller = Get.find<CartController>();
    final double sw = MediaQuery.sizeOf(context).width;

    return Container(
      padding: .symmetric(horizontal: sw * 0.04, vertical: sw * 0.02),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: .vertical(top: Radius.circular(sw * 0.06)),
        boxShadow: [
          BoxShadow(
            color: AppColors.charcoal.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: .min,
          children: [
            // Subtotal
            Row(
              mainAxisAlignment: .spaceBetween,
              children: [
                Text(
                  'Subtotal',
                  style: GoogleFonts.outfit(
                    fontSize: sw * 0.035,
                    color: AppColors.grey,
                  ),
                ),
                Obx(
                  () => Text(
                    '\$${controller.subtotal.toStringAsFixed(2)}',
                    style: GoogleFonts.outfit(
                      fontSize: sw * 0.03,
                      fontWeight: .w600,
                      color: AppColors.charcoal,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: sw * 0.02),

            // Delivery Fee
            Row(
              mainAxisAlignment: .spaceBetween,
              children: [
                Text(
                  'Delivery Fee',
                  style: GoogleFonts.outfit(
                    fontSize: sw * 0.035,
                    color: AppColors.grey,
                  ),
                ),
                Obx(
                  () => Text(
                    controller.subtotal > 0
                        ? '\$${controller.deliveryFee.toStringAsFixed(2)}'
                        : '\$0.00',
                    style: GoogleFonts.outfit(
                      fontSize: sw * 0.03,
                      fontWeight: .w600,
                      color: AppColors.charcoal,
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: .symmetric(vertical: sw * 0.02),
              child: const Divider(color: AppColors.greyLight, height: 1),
            ),

            // Total
            Row(
              mainAxisAlignment: .spaceBetween,
              children: [
                Text(
                  'Total',
                  style: GoogleFonts.outfit(
                    fontSize: sw * 0.04,
                    fontWeight: .w600,
                    color: AppColors.charcoal,
                  ),
                ),
                Obx(
                  () => Text(
                    '\$${controller.total.toStringAsFixed(2)}',
                    style: GoogleFonts.outfit(
                      fontSize: sw * 0.04,
                      fontWeight: .w600,
                      color: AppColors.charcoal,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: sw * 0.03),

            // Checkout Button
            Obx(
              () => CustomButton(
                text: 'Proceed to Stripe Checkout',
                onPressed: controller.cartItems.isEmpty
                    ? null
                    : () {
                        Get.snackbar(
                          'Checkout',
                          'Navigating to Stripe...',
                          backgroundColor: AppColors.camel,
                          colorText: AppColors.white,
                          snackPosition: .TOP,
                        );
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
