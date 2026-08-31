import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/app/utils/responsive.dart';
import 'package:ecom_app/app/widgets/custom_button.dart';
import '../../controllers/tracking_controller.dart';

class OrderLogisticsCard extends GetView<TrackingController> {
  const OrderLogisticsCard({super.key});

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.camel.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.local_shipping_outlined,
                      color: AppColors.camel,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "LOGISTICS PARTNER",
                    style: GoogleFonts.outfit(
                      fontSize: context.sp(10),
                      fontWeight: FontWeight.w800,
                      color: AppColors.grey,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              Obx(
                () => Text(
                  controller.courierName.value,
                  style: GoogleFonts.outfit(
                    fontSize: context.sp(13),
                    fontWeight: FontWeight.w700,
                    color: AppColors.charcoal,
                  ),
                ),
              ),
            ],
          ),
          const Divider(color: AppColors.greySubtle, height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "AWB Tracking Code",
                    style: GoogleFonts.outfit(
                      fontSize: context.sp(10),
                      color: AppColors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Obx(
                    () => Text(
                      controller.trackingId.value,
                      style: GoogleFonts.outfit(
                        fontSize: context.sp(14),
                        fontWeight: FontWeight.w800,
                        color: AppColors.charcoal,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              CustomButton(
                text: "Copy Code",
                variant: ButtonVariant.outlined,
                width: sw * 0.28,
                height: sw * 0.09,
                textColor: AppColors.charcoal,
                onPressed: () => controller.copyTrackingId(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
