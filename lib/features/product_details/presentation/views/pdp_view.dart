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

class PdpView extends GetView<PdpController> {
  const PdpView({super.key});

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          _buildContent(sw),
          _buildBottomBar(sw),
          ProductDetailBackButton(sw: sw),
          _buildFavoriteButton(sw),
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
                          () => Row(
                            mainAxisAlignment: .end,
                            children: [
                              _buildQuantityBtn(
                                Icons.remove_rounded,
                                () => controller.updateQuantity(
                                  controller.quantity.value - 1,
                                ),
                                sw,
                                "Decrease",
                              ),

                              SizedBox(
                                width: sw * 0.08,
                                child: Center(
                                  child: Text(
                                    '${controller.quantity.value}',
                                    style: GoogleFonts.outfit(
                                      fontSize: sw * 0.03,
                                      fontWeight: .w700,
                                      color: AppColors.charcoal,
                                    ),
                                  ),
                                ),
                              ),

                              _buildQuantityBtn(
                                Icons.add_rounded,
                                () => controller.updateQuantity(
                                  controller.quantity.value + 1,
                                ),
                                sw,
                                "Increase",
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: sw * 0.02),

                /// 🔹 SIZE SECTION
                VariantSection(
                  title: 'SELECT SIZE',
                  items: controller.sizes,
                  selectedItem: controller.selectedSize,
                  sw: sw,
                ),

                SizedBox(height: sw * 0.05),

                /// 🔹 COLOR SECTION
                VariantSection(
                  title: 'SELECT COLOR',
                  items: controller.colors,
                  selectedItem: controller.selectedColor,
                  sw: sw,
                ),

                SizedBox(height: sw * 0.06),

                /// 🔹 DESCRIPTION TITLE
                Text(
                  'DESCRIPTION',
                  style: GoogleFonts.outfit(
                    fontSize: sw * 0.024,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                    color: AppColors.grey,
                  ),
                ),

                SizedBox(height: sw * 0.02),

                /// DESCRIPTION TEXT
                Text(
                  controller.description,
                  style: GoogleFonts.outfit(
                    fontSize: sw * 0.034,
                    height: 1.7,
                    color: AppColors.charcoal.withValues(alpha: 0.85),
                  ),
                ),

                SizedBox(height: sw * 0.03),

                /// 🔹 AI SIZE PREDICTOR
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

  Widget _buildQuantityBtn(
    IconData icon,
    VoidCallback onPressed,
    double sw,
    String tooltip,
  ) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: .circular(sw * 0.03),
        child: Container(
          width: sw * 0.065,
          height: sw * 0.065,
          decoration: BoxDecoration(
            color: AppColors.white,
            shape: .circle,
            border: .all(color: AppColors.camel.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: AppColors.charcoal.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, size: sw * 0.04, color: AppColors.camel),
        ),
      ),
    );
  }

  Widget _buildFavoriteButton(double sw) {
    return Positioned(
      top: MediaQuery.of(Get.context!).padding.top + sw * 0.015,
      right: sw * 0.04,
      child: Container(
        width: sw * 0.1,
        height: sw * 0.1,
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.92),
          borderRadius: .circular(sw * 0.03),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
            ),
          ],
        ),
        child: IconButton(
          padding: .zero,
          icon: Icon(
            Icons.favorite_border_rounded,
            color: AppColors.charcoal,
            size: sw * 0.05,
          ),
          onPressed: () {
            Get.snackbar(
              'Added to Wishlist',
              'This item has been saved to your favorites.',
              backgroundColor: AppColors.charcoal,
              colorText: AppColors.white,
              snackPosition: .BOTTOM,
              margin: .all(sw * 0.04),
              borderRadius: sw * 0.02,
            );
          },
        ),
      ),
    );
  }
}
