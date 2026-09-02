import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/app/utils/responsive.dart';
import 'package:ecom_app/app/widgets/custom_snackbar.dart';
import '../../controllers/tracking_controller.dart';

class OrderRefundReceiptCard extends GetView<TrackingController> {
  const OrderRefundReceiptCard({super.key});

  @override
  Widget build(BuildContext context) {
    final double sw = context.screenWidth;

    return Obx(() {
      final s = controller.status.value.toLowerCase();
      final bool isCancelledOrRefunded =
          s == 'cancelled' || s == 'refunded' || s == 'refund_processing';

      if (!isCancelledOrRefunded) return const SizedBox.shrink();

      final String refCode =
          "REF-${controller.orderId.value.replaceAll('#', '')}-${controller.amount.value.toInt()}";

      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(sw * 0.045),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.sage.withValues(alpha: 0.4)),
          boxShadow: [
            BoxShadow(
              color: AppColors.sage.withValues(alpha: 0.04),
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
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.sage.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.verified_rounded,
                        color: AppColors.sage,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "REFUND INITIATED",
                      style: GoogleFonts.outfit(
                        fontSize: context.sp(11),
                        fontWeight: FontWeight.w800,
                        color: AppColors.sage,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
                Text(
                  "\$${controller.amount.value.toStringAsFixed(2)}",
                  style: GoogleFonts.outfit(
                    fontSize: context.sp(16),
                    fontWeight: FontWeight.w900,
                    color: AppColors.charcoal,
                  ),
                ),
              ],
            ),
            const Divider(color: AppColors.greySubtle, height: 20),
            _buildInfoRow(
              context,
              "Payment Method",
              "Safepay (Original Source)",
            ),
            const SizedBox(height: 8),
            _buildInfoRow(context, "Refund Status", "Processing Settlement"),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Reference Code",
                  style: GoogleFonts.outfit(
                    fontSize: context.sp(11.5),
                    color: AppColors.grey,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      refCode,
                      style: GoogleFonts.outfit(
                        fontSize: context.sp(11.5),
                        fontWeight: FontWeight.w700,
                        color: AppColors.charcoal,
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: refCode));
                        AppSnackbar.info(
                          title: 'Copied',
                          message: 'Refund Reference copied to clipboard.',
                        );
                      },
                      child: const Icon(
                        Icons.copy_rounded,
                        size: 13,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.sage.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.access_time_rounded,
                    color: AppColors.sage,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Funds will reflect in your account within 3-5 business days as per banking settlement cycle.",
                      style: GoogleFonts.outfit(
                        fontSize: context.sp(10.5),
                        color: const Color(0xFF166534),
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: context.sp(11.5),
            color: AppColors.grey,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: context.sp(11.5),
            fontWeight: FontWeight.w700,
            color: AppColors.charcoal,
          ),
        ),
      ],
    );
  }
}
