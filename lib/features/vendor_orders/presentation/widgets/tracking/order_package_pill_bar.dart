import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/app/utils/responsive.dart';
import '../../controllers/tracking_controller.dart';
import 'order_picker_modal.dart';

class OrderPackagePillBar extends GetView<TrackingController> {
  const OrderPackagePillBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.userOrders.length <= 1) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "YOUR ACTIVE PACKAGES (${controller.userOrders.length})",
                style: GoogleFonts.outfit(
                  fontSize: context.sp(10),
                  fontWeight: FontWeight.w800,
                  color: AppColors.grey,
                  letterSpacing: 1.0,
                ),
              ),
              GestureDetector(
                onTap: () => OrderPickerModal.show(context),
                child: Text(
                  "View All",
                  style: GoogleFonts.outfit(
                    fontSize: context.sp(11),
                    fontWeight: FontWeight.w700,
                    color: AppColors.camel,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: controller.userOrders.length,
              separatorBuilder: (ctx, idx) => const SizedBox(width: 8),
              itemBuilder: (ctx, idx) {
                final ord = controller.userOrders[idx];
                final id = ord['id']?.toString() ?? '';
                final isSelected = id == controller.orderId.value;
                final st = ord['status']?.toString() ?? 'Paid';

                return GestureDetector(
                  onTap: () => controller.switchOrder(id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.charcoal : AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? AppColors.charcoal : AppColors.greyLight,
                        width: 1.2,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.charcoal.withValues(alpha: 0.08),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.camel : AppColors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          id,
                          style: GoogleFonts.outfit(
                            fontSize: context.sp(11),
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected ? AppColors.white : AppColors.charcoal,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "($st)",
                          style: GoogleFonts.outfit(
                            fontSize: context.sp(10),
                            fontWeight: FontWeight.w500,
                            color: isSelected ? AppColors.camel : AppColors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }
}
