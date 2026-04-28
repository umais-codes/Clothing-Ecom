import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/widgets/custom_network_image.dart';
import '../../../../app/widgets/custom_text_field.dart';
import '../../domain/models/cart_item_model.dart';
import '../controllers/cart_controller.dart';

class CartItemTile extends StatefulWidget {
  final CartItem item;

  const CartItemTile({super.key, required this.item});

  @override
  State<CartItemTile> createState() => _CartItemTileState();
}

class _CartItemTileState extends State<CartItemTile> {
  late TextEditingController _qtyController;

  @override
  void initState() {
    super.initState();
    _qtyController = TextEditingController(
      text: widget.item.quantity.toString(),
    );
  }

  @override
  void didUpdateWidget(CartItemTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.quantity != widget.item.quantity) {
      _qtyController.text = widget.item.quantity.toString();
    }
  }

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CartController controller = Get.find<CartController>();
    final double sw = MediaQuery.sizeOf(context).width;

    return Container(
      margin: .symmetric(horizontal: sw * 0.02, vertical: sw * 0.012),
      padding: .symmetric(horizontal: sw * 0.01, vertical: sw * 0.005),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: .circular(sw * 0.03),
        border: .all(color: AppColors.greyLight.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: .start,
        children: [
          ///  IMAGE (TIGHTER)
          CustomNetworkImage(
            imageUrl: widget.item.imageUrl,
            width: sw * 0.14,
            height: sw * 0.17,
            borderRadius: sw * 0.025,
            fit: .cover,
          ),

          SizedBox(width: sw * 0.03),

          /// DETAILS
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                /// NAME
                Text(
                  widget.item.name,
                  maxLines: 2,
                  overflow: .ellipsis,
                  style: GoogleFonts.outfit(
                    fontSize: sw * 0.035,
                    fontWeight: .w600,
                    color: AppColors.charcoal,
                    height: 1.2,
                  ),
                ),

                SizedBox(height: sw * 0.001),

                /// VARIANTS
                if (widget.item.size != null || widget.item.color != null)
                  Text(
                    '${widget.item.size ?? ''}${widget.item.color != null ? ' • ${widget.item.color}' : ''}',
                    style: GoogleFonts.outfit(
                      fontSize: sw * 0.03,
                      color: AppColors.charcoal.withValues(alpha: 0.5),
                    ),
                  ),

                /// AI BADGE (SMALL & CLEAN)
                if (widget.item.isAiSizeMatched)
                  Padding(
                    padding: .only(top: sw * 0.005),
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
                            fontWeight: .w600,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),

                SizedBox(height: sw * 0.005),

                /// PRICE + QTY
                Row(
                  mainAxisAlignment: .spaceBetween,
                  children: [
                    Text(
                      '\$${widget.item.price.toStringAsFixed(2)}',
                      style: GoogleFonts.outfit(
                        fontSize: sw * 0.035,
                        fontWeight: .w700,
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

  /// 🔥 IMPROVED QUANTITY CONTROL
  Widget _buildQuantityControl(CartController controller, double sw) {
    if (widget.item.isB2B) {
      return SizedBox(
        width: sw * 0.2,
        child: CustomTextField(
          controller: _qtyController,
          keyboardType: .number,
          textAlign: .center,
          margin: .zero,
          contentPadding: .symmetric(
            vertical: sw * 0.015,
            horizontal: sw * 0.02,
          ),
          borderRadius: sw * 0.015,
          fillColor: AppColors.offWhite,
          style: GoogleFonts.outfit(
            fontSize: sw * 0.032,
            fontWeight: .w600,
            color: AppColors.charcoal,
          ),
          onChanged: (value) {
            final qty = int.tryParse(value);
            if (qty != null && qty > 0) {
              controller.updateQuantity(widget.item.id, qty);
            }
          },
        ),
      );
    }

    /// 🔥 B2C STEPPER (CLEAN & COMPACT)
    return Obx(() {
      final currentItem = controller.cartItems.firstWhereOrNull(
        (e) => e.id == widget.item.id,
      );
      final qty = currentItem?.quantity ?? widget.item.quantity;

      return Container(
        height: sw * 0.075,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: .circular(sw * 0.02),
          border: .all(color: AppColors.greyLight.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: .min,
          children: [
            _qtyBtn(
              icon: Icons.remove,
              onTap: () => controller.updateQuantity(widget.item.id, qty - 1),
              sw: sw,
            ),

            SizedBox(
              width: sw * 0.07,
              child: Center(
                child: Text(
                  '$qty',
                  style: GoogleFonts.outfit(
                    fontSize: sw * 0.03,
                    fontWeight: .w700,
                  ),
                ),
              ),
            ),

            _qtyBtn(
              icon: Icons.add,
              onTap: () => controller.updateQuantity(widget.item.id, qty + 1),
              sw: sw,
            ),
          ],
        ),
      );
    });
  }

  Widget _qtyBtn({
    required IconData icon,
    required VoidCallback onTap,
    required double sw,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: .circular(sw * 0.015),
      child: SizedBox(
        width: sw * 0.06,
        height: sw * 0.06,
        child: Icon(icon, size: sw * 0.032, color: AppColors.charcoal),
      ),
    );
  }
}
