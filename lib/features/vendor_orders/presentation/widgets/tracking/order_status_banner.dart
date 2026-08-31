import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/app/utils/responsive.dart';
import '../../controllers/tracking_controller.dart';

class OrderStatusBanner extends GetView<TrackingController> {
  const OrderStatusBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final double sw = context.screenWidth;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(sw * 0.045),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.greyLight.withValues(alpha: 0.7)),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Obx(
                    () => Text(
                      controller.orderId.value,
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w800,
                        fontSize: context.sp(16),
                        color: AppColors.charcoal,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(
                        ClipboardData(text: controller.orderId.value),
                      );
                      Get.snackbar(
                        'Copied',
                        'Order ID copied to clipboard',
                        snackPosition: SnackPosition.BOTTOM,
                        duration: const Duration(seconds: 1),
                      );
                    },
                    child: const Icon(
                      Icons.copy_rounded,
                      size: 14,
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
              _buildStatusBadge(context),
            ],
          ),
          SizedBox(height: sw * 0.02),
          Obx(() {
            final bool isCancelled =
                controller.status.value.toLowerCase() == 'cancelled';

            if (isCancelled) {
              return Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 14,
                    color: AppColors.error,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      "Order cancelled • Full refund initiated to original payment method",
                      style: GoogleFonts.outfit(
                        fontSize: context.sp(11.5),
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              );
            }

            return Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: AppColors.camel,
                ),
                const SizedBox(width: 6),
                Text(
                  "Estimated Delivery: ",
                  style: GoogleFonts.outfit(
                    fontSize: context.sp(12),
                    color: AppColors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Expanded(
                  child: Text(
                    controller.expectedDelivery.value,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      fontSize: context.sp(12),
                      color: AppColors.charcoal,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            );
          }),
          Obx(() {
            if (controller.createdAtFormatted.value.isEmpty) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: EdgeInsets.only(top: sw * 0.01),
              child: Text(
                "Placed on ${controller.createdAtFormatted.value}",
                style: GoogleFonts.outfit(
                  fontSize: context.sp(11),
                  color: AppColors.grey,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    return Obx(() {
      final s = controller.status.value.toLowerCase();
      Color bg = AppColors.camelLight;
      Color fg = AppColors.camelDark;

      if (s.contains('cancelled')) {
        bg = AppColors.errorBg;
        fg = AppColors.error;
      } else if (s.contains('delivered') || s.contains('completed')) {
        bg = AppColors.successBg;
        fg = AppColors.success;
      } else if (s.contains('shipped') || s.contains('transit')) {
        bg = const Color(0xFFE0F2FE);
        fg = const Color(0xFF0369A1);
      } else if (s.contains('packed') || s.contains('processing')) {
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFB45309);
      }

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
            ),
            const SizedBox(width: 5),
            Text(
              controller.status.value.toUpperCase(),
              style: GoogleFonts.outfit(
                color: fg,
                fontSize: context.sp(10),
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
      );
    });
  }
}
