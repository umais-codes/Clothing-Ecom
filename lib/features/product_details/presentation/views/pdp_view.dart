import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
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
          _buildBackButton(sw),
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
            padding: .fromLTRB(sw * 0.04, sw * 0.02, sw * 0.04, 0),
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Row(
                  crossAxisAlignment: .start,
                  children: [
                    Expanded(
                      child: Text(
                        controller.product['name'],
                        style: Get.textTheme.displaySmall?.copyWith(
                          fontSize: sw * 0.045,
                          fontWeight: .w700,
                          height: 1.1,
                        ),
                      ),
                    ),
                    SizedBox(width: sw * 0.03),
                    Text(
                      '\$${controller.product['price'].toStringAsFixed(0)}',
                      style: Get.textTheme.headlineMedium?.copyWith(
                        fontWeight: .w800,
                        fontSize: sw * 0.045,
                        color: AppColors.camel,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: sw * 0.02),
                VariantSection(
                  title: 'SIZE',
                  items: controller.sizes,
                  selectedItem: controller.selectedSize,
                  sw: sw,
                ),
                SizedBox(height: sw * 0.02),
                VariantSection(
                  title: 'COLOR',
                  items: controller.colors,
                  selectedItem: controller.selectedColor,
                  sw: sw,
                ),
                SizedBox(height: sw * 0.02),
                AISizePredictorCard(
                  sw: sw,
                  onPredict: () => controller.runAIPrediction(),
                ),
                SizedBox(height: sw * 0.25),
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
        padding: .fromLTRB(sw * 0.05, sw * 0.02, sw * 0.05, sw * 0.02),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: .vertical(top: .circular(sw * 0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: CustomButton(
          text: 'Add to Cart',
          onPressed: () {},
          icon: Icons.shopping_bag_outlined,
        ),
      ),
    );
  }

  Widget _buildBackButton(double sw) {
    return Positioned(
      top: MediaQuery.of(Get.context!).padding.top + sw * 0.015,
      left: sw * 0.04,
      child: Container(
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
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.charcoal,
            size: sw * 0.045,
          ),
          onPressed: () => Get.back(),
        ),
      ),
    );
  }
}
