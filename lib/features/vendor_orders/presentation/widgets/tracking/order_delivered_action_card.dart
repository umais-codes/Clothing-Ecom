import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/app/utils/responsive.dart';
import 'package:ecom_app/app/widgets/custom_button.dart';
import '../../controllers/tracking_controller.dart';
import 'package:ecom_app/features/post_purchase/presentation/views/review_submission_sheet.dart';
import 'package:ecom_app/features/post_purchase/presentation/controllers/review_controller.dart';
import 'package:ecom_app/features/vendor_orders/domain/entities/vendor_order.dart';

class OrderDeliveredActionCard extends GetView<TrackingController> {
  const OrderDeliveredActionCard({super.key});

  @override
  Widget build(BuildContext context) {
    final double sw = context.screenWidth;

    return Obx(() {
      final isDelivered =
          controller.activeStepIndex.value == controller.steps.length - 1;
      if (!isDelivered) return const SizedBox.shrink();

      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(sw * 0.045),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.camel.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: AppColors.camel.withValues(alpha: 0.05),
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
                const Icon(
                  Icons.verified_rounded,
                  color: AppColors.success,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  "Package Delivered",
                  style: GoogleFonts.outfit(
                    fontSize: context.sp(14),
                    fontWeight: FontWeight.w800,
                    color: AppColors.charcoal,
                  ),
                ),
              ],
            ),
            SizedBox(height: sw * 0.015),
            Text(
              "We hope your new wardrobe pieces exceed expectations. You may request an exchange/return within 7 days or leave a verified garment review.",
              style: GoogleFonts.outfit(
                fontSize: context.sp(11),
                color: AppColors.grey,
                height: 1.4,
              ),
            ),
            SizedBox(height: sw * 0.04),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: "Request RMA Return",
                    variant: ButtonVariant.outlined,
                    textColor: AppColors.charcoal,
                    height: sw * 0.11,
                    onPressed: () {
                      final vendorOrder = VendorOrder(
                        id: controller.orderId.value,
                        customerName: controller.customerName.value,
                        amount: controller.amount.value,
                        status: "Delivered",
                        orderDate: DateTime.now().subtract(
                          const Duration(days: 2),
                        ),
                        isB2B: false,
                        items: controller.orderItems.map((it) {
                          return VendorOrderItem(
                            id: it['product_id']?.toString() ?? 'item_1',
                            name: it['product_name']?.toString() ?? 'Garment',
                            quantity: (it['quantity'] as num?)?.toInt() ?? 1,
                            unitPrice:
                                (it['unit_price'] as num?)?.toDouble() ?? 0.0,
                            imageUrl: it['image_url']?.toString() ?? '',
                            size: it['size']?.toString() ?? 'M',
                            color: it['color']?.toString() ?? '',
                          );
                        }).toList(),
                        timeline: [],
                      );
                      Get.toNamed('/rma-request', arguments: vendorOrder);
                    },
                  ),
                ),
                SizedBox(width: sw * 0.03),
                Expanded(
                  child: CustomButton(
                    text: "Rate & Review",
                    buttonColor: AppColors.camel,
                    textColor: AppColors.white,
                    height: sw * 0.11,
                    onPressed: () {
                      Get.put(ReviewController());
                      final firstItem = controller.orderItems.isNotEmpty
                          ? controller.orderItems.first
                          : null;
                      Get.bottomSheet(
                        ReviewSubmissionSheet(
                          orderId: controller.orderId.value,
                          productId:
                              firstItem?['product_id']?.toString() ?? "prod_1",
                          productName:
                              firstItem?['product_name']?.toString() ??
                              "Product",
                          productImageUrl:
                              firstItem?['image_url']?.toString() ?? "",
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
      );
    });
  }
}
