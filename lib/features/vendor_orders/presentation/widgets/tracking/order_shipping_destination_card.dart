import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/app/utils/responsive.dart';
import '../../controllers/tracking_controller.dart';

class OrderShippingDestinationCard extends GetView<TrackingController> {
  const OrderShippingDestinationCard({super.key});

  @override
  Widget build(BuildContext context) {
    final double sw = context.screenWidth;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(sw * 0.045),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.greyLight.withValues(alpha: 0.7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: AppColors.camel,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                "DELIVERY DESTINATION",
                style: GoogleFonts.outfit(
                  fontSize: context.sp(10),
                  fontWeight: FontWeight.w800,
                  color: AppColors.grey,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const Divider(color: AppColors.greySubtle, height: 20),
          Obx(
            () => Text(
              controller.customerName.value,
              style: GoogleFonts.outfit(
                fontSize: context.sp(13),
                fontWeight: FontWeight.w700,
                color: AppColors.charcoal,
              ),
            ),
          ),
          const SizedBox(height: 3),
          Obx(
            () => Text(
              controller.shippingAddress.value,
              style: GoogleFonts.outfit(
                fontSize: context.sp(12),
                color: AppColors.grey,
                height: 1.4,
              ),
            ),
          ),
          Obx(() {
            if (controller.customerPhone.value.isEmpty) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                "Contact: ${controller.customerPhone.value}",
                style: GoogleFonts.outfit(
                  fontSize: context.sp(11),
                  color: AppColors.charcoal,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
