import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/app/utils/responsive.dart';
import '../../domain/entities/vendor_order.dart';
import '../controllers/vendor_order_controller.dart';
import 'package:ecom_app/app/widgets/custom_button.dart';

class RmaHandlingCard extends StatelessWidget {
  final VendorOrder order;
  final VendorOrderController controller;

  const RmaHandlingCard({
    super.key,
    required this.order,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final double sw = context.screenWidth;

    if (order.returnReason == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: sw * 0.04, vertical: sw * 0.02),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.error.withValues(alpha: 0.02),
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
                Icons.assignment_return_outlined,
                color: AppColors.error,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                "Return Details",
                style: GoogleFonts.outfit(
                  fontSize: context.sp(11),
                  fontWeight: FontWeight.w800,
                  color: AppColors.error,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const Divider(color: AppColors.greySubtle, height: 20),

          // Return Reason
          Text(
            "Customer Reason:",
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.w700,
              fontSize: context.sp(12),
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            order.returnReason!,
            style: GoogleFonts.outfit(
              fontSize: context.sp(12),
              color: AppColors.ink,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),

          // Evidence Photos
          if (order.returnImages != null && order.returnImages!.isNotEmpty) ...[
            Text(
              "Customer Uploaded Evidence:",
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w700,
                fontSize: context.sp(11),
                color: AppColors.charcoal,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: sw * 0.22,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: order.returnImages!.length,
                itemBuilder: (context, idx) {
                  final img = order.returnImages![idx];
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.greyLight),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        img,
                        width: sw * 0.22,
                        height: sw * 0.22,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) => Container(
                          width: sw * 0.22,
                          color: AppColors.greySubtle,
                          child: const Icon(
                            Icons.broken_image_outlined,
                            color: AppColors.grey,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Decision Actions
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: "REJECT",
                  variant: ButtonVariant.outlined,
                  textColor: AppColors.error,
                  borderRadius: sw * 0.025,
                  height: sw * 0.1,
                  fontSize: context.sp(11),
                  onPressed: () {
                    controller.processReturn(order.id);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  text: "APPROVE RETURN",
                  variant: ButtonVariant.primary,
                  buttonColor: AppColors.camel,
                  textColor: AppColors.white,
                  borderRadius: sw * 0.025,
                  height: sw * 0.1,
                  fontSize: context.sp(11),
                  onPressed: () {
                    controller.processReturn(order.id);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
