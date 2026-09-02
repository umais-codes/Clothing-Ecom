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
          SliverToBoxAdapter(child: _buildFreeDeliveryBanner(sw)),

          // 2. Multi-Vendor Grouped List
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
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
                    // Vendor Header Badge (Compact & Sleek)
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: sw * 0.012,
                        left: sw * 0.01,
                        right: sw * 0.01,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.storefront_rounded,
                            size: sw * 0.036,
                            color: AppColors.camel,
                          ),
                          SizedBox(width: sw * 0.015),
                          Text(
                            vendor.toUpperCase(),
                            style: GoogleFonts.outfit(
                              fontSize: sw * 0.028,
                              fontWeight: FontWeight.w700,
                              color: AppColors.charcoal,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            "${items.length} ${items.length == 1 ? 'item' : 'items'}",
                            style: GoogleFonts.outfit(
                              fontSize: sw * 0.024,
                              color: AppColors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

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
            }, childCount: vendorNames.length),
          ),

          SliverToBoxAdapter(child: SizedBox(height: sw * 0.08)),
        ],
      );
    });
  }

  Widget _buildFreeDeliveryBanner(double sw) {
    return Obx(() {
      final needed = controller.amountNeededForFreeShipping;
      final isFree = needed == 0.0 || controller.isFreeShippingPromo.value;

      return Container(
        margin: EdgeInsets.fromLTRB(sw * 0.04, sw * 0.02, sw * 0.04, sw * 0.01),
        padding: EdgeInsets.symmetric(
          horizontal: sw * 0.035,
          vertical: sw * 0.018,
        ),
        decoration: BoxDecoration(
          color: isFree
              ? AppColors.success.withValues(alpha: 0.08)
              : AppColors.camel.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(sw * 0.025),
          border: Border.all(
            color: isFree
                ? AppColors.success.withValues(alpha: 0.25)
                : AppColors.camel.withValues(alpha: 0.2),
            width: 0.7,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isFree ? Icons.local_shipping : Icons.local_shipping_outlined,
              color: isFree ? AppColors.success : AppColors.camel,
              size: sw * 0.042,
            ),
            SizedBox(width: sw * 0.025),
            Expanded(
              child: Text(
                isFree
                    ? "Congratulations! You have unlocked FREE Express Delivery."
                    : "Add \$${needed.toStringAsFixed(2)} more for FREE Delivery (Orders over \$${controller.freeDeliveryThreshold.toInt()}).",
                style: GoogleFonts.outfit(
                  fontSize: sw * 0.028,
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

class RetailCartItemTile extends StatelessWidget {
  final CartItem item;
  final B2CCartController controller;
  final RxBool _isRemoving = false.obs;

  RetailCartItemTile({
    super.key,
    required this.item,
    required this.controller,
  });

  void _onRemove() async {
    _isRemoving.value = true;
    await Future.delayed(const Duration(milliseconds: 180));
    controller.removeItem(item.id);
  }

  @override
  Widget build(BuildContext context) {
    final double sw = context.screenWidth;
    final hasSize = item.size != null && item.size!.isNotEmpty;
    final hasColor = item.color != null && item.color!.isNotEmpty;

    return Obx(
      () => AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: _isRemoving.value ? 0.0 : 1.0,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          margin: EdgeInsets.only(bottom: _isRemoving.value ? 0.0 : sw * 0.02),
          padding: EdgeInsets.all(sw * 0.025),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(sw * 0.03),
            border: Border.all(
              color: AppColors.greyLight.withValues(alpha: 0.5),
              width: 0.7,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.charcoal.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Compact Thumbnail Image
              GestureDetector(
                onTap: _openProductDetails,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(sw * 0.02),
                  child: Image.network(
                    item.imageUrl.isNotEmpty
                        ? item.imageUrl
                        : 'https://images.unsplash.com/photo-1591561954557-26941169b49e?w=600&h=600&fit=crop',
                    width: sw * 0.17,
                    height: sw * 0.19,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: sw * 0.17,
                      height: sw * 0.19,
                      color: AppColors.greySubtle,
                      child: Icon(
                        Icons.broken_image_outlined,
                        size: sw * 0.05,
                        color: AppColors.grey,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: sw * 0.028),

              // 2. Compact Info Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title + Remove Button
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: _openProductDetails,
                            child: Text(
                              item.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.outfit(
                                fontSize: sw * 0.033,
                                fontWeight: FontWeight.w600,
                                color: AppColors.charcoal,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: sw * 0.01),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _onRemove,
                            borderRadius: BorderRadius.circular(sw * 0.02),
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Icon(
                                Icons.close_rounded,
                                size: sw * 0.036,
                                color: AppColors.grey.withValues(alpha: 0.7),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: sw * 0.006),

                    // Variants & AI badge
                    Row(
                      children: [
                        if (hasSize || hasColor)
                          Text(
                            "${hasSize ? 'Size: ${item.size}' : ''}${hasSize && hasColor ? '  •  ' : ''}${hasColor ? item.color : ''}",
                            style: GoogleFonts.outfit(
                              fontSize: sw * 0.025,
                              color: AppColors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        if (item.isAiSizeMatched) ...[
                          SizedBox(width: sw * 0.015),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: sw * 0.014,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              "AI Fit",
                              style: GoogleFonts.outfit(
                                fontSize: sw * 0.02,
                                fontWeight: FontWeight.w700,
                                color: AppColors.success,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: sw * 0.014),

                    // Price, Wishlist, and Stepper Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Price
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              "\$${(item.price * item.quantity).toStringAsFixed(2)}",
                              style: GoogleFonts.outfit(
                                fontSize: sw * 0.038,
                                fontWeight: FontWeight.w700,
                                color: AppColors.camel,
                              ),
                            ),
                            if (item.quantity > 1) ...[
                              SizedBox(width: sw * 0.01),
                              Text(
                                "(\$${item.price.toStringAsFixed(2)})",
                                style: GoogleFonts.outfit(
                                  fontSize: sw * 0.022,
                                  color: AppColors.grey,
                                ),
                              ),
                            ],
                          ],
                        ),

                        // Wishlist + Stepper
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () =>
                                    controller.moveToWishlist(item),
                                borderRadius: BorderRadius.circular(sw * 0.02),
                                child: Padding(
                                  padding: EdgeInsets.all(sw * 0.01),
                                  child: Icon(
                                    Icons.favorite_border_rounded,
                                    size: sw * 0.038,
                                    color: AppColors.grey,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: sw * 0.015),
                            CustomStepper(
                              size: sw * 0.065,
                              value: item.quantity,
                              onChanged: (newQty) => controller
                                  .updateQuantity(item.id, newQty),
                            ),
                          ],
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

  void _openProductDetails() {
    final productMap = {
      'id': item.baseProductId,
      'name': item.name,
      'price': item.price,
      'image': item.imageUrl,
      'image_url': item.imageUrl,
      'isB2B': item.isB2B,
      'vendor': item.vendorName,
      'sizes': item.size != null ? [item.size!] : ['S', 'M', 'L'],
      'colors': item.color != null
          ? [item.color!]
          : ['Camel', 'White'],
    };
    Get.toNamed('/product-details', arguments: productMap);
  }
}
