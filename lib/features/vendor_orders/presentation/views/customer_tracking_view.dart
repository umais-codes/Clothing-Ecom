import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/app/utils/responsive.dart';
import 'package:ecom_app/app/widgets/custom_button.dart';
import '../controllers/tracking_controller.dart';
import 'package:ecom_app/app/widgets/custom_app_bar.dart';
import 'package:ecom_app/features/post_purchase/presentation/views/review_submission_sheet.dart';
import 'package:ecom_app/features/post_purchase/presentation/controllers/review_controller.dart';
import 'package:ecom_app/features/vendor_orders/domain/entities/vendor_order.dart';

class CustomerTrackingView extends GetView<TrackingController> {
  const CustomerTrackingView({super.key});

  @override
  Widget build(BuildContext context) {
    final double sw = context.screenWidth;

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: CustomAppBar(
        title: "Live Tracking",
        backgroundColor: AppColors.offWhite,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: "Simulate status update",
            icon: const Icon(Icons.bolt, color: AppColors.camel),
            onPressed: () => controller.simulateStatusUpdate(),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(sw * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Order Summary Header
              _buildOrderSummaryCard(context, sw),
              SizedBox(height: sw * 0.04),

              // 2. Courier Details Card
              _buildCourierCard(context, sw),
              SizedBox(height: sw * 0.04),

              // 3. Visual Stepper Container
              _buildStepperCard(context, sw),

              // 4. Post-Purchase Actions (Returns & Reviews)
              Obx(() {
                final isDelivered =
                    controller.activeStepIndex.value ==
                    controller.steps.length - 1;
                if (!isDelivered) return const SizedBox.shrink();

                return Column(
                  children: [
                    SizedBox(height: sw * 0.06),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(sw * 0.045),
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
                            "Order Delivered",
                            style: GoogleFonts.outfit(
                              fontSize: context.sp(14),
                              fontWeight: FontWeight.w800,
                              color: AppColors.charcoal,
                            ),
                          ),
                          SizedBox(height: sw * 0.01),
                          Text(
                            "We hope you love your new garment! Let us know how it fits or request a return if it didn't work out.",
                            style: GoogleFonts.outfit(
                              fontSize: context.sp(11),
                              color: AppColors.grey,
                              height: 1.3,
                            ),
                          ),
                          SizedBox(height: sw * 0.04),
                          Row(
                            children: [
                              Expanded(
                                child: CustomButton(
                                  text: "Request Return",
                                  variant: ButtonVariant.outlined,
                                  textColor: AppColors.charcoal,
                                  onPressed: () {
                                    final vendorOrder = VendorOrder(
                                      id: controller.orderId,
                                      customerName: "Velvet Maison Shopper",
                                      amount: 350.00,
                                      status: "Delivered",
                                      orderDate: DateTime.now().subtract(
                                        const Duration(days: 2),
                                      ),
                                      isB2B: false,
                                      items: [
                                        VendorOrderItem(
                                          id: "item_wool_blazer",
                                          name: controller.itemName,
                                          quantity: 1,
                                          unitPrice: 350.00,
                                          imageUrl: controller.itemImageUrl,
                                          size: "M",
                                          color: "Sand",
                                        ),
                                      ],
                                      timeline: [],
                                    );
                                    Get.toNamed(
                                      '/rma-request',
                                      arguments: vendorOrder,
                                    );
                                  },
                                ),
                              ),
                              SizedBox(width: sw * 0.03),
                              Expanded(
                                child: CustomButton(
                                  text: "Rate & Review",
                                  buttonColor: AppColors.camel,
                                  textColor: AppColors.white,
                                  onPressed: () {
                                    Get.put(ReviewController());
                                    Get.bottomSheet(
                                      ReviewSubmissionSheet(
                                        orderId: controller.orderId,
                                        productId: "b2c_1",
                                        productName: controller.itemName,
                                        productImageUrl:
                                            controller.itemImageUrl,
                                      ),
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderSummaryCard(BuildContext context, double sw) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(sw * 0.045),
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
                controller.orderId,
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w800,
                  fontSize: context.sp(14),
                  color: AppColors.charcoal,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.camelLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "In Transit",
                  style: GoogleFonts.outfit(
                    color: AppColors.camel,
                    fontSize: context.sp(9),
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: sw * 0.01),
          Text(
            "Estimated Delivery: ${controller.expectedDelivery}",
            style: GoogleFonts.outfit(
              fontSize: context.sp(12),
              color: AppColors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Divider(color: AppColors.greySubtle, height: 24),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  controller.itemImageUrl,
                  width: sw * 0.15,
                  height: sw * 0.15,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) => Container(
                    width: sw * 0.15,
                    height: sw * 0.15,
                    color: AppColors.greyLight,
                    child: const Icon(
                      Icons.broken_image_outlined,
                      color: AppColors.grey,
                    ),
                  ),
                ),
              ),
              SizedBox(width: sw * 0.04),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.itemName,
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w700,
                        fontSize: context.sp(14),
                        color: AppColors.charcoal,
                      ),
                    ),
                    Text(
                      "Velvet Maison Premium Collection",
                      style: GoogleFonts.outfit(
                        fontSize: context.sp(11),
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                "\$350.00",
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w900,
                  fontSize: context.sp(14),
                  color: AppColors.charcoal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCourierCard(BuildContext context, double sw) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(sw * 0.045),
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
              Row(
                children: [
                  const Icon(
                    Icons.local_shipping_outlined,
                    color: AppColors.camel,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Logistics Details",
                    style: GoogleFonts.outfit(
                      fontSize: context.sp(10),
                      fontWeight: FontWeight.w800,
                      color: AppColors.grey,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              Text(
                controller.courierName,
                style: GoogleFonts.outfit(
                  fontSize: context.sp(12),
                  fontWeight: FontWeight.w700,
                  color: AppColors.charcoal,
                ),
              ),
            ],
          ),
          const Divider(color: AppColors.greySubtle, height: 20),
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
                  Text(
                    controller.trackingId,
                    style: GoogleFonts.outfit(
                      fontSize: context.sp(14),
                      fontWeight: FontWeight.w700,
                      color: AppColors.charcoal,
                    ),
                  ),
                ],
              ),
              CustomButton(
                text: "Copy AWB",
                variant: ButtonVariant.outlined,
                textColor: AppColors.camel,
                width: sw * 0.28,
                height: sw * 0.09,
                fontSize: context.sp(11),
                fontWeight: FontWeight.w700,
                onPressed: () => controller.copyTrackingId(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepperCard(BuildContext context, double sw) {
    return Container(
      width: double.infinity,
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
            "Delivery Progress",
            style: GoogleFonts.outfit(
              fontSize: context.sp(10),
              fontWeight: FontWeight.w800,
              color: AppColors.grey,
              letterSpacing: 1.0,
            ),
          ),
          const Divider(color: AppColors.greySubtle, height: 20),
          SizedBox(height: sw * 0.02),
          Obx(() {
            final activeIndex = controller.activeStepIndex.value;
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.steps.length,
              itemBuilder: (context, index) {
                final step = controller.steps[index];
                final isCompleted = index < activeIndex;
                final isActive = index == activeIndex;
                final isPending = index > activeIndex;
                final isLast = index == controller.steps.length - 1;

                Color nodeColor = AppColors.greyLight;
                if (isActive) {
                  nodeColor = AppColors.camel;
                } else if (isCompleted) {
                  nodeColor = AppColors.success;
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Indicator Column (Circle + Connector line)
                    Column(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: sw * 0.05,
                          height: sw * 0.05,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isPending ? Colors.transparent : nodeColor,
                            border: Border.all(
                              color: isPending
                                  ? AppColors.greyLight
                                  : nodeColor,
                              width: 2,
                            ),
                            boxShadow: isActive
                                ? [
                                    BoxShadow(
                                      color: AppColors.camel.withValues(
                                        alpha: 0.3,
                                      ),
                                      blurRadius: 6,
                                      spreadRadius: 2,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: isCompleted
                                ? Icon(
                                    Icons.check,
                                    size: sw * 0.03,
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
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 2,
                            height: sw * 0.12,
                            color: isCompleted
                                ? AppColors.success
                                : AppColors.greyLight,
                          ),
                      ],
                    ),
                    SizedBox(width: sw * 0.04),
                    // Step texts
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
                              fontSize: context.sp(13),
                              color: isPending
                                  ? AppColors.grey
                                  : AppColors.charcoal,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            step['subtitle']!,
                            style: GoogleFonts.outfit(
                              fontSize: context.sp(11),
                              color: isPending
                                  ? AppColors.grey.withValues(alpha: 0.6)
                                  : AppColors.ink,
                            ),
                          ),
                          SizedBox(height: sw * 0.04),
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
}
