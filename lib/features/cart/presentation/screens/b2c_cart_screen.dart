import 'package:ecom_app/app/utils/responsive.dart';
import 'package:ecom_app/app/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecom_app/app/widgets/custom_app_bar.dart';
import 'package:ecom_app/app/widgets/custom_permission_dialog.dart';
import 'package:ecom_app/app/widgets/custom_snackbar.dart';
import '../../../../app/theme/app_colors.dart';
import '../controllers/b2c_cart_controller.dart';
import '../widgets/retail_cart_view.dart';

class B2CCartScreen extends StatelessWidget {
  B2CCartScreen({super.key});

  final TextEditingController _promoController = TextEditingController();
  final RxBool _isPromoExpanded = false.obs;

  @override
  Widget build(BuildContext context) {
    final B2CCartController controller = Get.find<B2CCartController>();
    final double sw = context.screenWidth;

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: CustomAppBar(
        title: "Shopping Bag",
        actions: [
          Obx(() {
            if (controller.cartItems.isEmpty) return const SizedBox.shrink();
            return IconButton(
              tooltip: "Clear bag",
              onPressed: () => _confirmClearCart(context, controller),
              icon: const Icon(Icons.delete_outline, color: AppColors.charcoal),
            );
          }),
        ],
      ),
      body: RetailCartView(controller: controller),
      bottomNavigationBar: Obx(() {
        if (controller.cartItems.isEmpty) return const SizedBox.shrink();
        return _buildBottomBar(sw, controller);
      }),
    );
  }

  void _confirmClearCart(BuildContext context, B2CCartController controller) {
    CustomPermissionDialog.show(
      context: context,
      icon: Icons.delete_outline,
      iconColor: AppColors.error,
      title: "Clear Shopping Bag?",
      description: "Are you sure you want to remove all items from your bag?",
      grantText: "Clear All",
      denyText: "Cancel",
      onGrant: () => controller.clearCart(),
    );
  }

  Widget _buildBottomBar(double sw, B2CCartController controller) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(sw * 0.06)),
        boxShadow: [
          BoxShadow(
            color: AppColors.charcoal.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: sw * 0.05, vertical: sw * 0.03),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Promo Code Section
              _buildPromoSection(sw, controller),
              SizedBox(height: sw * 0.02),

              // Summary Breakdown
              Obx(
                () => _buildSummaryRow(
                  "Subtotal (${controller.totalItemCount} ${controller.totalItemCount == 1 ? 'item' : 'items'})",
                  "\$${controller.subtotal.toStringAsFixed(2)}",
                  sw,
                ),
              ),

              Obx(() {
                if (controller.appliedPromoCode.isEmpty || controller.discountAmount <= 0) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: EdgeInsets.only(top: sw * 0.01),
                  child: _buildSummaryRow(
                    "Promo (${controller.appliedPromoCode.value})",
                    "-\$${controller.discountAmount.toStringAsFixed(2)}",
                    sw,
                    isDiscount: true,
                  ),
                );
              }),

              SizedBox(height: sw * 0.01),

              Obx(
                () => _buildSummaryRow(
                  "Express Delivery",
                  controller.deliveryFee == 0
                      ? "FREE"
                      : "\$${controller.deliveryFee.toStringAsFixed(2)}",
                  sw,
                  isFreeHighlight: controller.deliveryFee == 0,
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(vertical: sw * 0.02),
                child: const Divider(color: AppColors.greyLight, thickness: 0.8),
              ),

              // Total & Checkout Action
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Estimated Total",
                        style: GoogleFonts.outfit(
                          fontSize: sw * 0.032,
                          color: AppColors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Obx(
                        () => Text(
                          "\$${controller.total.toStringAsFixed(2)}",
                          style: GoogleFonts.outfit(
                            fontSize: sw * 0.055,
                            fontWeight: FontWeight.w700,
                            color: AppColors.charcoal,
                          ),
                        ),
                      ),
                    ],
                  ),
                  CustomButton(
                    text: "Proceed to Checkout",
                    width: sw * 0.48,
                    height: sw * 0.12,
                    onPressed: () => Get.toNamed('/checkout', arguments: {'isB2B': false}),
                    textColor: AppColors.white,
                    buttonColor: AppColors.camel,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPromoSection(double sw, B2CCartController controller) {
    return Obx(() {
      final hasPromo = controller.appliedPromoCode.isNotEmpty;

      if (hasPromo) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: sw * 0.03, vertical: sw * 0.015),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(sw * 0.02),
            border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle, size: sw * 0.04, color: AppColors.success),
              SizedBox(width: sw * 0.02),
              Text(
                "Code ${controller.appliedPromoCode.value} Applied",
                style: GoogleFonts.outfit(
                  fontSize: sw * 0.03,
                  fontWeight: FontWeight.w600,
                  color: AppColors.success,
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () => controller.removePromoCode(),
                child: Text(
                  "Remove",
                  style: GoogleFonts.outfit(
                    fontSize: sw * 0.028,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                ),
              ),
            ],
          ),
        );
      }

      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  _isPromoExpanded.toggle();
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isPromoExpanded.value
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.confirmation_number_outlined,
                      size: sw * 0.038,
                      color: AppColors.camel,
                    ),
                    SizedBox(width: sw * 0.015),
                    Text(
                      _isPromoExpanded.value ? "Hide Promo Code" : "Have a promo code?",
                      style: GoogleFonts.outfit(
                        fontSize: sw * 0.03,
                        fontWeight: FontWeight.w600,
                        color: AppColors.camel,
                      ),
                    ),
                  ],
                ),
              ),
              if (!_isPromoExpanded.value)
                Wrap(
                  spacing: sw * 0.015,
                  children: [
                    _buildQuickTag("VELVET10", controller, sw),
                    _buildQuickTag("FREESHIP", controller, sw),
                  ],
                ),
            ],
          ),
          if (_isPromoExpanded.value) ...[
            SizedBox(height: sw * 0.02),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: sw * 0.1,
                    padding: EdgeInsets.symmetric(horizontal: sw * 0.03),
                    decoration: BoxDecoration(
                      color: AppColors.offWhite,
                      borderRadius: BorderRadius.circular(sw * 0.02),
                      border: Border.all(color: AppColors.greyLight),
                    ),
                    child: TextField(
                      controller: _promoController,
                      textCapitalization: TextCapitalization.characters,
                      style: GoogleFonts.outfit(
                        fontSize: sw * 0.032,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        hintText: "Enter code (e.g. VELVET10, VIP20)",
                        hintStyle: GoogleFonts.outfit(
                          fontSize: sw * 0.03,
                          color: AppColors.grey,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: sw * 0.025),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: sw * 0.02),
                CustomButton(
                  text: "Apply",
                  width: sw * 0.22,
                  height: sw * 0.1,
                  buttonColor: AppColors.charcoal,
                  textColor: AppColors.white,
                  onPressed: () {
                    final success = controller.applyPromoCode(_promoController.text);
                    if (!success) {
                      AppSnackbar.warning(
                        title: "Invalid Voucher",
                        message: "Please try 'VELVET10', 'VIP20', or 'FREESHIP'",
                      );
                    } else {
                      _promoController.clear();
                      _isPromoExpanded.value = false;
                    }
                  },
                ),
              ],
            ),
          ],
        ],
      );
    });
  }

  Widget _buildQuickTag(String code, B2CCartController controller, double sw) {
    return InkWell(
      onTap: () => controller.applyPromoCode(code),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: sw * 0.02, vertical: sw * 0.006),
        decoration: BoxDecoration(
          color: AppColors.greySubtle,
          borderRadius: BorderRadius.circular(sw * 0.015),
          border: Border.all(color: AppColors.greyLight),
        ),
        child: Text(
          code,
          style: GoogleFonts.outfit(
            fontSize: sw * 0.025,
            fontWeight: FontWeight.w600,
            color: AppColors.charcoal,
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value,
    double sw, {
    bool isDiscount = false,
    bool isFreeHighlight = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: sw * 0.033,
            color: AppColors.grey,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: sw * 0.033,
            fontWeight: FontWeight.w600,
            color: isDiscount
                ? AppColors.success
                : (isFreeHighlight ? AppColors.success : AppColors.charcoal),
          ),
        ),
      ],
    );
  }
}
