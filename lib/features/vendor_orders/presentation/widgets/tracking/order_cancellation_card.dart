import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/app/utils/responsive.dart';
import 'package:ecom_app/app/widgets/custom_button.dart';
import '../../controllers/tracking_controller.dart';

class OrderCancellationCard extends GetView<TrackingController> {
  const OrderCancellationCard({super.key});

  @override
  Widget build(BuildContext context) {
    final double sw = context.screenWidth;

    return Obx(() {
      if (!controller.canCancel) return const SizedBox.shrink();

      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: sw * 0.04,
          vertical: sw * 0.035,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.greyLight.withValues(alpha: 0.7)),
          boxShadow: [
            BoxShadow(
              color:AppColors.charcoal.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cancel_outlined,
                color: AppColors.error,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Cancel Order",
                    style: GoogleFonts.outfit(
                      fontSize: context.sp(13),
                      fontWeight: FontWeight.w700,
                      color: AppColors.charcoal,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    "Available before package dispatch",
                    style: GoogleFonts.outfit(
                      fontSize: context.sp(11),
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _showCancelOrderSheet(context, sw),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.4),
                      width: 1.2,
                    ),
                  ),
                  child: Text(
                    "Cancel",
                    style: GoogleFonts.outfit(
                      fontSize: context.sp(12),
                      fontWeight: FontWeight.w700,
                      color: AppColors.error,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  void _showCancelOrderSheet(BuildContext context, double sw) {
    String selectedReason = "Changed my mind";
    final reasons = [
      "Changed my mind",
      "Ordered wrong size or color",
      "Found faster delivery alternative",
      "Duplicate order placed accidentally",
      "Incorrect delivery address",
      "Other reason",
    ];

    Get.bottomSheet(
      StatefulBuilder(
        builder: (dialogContext, setModalState) {
          return Container(
            padding: EdgeInsets.all(sw * 0.05),
            decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.greyLight,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.errorBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.cancel_outlined,
                              color: AppColors.error,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "Cancel Order",
                            style: GoogleFonts.outfit(
                              fontSize: context.sp(16),
                              fontWeight: FontWeight.w800,
                              color: AppColors.charcoal,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: AppColors.grey),
                        onPressed: () => Get.back(),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Text(
                    "Please let us know the reason for cancellation:",
                    style: GoogleFonts.outfit(
                      fontSize: context.sp(12),
                      color: AppColors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Column(
                    children: reasons.map((reason) {
                      final isSelected = reason == selectedReason;
                      return GestureDetector(
                        onTap: () {
                          setModalState(() {
                            selectedReason = reason;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.camel.withValues(alpha: 0.1)
                                : AppColors.offWhite,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.camel
                                  : AppColors.greyLight,
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isSelected
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_off,
                                color: isSelected
                                    ? AppColors.camel
                                    : AppColors.grey,
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  reason,
                                  style: GoogleFonts.outfit(
                                    fontSize: context.sp(12),
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? AppColors.charcoal
                                        : AppColors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.camel.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: AppColors.camelDark,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Obx(
                            () => Text(
                              "A full refund of \$${controller.amount.value.toStringAsFixed(2)} will be credited back automatically to your original payment method.",
                              style: GoogleFonts.outfit(
                                fontSize: context.sp(11),
                                color: AppColors.charcoal,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: "Keep Order",
                          variant: ButtonVariant.outlined,
                          height: sw * 0.11,
                          textColor: AppColors.charcoal,
                          onPressed: () => Get.back(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Obx(
                          () => CustomButton(
                            text: controller.isCancelling.value
                                ? "Cancelling..."
                                : "Confirm Cancel",
                            buttonColor: AppColors.error,
                            textColor: AppColors.white,
                            height: sw * 0.11,
                            onPressed: controller.isCancelling.value
                                ? null
                                : () async {
                                    final success = await controller
                                        .cancelOrder(selectedReason);
                                    if (success) {
                                      Get.back();
                                    }
                                  },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      isScrollControlled: true,
    );
  }
}
