import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/app/utils/responsive.dart';
import '../controllers/fulfillment_controller.dart';
import 'package:ecom_app/app/widgets/custom_button.dart';
import 'package:ecom_app/app/widgets/custom_text_field.dart';
import 'package:ecom_app/app/widgets/custom_dropdown_field.dart';

class CourierSelectionSheet extends StatelessWidget {
  final FulfillmentController controller;

  const CourierSelectionSheet({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final double sw = context.screenWidth;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: sw * 0.05,
        left: sw * 0.05,
        right: sw * 0.05,
        bottom: context.paddingBottom + sw * 0.02,
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
                style: GoogleFonts.outfit(
                  fontSize: context.sp(sw * 0.045),
                  fontWeight: FontWeight.w700,
                  color: AppColors.charcoal,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.close_rounded,
                  color: AppColors.charcoal,
                  size: sw * 0.06,
                ),
                onPressed: () => Get.back(),
              ),
            ],
          ),
          const Divider(color: AppColors.greySubtle, height: 20),

          // Logistics Dropdown
          Obx(() {
            return CustomDropdownField(
              label: "Courier Partner",
              icon: Icons.local_shipping_outlined,
              value: controller.selectedCourier.value,
              items: controller.couriers,
              isRequired: true,
              onChanged: (val) {
                if (val != null) {
                  controller.selectedCourier.value = val;
                }
              },
            );
          }),
          SizedBox(height: sw * 0.02),

          // Input: Weight
          CustomTextField(
            label: "Package Weight (KG)",
            icon: Icons.scale_outlined,
            controller: controller.weightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            hinttext: "e.g. 1.5",
            isRequired: true,
          ),
          SizedBox(height: sw * 0.02),

          // Input: Tracking Number
          CustomTextField(
            label: "AWB Tracking No",
            icon: Icons.qr_code_scanner_rounded,
            controller: controller.trackingController,
            hinttext: "Enter shipping label bar code number",
            isRequired: true,
          ),
          SizedBox(height: sw * 0.04),

          // Submit button
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: "Confirm Shipment & Notify Customer",
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
          SizedBox(height: sw * 0.04),
          Row(
            children: [
              const Expanded(child: Divider(color: AppColors.greySubtle)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  "OR",
                  style: GoogleFonts.outfit(
                    fontSize: context.sp(10),
                    fontWeight: FontWeight.w800,
                    color: AppColors.grey,
                  ),
                ),
              ),
              const Expanded(child: Divider(color: AppColors.greySubtle)),
            ],
          ),
          SizedBox(height: sw * 0.04),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: "Book Via Courier Api",
                  variant: ButtonVariant.outlined,
                  textColor: AppColors.camel,
                  onPressed: () {
                    Get.back();
                    Get.toNamed('/admin-dispatch');
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
