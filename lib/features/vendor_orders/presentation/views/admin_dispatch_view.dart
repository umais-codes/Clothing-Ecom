import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/app/utils/responsive.dart';
import 'package:ecom_app/app/widgets/custom_text_field.dart';
import 'package:ecom_app/app/widgets/custom_dropdown_field.dart';
import 'package:ecom_app/app/widgets/custom_button.dart';
import '../controllers/dispatch_controller.dart';

class AdminDispatchView extends GetView<DispatchController> {
  const AdminDispatchView({super.key});

  @override
  Widget build(BuildContext context) {
    final double sw = context.screenWidth;

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        backgroundColor: AppColors.offWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.charcoal,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Shipment Booking",
          style: GoogleFonts.cormorantGaramond(
            fontSize: context.sp(22),
            fontWeight: FontWeight.w800,
            color: AppColors.charcoal,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Obx(() {
          final booked = controller.isBooked.value;
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: booked
                ? _buildSuccessAWBState(context, sw)
                : _buildBookingFormState(context, sw),
          );
        }),
      ),
    );
  }

  Widget _buildBookingFormState(BuildContext context, double sw) {
    return SingleChildScrollView(
      key: const ValueKey('booking_form'),
      padding: EdgeInsets.all(sw * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(sw * 0.05),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.charcoal.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Logistics Booking Details",
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: context.sp(18),
                    fontWeight: FontWeight.w700,
                    color: AppColors.charcoal,
                  ),
                ),
                const Divider(color: AppColors.greySubtle, height: 20),

                // 1. Courier Selection Dropdown
                CustomDropdownField(
                  label: "Logistics Partner",
                  icon: Icons.local_shipping_outlined,
                  value: controller.selectedCourier.value,
                  items: controller.couriers,
                  isRequired: true,
                  onChanged: (val) {
                    if (val != null) {
                      controller.selectedCourier.value = val;
                    }
                  },
                ),
                SizedBox(height: sw * 0.02),

                // 2. Package Weight Input
                CustomTextField(
                  label: "Package Weight (KG)",
                  icon: Icons.scale_outlined,
                  controller: controller.weightController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  isRequired: true,
                  hinttext: "e.g. 1.25",
                ),
                SizedBox(height: sw * 0.02),

                // 3. Package Dimensions Inputs
                Text(
                  "Package Dimensions (CM)",
                  style: GoogleFonts.outfit(
                    fontSize: sw * 0.033,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                SizedBox(height: sw * 0.015),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: controller.lengthController,
                        keyboardType: TextInputType.number,
                        hinttext: "Len (L)",
                      ),
                    ),
                    SizedBox(width: sw * 0.02),
                    Expanded(
                      child: CustomTextField(
                        controller: controller.widthController,
                        keyboardType: TextInputType.number,
                        hinttext: "Wid (W)",
                      ),
                    ),
                    SizedBox(width: sw * 0.02),
                    Expanded(
                      child: CustomTextField(
                        controller: controller.heightController,
                        keyboardType: TextInputType.number,
                        hinttext: "Hgt (H)",
                      ),
                    ),
                  ],
                ),
                SizedBox(height: sw * 0.02),

                // 4. Delivery Address
                CustomTextField(
                  label: "Consignee Delivery Address",
                  icon: Icons.location_on_outlined,
                  controller: controller.addressController,
                  isRequired: true,
                  maxLines: 3,
                  hinttext: "Enter full street delivery address",
                ),
                SizedBox(height: sw * 0.05),

                // Booking Action button
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: "Book Shipment & Generate AWB",
                        variant: ButtonVariant.primary,
                        buttonColor: AppColors.camel,
                        textColor: AppColors.white,
                        onPressed: () => controller.bookShipment(),
                      ),
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

  Widget _buildSuccessAWBState(BuildContext context, double sw) {
    return SingleChildScrollView(
      key: const ValueKey('success_state'),
      padding: EdgeInsets.all(sw * 0.05),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(sw * 0.06),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.success.withValues(alpha: 0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.success.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Success Badge
                Container(
                  padding: EdgeInsets.all(sw * 0.04),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.success,
                    size: sw * 0.12,
                  ),
                ),
                SizedBox(height: sw * 0.04),
                Text(
                  "Logistics Booking Confirmed",
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: context.sp(20),
                    fontWeight: FontWeight.w700,
                    color: AppColors.charcoal,
                  ),
                ),
                Text(
                  "Courier pickup booked and AWB generated",
                  style: GoogleFonts.outfit(
                    fontSize: context.sp(11),
                    color: AppColors.grey,
                  ),
                ),
                const Divider(color: AppColors.greySubtle, height: 32),

                // AWB Details
                _buildDetailsRow(
                  context,
                  "Courier Selected",
                  "${controller.selectedCourier.value} Express",
                ),
                const SizedBox(height: 8),
                _buildDetailsRow(
                  context,
                  "AWB Tracking ID",
                  controller.generatedAwb.value,
                  isBold: true,
                ),
                const SizedBox(height: 8),
                _buildDetailsRow(
                  context,
                  "Weight Booked",
                  "${controller.weightController.text} kg",
                ),
                const SizedBox(height: 8),
                _buildDetailsRow(
                  context,
                  "Dimensions (L x W x H)",
                  "${controller.lengthController.text}x${controller.widthController.text}x${controller.heightController.text} cm",
                ),
                const Divider(color: AppColors.greySubtle, height: 32),

                // Customer Notification Toggle Option
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.notifications_active_outlined,
                          color: AppColors.camel,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Notify Customer",
                          style: GoogleFonts.outfit(
                            fontSize: context.sp(12),
                            fontWeight: FontWeight.w600,
                            color: AppColors.charcoal,
                          ),
                        ),
                      ],
                    ),
                    Obx(() {
                      return Switch(
                        value: controller.notifyCustomer.value,
                        activeThumbColor: AppColors.camel,
                        activeTrackColor: AppColors.camelLight,
                        onChanged: (val) {
                          controller.notifyCustomer.value = val;
                        },
                      );
                    }),
                  ],
                ),
                SizedBox(height: sw * 0.06),

                // Main download action button
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: "Download Shipping Label (AWB)",
                        variant: ButtonVariant.primary,
                        buttonColor: AppColors.camel,
                        textColor: AppColors.white,
                        onPressed: () {
                          Get.snackbar(
                            'Label Generating',
                            'Downloading shipping PDF label for ${controller.generatedAwb.value}...',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: AppColors.success.withValues(
                              alpha: 0.15,
                            ),
                            colorText: AppColors.success,
                          );
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: sw * 0.03),

                // Reset Action Button
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: "Book Another Shipment",
                        variant: ButtonVariant.outlined,
                        textColor: AppColors.charcoal,
                        onPressed: () => controller.resetBooking(),
                      ),
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

  Widget _buildDetailsRow(
    BuildContext context,
    String title,
    String val, {
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: context.sp(11),
            color: AppColors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          val,
          style: GoogleFonts.outfit(
            fontSize: context.sp(12),
            color: isBold ? AppColors.camel : AppColors.charcoal,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
