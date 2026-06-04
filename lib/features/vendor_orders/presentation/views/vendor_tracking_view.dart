import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/app/utils/responsive.dart';
import 'package:ecom_app/app/widgets/custom_button.dart';
import 'package:ecom_app/app/widgets/custom_app_bar.dart';
import '../controllers/vendor_tracking_controller.dart';

class VendorTrackingView extends GetView<VendorTrackingController> {
  const VendorTrackingView({super.key});

  @override
  Widget build(BuildContext context) {
    final double sw = context.screenWidth;

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: const CustomAppBar(
        title: "Logistics Dashboard",
        backgroundColor: AppColors.offWhite,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: sw * 0.03,
            vertical: sw * 0.02,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Shipment Specification Info Card (Vendor Specific)
              _buildSpecsCard(context, sw),
              SizedBox(height: sw * 0.02),

              // 2. Dest Consignee Card
              _buildConsigneeCard(context, sw),
              SizedBox(height: sw * 0.02),

              // 3. Dynamic Tracking Timeline
              _buildTimelineCard(context, sw),
              SizedBox(height: sw * 0.02),

              // 4. Webhook Simulator Panel
              _buildWebhookConsole(context, sw),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpecsCard(BuildContext context, double sw) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: sw * 0.03,
        vertical: sw * 0.015,
      ),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Shipment Specs",
                style: GoogleFonts.outfit(
                  fontSize: context.sp(sw * 0.045),
                  fontWeight: FontWeight.w700,
                  color: AppColors.charcoal,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: sw * 0.02,
                  vertical: sw * 0.01,
                ),
                decoration: BoxDecoration(
                  color: AppColors.camelLight,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  controller.orderId,
                  style: GoogleFonts.outfit(
                    fontSize: context.sp(sw * 0.03),
                    color: AppColors.camel,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          Divider(color: AppColors.greySubtle, height: sw * 0.03),
          _buildSpecRow("Courier Partner", controller.courierName, context, sw),
          SizedBox(height: sw * 0.01),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "AWB Tracking Code",
                style: GoogleFonts.outfit(
                  fontSize: context.sp(sw * 0.035),
                  color: AppColors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Row(
                children: [
                  Text(
                    controller.trackingId,
                    style: GoogleFonts.outfit(
                      fontSize: context.sp(sw * 0.035),
                      color: AppColors.charcoal,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: sw * 0.015),
                  Obx(() {
                    final copied = controller.isCopied.value;
                    return GestureDetector(
                      onTap: () => controller.copyAwb(),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          copied ? Icons.check_circle : Icons.copy_rounded,
                          key: ValueKey(copied),
                          color: copied ? AppColors.success : AppColors.camel,
                          size: 16,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),
          SizedBox(height: sw * 0.01),
          _buildSpecRow(
            "Package Weight",
            "${controller.packageWeight} kg",
            context,
            sw,
          ),
          SizedBox(height: sw * 0.01),
          _buildSpecRow("Dimensions", controller.dimensions, context, sw),
        ],
      ),
    );
  }

  Widget _buildSpecRow(
    String label,
    String value,
    BuildContext context,
    double sw,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: context.sp(sw * 0.035),
            color: AppColors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: context.sp(sw * 0.035),
            color: AppColors.charcoal,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildConsigneeCard(BuildContext context, double sw) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: sw * 0.03,
        vertical: sw * 0.015,
      ),
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
            "Consignee & Address",
            style: GoogleFonts.outfit(
              fontSize: context.sp(sw * 0.045),
              fontWeight: FontWeight.w700,
              color: AppColors.charcoal,
            ),
          ),
          Divider(color: AppColors.greySubtle, height: sw * 0.03),
          Text(
            controller.consigneeName,
            style: GoogleFonts.outfit(
              fontSize: context.sp(sw * 0.035),
              fontWeight: FontWeight.w600,
              color: AppColors.charcoal,
            ),
          ),
          SizedBox(height: sw * 0.01),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.location_on_outlined,
                color: AppColors.camel,
                size: context.sp(sw * 0.035),
              ),
              SizedBox(width: sw * 0.015),
              Expanded(
                child: Text(
                  controller.shippingAddress,
                  style: GoogleFonts.outfit(
                    fontSize: context.sp(sw * 0.03),
                    color: AppColors.charcoal,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineCard(BuildContext context, double sw) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: sw * 0.03,
        vertical: sw * 0.015,
      ),
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
            "Transit History",
            style: GoogleFonts.outfit(
              fontSize: context.sp(sw * 0.045),
              fontWeight: FontWeight.w700,
              color: AppColors.charcoal,
            ),
          ),
          Divider(color: AppColors.greySubtle, height: sw * 0.03),
          Obx(() {
            final activeIdx = controller.activeStepIndex.value;
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.steps.length,
              itemBuilder: (context, index) {
                final step = controller.steps[index];
                final isCompleted = index < activeIdx;
                final isActive = index == activeIdx;
                final isPending = index > activeIdx;
                final isLast = index == controller.steps.length - 1;

                Color color = AppColors.greyLight;
                if (isActive) {
                  color = AppColors.camel;
                } else if (isCompleted) {
                  color = AppColors.success;
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: sw * 0.045,
                          height: sw * 0.045,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isPending ? Colors.transparent : color,
                            border: Border.all(
                              color: isPending ? AppColors.greyLight : color,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: isCompleted
                                ? Icon(
                                    Icons.check,
                                    size: sw * 0.025,
                                    color: AppColors.white,
                                  )
                                : (isActive
                                      ? Container(
                                          width: sw * 0.015,
                                          height: sw * 0.015,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: AppColors.white,
                                          ),
                                        )
                                      : null),
                          ),
                        ),
                        if (!isLast)
                          Container(
                            width: 2,
                            height: sw * 0.12,
                            color: isCompleted
                                ? AppColors.success
                                : AppColors.greyLight,
                          ),
                      ],
                    ),
                    SizedBox(width: sw * 0.015),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            step['title']!,
                            style: GoogleFonts.outfit(
                              fontWeight: (isActive || isCompleted)
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              fontSize: context.sp(sw * 0.035),
                              color: isPending
                                  ? AppColors.grey
                                  : AppColors.charcoal,
                            ),
                          ),
                          Text(
                            step['subtitle']!,
                            style: GoogleFonts.outfit(
                              fontSize: context.sp(sw * 0.03),
                              color: isPending
                                  ? AppColors.grey.withValues(alpha: 0.6)
                                  : AppColors.charcoal,
                            ),
                          ),
                          SizedBox(height: sw * 0.03),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildWebhookConsole(BuildContext context, double sw) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: sw * 0.03,
        vertical: sw * 0.015,
      ),
      decoration: BoxDecoration(
        color: AppColors.camelLight.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.camel.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.developer_board_rounded,
                color: AppColors.camel,
                size: 20,
              ),
              SizedBox(width: sw * 0.02),
              Text(
                "Webhook API Console",
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.camel,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          SizedBox(height: sw * 0.02),
          Text(
            "Trigger mock logistics carrier status updates (webhook callbacks) to test the vendor's shipment status flow and notifications.",
            style: GoogleFonts.outfit(
              fontSize: context.sp(sw * 0.03),
              color: AppColors.ink,
              height: 1.3,
            ),
          ),
          SizedBox(height: sw * 0.02),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: "Trigger Mock Webhook Event",
                  variant: ButtonVariant.primary,
                  buttonColor: AppColors.camel,
                  textColor: AppColors.white,
                  onPressed: () => controller.simulateWebhookUpdate(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
