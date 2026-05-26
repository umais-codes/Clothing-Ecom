import 'package:ecom_app/app/widgets/custom_stepper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:ecom_app/app/utils/responsive.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/widgets/custom_network_image.dart';
import '../../domain/models/cart_item_model.dart';
import '../controllers/cart_controller.dart';

class CartItemTile extends StatelessWidget {
  final CartItem item;

  const CartItemTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final CartController controller = Get.find<CartController>();
    final double sw = context.screenWidth;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: sw * 0.02, vertical: sw * 0.01),
      padding: EdgeInsets.symmetric(
        horizontal: sw * 0.01,
        vertical: sw * 0.005,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(sw * 0.03),
        border: Border.all(color: AppColors.greyLight.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ///  IMAGE (TIGHTER)
          CustomNetworkImage(
            imageUrl: item.imageUrl,
            width: sw * 0.14,
            height: sw * 0.17,
            borderRadius: sw * 0.025,
            fit: BoxFit.cover,
          ),

          SizedBox(width: sw * 0.03),

          /// DETAILS
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// NAME
                Text(
                  item.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    fontSize: sw * 0.035,
                    fontWeight: FontWeight.w600,
                    color: AppColors.charcoal,
                    height: 1.2,
                  ),
                ),

                SizedBox(height: sw * 0.001),

                /// VARIANTS
                if (item.size != null || item.color != null)
                  Text(
                    '${item.size ?? ''}${item.color != null ? ' • ${item.color}' : ''}',
                    style: GoogleFonts.outfit(
                      fontSize: sw * 0.03,
                      color: AppColors.charcoal.withValues(alpha: 0.5),
                    ),
                  ),

                /// AI BADGE (SMALL & CLEAN)
                if (item.isAiSizeMatched)
                  Padding(
                    padding: EdgeInsets.only(top: sw * 0.005),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: sw * 0.03,
                          color: AppColors.success,
                        ),
                        SizedBox(width: sw * 0.008),
                        Text(
                          'Perfect Fit',
                          style: GoogleFonts.outfit(
                            fontSize: sw * 0.026,
                            fontWeight: FontWeight.w600,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),

                SizedBox(height: sw * 0.005),

                /// PRICE + QTY
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${item.price.toStringAsFixed(2)}',
                      style: GoogleFonts.outfit(
                        fontSize: sw * 0.035,
                        fontWeight: FontWeight.w700,
                        color: AppColors.camel,
                      ),
                    ),
                    _buildQuantityControl(controller, sw),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityControl(CartController controller, double sw) {
    return Obx(() {
      final currentItem = controller.cartItems.firstWhereOrNull(
        (e) => e.id == item.id,
      );
      final qty = currentItem?.quantity ?? item.quantity;

      return CustomStepper(
        value: qty,
        onChanged: (newQty) => controller.updateQuantity(item.id, newQty),
      );
    });
  }
}
