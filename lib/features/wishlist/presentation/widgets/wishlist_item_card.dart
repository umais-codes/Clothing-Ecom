import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/widgets/custom_network_image.dart';
import '../../../../app/widgets/custom_button.dart';
import '../../domain/models/product_model.dart';
import '../controllers/wishlist_controller.dart';

class WishlistItemCard extends StatelessWidget {
  final Product product;
  final double sw;

  const WishlistItemCard({super.key, required this.product, required this.sw});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WishlistController>();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: .circular(sw * 0.04),
        boxShadow: [
          BoxShadow(
            color: AppColors.charcoal.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          /// IMAGE SECTION
          Stack(
            children: [
              ClipRRect(
                borderRadius: .vertical(top: .circular(sw * 0.04)),
                child: CustomNetworkImage(
                  imageUrl: product.imageUrl,
                  height: sw * 0.35,
                  width: .infinity,
                  fit: .cover,
                ),
              ),

              /// HEART ICON
              Positioned(
                top: sw * 0.01,
                right: sw * 0.01,
                child: GestureDetector(
                  onTap: () => controller.removeFromWishlist(product.id),
                  child: Container(
                    padding: .symmetric(
                      horizontal: sw * 0.015,
                      vertical: sw * 0.015,
                    ),
                    decoration: const BoxDecoration(
                      color: AppColors.white,
                      shape: .circle,
                    ),
                    child: Icon(
                      Icons.favorite_rounded,
                      color: AppColors.camel,
                      size: sw * 0.045,
                    ),
                  ),
                ),
              ),

              /// STOCK BADGE
              if (product.inStock != null && !product.inStock!)
                Positioned(
                  bottom: sw * 0.02,
                  left: sw * 0.02,
                  child: Container(
                    padding: .symmetric(
                      horizontal: sw * 0.02,
                      vertical: sw * 0.008,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.charcoal.withValues(alpha: 0.6),
                      borderRadius: .circular(sw * 0.01),
                    ),
                    child: Text(
                      'OUT OF STOCK',
                      style: GoogleFonts.outfit(
                        fontSize: sw * 0.02,
                        fontWeight: .w700,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          /// INFO SECTION
          Padding(
            padding: .symmetric(horizontal: sw * 0.01),
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(
                  product.vendorName.toUpperCase(),
                  style: GoogleFonts.outfit(
                    fontSize: sw * 0.025,
                    fontWeight: .w600,
                    letterSpacing: 1.2,
                    color: AppColors.camel,
                  ),
                ),
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: .ellipsis,
                  style: GoogleFonts.outfit(
                    fontSize: sw * 0.03,
                    fontWeight: .w400,
                    color: AppColors.charcoal,
                  ),
                ),
                SizedBox(height: sw * 0.01),
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: GoogleFonts.outfit(
                    fontSize: sw * 0.03,
                    fontWeight: .w600,
                    color: AppColors.charcoal,
                  ),
                ),
                SizedBox(height: sw * 0.01),

                /// MOVE TO CART ACTION
                Row(
                  mainAxisAlignment: .spaceBetween,
                  children: [
                    SizedBox(width: sw * 0.01),
                    CustomButton(
                      icon: Icons.shopping_cart,
                      height: sw * 0.09,
                      width: sw * 0.13,
                      onPressed: product.inStock != null && product.inStock!
                          ? () => controller.moveToCart(product)
                          : null,
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
}
