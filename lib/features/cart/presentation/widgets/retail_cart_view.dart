import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/app/widgets/custom_stepper.dart';
import 'package:ecom_app/app/widgets/custom_button.dart';
import 'package:ecom_app/app/utils/responsive.dart';
import 'package:ecom_app/features/navigation/presentation/controllers/main_navigation_controller.dart';
import '../controllers/b2c_cart_controller.dart';
import '../../domain/models/cart_item_model.dart';

class RetailCartView extends StatelessWidget {
  final B2CCartController controller;

  const RetailCartView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final double sw = context.screenWidth;

    return Obx(() {
      if (controller.cartItems.isEmpty) {
        return _buildEmptyState(context, sw);
      }

      final groupedItems = controller.groupedCartItems;
      final vendorNames = groupedItems.keys.toList();

      return CustomScrollView(
        slivers: [
          // 1. Free Delivery Progress Banner
          SliverToBoxAdapter(
            child: _buildFreeDeliveryBanner(sw),
          ),

          // 2. Multi-Vendor Grouped List
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final vendor = vendorNames[index];
                final items = groupedItems[vendor]!;

                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: sw * 0.04,
                    vertical: sw * 0.015,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Vendor Header Badge
                      Row(
                        children: [
                          Icon(
                            Icons.store_mall_directory_outlined,
                            size: sw * 0.045,
                            color: AppColors.camel,
                          ),
                          SizedBox(width: sw * 0.02),
                          Text(
                            vendor.toUpperCase(),
                            style: GoogleFonts.outfit(
                              fontSize: sw * 0.032,
                              fontWeight: FontWeight.w700,
                              color: AppColors.charcoal,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            "${items.length} ${items.length == 1 ? 'item' : 'items'}",
                            style: GoogleFonts.outfit(
                              fontSize: sw * 0.028,
                              color: AppColors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: sw * 0.02),

                      // Item Cards
                      ...items.map(
                        (item) => RetailCartItemTile(
                          item: item,
                          controller: controller,
                        ),
                      ),
                    ],
                  ),
                );
              },
              childCount: vendorNames.length,
            ),
          ),

          SliverToBoxAdapter(
            child: SizedBox(height: sw * 0.08),
          ),
        ],
      );
    });
  }

  Widget _buildFreeDeliveryBanner(double sw) {
    return Obx(() {
      final needed = controller.amountNeededForFreeShipping;
      final isFree = needed == 0.0 || controller.isFreeShippingPromo.value;

      return Container(
        margin: EdgeInsets.fromLTRB(sw * 0.04, sw * 0.03, sw * 0.04, sw * 0.01),
        padding: EdgeInsets.symmetric(horizontal: sw * 0.04, vertical: sw * 0.025),
        decoration: BoxDecoration(
          color: isFree
              ? AppColors.success.withValues(alpha: 0.1)
              : AppColors.camel.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(sw * 0.03),
          border: Border.all(
            color: isFree
                ? AppColors.success.withValues(alpha: 0.3)
                : AppColors.camel.withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          children: [
            Icon(
              isFree ? Icons.local_shipping : Icons.local_shipping_outlined,
              color: isFree ? AppColors.success : AppColors.camel,
              size: sw * 0.05,
            ),
            SizedBox(width: sw * 0.03),
            Expanded(
              child: Text(
                isFree
                    ? "Congratulations! You have unlocked FREE Express Delivery."
                    : "Add \$${needed.toStringAsFixed(2)} more for FREE Delivery (Orders over \$${controller.freeDeliveryThreshold.toInt()}).",
                style: GoogleFonts.outfit(
                  fontSize: sw * 0.03,
                  fontWeight: FontWeight.w600,
                  color: isFree ? AppColors.success : AppColors.charcoal,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildEmptyState(BuildContext context, double sw) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: sw * 0.08),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: sw * 0.25,
              height: sw * 0.25,
              decoration: BoxDecoration(
                color: AppColors.camel.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_bag_outlined,
                size: sw * 0.12,
                color: AppColors.camel,
              ),
            ),
            SizedBox(height: sw * 0.04),
            Text(
              "Your Shopping Bag is Empty",
              style: GoogleFonts.outfit(
                fontSize: sw * 0.05,
                fontWeight: FontWeight.w700,
                color: AppColors.charcoal,
              ),
            ),
            SizedBox(height: sw * 0.015),
            Text(
              "Explore our luxury clothing collection and discover handcrafted garments tailored to perfection.",
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: sw * 0.033,
                color: AppColors.grey,
                height: 1.4,
              ),
            ),
            SizedBox(height: sw * 0.06),
            CustomButton(
              text: "Explore Collection",
              width: sw * 0.55,
              height: sw * 0.12,
              buttonColor: AppColors.charcoal,
              textColor: AppColors.white,
              onPressed: () {
                if (Get.isRegistered<MainNavigationController>()) {
                  Get.find<MainNavigationController>().changeTab(1);
                } else {
                  Get.toNamed('/discovery');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class RetailCartItemTile extends StatefulWidget {
  final CartItem item;
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
    await Future.delayed(const Duration(milliseconds: 200));
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
        margin: EdgeInsets.only(bottom: _isRemoving ? 0.0 : sw * 0.03),
        padding: EdgeInsets.all(sw * 0.03),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(sw * 0.04),
          border: Border.all(
            color: AppColors.greyLight.withValues(alpha: 0.5),
            width: 0.8,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.charcoal.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                GestureDetector(
                  onTap: _openProductDetails,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(sw * 0.03),
                    child: Image.network(
                      widget.item.imageUrl.isNotEmpty
                          ? widget.item.imageUrl
                          : 'https://images.unsplash.com/photo-1591561954557-26941169b49e?w=600&h=600&fit=crop',
                      width: sw * 0.22,
                      height: sw * 0.26,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: sw * 0.22,
                        height: sw * 0.26,
                        color: AppColors.greySubtle,
                        child: const Icon(Icons.broken_image, color: AppColors.grey),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: sw * 0.035),

                // Details Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: _openProductDetails,
                              child: Text(
                                widget.item.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.outfit(
                                  fontSize: sw * 0.038,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.charcoal,
                                  height: 1.2,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: Icon(
                              Icons.close,
                              size: sw * 0.045,
                              color: AppColors.grey,
                            ),
                            onPressed: _onRemove,
                          ),
                        ],
                      ),
                      SizedBox(height: sw * 0.015),

                      // Variant Chips (Size, Color)
                      Row(
                        children: [
                          if (widget.item.size != null && widget.item.size!.isNotEmpty)
                            _buildChip("Size: ${widget.item.size!}", sw),
                          if (widget.item.size != null &&
                              widget.item.size!.isNotEmpty &&
                              widget.item.color != null &&
                              widget.item.color!.isNotEmpty)
                            SizedBox(width: sw * 0.015),
                          if (widget.item.color != null && widget.item.color!.isNotEmpty)
                            _buildChip(widget.item.color!, sw),
                        ],
                      ),

                      if (widget.item.isAiSizeMatched) ...[
                        SizedBox(height: sw * 0.015),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: sw * 0.02,
                            vertical: sw * 0.005,
                          ),
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
                              SizedBox(width: sw * 0.01),
                              Text(
                                "AI Fit Matched",
                                style: GoogleFonts.outfit(
                                  fontSize: sw * 0.024,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.success,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      SizedBox(height: sw * 0.02),

                      // Price and Quantity Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "\$${widget.item.price.toStringAsFixed(2)}",
                            style: GoogleFonts.outfit(
                              fontSize: sw * 0.04,
                              fontWeight: FontWeight.w700,
                              color: AppColors.camel,
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

            // Bottom Quick Actions
            Padding(
              padding: EdgeInsets.only(top: sw * 0.02),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () => widget.controller.moveToWishlist(widget.item),
                    icon: Icon(
                      Icons.favorite_border,
                      size: sw * 0.035,
                      color: AppColors.grey,
                    ),
                    label: Text(
                      "Move to Wishlist",
                      style: GoogleFonts.outfit(
                        fontSize: sw * 0.028,
                        color: AppColors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openProductDetails() {
    final productMap = {
      'id': widget.item.baseProductId,
      'name': widget.item.name,
      'price': widget.item.price,
      'image': widget.item.imageUrl,
      'image_url': widget.item.imageUrl,
      'isB2B': widget.item.isB2B,
      'vendor': widget.item.vendorName,
      'sizes': widget.item.size != null ? [widget.item.size!] : ['S', 'M', 'L'],
      'colors': widget.item.color != null ? [widget.item.color!] : ['Camel', 'White'],
    };
    Get.toNamed('/product-details', arguments: productMap);
  }

  Widget _buildChip(String label, double sw) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: sw * 0.02,
        vertical: sw * 0.008,
      ),
      decoration: BoxDecoration(
        color: AppColors.offWhite,
        borderRadius: BorderRadius.circular(sw * 0.015),
        border: Border.all(color: AppColors.greyLight.withValues(alpha: 0.6)),
      ),
      child: Text(
        label,
        style: GoogleFonts.outfit(
          fontSize: sw * 0.026,
          fontWeight: FontWeight.w500,
          color: AppColors.charcoal,
        ),
      ),
    );
  }
}
