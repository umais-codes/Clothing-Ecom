import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/app/utils/responsive.dart';
import '../controllers/fulfillment_controller.dart';
import 'package:ecom_app/app/widgets/custom_button.dart';

class CourierSelectionSheet extends StatelessWidget {
  final FulfillmentController controller;

  const CourierSelectionSheet({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final double sw = context.screenWidth;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: sw * 0.05,
        left: sw * 0.05,
        right: sw * 0.05,
        bottom: context.paddingBottom + sw * 0.05,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: sw * 0.12,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.greyLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: sw * 0.04),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Courier Dispatch Setup",
                style: GoogleFonts.cormorantGaramond(
                  fontSize: context.sp(22),
                  fontWeight: FontWeight.w800,
                  color: AppColors.charcoal,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: AppColors.charcoal),
                onPressed: () => Get.back(),
              ),
            ],
          ),
          const Divider(color: AppColors.greySubtle, height: 20),

          // Logistics Dropdown
          Text(
            "COURIER PARTNER",
            style: GoogleFonts.outfit(
              fontSize: context.sp(10),
              fontWeight: FontWeight.w800,
              color: AppColors.grey,
              letterSpacing: 1.0,
            ),
          ),
          SizedBox(height: sw * 0.02),
          Obx(() {
            return DropdownButtonFormField<String>(
              value: controller.selectedCourier.value,
              decoration: InputDecoration(
                fillColor: AppColors.offWhite,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.greyLight),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              style: GoogleFonts.outfit(
                color: AppColors.charcoal,
                fontSize: context.sp(13),
                fontWeight: FontWeight.w600,
              ),
              dropdownColor: AppColors.white,
              iconEnabledColor: AppColors.camel,
              items: controller.couriers.map((String courier) {
                return DropdownMenuItem<String>(
                  value: courier,
                  child: Text(courier),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  controller.selectedCourier.value = val;
                }
              },
            );
          }),
          SizedBox(height: sw * 0.05),

          // Input: Weight
          Text(
            "PACKAGE WEIGHT (KG)",
            style: GoogleFonts.outfit(
              fontSize: context.sp(10),
              fontWeight: FontWeight.w800,
              color: AppColors.grey,
              letterSpacing: 1.0,
            ),
          ),
          SizedBox(height: sw * 0.02),
          TextField(
            controller: controller.weightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: GoogleFonts.outfit(color: AppColors.charcoal, fontSize: context.sp(13)),
            decoration: InputDecoration(
              hintText: "e.g. 1.5",
              hintStyle: GoogleFonts.outfit(color: AppColors.grey, fontSize: context.sp(12)),
              fillColor: AppColors.offWhite,
              filled: true,
              prefixIcon: const Icon(Icons.scale_outlined, color: AppColors.camel, size: 20),
            ),
          ),
          SizedBox(height: sw * 0.05),

          // Input: Tracking Number
          Text(
            "AWB TRACKING NUMBER",
            style: GoogleFonts.outfit(
              fontSize: context.sp(10),
              fontWeight: FontWeight.w800,
              color: AppColors.grey,
              letterSpacing: 1.0,
            ),
          ),
          SizedBox(height: sw * 0.02),
          TextField(
            controller: controller.trackingController,
            style: GoogleFonts.outfit(color: AppColors.charcoal, fontSize: context.sp(13)),
            decoration: InputDecoration(
              hintText: "Enter shipping label bar code number",
              hintStyle: GoogleFonts.outfit(color: AppColors.grey, fontSize: context.sp(12)),
              fillColor: AppColors.offWhite,
              filled: true,
              prefixIcon: const Icon(Icons.qr_code_scanner_rounded, color: AppColors.camel, size: 20),
            ),
          ),
          SizedBox(height: sw * 0.08),

          // Submit button
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: "CONFIRM SHIPMENT & NOTIFY CUSTOMER",
                  variant: ButtonVariant.primary,
                  buttonColor: AppColors.camel,
                  textColor: AppColors.white,
                  onPressed: () {
                    controller.confirmShipment();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
