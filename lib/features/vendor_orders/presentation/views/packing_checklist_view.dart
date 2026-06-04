import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecom_app/app/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/app/utils/responsive.dart';
import 'package:ecom_app/app/widgets/custom_app_bar.dart';
import '../controllers/fulfillment_controller.dart';
import '../widgets/courier_selection_sheet.dart';

class PackingChecklistView extends GetView<FulfillmentController> {
  const PackingChecklistView({super.key});

  @override
  Widget build(BuildContext context) {
    final double sw = context.screenWidth;

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: const CustomAppBar(
        title: "Fulfillment Checklist",
        backgroundColor: AppColors.offWhite,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Customer & Address Info Card
            _buildCustomerInfoCard(context, sw),

            // Checklist Counter
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: sw * 0.03,
                vertical: sw * 0.015,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Items Checklist",
                    style: GoogleFonts.outfit(
                      fontSize: context.sp(sw * 0.03),
                      fontWeight: FontWeight.w700,
                      color: AppColors.grey,
                      letterSpacing: 1.5,
                    ),
                  ),
                  Obx(() {
                    final total = controller.checklistItems.length;
                    final packed = controller.packedStates.values
                        .where((v) => v)
                        .length;
                    final allChecked = packed == total;
                    return Row(
                      children: [
                        Text(
                          "$packed of $total Packed",
                          style: GoogleFonts.outfit(
                            fontSize: context.sp(12),
                            fontWeight: FontWeight.w700,
                            color: allChecked
                                ? AppColors.success
                                : AppColors.camel,
                          ),
                        ),
                        SizedBox(width: sw * 0.03),
                        InkWell(
                          onTap: () => controller.markAllPacked(!allChecked),
                          borderRadius: BorderRadius.circular(6),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: EdgeInsets.symmetric(
                              horizontal: sw * 0.02,
                              vertical: sw * 0.005,
                            ),
                            decoration: BoxDecoration(
                              color: allChecked
                                  ? AppColors.success.withValues(alpha: 0.1)
                                  : AppColors.camel.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              allChecked ? "Uncheck All" : "Check All",
                              style: GoogleFonts.outfit(
                                fontSize: context.sp(sw * 0.025),
                                fontWeight: FontWeight.w600,
                                color: allChecked
                                    ? AppColors.success
                                    : AppColors.camel,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),

            // Scrollable Checklist
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: sw * 0.04),
                itemCount: controller.checklistItems.length,
                itemBuilder: (context, index) {
                  final item = controller.checklistItems[index];
                  return Obx(() {
                    final isPacked = controller.packedStates[item.id] ?? false;
                    return GestureDetector(
                      onTap: () => controller.togglePacked(item.id),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: EdgeInsets.only(bottom: sw * 0.015),
                        padding: EdgeInsets.symmetric(
                          horizontal: sw * 0.02,
                          vertical: sw * 0.01,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isPacked
                                ? AppColors.success.withValues(alpha: 0.5)
                                : AppColors.greyLight.withValues(alpha: 0.3),
                            width: isPacked ? 1.5 : 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isPacked
                                  ? AppColors.success.withValues(alpha: 0.03)
                                  : AppColors.charcoal.withValues(alpha: 0.02),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Product Thumbnail
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CachedNetworkImage(
                                imageUrl: item.imageUrl,
                                width: sw * 0.15,
                                height: sw * 0.15,
                                fit: BoxFit.cover,

                                placeholder: (context, url) => Container(
                                  width: sw * 0.15,
                                  height: sw * 0.15,
                                  alignment: Alignment.center,
                                  color: AppColors.greyLight,
                                  child: const CircularProgressIndicator(),
                                ),

                                errorWidget: (context, url, error) => Container(
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
                            SizedBox(width: sw * 0.03),
                            // Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.w700,
                                      fontSize: context.sp(14),
                                      color: isPacked
                                          ? AppColors.grey
                                          : AppColors.charcoal,
                                      decoration: isPacked
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                                  ),
                                  SizedBox(height: sw * 0.005),
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: sw * 0.015,
                                          vertical: sw * 0.005,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.offWhite,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          "Size: ${item.size}",
                                          style: GoogleFonts.outfit(
                                            fontSize: context.sp(10),
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.ink,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: sw * 0.02),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: sw * 0.015,
                                          vertical: sw * 0.005,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.offWhite,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          "Color: ${item.color}",
                                          style: GoogleFonts.outfit(
                                            fontSize: context.sp(10),
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.ink,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Qty & Checkbox
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "${item.quantity} Qty",
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.w800,
                                    fontSize: context.sp(sw * 0.03),
                                    color: isPacked
                                        ? AppColors.grey
                                        : AppColors.charcoal.withValues(
                                            alpha: 0.8,
                                          ),
                                  ),
                                ),
                                SizedBox(height: sw * 0.01),
                                Checkbox(
                                  value: isPacked,
                                  activeColor: AppColors.camel,
                                  checkColor: AppColors.white,
                                  onChanged: (val) {
                                    controller.togglePacked(item.id);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  });
                },
              ),
            ),

            // Bottom Action Drawer Panel
            _buildBottomPanel(context, sw),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerInfoCard(BuildContext context, double sw) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: sw * 0.03, vertical: sw * 0.015),
      padding: EdgeInsets.symmetric(horizontal: sw * 0.02, vertical: sw * 0.01),
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
            "Ship To",
            style: GoogleFonts.outfit(
              fontSize: context.sp(sw * 0.035),
              fontWeight: FontWeight.w700,
              color: AppColors.camel,
              letterSpacing: 1.0,
            ),
          ),
          SizedBox(height: sw * 0.01),
          Text(
            controller.order.customerName,
            style: GoogleFonts.outfit(
              fontSize: context.sp(sw * 0.035),
              fontWeight: FontWeight.w700,
              color: AppColors.charcoal,
            ),
          ),
          if (controller.order.customerPhone != null) ...[
            const SizedBox(height: 2),
            Text(
              "Phone: ${controller.order.customerPhone!}",
              style: GoogleFonts.outfit(
                fontSize: context.sp(11),
                color: AppColors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          Divider(color: AppColors.greySubtle, height: sw * 0.03),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: AppColors.camel,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  controller.order.shippingAddress ??
                      'No Shipping Address Provided',
                  style: GoogleFonts.outfit(
                    fontSize: context.sp(12),
                    color: AppColors.ink,
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

  Widget _buildBottomPanel(BuildContext context, double sw) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.04, vertical: sw * 0.02),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.charcoal.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Obx(() {
        final allPacked = controller.isAllPacked;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!allPacked)
              Padding(
                padding: EdgeInsets.only(bottom: sw * 0.02),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.camel,
                      size: context.sp(sw * 0.028),
                    ),
                    SizedBox(width: sw * 0.015),
                    Text(
                      "Mark all items as packed to finalize dispatch.",
                      style: GoogleFonts.outfit(
                        color: AppColors.camel,
                        fontSize: context.sp(sw * 0.025),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: "Proceed To Dispatch",
                    variant: ButtonVariant.primary,
                    buttonColor: allPacked
                        ? AppColors.camel
                        : AppColors.greyLight,
                    textColor: allPacked ? AppColors.white : AppColors.grey,
                    onPressed: allPacked
                        ? () {
                            Get.bottomSheet(
                              CourierSelectionSheet(controller: controller),
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                            );
                          }
                        : null,
                  ),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }
}
