import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/app/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductDetailBackButton extends StatelessWidget {
  const ProductDetailBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    final sw = context.screenWidth;
    return Positioned(
      top: context.paddingTop + sw * 0.015,
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
