import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/app/utils/responsive.dart';
import 'package:ecom_app/app/widgets/custom_app_bar.dart';
import 'package:ecom_app/app/widgets/custom_button.dart';
import 'package:ecom_app/app/widgets/custom_text_field.dart';
import '../controllers/checkout_controller.dart';

class CheckoutView extends GetView<CheckoutController> {
  const CheckoutView({super.key});

  @override
  Widget build(BuildContext context) {
    final double sw = context.screenWidth;
    final double sh = context.screenHeight;

    return Scaffold(
      backgroundColor: AppColors.offWhite, // Soft Ivory #FAF9F6
      appBar: const CustomAppBar(title: "Checkout", showBackButton: true),
      body: Obx(() {
        if (controller.isProcessing.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.camel),
                SizedBox(height: 16),
                Text(
                  "Securing your connection...",
                  style: TextStyle(
                    color: AppColors.charcoal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }

        return Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                sw * 0.04,
                sw * 0.03,
                sw * 0.04,
                sw * 0.28,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader("Billing & Shipping Details", sw),
                  SizedBox(height: sw * 0.01),
                  _buildShippingForm(sw, sh),
                  SizedBox(height: sw * 0.03),

                  if (controller.isB2B.value) ...[
                    _buildHeader("Corporate Details", sw),
                    SizedBox(height: sw * 0.01),
                    _buildCorporateDetailsForm(sw),
                    SizedBox(height: sw * 0.03),

                    _buildHeader("Procurement Payment Method", sw),
                    SizedBox(height: sw * 0.01),
                    _buildB2BPaymentOptions(sw),
                    SizedBox(height: sw * 0.03),
                  ] else ...[
                    _buildHeader("Secure Payment", sw),
                    SizedBox(height: sw * 0.01),
                    _buildB2CPaymentSection(sw),
                    SizedBox(height: sw * 0.03),
                  ],

                  _buildHeader("Order Summary & Items", sw),
                  SizedBox(height: sw * 0.02),
                  _buildOrderItemsSummary(sw),
                  SizedBox(height: sw * 0.02),
                  _buildBillingBreakdown(sw),
                ],
              ),
            ),

            // Sticky CTA bottom bar
            _buildStickyCTA(sw),
          ],
        );
      }),
    );
  }

  // --- Sub-headers ---
  Widget _buildHeader(String text, double sw) {
    return Text(
      text,
      style: GoogleFonts.outfit(
        fontSize: sw * 0.045,
        fontWeight: FontWeight.w700,
        color: AppColors.charcoal,
        letterSpacing: 1.5,
      ),
    );
  }

  // --- Shipping & Billing Card ---
  Widget _buildShippingForm(double sw, double sh) {
    return Container(
      padding: EdgeInsets.all(sw * 0.04),
      decoration: BoxDecoration(
        color: AppColors.white, // Clean White #FFFFFF
        borderRadius: BorderRadius.circular(16),
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
          CustomTextField(
            label: "Full Name",
            controller: controller.fullNameController,
            isRequired: true,
            hinttext: "e.g. Sarah Wilson",
            margin: EdgeInsets.only(bottom: sh * 0.015),
          ),
          CustomTextField(
            label: "Shipping Address",
            controller: controller.addressController,
            isRequired: true,
            hinttext: "Street Address, Apt, Suite",
            margin: EdgeInsets.only(bottom: sh * 0.015),
          ),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  label: "City",
                  controller: controller.cityController,
                  isRequired: true,
                  hinttext: "e.g. New York",
                  margin: EdgeInsets.only(bottom: sh * 0.015),
                ),
              ),
              SizedBox(width: sw * 0.03),
              Expanded(
                child: CustomTextField(
                  label: "Postal Code",
                  controller: controller.postalCodeController,
                  isRequired: true,
                  hinttext: "e.g. 10001",
                  keyboardType: TextInputType.number,
                  margin: EdgeInsets.only(bottom: sh * 0.015),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  label: "Mobile Number",
                  controller: controller.phoneController,
                  isRequired: true,
                  hinttext: "+1 555-0199",
                  keyboardType: TextInputType.phone,
                  margin: EdgeInsets.only(bottom: sh * 0.015),
                ),
              ),
              SizedBox(width: sw * 0.03),
              Expanded(
                child: CustomTextField(
                  label: "Contact Email",
                  controller: controller.emailController,
                  isRequired: true,
                  hinttext: "sarah@domain.com",
                  keyboardType: TextInputType.emailAddress,
                  margin: EdgeInsets.only(bottom: sh * 0.015),
                ),
              ),
            ],
          ),
          SizedBox(height: sw * 0.02),
          Obx(
            () => InkWell(
              onTap: () {
                controller.billingSameAsShipping.toggle();
              },
              child: Row(
                children: [
                  Checkbox(
                    value: controller.billingSameAsShipping.value,
                    onChanged: (val) {
                      if (val != null) {
                        controller.billingSameAsShipping.value = val;
                      }
                    },
                    activeColor: AppColors.camel,
                  ),
                  Text(
                    "Billing address is same as shipping",
                    style: GoogleFonts.outfit(
                      fontSize: sw * 0.032,
                      color: AppColors.ink,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- B2B Corporate Details Card ---
  Widget _buildCorporateDetailsForm(double sw) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.04, vertical: sw * 0.02),
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
        children: [
          CustomTextField(
            label: "Registered Company Name",
            controller: controller.companyNameController,
            isRequired: true,
            hinttext: "Velvet Textiles Ltd",
          ),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  label: "National Tax Number (NTN)",
                  controller: controller.ntnController,
                  isRequired: true,
                  hinttext: "NTN-88192-X",
                ),
              ),
              SizedBox(width: sw * 0.03),
              Expanded(
                child: CustomTextField(
                  label: "Procurement Contact Email",
                  controller: controller.procurementEmailController,
                  isRequired: false,
                  hinttext: "procure@company.com",
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- B2B Custom Payment Terms Card ---
  Widget _buildB2BPaymentOptions(double sw) {
    return Obx(() {
      final activeOpt = controller.selectedPaymentOption.value;
      return Column(
        children: [
          _buildPaymentCardOption(
            value: "PO",
            title: "Submit Purchase Order (PO)",
            desc: "Upload corporate PO details for accounts clearance.",
            icon: Icons.receipt_long_rounded,
            activeOpt: activeOpt,
            sw: sw,
            extraContent: activeOpt == 'PO'
                ? Padding(
                    padding: EdgeInsets.only(top: sw * 0.03),
                    child: CustomTextField(
                      label: "PO Number",
                      controller: controller.poNumberController,
                      isRequired: true,
                      hinttext: "e.g. PO-88912",
                      margin: EdgeInsets.zero,
                    ),
                  )
                : null,
          ),
          SizedBox(height: sw * 0.03),
          _buildPaymentCardOption(
            value: "Net30",
            title: "Request Net-30 Invoice",
            desc:
                "Procure and fulfill immediately. Payment terms Net-30 days post-dispatch.",
            icon: Icons.schedule_rounded,
            activeOpt: activeOpt,
            sw: sw,
          ),
          SizedBox(height: sw * 0.03),
          _buildPaymentCardOption(
            value: "Safepay",
            title: "Pay via Safepay (Raast/Bank Transfer)",
            desc:
                "Pay online instantly using Raast ID, cards, or bank transfer for immediate dispatch.",
            icon: Icons.payment_rounded,
            activeOpt: activeOpt,
            sw: sw,
          ),
        ],
      );
    });
  }

  Widget _buildPaymentCardOption({
    required String value,
    required String title,
    required String desc,
    required IconData icon,
    required String activeOpt,
    required double sw,
    Widget? extraContent,
  }) {
    final bool isSelected = activeOpt == value;
    return GestureDetector(
      onTap: () => controller.selectedPaymentOption.value = value,
      child: Container(
        padding: EdgeInsets.all(sw * 0.04),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.camel
                : AppColors.greyLight.withValues(alpha: 0.8),
            width: isSelected ? 1.8 : 1.2,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: AppColors.camel.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            else
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.01),
                blurRadius: 4,
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: isSelected ? AppColors.camel : AppColors.charcoal,
                  size: sw * 0.05,
                ),
                SizedBox(width: sw * 0.03),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.outfit(
                          fontSize: sw * 0.034,
                          fontWeight: FontWeight.w700,
                          color: AppColors.charcoal,
                        ),
                      ),
                      SizedBox(height: sw * 0.005),
                      Text(
                        desc,
                        style: GoogleFonts.outfit(
                          fontSize: sw * 0.028,
                          color: AppColors.grey,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                Radio<String>(
                  value: value,
                  groupValue: activeOpt,
                  onChanged: (val) {
                    if (val != null) {
                      controller.selectedPaymentOption.value = val;
                    }
                  },
                  activeColor: AppColors.camel,
                ),
              ],
            ),
            ?extraContent,
          ],
        ),
      ),
    );
  }

  // --- B2C Secure Safepay Section ---
  Widget _buildB2CPaymentSection(double sw) {
    return Container(
      padding: EdgeInsets.all(sw * 0.04),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
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
              Container(
                padding: EdgeInsets.all(sw * 0.02),
                decoration: BoxDecoration(
                  color: AppColors.camel.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.shield_outlined,
                  color: AppColors.camel,
                  size: sw * 0.055,
                ),
              ),
              SizedBox(width: sw * 0.03),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Secure Checkout via Safepay",
                      style: GoogleFonts.outfit(
                        fontSize: sw * 0.035,
                        fontWeight: FontWeight.w700,
                        color: AppColors.charcoal,
                      ),
                    ),
                    Text(
                      "Supports Raast, Bank Transfer, & Cards",
                      style: GoogleFonts.outfit(
                        fontSize: sw * 0.028,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: sw * 0.03),
          Text(
            "Velvet Maison handles your order configuration dynamically. Once you proceed, Safepay will host a secure payment terminal where you can finalize payments utilizing cards, digital wallets, or quick bank payments.",
            style: GoogleFonts.outfit(
              fontSize: sw * 0.03,
              color: AppColors.ink,
              height: 1.4,
            ),
          ),
          SizedBox(height: sw * 0.03),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildPaymentLogoMock("Visa/Mastercard", sw),
              _buildPaymentLogoMock("Raast Pay", sw),
              _buildPaymentLogoMock("Bank Transfer", sw),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentLogoMock(String label, double sw) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: sw * 0.025,
        vertical: sw * 0.012,
      ),
      decoration: BoxDecoration(
        color: AppColors.offWhite,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.greyLight.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: GoogleFonts.outfit(
          fontSize: sw * 0.025,
          fontWeight: FontWeight.w600,
          color: AppColors.charcoal,
        ),
      ),
    );
  }

  // --- Summary & Items Card ---
  Widget _buildOrderItemsSummary(double sw) {
    final items = controller.isB2B.value
        ? controller.b2bCart.cartItems
        : controller.b2cCart.cartItems;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.04, vertical: sw * 0.02),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(15),
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
            "Review Items",
            style: GoogleFonts.outfit(
              fontSize: sw * 0.035,
              fontWeight: FontWeight.w700,
              color: AppColors.grey,
            ),
          ),
          Divider(height: sw * 0.03),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (ctx, index) {
              final item = items[index];
              return Padding(
                padding: EdgeInsets.only(bottom: sw * 0.01),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: item.imageUrl,
                        width: sw * 0.12,
                        height: sw * 0.12,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: sw * 0.12,
                          height: sw * 0.12,
                          color: AppColors.greyLight,
                          child: const Center(
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: sw * 0.12,
                          height: sw * 0.12,
                          color: AppColors.greyLight,
                          child: const Icon(Icons.image),
                        ),
                      ),
                    ),
                    SizedBox(width: sw * 0.03),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w700,
                              fontSize: sw * 0.032,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "${item.size != null ? 'Size: ${item.size} | ' : ''}Qty: ${item.quantity} units",
                            style: GoogleFonts.outfit(
                              color: AppColors.grey,
                              fontSize: sw * 0.028,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      "\$${(item.price * item.quantity).toStringAsFixed(2)}",
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w700,
                        fontSize: sw * 0.032,
                        color: AppColors.charcoal,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // --- Costs Breakdown ---
  Widget _buildBillingBreakdown(double sw) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.04, vertical: sw * 0.02),
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
        children: [
          _buildBreakdownRow(
            "Subtotal",
            "\$${controller.subtotal.toStringAsFixed(2)}",
            sw,
          ),
          if (controller.isB2B.value) ...[
            SizedBox(height: sw * 0.01),
            _buildBreakdownRow(
              "Corporate Discount",
              "Fitted Tier Matrix",
              sw,
              textColor: AppColors.success,
            ),
            SizedBox(height: sw * 0.01),
            _buildBreakdownRow("Shipping Fee", "Free (Wholesale Contract)", sw),
          ] else ...[
            SizedBox(height: sw * 0.01),
            _buildBreakdownRow(
              "Shipping Fee",
              "\$${controller.shippingFee.toStringAsFixed(2)}",
              sw,
            ),
          ],
          Divider(height: sw * 0.03),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total Estimate",
                style: GoogleFonts.outfit(
                  fontSize: sw * 0.034,
                  fontWeight: FontWeight.w800,
                  color: AppColors.charcoal,
                ),
              ),
              Text(
                "\$${controller.total.toStringAsFixed(2)}",
                style: GoogleFonts.outfit(
                  fontSize: sw * 0.045,
                  fontWeight: FontWeight.w900,
                  color: AppColors.camel,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownRow(
    String label,
    String val,
    double sw, {
    Color? textColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: sw * 0.032,
            color: AppColors.grey,
          ),
        ),
        Text(
          val,
          style: GoogleFonts.outfit(
            fontSize: sw * 0.032,
            fontWeight: FontWeight.w600,
            color: textColor ?? AppColors.charcoal,
          ),
        ),
      ],
    );
  }

  // --- Sticky full-width CTA bar ---
  Widget _buildStickyCTA(double sw) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: sw * 0.04,
          vertical: sw * 0.03,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: AppColors.charcoal.withValues(alpha: 0.06),
              blurRadius: 15,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Obx(() {
            final isValid = controller.isFormValid.value;
            String text = "Pay Securely via Safepay";
            if (controller.isB2B.value) {
              if (controller.selectedPaymentOption.value == 'Safepay') {
                text = "Pay Securely via Safepay";
              } else if (controller.selectedPaymentOption.value == 'PO') {
                text = "Submit PO & Complete";
              } else {
                text = "Submit Terms & Invoice";
              }
            }

            return CustomButton(
              text: text,
              onPressed: isValid ? () => controller.submitCheckout() : null,
              buttonColor: AppColors.camel,
              textColor: AppColors.white,
              width: double.infinity,
            );
          }),
        ),
      ),
    );
  }
}
