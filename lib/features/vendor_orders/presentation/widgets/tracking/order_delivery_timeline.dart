import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/app/utils/responsive.dart';
import '../../controllers/tracking_controller.dart';

class OrderDeliveryTimeline extends GetView<TrackingController> {
  const OrderDeliveryTimeline({super.key});

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
              Text(
                "DELIVERY TIMELINE",
                style: GoogleFonts.outfit(
                  fontSize: context.sp(11),
                  fontWeight: FontWeight.w800,
                  color: AppColors.grey,
                  letterSpacing: 1.0,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    "Realtime Live",
                    style: GoogleFonts.outfit(
                      fontSize: context.sp(10),
                      fontWeight: FontWeight.w700,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Divider(color: AppColors.greySubtle, height: 22),
          Obx(() {
            final activeIdx = controller.activeStepIndex.value;
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.steps.length,
              itemBuilder: (context, index) {
                final step = controller.steps[index];
                final isCompleted = index <= activeIdx;
                final isCurrent = index == activeIdx;
                final isLast = index == controller.steps.length - 1;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCurrent
                                ? AppColors.camel
                                : (isCompleted
                                      ? AppColors.charcoal
                                      : AppColors.offWhite),
                            border: Border.all(
                              color: isCompleted
                                  ? (isCurrent
                                        ? AppColors.camel
                                        : AppColors.charcoal)
                                  : AppColors.greyLight,
                              width: 2,
                            ),
                            boxShadow: isCurrent
                                ? [
                                    BoxShadow(
                                      color: AppColors.camel.withValues(
                                        alpha: 0.4,
                                      ),
                                      blurRadius: 8,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: isCompleted
                                ? const Icon(
                                    Icons.check_rounded,
                                    size: 14,
                                    color: AppColors.white,
                                  )
                                : Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: AppColors.grey,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                          ),
                        ),
                        if (!isLast)
                          Container(
                            width: 2,
                            height: 38,
                            color: index < controller.activeStepIndex.value
                                ? AppColors.charcoal
                                : AppColors.greyLight,
                          ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              step['title']!,
                              style: GoogleFonts.outfit(
                                fontWeight: isCurrent
                                    ? FontWeight.w800
                                    : (isCompleted
                                          ? FontWeight.w700
                                          : FontWeight.w500),
                                fontSize: context.sp(13),
                                color: isCompleted
                                    ? AppColors.charcoal
                                    : AppColors.grey,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              step['subtitle']!,
                              style: GoogleFonts.outfit(
                                fontSize: context.sp(11),
                                color: isCompleted
                                    ? AppColors.charcoal.withValues(alpha: 0.7)
                                    : AppColors.greyLight,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
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
