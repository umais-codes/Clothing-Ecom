import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/app/utils/responsive.dart';
import '../controllers/fulfillment_controller.dart';
import 'package:ecom_app/app/widgets/custom_button.dart';
import 'package:ecom_app/app/widgets/custom_text_field.dart';
import 'package:ecom_app/app/widgets/custom_dropdown_field.dart';
import 'shipping_label_modal.dart';

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
      child: SingleChildScrollView(
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
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "Courier Dispatch Setup",
                      style: GoogleFonts.outfit(
                        fontSize: context.sp(sw * 0.045),
                        fontWeight: FontWeight.w700,
                        color: AppColors.charcoal,
                      ),
                    ),
                  ],
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
                    controller.autoGenerateAwb();
                  }
                },
              );
            }),
            SizedBox(height: sw * 0.03),

            // Input: Weight
            CustomTextField(
              label: "Package Weight (KG)",
              icon: Icons.scale_outlined,
              controller: controller.weightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              hinttext: "e.g. 1.2",
              isRequired: true,
            ),
            SizedBox(height: sw * 0.03),

            // Input: Tracking Number with Auto-generate button
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "AWB Tracking No *",
                      style: GoogleFonts.outfit(
                        fontSize: context.sp(12),
                        fontWeight: FontWeight.w600,
                        color: AppColors.charcoal,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => controller.autoGenerateAwb(),
                      child: Row(
                        children: [
                          const Icon(Icons.auto_awesome_rounded, size: 14, color: AppColors.camel),
                          const SizedBox(width: 4),
                          Text(
                            "Auto-Generate",
                            style: GoogleFonts.outfit(
                              fontSize: context.sp(11),
                              fontWeight: FontWeight.w700,
                              color: AppColors.camel,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                CustomTextField(
                  label: "",
                  icon: Icons.qr_code_scanner_rounded,
                  controller: controller.trackingController,
                  hinttext: "Enter or scan AWB number",
                  isRequired: true,
                ),
              ],
            ),
            SizedBox(height: sw * 0.04),

            // Action: Preview Shipping Label Button
            CustomButton(
              text: "Preview Printable Shipping Label",
              variant: ButtonVariant.outlined,
              height: sw * 0.11,
              textColor: AppColors.charcoal,
              onPressed: () {
                ShippingLabelModal.show(
                  context: context,
                  order: controller.order,
                  courier: controller.selectedCourier.value,
                  trackingNumber: controller.trackingController.text.trim(),
                  weight: double.tryParse(controller.weightController.text.trim()) ?? 1.2,
                );
              },
            ),
            SizedBox(height: sw * 0.03),

            // Submit button
            Obx(
              () => CustomButton(
                text: controller.isSubmitting.value
                    ? "Dispatching Order..."
                    : "Confirm Shipment & Notify Customer",
                variant: ButtonVariant.primary,
                buttonColor: AppColors.camel,
                textColor: AppColors.white,
                height: sw * 0.12,
                onPressed: controller.isSubmitting.value
                    ? null
                    : () => controller.confirmShipment(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
