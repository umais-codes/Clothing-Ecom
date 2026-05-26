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
        padding: .only(bottom: w * 0.06),
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
                Padding(
                  padding: .symmetric(horizontal: w * 0.04, vertical: 0),
                  child: Row(
                    mainAxisAlignment: .spaceBetween,
                    children: [
                      Text(
                        vendor.toUpperCase(),
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: w * 0.04,
                          fontWeight: .w600,
                          color: AppColors.charcoal,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: AppColors.camel,
                        size: w * 0.05,
                      ),
                    ],
                  ),
                ),
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

class RetailCartItemTile extends StatelessWidget {
  final dynamic item;
  final B2CCartController controller;

  const RetailCartItemTile({
    super.key,
    required this.item,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final double sw = context.screenWidth;

    return Container(
      height: sw * 0.215,
      margin: .symmetric(horizontal: sw * 0.02),
      padding: .symmetric(horizontal: sw * 0.02, vertical: sw * 0.01),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: .circular(sw * 0.04),
        boxShadow: [
          BoxShadow(
            color: AppColors.charcoal.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: .zero,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: .start,
        children: [
          // Image
          ClipRRect(
            borderRadius: .circular(sw * 0.02),
            child: Image.network(
              item.imageUrl,
              width: sw * 0.22,
              height: sw * 0.26,
              fit: .cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: sw * 0.22,
                height: sw * 0.26,
                color: AppColors.greySubtle,
                child: const Icon(Icons.broken_image),
              ),
            ),
          ),

          SizedBox(width: sw * 0.02),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              mainAxisAlignment: .spaceBetween,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: .ellipsis,
                  style: GoogleFonts.outfit(
                    fontSize: sw * 0.035,
                    fontWeight: .w600,
                    color: AppColors.charcoal,
                  ),
                ),

                SizedBox(height: sw * 0.01),

                // Color/Size Chips
                Row(
                  children: [
                    if (item.size != null) _buildChip(item.size!, sw),
                    if (item.size != null && item.color != null)
                      SizedBox(width: sw * 0.015),
                    if (item.color != null) _buildChip(item.color!, sw),
                  ],
                ),

                SizedBox(height: sw * 0.01),

                if (item.isAiSizeMatched)
                  Container(
                    padding: .symmetric(horizontal: sw * 0.02),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: .circular(sw * 0.01),
                    ),
                    child: Row(
                      mainAxisSize: .min,
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
                            fontWeight: .w600,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),

                const Spacer(),

                Row(
                  mainAxisAlignment: .spaceBetween,
                  children: [
                    Text(
                      "\$${item.price.toStringAsFixed(2)}",
                      style: GoogleFonts.outfit(
                        fontSize: sw * 0.035,
                        fontWeight: .w700,
                        letterSpacing: 1.1,
                        color: AppColors.charcoal,
                      ),
                    ),
                    CustomStepper(
                      value: item.quantity,
                      onChanged: (newQty) =>
                          controller.updateQuantity(item.id, newQty),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, double sw) {
    return Container(
      padding: .symmetric(horizontal: sw * 0.01, vertical: sw * 0.005),
      decoration: BoxDecoration(
        color: AppColors.greySubtle,
        borderRadius: .circular(sw * 0.01),
        border: .all(color: AppColors.greyLight),
      ),
      child: Text(
        label,
        style: GoogleFonts.outfit(fontSize: sw * 0.025, color: AppColors.ink),
      ),
    );
  }
}
