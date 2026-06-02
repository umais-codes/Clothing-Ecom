import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/app/utils/responsive.dart';
import 'package:ecom_app/app/widgets/custom_button.dart';
import '../controllers/fulfillment_controller.dart';
import '../widgets/courier_selection_sheet.dart';

class PackingChecklistView extends GetView<FulfillmentController> {
  const PackingChecklistView({super.key});

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
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.charcoal),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Fulfillment Checklist",
          style: GoogleFonts.cormorantGaramond(
            fontSize: context.sp(22),
            fontWeight: FontWeight.w800,
            color: AppColors.charcoal,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Customer & Address Info Card
            _buildCustomerInfoCard(context, sw),

            // Checklist Counter
            Padding(
              padding: EdgeInsets.symmetric(horizontal: sw * 0.05, vertical: sw * 0.02),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "ITEMS CHECKLIST",
                    style: GoogleFonts.outfit(
                      fontSize: context.sp(11),
                      fontWeight: FontWeight.w800,
                      color: AppColors.grey,
                      letterSpacing: 1.5,
                    ),
                  ),
                  Obx(() {
                    final total = controller.checklistItems.length;
                    final packed = controller.packedStates.values.where((v) => v).length;
                    return Text(
                      "$packed of $total Packed",
                      style: GoogleFonts.outfit(
                        fontSize: context.sp(12),
                        fontWeight: FontWeight.w700,
                        color: packed == total ? AppColors.success : AppColors.camel,
                      ),
                    );
                  }),
                ],
              ),
            ),

            // Scrollable Checklist
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: sw * 0.05),
                itemCount: controller.checklistItems.length,
                itemBuilder: (context, index) {
                  final item = controller.checklistItems[index];
                  return Obx(() {
                    final isPacked = controller.packedStates[item.id] ?? false;
                    return GestureDetector(
                      onTap: () => controller.togglePacked(item.id),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: EdgeInsets.only(bottom: sw * 0.03),
                        padding: EdgeInsets.all(sw * 0.035),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
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
                              child: Image.network(
                                item.imageUrl,
                                width: sw * 0.15,
                                height: sw * 0.15,
                                fit: BoxFit.cover,
                                errorBuilder: (ctx, err, stack) => Container(
                                  width: sw * 0.15,
                                  height: sw * 0.15,
                                  color: AppColors.greyLight,
                                  child: const Icon(Icons.broken_image_outlined, color: AppColors.grey),
                                ),
                              ),
                            ),
                            SizedBox(width: sw * 0.035),
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
                                      color: isPacked ? AppColors.grey : AppColors.charcoal,
                                      decoration: isPacked ? TextDecoration.lineThrough : null,
                                    ),
                                  ),
                                  SizedBox(height: sw * 0.005),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.offWhite,
                                          borderRadius: BorderRadius.circular(4),
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
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.offWhite,
                                          borderRadius: BorderRadius.circular(4),
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
                                    fontSize: context.sp(13),
                                    color: isPacked ? AppColors.grey : AppColors.charcoal,
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
      margin: EdgeInsets.all(sw * 0.05),
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
            "SHIP TO",
            style: GoogleFonts.outfit(
              fontSize: context.sp(10),
              fontWeight: FontWeight.w800,
              color: AppColors.camel,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            controller.order.customerName,
            style: GoogleFonts.cormorantGaramond(
              fontSize: context.sp(18),
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
          const Divider(color: AppColors.greySubtle, height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_outlined, color: AppColors.camel, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  controller.order.shippingAddress ?? 'No Shipping Address Provided',
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
      padding: EdgeInsets.all(sw * 0.05),
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
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.info_outline_rounded, color: AppColors.camel, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      "Mark all items as packed to finalize dispatch.",
                      style: GoogleFonts.outfit(
                        color: AppColors.camel,
                        fontSize: context.sp(11),
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
                    text: "PROCEED TO COURIER DISPATCH",
                    variant: ButtonVariant.primary,
                    buttonColor: allPacked ? AppColors.camel : AppColors.greyLight,
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
