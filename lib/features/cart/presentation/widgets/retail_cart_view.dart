import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/app/widgets/custom_stepper.dart';
import 'package:ecom_app/app/utils/responsive.dart';
import '../controllers/b2c_cart_controller.dart';

class RetailCartView extends StatelessWidget {
  final B2CCartController controller;

  const RetailCartView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final double w = context.screenWidth;

    return Obx(() {
      if (controller.cartItems.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: .center,
            children: [
              Icon(
                Icons.shopping_bag_outlined,
                size: w * 0.16,
                color: AppColors.greyLight,
              ),
              SizedBox(height: w * 0.02),
              Text(
                'Your retail cart is empty',
                style: GoogleFonts.outfit(
                  fontSize: w * 0.04,
                  color: AppColors.grey,
                ),
              ),
            ],
          ),
        );
      }

      final groupedItems = controller.groupedCartItems;
      final vendorNames = groupedItems.keys.toList();

      return ListView.builder(
        padding: .only(bottom: w * 0.05),
        itemCount: vendorNames.length,
        itemBuilder: (context, index) {
          final vendor = vendorNames[index];
          final items = groupedItems[vendor]!;

          return Padding(
            padding: .only(bottom: w * 0.01),
            child: Column(
              crossAxisAlignment: .start,
              children: [
                // Vendor Header
                ...items.map(
                  (item) =>
                      RetailCartItemTile(item: item, controller: controller),
                ),
              ],
            ),
          );
        },
      );
    });
  }
}

class RetailCartItemTile extends StatefulWidget {
  final dynamic item;
  final B2CCartController controller;

  const RetailCartItemTile({
    super.key,
    required this.item,
    required this.controller,
  });

  @override
  State<RetailCartItemTile> createState() => _RetailCartItemTileState();
}

class _RetailCartItemTileState extends State<RetailCartItemTile> {
  bool _isRemoving = false;

  void _onRemove() async {
    setState(() {
      _isRemoving = true;
    });
    // Let the fade and collapse animations run for 250ms
    await Future.delayed(const Duration(milliseconds: 250));
    if (mounted) {
      widget.controller.removeItem(widget.item.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double sw = context.screenWidth;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: _isRemoving ? 0.0 : 1.0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        height: _isRemoving ? 0.0 : sw * 0.212,
        margin: EdgeInsets.only(
          left: sw * 0.02,
          right: sw * 0.02,
          bottom: _isRemoving ? 0.0 : sw * 0.02,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: sw * 0.02,
          vertical: _isRemoving ? 0.0 : sw * 0.01,
        ),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(sw * 0.04),
          boxShadow: [
            BoxShadow(
              color: AppColors.charcoal.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: Offset.zero,
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(sw * 0.04),
          onTap: () {
            final parts = widget.item.id.split('_');
            final productId = (parts.length >= 2)
                ? "${parts[0]}_${parts[1]}"
                : widget.item.id;
            final productMap = {
              'id': productId,
              'name': widget.item.name,
              'price': widget.item.price,
              'image': widget.item.imageUrl,
              'isB2B': widget.item.isB2B,
              'vendor': widget.item.vendorName,
            };
            Get.toNamed('/product-details', arguments: productMap);
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(sw * 0.02),
                child: Image.network(
                  widget.item.imageUrl,
                  width: sw * 0.18,
                  height: sw * 0.192,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: sw * 0.18,
                    height: sw * 0.192,
                    color: AppColors.greySubtle,
                    child: const Icon(Icons.broken_image),
                  ),
                ),
              ),

              SizedBox(width: sw * 0.02),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            widget.item.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(
                              fontSize: sw * 0.035,
                              fontWeight: FontWeight.w600,
                              color: AppColors.charcoal,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: _onRemove,
                          child: Icon(
                            Icons.close,
                            size: sw * 0.045,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: sw * 0.01),

                    // Color/Size Chips
                    Row(
                      children: [
                        if (widget.item.size != null)
                          _buildChip(widget.item.size!, sw),
                        if (widget.item.size != null &&
                            widget.item.color != null)
                          SizedBox(width: sw * 0.015),
                        if (widget.item.color != null)
                          _buildChip(widget.item.color!, sw),
                      ],
                    ),

                    SizedBox(height: sw * 0.01),

                    if (widget.item.isAiSizeMatched)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: sw * 0.02),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(sw * 0.01),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              size: sw * 0.03,
                              color: AppColors.success,
                            ),
                            Text(
                              "AI Size Matched",
                              style: GoogleFonts.outfit(
                                fontSize: sw * 0.022,
                                fontWeight: FontWeight.w600,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "\$${widget.item.price.toStringAsFixed(2)}",
                          style: GoogleFonts.outfit(
                            fontSize: sw * 0.035,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.1,
                            color: AppColors.charcoal,
                          ),
                        ),
                        CustomStepper(
                          value: widget.item.quantity,
                          onChanged: (newQty) => widget.controller
                              .updateQuantity(widget.item.id, newQty),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(String label, double sw) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: sw * 0.01,
        vertical: sw * 0.005,
      ),
      decoration: BoxDecoration(
        color: AppColors.greySubtle,
        borderRadius: BorderRadius.circular(sw * 0.01),
        border: Border.all(color: AppColors.greyLight),
      ),
      child: Text(
        label,
        style: GoogleFonts.outfit(fontSize: sw * 0.025, color: AppColors.ink),
      ),
    );
  }
}
