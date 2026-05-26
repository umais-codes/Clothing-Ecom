import 'package:ecom_app/app/utils/responsive.dart';
import 'package:ecom_app/features/product_details/presentation/widgets/product_detail_back_btn.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/pdp_controller.dart';
import '../widgets/pdp_carousel.dart';
import '../widgets/variant_section.dart';
import '../widgets/ai_size_predictor_card.dart';
import 'package:ecom_app/app/widgets/custom_button.dart';
import 'package:ecom_app/features/wishlist/domain/models/product_model.dart';
import 'package:ecom_app/features/wishlist/presentation/controllers/wishlist_controller.dart';
import 'package:ecom_app/app/widgets/custom_stepper.dart';

class PdpView extends GetView<PdpController> {
  const PdpView({super.key});

  @override
  Widget build(BuildContext context) {
    final double sw = context.screenWidth;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          _buildContent(sw),
          _buildBottomBar(sw),
          const ProductDetailBackButton(),
          _buildFavoriteButton(context, sw),
        ],
      ),
    );
  }

  Widget _buildContent(double sw) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: .start,
        children: [
          PdpCarousel(sw: sw, imageUrl: controller.product['image']),
          Padding(
            padding: .fromLTRB(sw * 0.04, sw * 0.015, sw * 0.04, 0),
            child: Column(
              crossAxisAlignment: .start,
              children: [
                /// 🔹 BRAND NAME
                Text(
                  (controller.product['vendor'] ?? 'BOUTIQUE APPAREL')
                      .toUpperCase(),
                  style: GoogleFonts.outfit(
                    fontSize: sw * 0.024,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                    color: AppColors.camel,
                  ),
                ),

                SizedBox(height: sw * 0.015),

                /// 🔹 PRODUCT NAME + PRICE/QTY
                Row(
                  crossAxisAlignment: .start,
                  children: [
                    Expanded(
                      child: Text(
                        controller.product['name'],
                        maxLines: 3,
                        overflow: .ellipsis,
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: sw * 0.055,
                          fontWeight: .w700,
                          height: 1.15,
                          color: AppColors.charcoal,
                        ),
                      ),
                    ),

                    SizedBox(width: sw * 0.02),

                    /// RIGHT SIDE (PRICE + QTY)
                    Column(
                      crossAxisAlignment: .end,
                      children: [
                        /// PRICE
                        Text(
                          '\$${controller.product['price'].toStringAsFixed(0)}',
                          style: GoogleFonts.outfit(
                            fontSize: sw * 0.045,
                            fontWeight: .w800,
                            color: AppColors.camel,
                          ),
                        ),

                        SizedBox(height: sw * 0.015),

                        /// 🔥 QTY STEPPER (FIXED)
                        Obx(
                          () => CustomStepper(
                            value: controller.quantity.value,
                            onChanged: (newQty) =>
                                controller.updateQuantity(newQty),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: sw * 0.02),

                VariantSection(
                  title: 'SELECT SIZE',
                  items: controller.sizes,
                  selectedItem: controller.selectedSize,
                  sw: sw,
                ),

                SizedBox(height: sw * 0.05),

                VariantSection(
                  title: 'SELECT COLOR',
                  items: controller.colors,
                  selectedItem: controller.selectedColor,
                  sw: sw,
                ),

                SizedBox(height: sw * 0.06),

                Text(
                  'DESCRIPTION',
                  style: GoogleFonts.outfit(
                    fontSize: sw * 0.024,
                    fontWeight: .w600,
                    letterSpacing: 1.5,
                    color: AppColors.grey,
                  ),
                ),

                SizedBox(height: sw * 0.02),

                Text(
                  controller.description,
                  style: GoogleFonts.outfit(
                    fontSize: sw * 0.034,
                    height: 1.7,
                    color: AppColors.charcoal.withValues(alpha: 0.85),
                  ),
                ),

                SizedBox(height: sw * 0.03),

                AISizePredictorCard(
                  sw: sw,
                  onPredict: () => controller.runAIPrediction(),
                ),

                SizedBox(height: sw * 0.15),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(double sw) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: .symmetric(horizontal: sw * 0.04, vertical: sw * 0.01),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: .vertical(top: .circular(sw * 0.05)),
        ),
        child: CustomButton(
          text: 'Add to Cart',
          onPressed: () => controller.addToCart(),
          icon: Icons.shopping_cart_checkout_rounded,
        ),
      ),
    );
  }

  Widget _buildFavoriteButton(BuildContext context, double sw) {
    final wishlistController = Get.put(WishlistController());
    final product = Product.fromMap(controller.product);

    return Positioned(
      top: context.paddingTop + sw * 0.015,
      right: sw * 0.04,
      child: Obx(
        () => Container(
          width: sw * 0.1,
          height: sw * 0.1,
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(sw * 0.03),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
              ),
            ],
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: Icon(
              wishlistController.isInWishlist(product.id)
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: wishlistController.isInWishlist(product.id)
                  ? AppColors.camel
                  : AppColors.charcoal,
              size: sw * 0.05,
            ),
            onPressed: () => wishlistController.toggleWishlist(product),
          ),
        ),
      ),
    );
  }
}
